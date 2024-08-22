## Description #############################################################################
#
# Types and structures for the HTML back end.
#
############################################################################################

export HtmlHighlighter, HtmlTableFormat

############################################################################################
#                                       Highlighters                                       #
############################################################################################

"""
    struct HtmlHighlighter

Define the default highlighter of a table when using the HTML back end.

# Fields

- `f::Function`: Function with the signature `f(data, i, j)` in which should return `true`
    if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Function`: Function with the signature `f(h, data, i, j)` in which `h` is the
    highlighter. This function must return a `Dict{String, String}` with properties
    compatible with the `style` field that will be applied to the highlighted cell.
- `_decoration::Dict{String, String}`: The decoration to be applied to the highlighted cell
    if the default `fd` is used.

# Remarks

This structure can be constructed using three helpers:

    HtmlHighlighter(f::Function, decoration::Dict{String, String})

    HtmlHighlighter(f::Function, decorations::NTuple{N, Pair{String, String})

    HtmlHighlighter(f::Function, fd::Function)

The first will apply a fixed decoration to the highlighted cell specified in `decoration`,
whereas the second let the user select the desired decoration by specifying the function
`fd`.
"""
@kwdef struct HtmlHighlighter
    f::Function
    fd::Function

    # == Private Fields ====================================================================
    _decoration::Dict{String, String} = Dict{String, String}()
end

_html__default_html_highlighter_fd(h::HtmlHighlighter, ::Any, ::Int, ::Int) = h._decoration

# Helper function to construct highlighters.
function HtmlHighlighter(f::Function, decoration::Pair{String, String}, args...)
    return HtmlHighlighter(
        f,
        _html__default_html_highlighter_fd,
        Dict{String, String}(decoration, args...)
    )
end

function HtmlHighlighter(f::Function, decoration::Dict{String, String})
    return HtmlHighlighter(f, _html__default_html_highlighter_fd, decoration)
end

HtmlHighlighter(f::Function, fd::Function) = HtmlHighlighter(f, fd, Dict{String, String}())

function HtmlHighlighter(f::Function, decoration::Pair{String, String})
    return HtmlHighlighter(
        f,
        _html__default_html_highlighter_fd,
        Dict{String, String}(decoration)
    )
end

############################################################################################
#                                       Table Format                                       #
############################################################################################

# Create some default decorations to reduce allocations.
const _HTML__NO_DECORATION = Dict{String, String}()
const _HTML__BOLD = Dict{String, String}("font-weight" => "bold")
const _HTML__ITALIC = Dict{String, String}("font-style" => "italic")
const _HTML__SMALL_ITALIC = Dict{String, String}("font-size" => "smaller", "font-style" => "italic")

"""
    HtmlTableFormat

Format that will be used to print the HTML table. All parameters are strings compatible with
the corresponding HTML property.

# Fields

- `css::String`: CSS to be injected at the end of the `<style>` section.
- `table_width::String`: Table width.

# Remarks

Besides the usual HTML tags related to the tables (`table`, `td, `th`, `tr`, etc.), there
are three important classes that can be used to format tables using the variable `css`.

TODO: Add the classes.
"""
@kwdef struct HtmlTableFormat
    css::String = """
    table, td, th {
      border-collapse: collapse;
      font-family: sans-serif;
    }

    td, th {
      padding: 4px
    }

    table > *:first-child > tr:first-child {
      border-top: 2px solid black;
    }

    table > *:last-child > tr:last-child {
      border-bottom: 2px solid black;
    }

    thead tr:last-child {
        border-bottom: 1px solid black;
    }

    tbody tr:last-child {
        border-bottom: 1px solid black;
    }

    tfoot tr:nth-last-child(1 of .footnote) {
        border-bottom: 1px solid black;
    }"""

    table_width::String = ""

    table_style::Dict{String, String} = _HTML__NO_DECORATION

    # == Decorations of Table Sections =====================================================

    top_left_string_decoration::Dict{String, String}    = _HTML__BOLD
    top_right_string_decoration::Dict{String, String}   = _HTML__ITALIC
    title_decoration::Dict{String, String}              = _HTML__BOLD
    subtitle_decoration::Dict{String, String}           = _HTML__NO_DECORATION
    row_number_label_decoration::Dict{String, String}   = _HTML__BOLD
    row_number_decoration::Dict{String, String}         = _HTML__BOLD
    stubhead_label_decoration::Dict{String, String}     = _HTML__BOLD
    row_label_decoration::Dict{String, String}          = _HTML__BOLD
    first_column_label_decoration::Dict{String, String} = _HTML__BOLD
    column_label_decoration::Dict{String, String}       = _HTML__NO_DECORATION
    summary_cell_decoration::Dict{String, String}       = _HTML__NO_DECORATION
    footnote_decoration::Dict{String, String}           = _HTML__NO_DECORATION
    source_note_decoration::Dict{String, String}        = _HTML__SMALL_ITALIC
end

# Default HTML format.
const _HTML__DEFAULT_TABLE_FORMAT = HtmlTableFormat()
