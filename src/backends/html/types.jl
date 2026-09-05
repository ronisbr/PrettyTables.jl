## Description #############################################################################
#
# Types and structures for the HTML back end.
#
############################################################################################

export HtmlHighlighter, HtmlPair, HtmlTableBorders, HtmlTableFormat, HtmlTableStyle

"""
    const HtmlPair = Pair{String, String}

Pair with a CSS property and its value, which is the native decoration of the HTML back end
(for example, `"font-weight" => "bold"`).
"""
const HtmlPair = Pair{String, String}

############################################################################################
#                                       Highlighters                                       #
############################################################################################

"""
    struct HtmlHighlighter

Define the default highlighter of a table when using the HTML back end.

# Fields

- `f::Function`: Function with the signature `f(data, i, j)` which should return `true`
    if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Function`: Function with the signature `f(h, data, i, j)` in which `h` is the
    highlighter. This function must return a `Vector{Pair{String, String}}` with properties
    compatible with the `style` field that will be applied to the highlighted cell.
# Remarks

This structure can be constructed using the following helpers:

    HtmlHighlighter(f::Function, decoration::HtmlPair)

    HtmlHighlighter(f::Function, decoration::Vector{HtmlPair})

    HtmlHighlighter(f::Function, fd::Function)

The first two apply a fixed decoration to the highlighted cell, whereas the third lets the
user select the desired decoration by specifying the function `fd`.

The following helpers create the decoration from a `Face` of StyledStrings.jl, converted
with [`html_decoration`](@ref), from a `Crayon`, converted to the equivalent face, or from the
keywords of `Face` and `Crayon` (see [`Highlighter`](@ref)):

    HtmlHighlighter(f::Function, face::Face)

    HtmlHighlighter(f::Function, crayon::Crayon)

    HtmlHighlighter(f::Function; kwargs...)
"""
struct HtmlHighlighter <: AbstractHighlighter
    f::Function
    fd::Function

    # == Private Fields ====================================================================

    _decoration::Vector{HtmlPair}

    # == Constructors ======================================================================

    function HtmlHighlighter(f::Function, fd::Function)
        return new(f, fd, HtmlPair[])
    end

    function HtmlHighlighter(f::Function, decoration::HtmlPair)
        return new(f, _html__default_highlighter_fd, [decoration])
    end

    function HtmlHighlighter(f::Function, decoration::Vector{HtmlPair})
        return new(f, _html__default_highlighter_fd, decoration)
    end

    function HtmlHighlighter(f::Function, decoration::Vector{HtmlPair}, args::HtmlPair...)
        return new(f, _html__default_highlighter_fd, [decoration..., args...])
    end

    function HtmlHighlighter(f::Function, face::Face)
        return HtmlHighlighter(f, html_decoration(face))
    end

    function HtmlHighlighter(f::Function, crayon::Crayon)
        return HtmlHighlighter(f, _face_from_crayon(crayon))
    end

    function HtmlHighlighter(f::Function; kwargs...)
        return HtmlHighlighter(f, _face_from_kwargs(; kwargs...))
    end
end

_html__default_highlighter_fd(h::HtmlHighlighter, ::Any, ::Int, ::Int) = h._decoration

############################################################################################
#                                       Table Format                                       #
############################################################################################

# Create some default decorations to reduce allocations.
const _HTML__NO_DECORATION = HtmlPair[]
const _HTML__BOLD = ["font-weight" => "bold"]
const _HTML__ITALIC = ["font-style" => "italic"]
const _HTML__XLARGE_BOLD = ["font-size" => "x-large", "font-weight" => "bold"]
const _HTML__LARGE_ITALIC = ["font-size" => "large", "font-style" => "italic"]
const _HTML__SMALL = ["font-size" => "small"]
const _HTML__SMALL_ITALIC = ["font-size" => "small", "font-style" => "italic"]
const _HTML__SMALL_ITALIC_GRAY = [
    "color" => "gray", "font-size" => "small", "font-style" => "italic"
]

# Default CSS injected in the `<style>` section when `stand_alone = true`. The table borders
# are not defined here because they are emitted as inline styles, allowing them to appear in
# any rendering mode.
const _HTML__DEFAULT_CSS = """
    table, td, th {
      font-family: sans-serif;
    }

    td, th {
      padding-bottom: 6px !important;
      padding-left: 8px !important;
      padding-right: 8px !important;
      padding-top: 6px !important;
    }

    tr.title td {
      padding-bottom: 2px !important;
    }

    tr.footnote td {
      padding-bottom: 2px !important;
    }

    tr.sourceNotes td {
      padding-bottom: 2px !important;
    }"""

"""
    struct HtmlTableBorders

Define the borders of a table printed with the HTML back end. All fields are strings with a
CSS `border` shorthand value (e.g., `"1px dashed #0000ff"`).

# Fields

## Horizontal Lines

- `top_line::String`: Border at the top of the table.
    (**Default**: `"2px solid black"`)
- `header_line::String`: Border of the lines surrounding the column labels.
    (**Default**: `"1px solid black"`)
- `merged_header_cell_line::String`: Border below merged column label cells.
    (**Default**: `"1px solid black"`)
- `middle_line::String`: Border of horizontal lines inside the table body.
    (**Default**: `"1px solid black"`)
- `bottom_line::String`: Border at the bottom of the table.
    (**Default**: `"2px solid black"`)

## Vertical Lines

- `left_line::String`: Border at the left of the table.
    (**Default**: `"2px solid black"`)
- `center_line::String`: Border of vertical lines inside the table body.
    (**Default**: `"1px solid black"`)
- `right_line::String`: Border at the right of the table.
    (**Default**: `"2px solid black"`)
"""
@kwdef struct HtmlTableBorders
    # == Horizontal Lines ==================================================================

    top_line::String                = "2px solid black"
    header_line::String             = "1px solid black"
    merged_header_cell_line::String = "1px solid black"
    middle_line::String             = "1px solid black"
    bottom_line::String             = "2px solid black"

    # == Vertical Lines ====================================================================

    left_line::String   = "2px solid black"
    center_line::String = "1px solid black"
    right_line::String  = "2px solid black"
end

"""
    struct HtmlTableFormat

Define the format of the tables printed with the HTML back end.

# Fields

- `css::String`: CSS to be injected at the end of the `<style>` section. Notice that this
    field is only applied if `stand_alone = true`.
- `table_width::String`: Table width. Notice that this field is only applied if
    `stand_alone = true`.
- `borders::HtmlTableBorders`: Format of the borders. The borders are emitted as inline
    styles in the table elements. Hence, they are applied in any rendering mode.
- `horizontal_line_at_beginning::Bool`: If `true`, a horizontal line will be drawn at the
    beginning of the table.
- `horizontal_line_before_column_labels::Bool`: If `true`, a horizontal line will be drawn
    before the column labels when the table has a title or subtitle. (HTML back end only)
- `horizontal_line_after_column_labels::Bool`: If `true`, a horizontal line will be drawn
    after the column labels.
- `horizontal_line_at_merged_column_labels::Bool`: If `true`, a horizontal line will be
    drawn at the bottom of the merged column labels.
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
- `horizontal_line_after_footnotes::Bool`: If `true`, a horizontal line will be drawn after
    the footnotes when the table also has source notes. (HTML back end only)
- `horizontal_line_at_end::Bool`: If `true`, a horizontal line will be drawn at the end of
    the table, i.e. after the last summary row or the last data row and before the
    footnotes and source notes, even when `horizontal_line_after_data_rows` and
    `horizontal_line_after_summary_rows` are `false`. (HTML back end only)
- `vertical_line_at_beginning::Bool`: If `true`, a vertical line will be drawn at the
    beginning of the table.
- `vertical_line_after_row_number_column::Bool`: If `true`, a vertical line will be drawn
    after the row number column.
- `vertical_line_after_row_label_column::Bool`: If `true`, a vertical line will be drawn
    after the row label column.
- `vertical_lines_at_data_columns::Union{Symbol, Vector{Int}}`: A vertical line will be
    drawn after each data column index listed in this vector. If the symbol `:all` is
    passed, a vertical line will be drawn after every data column. If the symbol `:none` is
    passed, no vertical lines will be drawn after the data columns.
- `vertical_line_after_data_columns::Bool`: If `true`, a vertical line will be drawn after
    the data columns.
- `vertical_line_after_continuation_column::Bool`: If `true`, a vertical line will be
    drawn after the continuation column.

# Remarks

By default, the HTML back end draws no lines: every line presence field defaults to `false`
(or `:none`), and the emitted code has no border decoration. Hence, the table appearance can
be fully customized with CSS. The fields above (or the backend-agnostic
[`TableFormat`](@ref)) can be used to draw lines as inline styles, which are applied in any
rendering mode.

The horizontal line at the beginning of the table is emitted as an inline border of the
`<table>` element, the other horizontal lines (including the line at the end of the table)
are emitted as inline borders of the `<tr>` elements, and the vertical lines are emitted as
inline borders of the `<col>` elements, except for the line under a merged column label,
which is a border of the cell. Since the table borders are collapsed, those borders are
applied to the edges of every cell of the row or column. When two lines meet at the same
edge (for example, the line after the data rows and the line before the summary rows), the
CSS border-collapsing rules select the wider border, and then the border with the higher
style precedence.

As in the text back end, the footnotes and source notes are outside the ruled area: the
line at the end of the table is drawn before them, and the vertical lines at the edges of
the table are hidden in their cells. Also as in the other back ends, the line drawn after
the last row of the ruled area by `horizontal_line_after_summary_rows`,
`horizontal_line_after_data_rows` (if the table has no summary rows), or
`horizontal_line_after_column_labels` (if the table has no rows) uses the bottom line style
instead of the middle or header one, whereas the lines selected by
`horizontal_lines_at_data_rows` are internal and always use the middle line style.
"""
@kwdef struct HtmlTableFormat
    css::String = _HTML__DEFAULT_CSS
    table_width::String = ""

    # == Borders ===========================================================================

    borders::HtmlTableBorders = HtmlTableBorders()

    # == Configuration for the Horizontal and Vertical Lines ===============================

    # NOTE: The HTML back end draws no lines by default so that the emitted code has no
    # border decoration, matching the behavior before the borders were introduced and
    # keeping the output fully customizable with CSS.
    horizontal_line_at_beginning::Bool = false
    horizontal_line_before_column_labels::Bool = false
    horizontal_line_after_column_labels::Bool = false
    horizontal_line_at_merged_column_labels::Bool = false
    horizontal_lines_at_data_rows::Union{Symbol, Vector{Int}} = :none
    horizontal_line_before_row_group_label::Bool = false
    horizontal_line_after_row_group_label::Bool = false
    horizontal_line_after_data_rows::Bool = false
    horizontal_line_before_summary_rows::Bool = false
    horizontal_line_after_summary_rows::Bool = false
    horizontal_line_after_footnotes::Bool = false
    horizontal_line_at_end::Bool = false

    vertical_line_at_beginning::Bool = false
    vertical_line_after_row_number_column::Bool = false
    vertical_line_after_row_label_column::Bool = false
    vertical_lines_at_data_columns::Union{Symbol, Vector{Int}} = :none
    vertical_line_after_data_columns::Bool = false
    vertical_line_after_continuation_column::Bool = false
end

# Positional constructor with the fields of v3.4.8, before the border fields were added, so
# that the code written for the previous versions keeps working.
function HtmlTableFormat(css::AbstractString, table_width::AbstractString)
    return HtmlTableFormat(; css = String(css), table_width = String(table_width))
end

"""
    struct HtmlTableStyle

Define the style of the tables printed with the HTML back end.

# Fields

- `top_left_string::Vector{HtmlPair}`: Style for the top left string.
- `top_right_string::Vector{HtmlPair}`: Style for the top right string.
- `table::Vector{HtmlPair}`: Style for the table.
- `title::Vector{HtmlPair}`: Style for the title.
- `subtitle::Vector{HtmlPair}`: Style for the subtitle.
- `row_number_label::Vector{HtmlPair}`: Style for the row number label.
- `row_number::Vector{HtmlPair}`: Style for the row number.
- `stubhead_label::Vector{HtmlPair}`: Style for the stubhead label.
- `row_label::Vector{HtmlPair}`: Style for the row label.
- `row_group_label::Vector{HtmlPair}`: Style for the row group label.
- `first_line_column_label::Union{Vector{HtmlPair}, Vector{Vector{HtmlPair}}}`: Style for
    the first line of the column labels. If a vector of `Vector{HtmlPair}` is provided,
    each column label in the first line will use the corresponding style.
- `column_label::Union{Vector{HtmlPair}, Vector{Vector{HtmlPair}}}`: Style for the rest of
    the column labels. If a vector of `Vector{HtmlPair}` is provided, each column label
    will use the corresponding style.
- `first_line_merged_column_label::Vector{HtmlPair}`: Style for the merged cells at the
    first column label line.
- `merged_column_label::Vector{HtmlPair}`: Style for the merged cells at the rest of the
    column labels.
- `summary_row_cell::Vector{HtmlPair}`: Style for the summary row cell.
- `summary_row_label::Vector{HtmlPair}`: Style for the summary row label.
- `footnote::Vector{HtmlPair}`: Style for the footnote.
- `source_note::Vector{HtmlPair}`: Style for the source notes.

# Constructor

    HtmlTableStyle(; kwargs...)

Create a style in which each field can be passed as a keyword. Every keyword also accepts a
`Face` (or a `Crayon`, converted to the equivalent face), which is converted with [`html_decoration`](@ref). The keywords
`first_line_column_label` and `column_label` also accept a vector with one decoration (CSS
properties or `Face`) per column.
"""
struct HtmlTableStyle{
    TFCL <: Union{Vector{HtmlPair}, Vector{Vector{HtmlPair}}},
    TCL <: Union{Vector{HtmlPair}, Vector{Vector{HtmlPair}}},
}
    top_left_string::Vector{HtmlPair}
    top_right_string::Vector{HtmlPair}
    table::Vector{HtmlPair}
    title::Vector{HtmlPair}
    subtitle::Vector{HtmlPair}
    row_number_label::Vector{HtmlPair}
    row_number::Vector{HtmlPair}
    stubhead_label::Vector{HtmlPair}
    row_label::Vector{HtmlPair}
    row_group_label::Vector{HtmlPair}
    first_line_column_label::TFCL
    column_label::TCL
    first_line_merged_column_label::Vector{HtmlPair}
    merged_column_label::Vector{HtmlPair}
    summary_row_cell::Vector{HtmlPair}
    summary_row_label::Vector{HtmlPair}
    footnote::Vector{HtmlPair}
    source_note::Vector{HtmlPair}
end

function HtmlTableStyle(;
    top_left_string                = _HTML__NO_DECORATION,
    top_right_string               = _HTML__ITALIC,
    table                          = _HTML__NO_DECORATION,
    title                          = _HTML__XLARGE_BOLD,
    subtitle                       = _HTML__LARGE_ITALIC,
    row_number_label               = _HTML__BOLD,
    row_number                     = _HTML__BOLD,
    stubhead_label                 = _HTML__BOLD,
    row_label                      = _HTML__BOLD,
    row_group_label                = _HTML__BOLD,
    first_line_column_label        = _HTML__BOLD,
    column_label                   = _HTML__NO_DECORATION,
    first_line_merged_column_label = _HTML__NO_DECORATION,
    merged_column_label            = _HTML__NO_DECORATION,
    summary_row_cell               = _HTML__NO_DECORATION,
    summary_row_label              = _HTML__BOLD,
    footnote                       = _HTML__SMALL,
    source_note                    = _HTML__SMALL_ITALIC_GRAY,
)
    return HtmlTableStyle(
        _html__decoration(top_left_string),
        _html__decoration(top_right_string),
        _html__decoration(table),
        _html__decoration(title),
        _html__decoration(subtitle),
        _html__decoration(row_number_label),
        _html__decoration(row_number),
        _html__decoration(stubhead_label),
        _html__decoration(row_label),
        _html__decoration(row_group_label),
        _html__column_label_decoration(first_line_column_label),
        _html__column_label_decoration(column_label),
        _html__decoration(first_line_merged_column_label),
        _html__decoration(merged_column_label),
        _html__decoration(summary_row_cell),
        _html__decoration(summary_row_label),
        _html__decoration(footnote),
        _html__decoration(source_note),
    )
end
