# Formatters

```@meta
CurrentModule = PrettyTables
```

```@setup formatters
using PrettyTables
```

The keyword `formatters` can be used to pass functions to format the values in the columns.
It must be a tuple of functions in which each function has the following signature:

```julia
f(v, i, j)
```

where `v` is the value in the cell, `i` is the row number, and `j` is the column number.
Thus, it must return the formatted value of the cell `(i, j)` that has the value `v`. Notice
that the returned value will be converted to string after using the function `sprint`.

This keyword can also be a single function, meaning that only one formatter is available, or
`nothing`, meaning that no formatter will be used.

For example, if we want to multiply all values in odd rows of the column 2 by π, the
formatter should look like:

```julia
formatters = (v, i, j) -> (j == 2 && isodd(i)) ? v * π : v
```

If multiple formatters are available, they will be applied in the same order as they are
located in the tuple. Thus, for the following `formatters`:

```julia
formatters = (f1, f2, f3)
```

each element `v` in the table (i-th row and j-th column) will be formatted by:

```julia
v = f1(v, i, j)
v = f2(v, i, j)
v = f3(v, i, j)
```

Thus, the user must be ensure that the type of `v` between the calls are compatible.

```@repl formatters
data = Any[f(a) for a = 0:30:90, f in (sind, cosd, tand)]

formatter = (v, i, j) -> round(v, digits = 3)

pretty_table(data; formatters = formatter)
```

!!! note

    The user can check if a value is undefined (`#undef`) inside a formatter by using the
    comparison `v isa PrettyTables.UndefinedCell`.

## Predefined Formatters

There are a set of predefined formatters (with names `ft_*`) to make the usage simpler. They
are defined in the file `./src/predefined_formatter.jl`.

```julia
function ft_printf(ftv_str, [columns])
```

Apply the formats `ftv_str` (see `@sprintf`) to the elements in the columns `columns`.

If `ftv_str` is a `Vector`, `columns` must be also be a `Vector` with the same number of
elements. If `ftv_str` is a `String`, and `columns` is not specified (or is empty), the
format will be applied to the entire table.  Otherwise, if `ftv_str` is a `String` and
`columns` is a `Vector`, the format will be applied only to the columns in `columns`.

!!! note

    This formatter will be applied only to the cells that are of type `Number`. The other
    types of cells will be left untouched.

```@repl formatters
data = Any[ f(a) for a = 0:30:90, f in (sind, cosd, tand)]

pretty_table(data; formatters = ft_printf("%5.3f"))

pretty_table(data; formatters = ft_printf("%5.3f", [1,3]))
```

```julia
function ft_round(digits, [columns])
```

Round the elements in the columns `columns` to the number of digits in `digits`.

If `digits` is a `Vector`, `columns` must be also be a `Vector` with the same number of
elements. If `digits` is a `Number`, and `columns` is not specified (or is empty), the
rounding will be applied to the entire table.  Otherwise, if `digits` is a `Number` and
`columns` is a `Vector`, the elements in the columns `columns` will be rounded to the number
of digits `digits`.

```@repl formatters
data = Any[ f(a) for a = 0:30:90, f in (sind, cosd, tand)]

pretty_table(data; formatters = ft_round(1))

pretty_table(data; formatters = ft_round(1, [1, 3]))
```

```julia
ft_nomissing
```

This pre-defined formatter converts any cell that is `missing` to an empty string.

```@repl formatters
data = [1 2 missing; 3 missing 4; 5 6 missing]

pretty_table(data)

pretty_table(data, formatters = ft_nomissing)
```

```julia
ft_nonothing
```

This pre-defined formatter converts any cell that is `nothing` to an empty string.

```@repl formatters
data = [1 2 nothing; 3 missing 4; 5 6 nothing]

pretty_table(data)

pretty_table(data, formatters = ft_nonothing)
```

Notice that `ft_nomissing` and `ft_nonothing` can be combined:

```@repl formatters
data = [1 2 nothing; 3 missing 4; 5 6 nothing]

pretty_table(data, formatters = (ft_nonothing, ft_nomissing))
```

!!! note

    The `formatters` keyword is supported in all back ends.
