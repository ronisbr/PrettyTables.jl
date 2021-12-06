Formatters
==========

```@meta
CurrentModule = PrettyTables
DocTestSetup = quote
    using PrettyTables
end
```

The keyword `formatters` can be used to pass functions to format the values in
the columns. It must be a tuple of functions in which each function has the
following signature:

    f(v, i, j)

where `v` is the value in the cell, `i` is the row number, and `j` is the column
number. Thus, it must return the formatted value of the cell `(i, j)` that has
the value `v`. Notice that the returned value will be converted to string after
using the function `sprint`.

This keyword can also be a single function, meaning that only one formatter is
available, or `nothing`, meaning that no formatter will be used.

For example, if we want to multiply all values in odd rows of the column 2 by π,
then the formatter should look like:

    formatters = (v, i, j) -> (j == 2 && isodd(i)) ? v * π : v

If multiple formatters are available, then they will be applied in the same
order as they are located in the tuple. Thus, for the following `formatters`:

    formatters = (f1, f2, f3)

each element `v` in the table (i-th row and j-th column) will be formatted by:

    v = f1(v, i, j)
    v = f2(v, i, j)
    v = f3(v, i, j)

Thus, the user must be ensure that the type of `v` between the calls are
compatible.

```jldoctest
julia> data = Any[f(a) for a = 0:30:90, f in (sind, cosd, tand)];

julia> formatter = (v, i, j) -> round(v, digits = 3);

julia> pretty_table(data; formatters = formatter)
┌────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │
├────────┼────────┼────────┤
│    0.0 │    1.0 │    0.0 │
│    0.5 │  0.866 │  0.577 │
│  0.866 │    0.5 │  1.732 │
│    1.0 │    0.0 │    Inf │
└────────┴────────┴────────┘
```

!!! note
    The user can check if a value is undefined (`#undef`) inside a formatter by
    using the comparison `v == undef`.

## Predefined formatters

There are a set of predefined formatters (with names `ft_*`) to make the
usage simpler. They are defined in the file `./src/predefined_formatter.jl`.

```julia
function ft_printf(ftv_str, [columns])
```

Apply the formats `ftv_str` (see `@sprintf`) to the elements in the columns
`columns`.

If `ftv_str` is a `Vector`, then `columns` must be also be a `Vector` with the
same number of elements. If `ftv_str` is a `String`, and `columns` is not
specified (or is empty), then the format will be applied to the entire table.
Otherwise, if `ftv_str` is a `String` and `columns` is a `Vector`, then the
format will be applied only to the columns in `columns`.

!!! note
    This formatter will be applied only to the cells that are of type `Number`.
    The other types of cells will be left untouched.

```jldoctest
julia> data = Any[ f(a) for a = 0:30:90, f in (sind, cosd, tand)];

julia> pretty_table(data; formatters = ft_printf("%5.3f"))
┌────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │
├────────┼────────┼────────┤
│  0.000 │  1.000 │  0.000 │
│  0.500 │  0.866 │  0.577 │
│  0.866 │  0.500 │  1.732 │
│  1.000 │  0.000 │    Inf │
└────────┴────────┴────────┘

julia> pretty_table(data; formatters = ft_printf("%5.3f", [1,3]))
┌────────┬──────────┬────────┐
│ Col. 1 │   Col. 2 │ Col. 3 │
├────────┼──────────┼────────┤
│  0.000 │      1.0 │  0.000 │
│  0.500 │ 0.866025 │  0.577 │
│  0.866 │      0.5 │  1.732 │
│  1.000 │      0.0 │    Inf │
└────────┴──────────┴────────┘
```

!!! note
    Now, this formatter uses the function `sprintf1` from the package
    [Formatting.jl](https://github.com/JuliaIO/Formatting.jl) that drastically
    improved the performance compared to the case with the macro `@sprintf`.
    Thanks to @RalphAS for the information!

```
function ft_round(digits, [columns])
```

Round the elements in the columns `columns` to the number of digits in `digits`.

If `digits` is a `Vector`, then `columns` must be also be a `Vector` with the
same number of elements. If `digits` is a `Number`, and `columns` is not
specified (or is empty), then the rounding will be applied to the entire table.
Otherwise, if `digits` is a `Number` and `columns` is a `Vector`, then the
elements in the columns `columns` will be rounded to the number of digits
`digits`.

```jldoctest
julia> data = Any[ f(a) for a = 0:30:90, f in (sind, cosd, tand)];

julia> pretty_table(data; formatters = ft_round(1))
┌────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │
├────────┼────────┼────────┤
│    0.0 │    1.0 │    0.0 │
│    0.5 │    0.9 │    0.6 │
│    0.9 │    0.5 │    1.7 │
│    1.0 │    0.0 │    Inf │
└────────┴────────┴────────┘

julia> pretty_table(data; formatters = ft_round(1, [1, 3]))
┌────────┬──────────┬────────┐
│ Col. 1 │   Col. 2 │ Col. 3 │
├────────┼──────────┼────────┤
│    0.0 │      1.0 │    0.0 │
│    0.5 │ 0.866025 │    0.6 │
│    0.9 │      0.5 │    1.7 │
│    1.0 │      0.0 │    Inf │
└────────┴──────────┴────────┘
```

```
ft_nomissing
```

This pre-defined formatter converts any cell that is `missing` to an empty
string.

```jldoctest
julia> data = [1 2 missing; 3 missing 4; 5 6 missing];

julia> pretty_table(data)
┌────────┬─────────┬─────────┐
│ Col. 1 │  Col. 2 │  Col. 3 │
├────────┼─────────┼─────────┤
│      1 │       2 │ missing │
│      3 │ missing │       4 │
│      5 │       6 │ missing │
└────────┴─────────┴─────────┘

julia> pretty_table(data, formatters = ft_nomissing)
┌────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │
├────────┼────────┼────────┤
│      1 │      2 │        │
│      3 │        │      4 │
│      5 │      6 │        │
└────────┴────────┴────────┘
```

```
ft_nonothing
```

This pre-defined formatter converts any cell that is `nothing` to an empty
string.

```jldoctest
julia> data = [1 2 nothing; 3 missing 4; 5 6 nothing];

julia> pretty_table(data)
┌────────┬─────────┬─────────┐
│ Col. 1 │  Col. 2 │  Col. 3 │
├────────┼─────────┼─────────┤
│      1 │       2 │ nothing │
│      3 │ missing │       4 │
│      5 │       6 │ nothing │
└────────┴─────────┴─────────┘

julia> pretty_table(data, formatters = ft_nonothing)
┌────────┬─────────┬────────┐
│ Col. 1 │  Col. 2 │ Col. 3 │
├────────┼─────────┼────────┤
│      1 │       2 │        │
│      3 │ missing │      4 │
│      5 │       6 │        │
└────────┴─────────┴────────┘
```

Notice that `ft_nomissing` and `ft_nonothing` can be combined:

```julia
julia> data = [1 2 nothing; 3 missing 4; 5 6 nothing];

julia> pretty_table(data, formatters = (ft_nonothing, ft_nomissing))
┌────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │
├────────┼────────┼────────┤
│      1 │      2 │        │
│      3 │        │      4 │
│      5 │      6 │        │
└────────┴────────┴────────┘
```

!!! note
    The `formatters` keyword is supported in all back-ends.
