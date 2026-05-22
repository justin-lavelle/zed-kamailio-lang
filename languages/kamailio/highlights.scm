; ==================================================================
; Kamailio configuration syntax highlighting for Zed
; Targets the tree-sitter-kamailio-cfg grammar.
; ==================================================================

; ----- File starter / shebang-style header ------------------------
(file_starter) @preproc

; ----- Comments ---------------------------------------------------
(comment) @comment
(multiline_comment) @comment

; ----- Preprocessor / config directives ---------------------------
; Highlight the directive tokens themselves. Doing this on the tokens
; (anonymous nodes in the grammar) — rather than on the entire
; `preproc_def` / `preproc_ifdef` parent node — means we don't need
; an optional `preproc_arg` to match, and we don't accidentally paint
; everything inside an `#!ifdef … #!endif` block as a directive.
[
  "#!define"
  "#!trydef"
  "#!trydefine"
  "#!redefine"
  "#!redef"
  "#!defenv"
  "#!defenvs"
  "#!trydefenv"
  "#!trydefenvs"
  "#!defexp"
  "#!defexps"
  "#!subst"
  "#!substdef"
  "#!substdefs"
  "#!ifdef"
  "#!ifndef"
  "#!ifexp"
  "#!else"
  "#!endif"
] @keyword.directive

; Name of the macro being (un)defined or tested.
(preproc_def         name: (identifier) @constant)
(preproc_trydef      name: (identifier) @constant)
(preproc_redef       name: (identifier) @constant)
(preproc_defenv      name: (identifier) @constant)
(preproc_defenvs     name: (identifier) @constant)
(preproc_trydefenv   name: (identifier) @constant)
(preproc_trydefenvs  name: (identifier) @constant)
(preproc_defexp      name: (identifier) @constant)
(preproc_defexps     name: (identifier) @constant)
(preproc_ifdef       name: (identifier) @constant)
(preproc_ifndef      name: (identifier) @constant)

; Value assigned to a `#!define`-style directive.
(preproc_def         value: (preproc_arg) @string)
(preproc_trydef      value: (preproc_arg) @string)
(preproc_redef       value: (preproc_arg) @string)
(preproc_defenv      value: (preproc_arg) @string)
(preproc_defenvs     value: (preproc_arg) @string)
(preproc_trydefenv   value: (preproc_arg) @string)
(preproc_trydefenvs  value: (preproc_arg) @string)
(preproc_defexp      value: (preproc_arg) @string)
(preproc_defexps     value: (preproc_arg) @string)

; Expression evaluated by `#!ifexp`.
(preproc_ifexp       value: (preproc_arg) @string)

; Substitution payload (`#!subst`, `#!substdef`, `#!substdefs`) is a
; sed-style regex expression.
(preproc_subst     value: (preproc_arg) @string.regex)
(preproc_substdef  value: (preproc_arg) @string.regex)
(preproc_substdefs value: (preproc_arg) @string.regex)

; #!include_file / import_file
(include_file
  file_name: (string) @string.special.path) @keyword.import
(import_file
  file_name: (string) @string.special.path) @keyword.import

; ----- Module loading ---------------------------------------------
(loadmodule
  module_name: (string) @string.special.path) @keyword.import
(loadmodulex
  module_name: (string) @string.special.path) @keyword.import
(loadpath
  path: (string) @string.special.path) @keyword.import

(modparam
  module_name: (string) @string.special.path) @function.builtin
(modparamx
  module_name: (string) @string.special.path) @function.builtin

; ----- Routes -----------------------------------------------------
; route definition: e.g.  request_route { ... }, route[NAME] { ... }
(routing_block
  route: (predef_route) @keyword.function)
(routing_block
  route_name: (_) @function)

; route(NAME) call sites
(route_call) @function.call

; ----- Core var assignments e.g. `debug=4`, `port=5060`,
; `log_facility=LOG_LOCAL0`. Only highlight the key as a builtin
; variable; the right-hand side is left for the normal expression
; rules below. We need both rules because the grammar uses
; `top_level_assignment_expression` at the top level and
; `assignment_expression` inside `#!ifdef … #!endif` blocks.
(top_level_assignment_expression
  key: (identifier) @variable.builtin)
(assignment_expression
  left: (identifier) @variable.builtin)

; ----- Pseudo variables ($var, $rU, $hdr(...), etc.) --------------
(pseudo_variable
  "$" @keyword.operator
  var: (pseudo_content) @variable.builtin)
(pvar_expression
  "$" @keyword.operator
  var: (pseudo_content) @variable.builtin)

(var_
  name: (pvar_argument) @variable)
(avp_var
  name: (pvar_argument) @variable)
(dlg_var
  name: (pvar_argument) @variable)

(xavp_values
  name: (identifier) @variable
  index: (identifier) @variable.builtin
  field: (identifier) @property)

(htable
  htable: (identifier) @variable
  "=>" @punctuation.special)

; ----- Transformations  {s.len}, {uri.host}, ... ------------------
(transformation) @function.builtin

; ----- Regex patterns ---------------------------------------------
(regex_pattern) @string.regex
(regex_replacement) @string.regex
(regex_flags) @string.regex

; ----- Generic call expressions (kamailio module/core fns) --------
(call_expression
  function: (expression) @function.call
  arguments: (argument_list
    "(" @punctuation.bracket
    ")" @punctuation.bracket))

; ----- Literals ---------------------------------------------------
(string) @string
(number_literal) @number

(true) @boolean
(false) @boolean
(null) @constant.builtin

; ----- Punctuation ------------------------------------------------
"(" @punctuation.bracket
")" @punctuation.bracket
"{" @punctuation.bracket
"}" @punctuation.bracket
"[" @punctuation.bracket
"]" @punctuation.bracket

"," @punctuation.delimiter
":" @punctuation.delimiter
"::" @punctuation.special
(eos) @punctuation.delimiter

; ----- Operators --------------------------------------------------
[
  "="
  "=="
  "!="
  "<"
  ">"
  "<="
  ">="
  "=~"
  "+="
  "!"
  "&&"
  "&"
  "||"
  "|"
  "^"
  "<<"
  ">>"
  "+"
  "-"
] @operator

[
  "and"
  "or"
  "not"
] @keyword.operator

; ----- Keywords ---------------------------------------------------
[
  "break"
  "continue"
  "return"
  "drop"
  "exit"
] @keyword.return

"switch" @keyword.conditional
"while"  @keyword.repeat

[
  "if"
  "else"
  "default"
  "case"
] @keyword.conditional
