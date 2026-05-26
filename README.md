# Kamailio Language Extension for Zed

[Zed](https://zed.dev) language extension that adds syntax highlighting,
bracket matching, auto-indentation and a code outline for
[Kamailio SIP Server](https://www.kamailio.org) configuration files
(`kamailio.cfg`, `*.cfg`, `*.inc`).

It is inspired by the
[VS Code Kamailio Syntax extension](https://github.com/miconda/vscode-kamailio-syntax)
and is powered by a small fork of the
[`tree-sitter-kamailio-cfg`](https://github.com/IbrahimShahzad/tree-sitter-kamailio-cfg)
grammar (see [Grammar fork](#grammar-fork) below for what was added
and why).

## Features

- Syntax highlighting for:
  - Line and block comments (`#`, `//`, `/* ... */`)
  - Preprocessor directives (`#!ifdef`, `#!define`, `#!subst`, …)
  - File starter line (`#!KAMAILIO`, `#!SER`, `#!OPENSER`, …)
  - Module loading (`loadmodule`, `loadpath`, `modparam`)
  - Routing block definitions (`request_route`, `reply_route`,
    `route[NAME]`, `branch_route[NAME]`, `event_route[NAME]`, …)
  - Pseudo-variables (`$var(x)`, `$rU`, `$hdr(From)`, `$avp(...)`,
    `$dlg_var(...)`, `$sht(...)`, …) and transformations (`{s.len}`,
    `{uri.host}`, `{re.subst,/.../.../i}`, …)
  - Regex literals
  - Numeric, string, boolean and null literals
  - Control flow keywords (`if`, `else`, `while`, `switch`, `case`,
    `default`, `break`, `continue`, `return`, `exit`, `drop`)
  - Logical and comparison operators
- Bracket matching and rainbow bracket support
- Auto-indentation inside braces and parentheses
- Code outline panel entries for routing blocks, `#!define`s and
  loaded modules
- First-line detection of Kamailio configuration files
  (`#!KAMAILIO`, `#!SER`, `#!SIP-ROUTER`, `#!OPENSER`, …)

## Installation

### From the Zed Extensions registry

> Once published, the extension can be installed from Zed via
> `cmd-shift-x` (Linux/Windows: `ctrl-shift-x`) → search for
> _"Kamailio"_.

### Install as a dev extension

1. Clone this repository.
2. In Zed, open the command palette
   (`cmd-shift-p` / `ctrl-shift-p`) and run
   **`zed: install dev extension`**.
3. Select the cloned directory.

Zed will fetch the Tree-sitter grammar (compiled to WebAssembly) and
register the language. Open any `*.cfg` / `*.kamailio` /
`*.kamailio.cfg` file – or any file whose first line matches one of the
Kamailio shebang headers – and switch the language to **Kamailio**.

## File associations

By default the extension associates the following path suffixes with
the Kamailio language:

- `*.kamailio`
- `*.kamailio.cfg`

`.cfg` and `.inc` are intentionally **not** registered globally because
those extensions collide with too many unrelated configuration formats.
To associate them, add a `file_types` entry to your Zed `settings.json`:

```json
{
  "file_types": {
    "Kamailio": ["*.cfg", "*.inc", "kamailio*.cfg"]
  }
}
```

Files that start with a Kamailio shebang
(e.g. `#!KAMAILIO`, `#!SER`, `#!OPENSER`, …) are auto-detected
regardless of file name.

## Development

The extension consists of a manifest (`extension.toml`) and a set of
Tree-sitter query files under `languages/kamailio/`:

```
extension.toml
languages/
  kamailio/
    config.toml          language metadata, brackets, comments
    highlights.scm       syntax highlighting queries
    brackets.scm         bracket pair detection
    indents.scm          auto-indent rules
    outline.scm          outline-panel entries
```

After editing any of the query files, reload the dev extension via
**`zed: reload extensions`** (or simply re-run
**`zed: install dev extension`**).

### Grammar fork

The Tree-sitter grammar is forked from upstream
[`IbrahimShahzad/tree-sitter-kamailio-cfg`](https://github.com/IbrahimShahzad/tree-sitter-kamailio-cfg)
with the following additions:

**Preprocessor directives the upstream grammar doesn't yet recognise:**

| Directive       | Notes                                                              |
| --------------- | ------------------------------------------------------------------ |
| `#!trydefine`   | Accepted as a synonym for `#!trydef`                               |
| `#!redef`       | Accepted as a synonym for `#!redefine`                             |
| `#!defenv`      | Define a macro from the value of an environment variable           |
| `#!defenvs`     | Same as `#!defenv`, but the value is wrapped as a string literal   |
| `#!trydefenv`   | Try-define from environment (no error if the env var is missing)   |
| `#!trydefenvs`  | Try-define from environment as a string                            |
| `#!defexp`      | Define a macro from an arbitrary expression                        |
| `#!defexps`     | Same as `#!defexp`, but the value is wrapped as a string literal   |
| `#!ifexp`       | Conditional block guarded by an arbitrary expression (`#!endif`)   |

**Pseudo-variable forms the upstream grammar doesn't accept:**

- Bare-form transformations: `$rU{s.tolower}{s.len}` (upstream only
  accepted the parenthesised form `$(rU{s.tolower})`).
- Identifier / string arguments for `$T_req(...)`, `$T_rpl(...)`,
  `$T_inv(...)`, e.g. `$T_req(From)` (upstream required a nested
  `$`-variable).

**String transformations now accept quoted arguments:**

`s.rm`, `s.replace`, `s.after`, `s.rafter`, `s.before`, `s.rbefore`,
`s.count`, `s.select`, and `s.ftime` originally only accepted a single
unquoted character. They now also accept a quoted string literal, so
expressions such as `$(var(x){s.rm, '"'})` and
`$(var(x){s.replace, "old", "new"})` parse correctly.

Without these grammar rules, the parser either produces `ERROR` nodes
or silently mis-tokenises, and no query rule can recover from that.

By default, `extension.toml` points at a local sibling checkout of the
fork via a `file://` URL:

```
zed/
  kamailio-lang/             this extension
  tree-sitter-kamailio-cfg/  patched grammar (sibling dir)
```

To publish the extension to the Zed extensions registry, push the
patched grammar to a public GitHub repository and update the
`[grammars.kamailio_cfg]` block in `extension.toml`:

```toml
[grammars.kamailio_cfg]
repository = "https://github.com/<your-org>/tree-sitter-kamailio-cfg"
commit     = "<sha of your fork commit>"
```

A pull request against the upstream grammar repo would be the cleanest
long-term fix — the patch is small (four `preproc_*` rules following
the existing `preproc_def` shape, plus registering them in
`top_level_item` / `_higher_level_block_item` / `_block_item`).

## License

[MIT](./LICENSE).

## Acknowledgements

- [Kamailio SIP Server](https://www.kamailio.org) by the Kamailio team.
- [vscode-kamailio-syntax](https://github.com/miconda/vscode-kamailio-syntax)
  by [@miconda](https://github.com/miconda) — used as a reference for
  the highlight scope mapping.
- [tree-sitter-kamailio-cfg](https://github.com/IbrahimShahzad/tree-sitter-kamailio-cfg)
  by [@IbrahimShahzad](https://github.com/IbrahimShahzad) — Tree-sitter
  grammar that powers the highlighting.
- [Zed language extension docs](https://zed.dev/docs/extensions/languages).
