; Indent inside braces, parens, and call argument lists.
(compound_statement (block_end) @end) @indent
(argument_list ")" @end) @indent
(parenthesized_expression ")" @end) @indent
