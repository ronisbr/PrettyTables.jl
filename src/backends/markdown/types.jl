## Description #############################################################################
#
# Types and strcutures for the Markdown back end.
#
############################################################################################

export MarkdownDecoration, MarkdownHighlighter

"""
    struct MarkdownDecoration

Structure that defines parameters to decorate a table cell in Markdown back end.

# Fields

- `bold::Bool`: Bold text.
- `italic::Bool`: Italic text.
- `strikethrough::Bool`: Strikethrough.
- `code::Bool`: Code.
"""
@kwdef struct MarkdownDecoration
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
    highlighter. This function must return the `MarkdownDecoration` to be applied to the
    cell that must be highlighted.
- `decoration::MarkdownDecoration`: The `MarkdownDecoration` to be applied to the
    highlighted cell if the default `fd` is used.

# Remarks

This structure can be constructed using two helpers:

    MarkdownHighlighter(f::Function, decoration::MarkdownDecoration)

    MarkdownHighlighter(f::Function, fd::Function)

The first will apply a fixed decoration to the highlighted cell specified in `decoration`
whereas the second let the user select the desired decoration by specifying the function
`fd`.
"""
@kwdef struct MarkdownHighlighter
    # API
    f::Function
    fd::Function = (h, data, i, j) -> h.decoration
    decoration::MarkdownDecoration = MarkdownDecoration()
end

# Helper function to construct MarkdownHighlighter.
function MarkdownHighlighter(f::Function, decoration::MarkdownDecoration)
    return MarkdownHighlighter(f = f, decoration = decoration)
end

MarkdownHighlighter(f::Function, fd::Function) = MarkdownHighlighter(f = f, fd = fd)
