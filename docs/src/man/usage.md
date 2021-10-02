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
function pretty_table([io::IO | String,] table;  kwargs...)
```

Print to `io` the table `table`.

If `io` is omitted, then it defaults to `stdout`. If `String` is passed in the
place of `io`, then a `String` with the printed table will be returned by the
function. If `HTML` is passed in the place of `io`, then an `HTML` object is
returned with the printed table.

When printing, it will be verified if `table` complies with
[**Tables.jl**](https://github.com/JuliaData/Tables.jl) API.  If it is is
compliant, then this interface will be used to print the table. If it is not
compliant, then only the following types are supported:

1. `AbstractVector`: any vector can be printed.
2. `AbstractMatrix`: any matrix can be printed.
3. `Dict`: any `Dict` can be printed. In this case, the special keyword
    `sortkeys` can be used to select whether or not the user wants to print the
    dictionary with the keys sorted. If it is `false`, then the elements will be
    printed on the same order returned by the functions `keys` and `values`.
    Notice that this assumes that the keys are sortable, if they are not, then
    an error will be thrown.

The user can select which back-end will be used to print the tables using the
keyword argument `backend`. Currently, the following back-ends are supported:

1. **Text** (`backend = Val(:text)`): prints the table in text mode. This is the
    default selection if the keyword `backend` is absent.
2. **HTML** (`backend = Val(:html)`): prints the table in HTML.
3. **LaTeX** (`backend = Val(:latex)`): prints the table in LaTeX format.

Each back-end defines its own configuration keywords that can be passed using
`kwargs`. However, the following keywords are valid for all back-ends:

- `alignment::Union{Symbol, Vector{Symbol}}`: Select the alignment of the
    columns (see the section [Alignment](@ref)).
- `backend::Union{Symbol, T_BACKENDS}`: Select which back-end will be used to
    print the table. Notice that the additional configuration in `kwargs...`
    depends on the selected backend.
- `cell_alignment::Union{Nothing, Dict{Tuple{Int, Int}, Symbol}, Function, Tuple}`:
    A tuple of functions with the signature `f(data, i, j)` that overrides the
    alignment of the cell `(i, j)` to the value returned by `f`. It can also be a
    single function, when it is assumed that only one alignment function is
    required, or `nothing`, when no cell alignment modification will be
    performed. If the function `f` does not return a valid alignment symbol as
    shown in section [Alignment](@ref), then it will be discarded. For
    convenience, it can also be a dictionary of type `(i, j) => a` that
    overrides the alignment of the cell `(i, j)` to `a`. `a` must be a symbol
    like specified in the section [Alignment](@ref). (**Default** = `nothing`)

!!! note
    If more than one alignment function is passed to `cell_alignment`, then
    the functions will be evaluated in the same order of the tuple. The
    first one that returns a valid alignment symbol for each cell is applied,
    and the rest is discarded.

- `cell_first_line_only::Bool`: If `true`, then only the first line of each cell
    will be printed. (**Default** = `false`)
- `compact_printing::Bool`: Select if the option `:compact` will be used when
    printing the data. (**Default** = `true`)
- `filters_row::Union{Nothing, Tuple}`: Filters for the rows (see the section
    [Filters](@ref)).
- `filters_col::Union{Nothing, Tuple}`: Filters for the columns (see the section
    [Filters](@ref)).
- `formatters::Union{Nothing, Function, Tuple}`: See the section
    [Formatters](@ref).
- `header::Union{Symbol, Vector{Symbol}}`: The header must be a tuple of
    vectors. Each one must have the number of elements equal to the number of
    columns in the table. The first vector is considered the header and the
    others are the subheaders. If it is `nothing`, then a default value based on
    the type will be used. If a single vector is passed, then it will be
    considered the header. (**Default** = `nothing`)
- `header_alignment::Union{Symbol, Vector{Symbol}}`: Select the alignment of the
    header columns (see the section [Alignment](@ref)). If the symbol that
    specifies the alignment is `:s` for a specific column, then the same
    alignment in the keyword `alignment` for that column will be used.
    (**Default** = `:s`)
- `header_cell_alignment::Union{Nothing, Dict{Tuple{Int, Int}, Symbol}, Function, Tuple}`:
    This keyword has the same structure of `cell_alignment` but in this case it
    operates in the header. Thus, `(i, j)` will be a cell in the header matrix
    that contains the header and sub-headers. This means that the `data` field
    in the functions will be the same value passed in the keyword `header`.
    (**Default** = `nothing`)

!!! note
      If more than one alignment function is passed to `header_cell_alignment`,
      then the functions will be evaluated in the same order of the tuple. The
      first one that returns a valid alignment symbol for each cell is applied,
      and the rest is discarded.

- `limit_printing::Bool`: If `true`, then the cells will be converted using the
    property `:limit => true` of `IOContext`. (**Default** = `true`)
- `renderer::Symbol`: A symbol that indicates which function should be used to
    convert an object to a string. It can be `:print` to use the function
    `print` or `:show` to use the function `show`. Notice that this selection is
    applicable only to the table data. Headers, sub-headers, and row name column
    are always rendered with print. (**Default** = `:print`)
- `row_names::Union{Nothing, AbstractVector}`: A vector containing the row names
    that will be appended to the left of the table. If it is `nothing`, then the
    column with the row names will not be shown. Notice that the size of this
    vector must match the number of rows in the table. (**Default** = `nothing`)
- `row_name_alignment::Symbol`: Alignment of the column with the rows name (see
    the section [Alignment](@ref)).
- `row_name_column_title::AbstractString`: Title of the column with the row
    names. (**Default** = "")
- `row_number_column_title::AbstractString`: Title of the column with the row
    numbers. (**Default** = "Row")
- `show_row_number::Bool`: If `true`, then a new column will be printed showing
    the row number. (**Default** = `false`)
- `title::AbstractString`: The title of the table. If it is empty, then no title
    will be printed. (**Default** = "")
- `title_alignment::Symbol`: Alignment of the title, which must be a symbol as
    explained in the section [Alignment](@ref). This argument is ignored in the
    LaTeX backend. (**Default** = :l)

!!! note
    Notice that all back-ends have the keyword `tf` to specify the table
    printing format. Thus, if the keyword `backend` is not present or if it is
    `nothing`, then the back-end will be automatically inferred from the type of
    the keyword `tf`. In this case, if `tf` is also not present, then it just
    fall-back to the text back-end unless `HTML` is passed as the first
    argument. In this case, the default back-end is set to HTML.

If `String` is used, then the keyword `color` selects whether or not the table
will be converted to string with or without colors. The default value is
`false`. Notice that this option only has effect in text backend.

# Examples

In the following, it is possible to see some examples for a quick start using
the text back-end.

```jldoctest
julia> data = [1 2 3; 4 5 6];

julia> pretty_table(data; header = ["Column 1", "Column 2", "Column 3"])
┌──────────┬──────────┬──────────┐
│ Column 1 │ Column 2 │ Column 3 │
├──────────┼──────────┼──────────┤
│        1 │        2 │        3 │
│        4 │        5 │        6 │
└──────────┴──────────┴──────────┘

julia> pretty_table(data;
                    header = (["Column 1", "Column 2", "Column 3"],
                              ["A", "B", "C"]))
┌──────────┬──────────┬──────────┐
│ Column 1 │ Column 2 │ Column 3 │
│        A │        B │        C │
├──────────┼──────────┼──────────┤
│        1 │        2 │        3 │
│        4 │        5 │        6 │
└──────────┴──────────┴──────────┘

julia> str = pretty_table(String, data;
                          header = ["Column 1", "Column 2", "Column 3"]);

julia> print(str)
┌──────────┬──────────┬──────────┐
│ Column 1 │ Column 2 │ Column 3 │
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

# Configuration

The following function can be used to print a table changing the default
configurations of **PrettyTables.jl**:

```julia
pretty_table_with_conf(conf::PrettyTablesConf, args...; kwargs...)
```

It calls `pretty_table` using the default configuration in `conf`. The `args...`
and `kwargs...` can be the same as those passed to `pretty_tables`. Notice that
all the configurations in `kwargs...` will overwrite the ones in `conf`.

The object `conf` can be created by the function `set_pt_conf` in which the
keyword parameters can be any one supported by the function `pretty_table` as
shown in the following.

```jldoctest
julia> conf = set_pt_conf(tf = tf_markdown, alignment = :c);

julia> data = [1 2 3; 4 5 6];

julia> header = ["Column 1", "Column 2", "Column 3"];

julia> pretty_table_with_conf(conf, data; header = header)
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
|    1     |    2     |    3     |
|    4     |    5     |    6     |
```

A configuration object can be modified by the function `set_pt_conf!` and
cleared by the function `clear_pt_conf!`.

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

julia> @pt :header = ["Column 1", "Column 2", "Column 3"] data :header = (["Column 1", "Column 2", "Column 3"], ["A", "B", "C"]) data
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

julia> @ptconf tf = tf_ascii_dots alignment = :c

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
