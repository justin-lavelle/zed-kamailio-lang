; Routing blocks with explicit name, e.g. `route[FOO] { ... }`,
; `branch_route[BAR] { ... }`, etc.
(routing_block
  route: (predef_route) @context
  route_name: (_) @name) @item

; Unnamed routing blocks like `request_route { ... }`, `reply_route { ... }`.
(routing_block
  route: (predef_route) @name
  !route_name) @item

; Preprocessor definitions like `#!define FOO bar`.
(preproc_def
  name: (identifier) @name) @item

; Module loading and parameters.
(loadmodule
  module_name: (string) @name) @item
(loadmodulex
  module_name: (string) @name) @item
