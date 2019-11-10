# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Types and structures for the html backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export HTMLDecoration, HTMLHighlighter, HTMLTableFormat

"""
    struct HTMLDecoration

Structure that defines parameters to decorate a table cell.

"""
@with_kw struct HTMLDecoration
    color::String           = ""
    background::String      = ""
    font_family::String     = ""
    font_weight::String     = ""
    font_decoration::String = ""
end

HTMLDecoration(color::String) = HTMLDecoration(color = color)

function Dict(d::HTMLDecoration)
    style = Dict{String,String}()

    !isempty(d.color)           && (style["color"]           = d.color)
    !isempty(d.background)      && (style["background"]      = d.background)
    !isempty(d.font_decoration) && (style["font-decoration"] = d.font_decoration)
    !isempty(d.font_family)     && (style["font-family"]     = d.font_family)
    !isempty(d.font_weight)     && (style["font-weight"]     = d.font_weight)

    return style
end

"""
    struct HTMLTableFormat

Format that will be used to print the HTML table. All parameters are strings
compatible with the corresponding HTML property.

# Fields

* `border_color`: Color and type of the table border.
* `border_size`: Size of the table border.
* `css`: CSS to be injected at the end of the `<style>` section.
* `header_colors`: A tuple with the foreground and background colors of the
                   header.
* `subheader_colors`: A tuple with the foreground and background colors of the
                      sub-headers
* `table_width`: Table width.

"""
@with_kw struct HTMLTableFormat
    border_color::String = ""
    border_size::String = ""
    css::String = """
    table {
        font-family: sans-serif;
    }

    tr:nth-child(odd) {
        background: #eee;
    }

    tr:nth-child(even) {
        background: #fff;
    }
    """
    header_decoration::HTMLDecoration    = HTMLDecoration(color = "white", background = "navy")
    subheader_decoration::HTMLDecoration = HTMLDecoration(color = "black", background = "lightgray")
    table_width::String = ""
end

#                                 Highlighters
# ==============================================================================

# Abstract type for all highlighters.
"""
    abstract type AbstractHTMLHighlighter

All HTLM highlighters must be a subtype of `AbstractHTMLHighlighter`. They API
dictates that they must implement two functions:

* `f`: Function with the signature `f(data,i,j)` in which should return `true`
       if the element `(i,j)` in `data` must be highlighter, or `false`
       otherwise.
* `fd`: Function with the signature `f(h,data,i,j)` in which `h` is the
        highlighter. This function must return the `HTMLDecoration` to be
        applied to the cell that must be highlighted.

"""
abstract type AbstractHTMLHighlighter end

"""
    struct HTMLHighlighter

Defines the default highlighter of a table when using the html backend.

# Fields

* `f`: Function with the signature `f(data,i,j)` in which should return `true`
       if the element `(i,j)` in `data` must be highlighter, or `false`
       otherwise.
* `fd`: Function with the signature `f(h,data,i,j)` in which `h` is the
        highlighter. This function must return the `HTMLDecoration` to be
        applied to the cell that must be highlighted.
* `decoration`: The `HTMLDecoration` to be applied to the highlighted cell if
                the default `fd` is used.

# Remarks

This structure can be constructed using two helpers:

    HTMLHighlighter(f::Function, decoration::HTMLDecoration)

    HTMLHighlighter(f::Function, fd::Function)

The first will apply a fixed decoration to the highlighted cell specified in
`decoration` whereas the second let the user select the desired decoration by
specifying the function `fd`.

"""
@with_kw struct HTMLHighlighter <: AbstractHTMLHighlighter
    # API
    f::Function
    fd::Function = (h,data,i,j)->h.decoration

    # Private
    decoration::HTMLDecoration = HTMLDecoration()
end

# Helper function to construct HTMLHighlighter.
HTMLHighlighter(f::Function, decoration::HTMLDecoration) =
    HTMLHighlighter(f = f, decoration = decoration)

HTMLHighlighter(f::Function, fd::Function) =
    HTMLHighlighter(f = f, fd = fd)
