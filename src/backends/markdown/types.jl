# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==========================================================================================
#
#   Types and strcutures for the Markdown back end.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export MarkdownDecoration

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
