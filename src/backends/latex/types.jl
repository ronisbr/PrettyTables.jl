## Description #############################################################################
#
# Types and structures for the LaTeX backend.
#
############################################################################################

export LatexCell, LatexTableFormat, LatexHighlighter
export @latex_cell_str

"""
    struct LatexCell

Defines a table cell that contains LaTeX code. It can be created using the macro
[`@latex_cell_str`](@ref).
"""
struct LatexCell{T}
    data::T
end

"""
    @latex_cell_str(str)

Create a table cell with LaTeX code.

# Examples

```julia
julia> latex_cell"\textbf{Bold text}"
LatexCell{String}("\\textbf{Bold text}")
```
"""
macro latex_cell_str(str)
    return :(LatexCell($str))
end

"""
    struct LatexTableFormat

This structure defines the format of the LaTeX table.

# Fields

- `top_line::String`: Top line of the table.
- `header_line::String`: Line that separate the header from the table body.
- `mid_line::String`: Line printed in the middle of the table.
- `bottom_line::String`: Bottom line of the table.
- `left_vline::String`: Left vertical line of the table.
- `mid_vline::String`: Vertical line in the middle of the table.
- `right_vline::String`: Right vertical line of the table.
- `header_envs::Vector{String}`: LaTeX environments that will be used in each header cell.
- `subheader_envs::Vector{String}`: LaTeX environments that will be used in each sub-header
    cell.
- `hlines::Vector{Symbol}`: Horizontal lines that must be drawn by default.
- `vlines::Union{Symbol, Vector{Symbol}}`: Vertical lines that must be drawn by default.
- `table_type::Symbol`: Select the type of table that should be used for this format.
- `wrap_table::Bool`: Select if the table must be wrapped inside the environment defined by
    `wrap_table_environment`.
- `wrap_table_environment::String`: Environment in which the table will be wrapped if
    `wrap_table` is true.
"""
@kwdef struct LatexTableFormat
    top_line::String                      = "\\hline"
    header_line::String                   = "\\hline"
    mid_line::String                      = "\\hline"
    bottom_line::String                   = "\\hline"
    left_vline::String                    = "|"
    mid_vline::String                     = "|"
    right_vline::String                   = "|"
    header_envs::Vector{String}           = ["textbf"]
    subheader_envs::Vector{String}        = ["texttt"]
    hlines::Vector{Symbol}                = [:begin, :header, :end]
    vlines::Union{Symbol, Vector{Symbol}} = :none
    table_type::Symbol                    = :tabular
    wrap_table::Bool                      = true
    wrap_table_environment::String        = "table"
end

"""
    LatexHighlighter

Defines the default highlighter of a table when using the LaTeX backend.

# Fields

- `f::Function`: Function with the signature `f(data, i, j)` in which should return `true`
    if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd`: A function with the signature `f(data, i, j, str)::String` in which `data` is the
    matrix, `(i, j)` is the element position in the table, and `str` is the data converted
    to string. This function must return a string that will be placed in the cell.

# Remarks

This structure can be constructed using two helpers:

    LatexHighlighter(f::Function, envs::Union{String, Vector{String}})

    LatexHighlighter(f::Function, fd::Function)

The first will apply recursively all the LaTeX environments in `envs` to the highlighted
text whereas the second let the user select the desired decoration by specifying the
function `fd`.

Thus, for example:

    LatexHighlighter((data, i, j)->true, ["textbf", "small"])

will wrap all the cells in the table in the following environment:

    \\textbf{\\small{<Cell text>}}
"""
@kwdef struct LatexHighlighter
    f::Function
    fd::Function
end

LatexHighlighter(f::Function, env::String) = LatexHighlighter(f, [env])

function LatexHighlighter(f::Function, envs::Vector{String})
    return LatexHighlighter(f, (data, i, j, str)->_latex_envs(str, envs))
end
