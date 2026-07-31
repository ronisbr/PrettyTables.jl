module PrettyTablesTypstryExt

using PrettyTables

using Markdown
using Typstry

function PrettyTables.pretty_table(::Type{Typst}, @nospecialize(data::Any); kwargs...)
    # If the keywords do not set the back end or the table format, use the Typst back end
    # by default.
    str = if !haskey(kwargs, :backend)
        pretty_table(String, data; backend = :typst, kwargs...)
    else
        pretty_table(String, data; kwargs...)
    end

    return Typst(TypstText(str))
end

# Render cells with Typst commands.
function PrettyTables._typst__render_cell(
    cell::TypstString, context::IOContext, renderer::Union{Val{:print}, Val{:show}}
)
    return sprint(show, MIME("text/typst"), cell)
end

# A `TypstString` cell must be treated as a raw Typst component.
PrettyTables._typst__is_raw_typst_cell(::TypstString) = true

# Try to render the table as an image if the current display supports it. This function
# returns whether the table was displayed. Notice that it is called by
# `PrettyTables._typst__display` through `Base.get_extension`.
function _typst__display(output_str::String)
    displayable(MIME("image/png")) || return false

    try
        display(MIME("image/png"), Typst(TypstText(output_str)))
        return true
    catch
        return false
    end
end

end
