module PrettyTablesTypstryExt
using PrettyTables, Typstry

function PrettyTables.pretty_table(::Type{Typst}, @nospecialize(data::Any); kwargs...)
    # If the keywords does not set the back end or the table format, use the HTML back end
    # by default.
    str = if !haskey(kwargs, :backend)
        pretty_table(String, data; backend = :typst, kwargs...)
    else
        pretty_table(String, data; kwargs...)
    end

    return Typst(TypstText(str))
end

end