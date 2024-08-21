## Description #############################################################################
#
# Types and structures for the HTML back end.
#
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
        border-bottom: 0;
        padding: 4px
    }
    """
    table_width::String = ""
end
