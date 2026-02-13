## Description #############################################################################
#
# Functions to render the table cells in the Typst back end.
#
############################################################################################

"""
    _typst__cell_to_str(cell::Any, context::IOContext, renderer::Union{Val{:print}, Val{:show}}) -> String

Convert the `cell` to a string using a specific `context` and `renderer`.
"""
function _typst__cell_to_str(cell::Any, context::IOContext, ::Val{:print})
    return sprint(print, cell; context)
end

function _typst__cell_to_str(cell::Any, context::IOContext, ::Val{:show})
    if showable(MIME("text/typst"), cell)
        cell_str = sprint(show, MIME("text/typst"), cell; context)
    else
        cell_str = sprint(show, cell; context)
    end

    return cell_str
end

function _typst__cell_to_str(cell::AbstractString, context::IOContext, ::Val{:show})
    if showable(MIME("text/typst"), cell)
        cell_str = sprint(show, MIME("text/typst"), cell; context)
    else
        cell_str = string(cell)
    end

    return cell_str
end

_typst__cell_to_str(cell::UndefinedCell, context::IOContext, ::Val{:print}) = "#undef"

_typst__cell_to_str(cell::UndefinedCell, context::IOContext, ::Val{:show}) = "#undef"

"""
    _typst__render_cell(cell::Any, context::IOContext, renderer::Union{Val{:print}, Val{:show}}) -> String

Render the `cell` in Typst back end using a specific `context` and `renderer`.
"""
function _typst__render_cell(
    cell::Any,
    context::IOContext,
    renderer::Union{Val{:print}, Val{:show}},
)
    cell_str = _typst__cell_to_str(cell, context, renderer)

    # If the user wants HTML code inside cell, we must not escape the HTML characters.
    return _typst__escape_str(cell_str)
end

function _typst__render_cell(
    cell::AbstractString,
    context::IOContext,
    renderer::Union{Val{:print}, Val{:show}},
)
    cell_str = _typst__cell_to_str(cell, context, renderer)

    # If the user wants HTML code inside cell, we must not escape the HTML characters.
    return _typst__escape_str(cell_str)
end

function PrettyTables._typst__render_cell(
    cell::Markdown.MD,
    context::IOContext,
    renderer::Union{Val{:print}, Val{:show}},
)
    # We will always render Markdown cells using `#raw` until we can obtain a good way to
    # convert Markdown to Typst.
    str = "\"" * replace(chomp(string(cell)), "\n" => "\\n\" + \n  \"") * "\""

    return """
        #raw(
          $str,
          block: false,
          lang: "markdown",
        )"""
end