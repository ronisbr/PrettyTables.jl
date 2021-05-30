Pretty Tables
=============

[![Build status](https://github.com/ronisbr/PrettyTables.jl/workflows/CI/badge.svg)](https://github.com/ronisbr/PrettyTables.jl/actions)
[![codecov](https://codecov.io/gh/ronisbr/PrettyTables.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/ronisbr/PrettyTables.jl)
[![](https://img.shields.io/badge/docs-stable-blue.svg)][docs-stable-url]
[![](https://img.shields.io/badge/docs-dev-blue.svg)][docs-dev-url]
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

This package has the purpose to print data in matrices in a human-readable
format. It was inspired in the functionality provided by
https://ozh.github.io/ascii-tables/

## Backends status

* **Text backend**: stable.
* **HTML backend**: not stable, API can change in minor versions, consider as
    **beta**.
* **LaTeX backend**: not stable, API can change in minor version, consider as
    **beta**.

## Installation

```julia-repl
julia> using Pkg
julia> Pkg.add("PrettyTables")
```

## Example

![](./docs/src/assets/welcome_figure.png)

## Usage

See the [documentation][docs-stable-url].

[docs-dev-url]: https://ronisbr.github.io/PrettyTables.jl/dev
[docs-stable-url]: https://ronisbr.github.io/PrettyTables.jl/stable
