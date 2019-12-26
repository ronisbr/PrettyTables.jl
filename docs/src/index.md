PrettyTables.jl
===============

```@meta
CurrentModule = PrettyTables
DocTestSetup = quote
    using PrettyTables
end
```

This package has the purpose to print data in matrices in a human-readable
format. It was inspired in the functionality provided by
[ASCII Table Generator](https://ozh.github.io/ascii-tables/).

![](./assets/welcome_figure.png)

## Requirements

* Julia >= 1.0
* Parameters >= 0.10.3
* Tables >= 0.1.14

## Installation

```julia-repl
julia> using Pkg
julia> Pkg.add("PrettyTables")
```

## Manual outline

```@contents
Pages = [
    "man/usage.md"
    "man/text_backend.md"
    "man/html_backend.md"
    "man/latex_backend.md"
    "man/alignment.md"
    "man/filters.md"
    "man/formatter.md"
    "man/text_examples.md"
    "man/html_examples.md"
    "lib/library.md"
]
Depth = 2
```
