module PrettyTablesTypstryExt

using PrettyTables

using Markdown
using Typstry

function PrettyTables.pretty_table(::Type{Typst}, @nospecialize(data::Any); kwargs...)
    # If the keywords does not set the back end or the table format, use the Typst back end
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
    cell::TypstString,
    context::IOContext,
    renderer::Union{Val{:print}, Val{:show}},
)
    return sprint(show, MIME("text/typst"), cell)
end

end