## Description #############################################################################
#
# Private functions for the Markdown back end.
#
############################################################################################

"""
    _apply_markdown_decoration(str::String, d::MarkdownDecoration) -> String

Apply the markdown decoration `d` to `str`.
"""
function _apply_markdown_decoration(str::String, d::MarkdownDecoration)
    isempty(str) && return str

    # In the case of `code`, we should neglect all other highlights.
    d.code && return "`$(str)`"

    if d.strikethrough
        str = "~$(str)~"
    end

    if d.italic
        str = "_$(str)_"
    end

    if d.bold
        str = "**$(str)**"
    end

    return str
end
