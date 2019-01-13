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
    "man/formats.md"
    "man/alignment.md"
    "man/formatter.md"
    "man/highlighters.md"
    "man/examples.md"
]
Depth = 2
```

## Library documentation

```@index
Pages = ["lib/library.md"]
```
