# Project notes

## GDScript

- **Always use static type annotations.** The project treats warnings as errors, so an untyped local like `var x = foo()` fails parsing. Write `var x: Type = foo()` — including for local variables returned by `get_meta`, `get_node`, etc.
