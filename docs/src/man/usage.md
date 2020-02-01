Usage
=====

```@meta
CurrentModule = PrettyTables
DocTestSetup = quote
    using PrettyTables
end
```

The following function can be used to print data.

```julia
function pretty_table([io::IO,] table[, header::AbstractVecOrMat];  kwargs...)
```

Print to `io` the table `table` with header `header`. If `io` is omitted, then
it defaults to `stdout`. If `header` is empty or missing, then it will be
automatically filled with "Col.  i" for the *i*-th column.

The `header` can be a `Vector` or a `Matrix`. If it is a `Matrix`, then each row
will be a header line. The first line is called *header* and the others are
called *sub-headers* .

When printing, it will be verified if `table` complies with
[**Tables.jl**](https://github.com/JuliaData/Tables.jl) API.  If it is is
compliant, then this interface will be used to print the table. If it is not
compliant, then only the following types are supported:

1. `AbstractVector`: any vector can be printed. In this case, the `header`
   **must** be a vector, where the first element is considered the header and
   the others are the sub-headers.
2. `AbstractMatrix`: any matrix can be printed.
3. `Dict`: any `Dict` can be printed. In this case, the special keyword
   `sortkeys` can be used to select whether or not the user wants to print the
   dictionary with the keys sorted. If it is `false`, then the elements will be
   printed on the same order returned by the functions `keys` and `values`.
   Notice that this assumes that the keys are sortable, if they are not, then an
   error will be thrown.

The user can select which back-end will be used to print the tables using the
keyword argument `backend`. Currently, the following back-ends are supported:

1. **Text** (`backend = :text`): prints the table in text mode. This is the
   default selection if the keyword `backend` is absent.
2. **HTML** (`backend = :html`): prints the table in HTML.
3. **LaTeX** (`backend = :latex`): prints the table in LaTeX format.

Each back-end defines its own configuration keywords that can be passed using
`kwargs`. However, the following keywords are valid for all back-ends:

* `alignment`: Select the alignment of the columns (see the section `Alignment`).
* `backend`: Select which back-end will be used to print the table. Notice that
             the additional configuration in `kwargs...` depends on the selected
             backend.
* `filters_row`: Filters for the rows (see the section `Filters`).
* `filters_col`: Filters for the columns (see the section `Filters`).

!!! note

    Notice that all back-ends have the keyword `tf` to specify the table
    printing format. Thus, if the keyword `backend` is not present or if it is
    `nothing`, then the back-end will be automatically inferred from the type of
    the keyword `tf`. In this case, if `tf` is also not present, then it just
    fall-back to the text back-end.

# Examples

In the following, it is possible to see some examples for a quick start using
the text back-end.

```jldoctest
julia> data = [1 2 3; 4 5 6];

julia> pretty_table(data, ["Column 1", "Column 2", "Column 3"])
┌──────────┬──────────┬──────────┐
│ Column 1 │ Column 2 │ Column 3 │
├──────────┼──────────┼──────────┤
│        1 │        2 │        3 │
│        4 │        5 │        6 │
└──────────┴──────────┴──────────┘

julia> pretty_table(data, ["Column 1" "Column 2" "Column 3"; "A" "B" "C"])
┌──────────┬──────────┬──────────┐
│ Column 1 │ Column 2 │ Column 3 │
│        A │        B │        C │
├──────────┼──────────┼──────────┤
│        1 │        2 │        3 │
│        4 │        5 │        6 │
└──────────┴──────────┴──────────┘
```

```julia
julia> dict = Dict(1 => "Jan", 2 => "Feb", 3 => "Mar", 4 => "Apr", 5 => "May", 6 => "Jun");

julia> pretty_table(dict)
┌───────┬────────┐
│  Keys │ Values │
│ Int64 │ String │
├───────┼────────┤
│     4 │    Apr │
│     2 │    Feb │
│     3 │    Mar │
│     5 │    May │
│     6 │    Jun │
│     1 │    Jan │
└───────┴────────┘

julia> pretty_table(dict, sortkeys = true)
┌───────┬────────┐
│  Keys │ Values │
│ Int64 │ String │
├───────┼────────┤
│     1 │    Jan │
│     2 │    Feb │
│     3 │    Mar │
│     4 │    Apr │
│     5 │    May │
│     6 │    Jun │
└───────┴────────┘

```

## Helpers

The macro `@pt` was created to make it easier to pretty print tables to
`stdout`. Its signature is:

```julia
macro pt(expr...)
```

where the expression list `expr` contains the tables that should be printed
like:

```julia
@pt table1 table2 table3
```

The user can select the table header by passing the expression:

```
:header = [<Vector with the header>]
```

Notice that the header is valid only for the next printed table. Hence:

```julia
    @pt :header = header1 table1 :header = header2 table2 table3
```

will print `table1` using `header1`, `table2` using `header2`, and `table3`
using the default header.

The global configurations used to print tables with the macro `@pt` can be
selected by:

```julia
macro ptconf(expr...)
```

where `expr` format must be:

```
keyword1 = value1 keyword2 = value2 ...
```

The keywords can be any possible keyword that can be used in the function
`pretty_table`.

All the configurations can be reseted by calling `@ptconfclean`.

!!! warning

    If a keyword is not supported by the function `pretty_table`, then no error
    message is printed when calling `@ptconf`. However, an error will be thrown
    when `@pt` is called.

!!! info

    When more than one table is passed to the macro `@pt`, then multiple calls
    to `pretty_table` will occur. Hence, the cropping algorithm will behave
    exactly the same as printing the tables separately.

```jldoctest
julia> data = [1 2 3; 4 5 6];

julia> @pt data
┌────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │
├────────┼────────┼────────┤
│      1 │      2 │      3 │
│      4 │      5 │      6 │
└────────┴────────┴────────┘

julia> @pt :header = ["Column 1", "Column 2", "Column 3"] data :header = ["Column 1" "Column 2" "Column 3"; "A" "B" "C"] data
┌──────────┬──────────┬──────────┐
│ Column 1 │ Column 2 │ Column 3 │
├──────────┼──────────┼──────────┤
│        1 │        2 │        3 │
│        4 │        5 │        6 │
└──────────┴──────────┴──────────┘
┌──────────┬──────────┬──────────┐
│ Column 1 │ Column 2 │ Column 3 │
│        A │        B │        C │
├──────────┼──────────┼──────────┤
│        1 │        2 │        3 │
│        4 │        5 │        6 │
└──────────┴──────────┴──────────┘

julia> @ptconf tf = ascii_dots alignment = :c

julia> @pt data
............................
: Col. 1 : Col. 2 : Col. 3 :
:........:........:........:
:   1    :   2    :   3    :
:   4    :   5    :   6    :
:........:........:........:

julia> @ptconfclean

julia> @pt data
┌────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │
├────────┼────────┼────────┤
│      1 │      2 │      3 │
│      4 │      5 │      6 │
└────────┴────────┴────────┘
```
