## Description #############################################################################
#
# Types and structures for the LaTeX back end.
#
############################################################################################

export LatexTableBorders, LatexTableFormat, LatexTableStyle
export LatexEnvironments, LatexHighlighter

############################################################################################
#                                       Table Format                                       #
############################################################################################

"""
    const LatexEnvironments = Vector{String}

Vector with the LaTeX environments applied to a cell, which is the native decoration of the
LaTeX back end (for example, `["textbf", "small"]`).
"""
const LatexEnvironments = Vector{String}

# Create some default decorations to reduce allocations.
const _LATEX__DEFAULT      = String[]
const _LATEX__BOLD         = ["textbf"]
const _LATEX__ITALIC       = ["textit"]
const _LATEX__LARGE_BOLD   = ["large", "textbf"]
const _LATEX__SMALL        = ["small"]
const _LATEX__SMALL_ITALIC = ["small", "textit"]

"""
    struct LatexTableBorders

Define the horizontal rules of a table printed with the LaTeX back end. All fields are
strings with a LaTeX command. The vertical lines are drawn with the column specification of
the table environment and cannot be customized here.

# Fields

- `top_line::String`: Rule at the top of the table.
    (**Default**: `"\\\\hline"`)
- `header_line::String`: Rule of the lines surrounding the column labels.
    (**Default**: `"\\\\hline"`)
- `merged_header_cell_line::String`: Command of the rule under merged column label cells,
    to which the back end appends the column range.
    (**Default**: `"\\\\cline"`)
- `middle_line::String`: Rule of the horizontal lines inside the table body.
    (**Default**: `"\\\\hline"`)
- `bottom_line::String`: Rule at the bottom of the table.
    (**Default**: `"\\\\hline"`)
"""
@kwdef struct LatexTableBorders
    top_line::String                = "\\hline"
    header_line::String             = "\\hline"
    merged_header_cell_line::String = "\\cline"
    middle_line::String             = "\\hline"
    bottom_line::String             = "\\hline"
end

"""
    struct LatexTableFormat

Define the format of the tables printed with the LaTeX back end.

# Fields

- `borders::LatexTableBorders`: Format of the borders.
- `horizontal_line_at_beginning::Bool`: If `true`, a horizontal line will be drawn at the
    beginning of the table.
- `horizontal_line_at_merged_column_labels::Bool`: If `true`, a horizontal line will be
    drawn at the bottom of the merged column labels using `\\cline`. The default is `true`,
    whereas the text back end defaults to `false`.
- `horizontal_line_after_column_labels::Bool`: If `true`, a horizontal line will be drawn
    after the column labels.
- `horizontal_lines_at_data_rows::Union{Symbol, Vector{Int}}`: A horizontal line will be
    drawn after each data row index listed in this vector. If the symbol `:all` is passed, a
    horizontal line will be drawn after every data row. If the symbol `:none` is passed,
    no horizontal lines will be drawn after the data rows.
- `horizontal_line_before_row_group_label::Bool`: If `true`, a horizontal line will be
    drawn before the row group label.
- `horizontal_line_after_row_group_label::Bool`: If `true`, a horizontal line will be
    drawn after the row group label.
- `horizontal_line_after_data_rows::Bool`: If `true`, a horizontal line will be drawn
    after the data rows.
- `horizontal_line_before_summary_rows::Bool`: If `true`, a horizontal line will be drawn
    before the summary rows. Notice that this line is the same as the one drawn if
    `horizontal_line_after_data_rows` is `true`. However, in this case, the line is omitted
    if there are no summary rows.
- `horizontal_line_after_summary_rows::Bool`: If `true`, a horizontal line will be drawn
    after the summary rows.
- `vertical_line_at_beginning::Bool`: If `true`, a vertical line will be drawn at the
    beginning of the table.
- `vertical_line_after_row_number_column::Bool`: If `true`, a vertical line will be drawn
    after the row number column.
- `vertical_line_after_row_label_column::Bool`: If `true`, a vertical line will be drawn
    after the row label column.
- `vertical_lines_at_data_columns::Union{Symbol, Vector{Int}}`: A vertical line will be
    drawn after each data column index listed in this vector. If the symbol `:all` is
    passed, a vertical line will be drawn after every data row. If the symbol `:none` is
    passed, no vertical lines will be drawn after the data columns.
- `vertical_line_after_data_columns::Bool`: If `true`, a vertical line will be drawn after
    the data columns.
- `vertical_line_after_continuation_column::Bool`: If `true`, a vertical line will be
    drawn after the continuation column.
"""
@kwdef struct LatexTableFormat
    # == Border and Lines ==================================================================

    borders::LatexTableBorders = LatexTableBorders()

    # == Configuration for the Horizontal and Vertical Lines ===============================

    horizontal_line_at_beginning::Bool = true
    horizontal_line_after_column_labels::Bool = true
    horizontal_line_at_merged_column_labels::Bool = true
    horizontal_lines_at_data_rows::Union{Symbol, Vector{Int}} = :none
    horizontal_line_before_row_group_label::Bool = true
    horizontal_line_after_row_group_label::Bool = true
    horizontal_line_after_data_rows::Bool = true
    horizontal_line_before_summary_rows::Bool = true
    horizontal_line_after_summary_rows::Bool = true

    vertical_line_at_beginning::Bool = true
    vertical_line_after_row_number_column::Bool = true
    vertical_line_after_row_label_column::Bool = true
    vertical_lines_at_data_columns::Union{Symbol, Vector{Int}} = :all
    vertical_line_after_data_columns::Bool = true
    vertical_line_after_continuation_column::Bool = true
end

"""
    struct LatexTableStyle

Define the style of the tables printed with the latex back end.

# Fields

- `title::LatexEnvironments`: Latex environments with the style for the title.
- `subtitle::LatexEnvironments`: Latex environments with the style for the subtitle.
- `row_number_label::LatexEnvironments`: Latex environments with the style for the row
    number label.
- `row_number::LatexEnvironments`: Latex environments with the style for the row numbers.
- `stubhead_label::LatexEnvironments`:  Latex environments with the style for the stubhead
    label.
- `row_label::LatexEnvironments`: Latex environments with the style for the row labels.
- `row_group_label::LatexEnvironments`: Latex environments with the style for the row group
    label.
- `first_line_column_label::Union{LatexEnvironments, Vector{LatexEnvironments}}`: Latex
    environments with the style for the first line of the column labels. If a vector of
    `LatexEnvironments` is provided, each column label in the first line will use the
    corresponding style.
- `column_label::Union{LatexEnvironments, Vector{LatexEnvironments}}`: Latex environments
    with the style for the rest of the column labels. If a vector of `LatexEnvironments` is
    provided, each column label will use the corresponding style.
- `first_line_merged_column_label::LatexEnvironments`: Latex environments with the style for
    the merged cells at the first column label line.
- `merged_column_label::LatexEnvironments`: Latex environments with the style for the merged
    cells at the rest of the column labels.
- `summary_row_cell::LatexEnvironments`: Latex environments with the style for the summary
    row cell.
- `summary_row_label::LatexEnvironments`: Latex environments with the style for the summary
    row label.
- `footnote::LatexEnvironments`: Latex environments with the style for the footnotes.
- `source_note::LatexEnvironments`: Latex environments with the style for the source notes.
- `omitted_cell_summary::LatexEnvironments`: Latex environments with the style for the
    omitted cell summary.

# Constructor

    LatexTableStyle(; kwargs...)

Create a style in which each field can be passed as a keyword. Every keyword also accepts a
`Face` (or a `Crayon`, converted to the equivalent face), which is converted with [`latex_decoration`](@ref). The keywords
`first_line_column_label` and `column_label` also accept a vector with one decoration
(LaTeX environments or `Face`) per column.
"""
struct LatexTableStyle{
    TFCL <: Union{LatexEnvironments, Vector{LatexEnvironments}},
    TCL <: Union{LatexEnvironments, Vector{LatexEnvironments}},
}
    title::LatexEnvironments
    subtitle::LatexEnvironments
    row_number_label::LatexEnvironments
    row_number::LatexEnvironments
    stubhead_label::LatexEnvironments
    row_label::LatexEnvironments
    row_group_label::LatexEnvironments
    first_line_column_label::TFCL
    column_label::TCL
    first_line_merged_column_label::LatexEnvironments
    merged_column_label::LatexEnvironments
    summary_row_cell::LatexEnvironments
    summary_row_label::LatexEnvironments
    footnote::LatexEnvironments
    source_note::LatexEnvironments
    omitted_cell_summary::LatexEnvironments
end

function LatexTableStyle(;
    title                          = _LATEX__LARGE_BOLD,
    subtitle                       = _LATEX__ITALIC,
    row_number_label               = _LATEX__BOLD,
    row_number                     = _LATEX__DEFAULT,
    stubhead_label                 = _LATEX__BOLD,
    row_label                      = _LATEX__BOLD,
    row_group_label                = _LATEX__BOLD,
    first_line_column_label        = _LATEX__BOLD,
    column_label                   = _LATEX__ITALIC,
    first_line_merged_column_label = _LATEX__BOLD,
    merged_column_label            = _LATEX__BOLD,
    summary_row_cell               = _LATEX__DEFAULT,
    summary_row_label              = _LATEX__BOLD,
    footnote                       = _LATEX__SMALL,
    source_note                    = _LATEX__SMALL_ITALIC,
    omitted_cell_summary           = _LATEX__SMALL_ITALIC,
)
    return LatexTableStyle(
        _latex__decoration(title),
        _latex__decoration(subtitle),
        _latex__decoration(row_number_label),
        _latex__decoration(row_number),
        _latex__decoration(stubhead_label),
        _latex__decoration(row_label),
        _latex__decoration(row_group_label),
        _latex__column_label_decoration(first_line_column_label),
        _latex__column_label_decoration(column_label),
        _latex__decoration(first_line_merged_column_label),
        _latex__decoration(merged_column_label),
        _latex__decoration(summary_row_cell),
        _latex__decoration(summary_row_label),
        _latex__decoration(footnote),
        _latex__decoration(source_note),
        _latex__decoration(omitted_cell_summary),
    )
end

############################################################################################
#                                     LatexHighlighter                                     #
############################################################################################

"""
    LatexHighlighter

Defines the default highlighter of a table when using the LaTeX backend.

# Fields

- `f::Function`: Function with the signature `f(data, i, j)` which should return `true`
    if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd`: A function with the signature `fd(h, data, i, j)::Vector{String}` in which `h` is the
    highlighter object, `data` is the matrix, and `(i, j)` is the element position in the
    table. This function should return a vector with the LaTeX environments to be applied to
    the cell.

# Remarks

This structure can be constructed using two helpers:

```julia
LatexHighlighter(f::Function, envs::Vector{String})
```

where it will apply recursively all the LaTeX environments in `envs` to the highlighted
text, and

```julia
LatexHighlighter(f::Function, fd::Function)
```

where the user selects the desired decoration by specifying the function `fd`.

Thus, for example:

```julia
LatexHighlighter((data, i, j) -> true, ["textbf", "small"])
```

will wrap all the cells in the table in the following environment:

```latex
\\small{\\textbf{<Cell text>}}
```

Notice that the environments are applied in order, meaning that the **last** one in the
vector ends up being the outermost.

The following helpers create the decoration from a `Face` of StyledStrings.jl, converted
with [`latex_decoration`](@ref), from a `Crayon`, converted to the equivalent face, or from the
keywords of `Face` and `Crayon` (see [`Highlighter`](@ref)):

    LatexHighlighter(f::Function, face::Face)

    LatexHighlighter(f::Function, crayon::Crayon)

    LatexHighlighter(f::Function; kwargs...)
"""
struct LatexHighlighter <: AbstractHighlighter
    f::Function
    fd::Function

    # == Private Fields ====================================================================

    _environments::LatexEnvironments

    # == Constructors ======================================================================

    function LatexHighlighter(f::Function, fd::Function)
        return new(f, fd, _LATEX__DEFAULT)
    end

    function LatexHighlighter(f::Function, envs::Vector{String})
        return new(f, _latex__default_highlighter_fd, envs)
    end

    function LatexHighlighter(f::Function, face::Face)
        return LatexHighlighter(f, latex_decoration(face))
    end

    function LatexHighlighter(f::Function, crayon::Crayon)
        return LatexHighlighter(f, _face_from_crayon(crayon))
    end

    function LatexHighlighter(f::Function; kwargs...)
        return LatexHighlighter(f, _face_from_kwargs(; kwargs...))
    end
end

_latex__default_highlighter_fd(h::LatexHighlighter, ::Any, ::Int, ::Int) = h._environments

############################################################################################
#                                        LaTeX Cell                                        #
############################################################################################

export LatexCell
export @latex_cell_str

"""
    struct LatexCell

Defines a table cell that contains LaTeX code. It can be created using the macro
[`@latex_cell_str`](@ref).
"""
struct LatexCell{T}
    data::T
end

raw"""
    @latex_cell_str(str)

Create a table cell with LaTeX code.

# Examples

```julia
julia> latex_cell"\textbf{Bold text}"
LatexCell{String}("\textbf{Bold text}")
```
"""
macro latex_cell_str(str)
    return :(LatexCell($str))
end
