## Description #############################################################################
#
# Types and structures for the markdown back end
#
############################################################################################

export MarkdownStyle, MarkdownHighlighter, MarkdownTableFormat, MarkdownTableStyle

"""
    struct MarkdownStyle

Structure that defines styling parameters to a table cell in the markdown back end.

# Fields

- `bold::Bool`: Bold text.
- `italic::Bool`: Italic text.
- `strikethrough::Bool`: Strikethrough.
- `code::Bool`: Code.
"""
@kwdef struct MarkdownStyle
    bold::Bool = false
    italic::Bool = false
    strikethrough::Bool = false
    code::Bool = false
end

############################################################################################
#                                       Highlighters                                       #
############################################################################################

"""
    struct MarkdownHighlighter

Defines the default highlighter of a table when using the markdown backend.

# Fields

- `f::Function`: Function with the signature `f(data, i, j)` in which should return `true`
    if the element `(i, j)` in `data` must be highlighter, or `false` otherwise.
- `fd::Function`: Function with the signature `fd(h, data, i, j)` in which `h` is the
    highlighter. This function must return the `MarkdownStyle` to be applied to the
    cell that must be highlighted.
- `_decoration::MarkdownStyle`: The decoration to be applied to the highlighted cell if
    the default `fd` is used.

# Remarks

This structure can be constructed using two helpers:

    MarkdownHighlighter(f::Function, decoration::MarkdownStyle)

    MarkdownHighlighter(f::Function, fd::Function)

The first will apply a fixed decoration to the highlighted cell specified in `decoration`
whereas the second let the user select the desired decoration by specifying the function
`fd`.
"""
struct MarkdownHighlighter
    f::Function
    fd::Function

    # == Private Fields ====================================================================

    _decoration::MarkdownStyle

    # == Constructors ======================================================================

    function MarkdownHighlighter(f::Function, fd::Function)
        return new(f, fd, MarkdownStyle())
    end

    function MarkdownHighlighter(f::Function, decoration::MarkdownStyle)
        return new(
            f,
            _markdown__default_highlighter_fd,
            decoration
        )
    end
end

_markdown__default_highlighter_fd(h::MarkdownHighlighter, ::Any, ::Int, ::Int) = h._decoration

############################################################################################
#                                       Table Format                                       #
############################################################################################

# Create some default decorations to reduce allocations.
const _MARKDOWN__NO_DECORATION = MarkdownStyle()
const _MARKDOWN__BOLD          = MarkdownStyle(bold   = true)
const _MARKDOWN__ITALIC        = MarkdownStyle(italic = true)
const _MARKDOWN__CODE          = MarkdownStyle(code   = true)

"""
    struct MarkdownTableFormat

Define the format of the tables printed with the markdown back end.

# Fields

- `title_heading_level::Int`: Title heading level.
- `subtitle_heading_level::Int`: Subtitle heading level.
- `horizontal_line_char::Char`: Character used to draw the horizontal line.
- `line_before_summary_rows::Bool`: Whether to draw a line before the summary rows.
"""
@kwdef struct MarkdownTableFormat
    title_heading_level::Int       = 1
    subtitle_heading_level::Int    = 2
    horizontal_line_char::Char     = '─'
    line_before_summary_rows::Bool = true
end

"""
    struct MarkdownTableStyle

Define the style of the tables printed with the markdown back end.

# Fields

- `row_number_label::MarkdownStyle`: Style for the row number label.
- `row_number::MarkdownStyle`: Style for the row number.
- `stubhead_label::MarkdownStyle`: Style for the stubhead label.
- `row_label::MarkdownStyle`: Style for the row label.
- `row_group_label::MarkdownStyle`: Style for the row group label.
- `first_column_label::MarkdownStyle`: Style for the first line of the  column
    labels.
- `column_label::MarkdownStyle`: Style for the column label.
- `summary_row_label::MarkdownStyle`: Style for the summary row label.
- `summary_row_cell::MarkdownStyle`: Style for the summary row cell.
- `footnote::MarkdownStyle`: Style for the footnote.
- `source_note::MarkdownStyle`: Style for the source note.
- `omitted_cell_summary::MarkdownStyle`: Style for the omitted cell summary.
"""
@kwdef struct MarkdownTableStyle
    row_number_label::MarkdownStyle     = _MARKDOWN__BOLD
    row_number::MarkdownStyle           = _MARKDOWN__BOLD
    stubhead_label::MarkdownStyle       = _MARKDOWN__BOLD
    row_label::MarkdownStyle            = _MARKDOWN__BOLD
    row_group_label::MarkdownStyle      = _MARKDOWN__BOLD
    first_column_label::MarkdownStyle   = _MARKDOWN__BOLD
    column_label::MarkdownStyle         = _MARKDOWN__CODE
    summary_row_label::MarkdownStyle    = _MARKDOWN__BOLD
    summary_row_cell::MarkdownStyle     = _MARKDOWN__NO_DECORATION
    footnote::MarkdownStyle             = _MARKDOWN__NO_DECORATION
    source_note::MarkdownStyle          = _MARKDOWN__NO_DECORATION
    omitted_cell_summary::MarkdownStyle = _MARKDOWN__ITALIC
end
