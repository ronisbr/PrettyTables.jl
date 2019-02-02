Formatter
=========

```@meta
CurrentModule = PrettyTables
DocTestSetup = quote
    using PrettyTables
end
```

The keyword `formatter` can be used to pass functions to format the values in
the columns. It must be a `Dict{Number,Function}()`. The key indicates the
column number in which its elements will be converted by the function in the
value of the dictionary. The function must have the following signature:

    f(value, i)

in which `value` is the data and `i` is the row number. It must return the
formatted value.

For example, if we want to multiply all values in odd rows of the column 2 by π,
then the formatter should look like:

    Dict(2 => (v,i)->isodd(i) ? v*π : v)

If the key `0` is present, then the corresponding function will be applied to
all columns that does not have a specific key.

```jldoctest
julia> data = Any[ f(a) for a = 0:30:90, f in (sind,cosd,tand)];

julia> formatter = Dict(0 => (v,i) -> round(v,digits=3));

julia> pretty_table(data; formatter=formatter)
┌────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │
├────────┼────────┼────────┤
│    0.0 │    1.0 │    0.0 │
│    0.5 │  0.866 │  0.577 │
│  0.866 │    0.5 │  1.732 │
│    1.0 │    0.0 │    Inf │
└────────┴────────┴────────┘
```

There are a set of pre-defined formatters (with names `ft_*`) to make the
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

```jldoctest
julia> data = Any[ f(a) for a = 0:30:90, f in (sind,cosd,tand)];

julia> pretty_table(data; formatter=ft_printf("%5.3f"))
┌────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │
├────────┼────────┼────────┤
│  0.000 │  1.000 │  0.000 │
│  0.500 │  0.866 │  0.577 │
│  0.866 │  0.500 │  1.732 │
│  1.000 │  0.000 │    Inf │
└────────┴────────┴────────┘

julia> pretty_table(data; formatter=ft_printf("%5.3f", [1,3]))
┌────────┬────────────────────┬────────┐
│ Col. 1 │             Col. 2 │ Col. 3 │
├────────┼────────────────────┼────────┤
│  0.000 │                1.0 │  0.000 │
│  0.500 │ 0.8660254037844386 │  0.577 │
│  0.866 │                0.5 │  1.732 │
│  1.000 │                0.0 │    Inf │
└────────┴────────────────────┴────────┘
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
julia> data = Any[ f(a) for a = 0:30:90, f in (sind,cosd,tand)];

julia> pretty_table(data; formatter=ft_round(1))
┌────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │
├────────┼────────┼────────┤
│    0.0 │    1.0 │    0.0 │
│    0.5 │    0.9 │    0.6 │
│    0.9 │    0.5 │    1.7 │
│    1.0 │    0.0 │    Inf │
└────────┴────────┴────────┘

julia> pretty_table(data; formatter=ft_round(1,[1,3]))
┌────────┬────────────────────┬────────┐
│ Col. 1 │             Col. 2 │ Col. 3 │
├────────┼────────────────────┼────────┤
│    0.0 │                1.0 │    0.0 │
│    0.5 │ 0.8660254037844386 │    0.6 │
│    0.9 │                0.5 │    1.7 │
│    1.0 │                0.0 │    Inf │
└────────┴────────────────────┴────────┘
```
