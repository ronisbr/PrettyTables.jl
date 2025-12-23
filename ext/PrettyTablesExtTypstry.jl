module PrettyTablesExtTypstry

using PrettyTables
using Typstry
function pretty_table(::Type{HTML}, @nospecialize(data::Any); kwargs...)
    # If the keywords does not set the back end or the table format, use the HTML back end
    # by default.
    str = if !haskey(kwargs, :backend) && !haskey(kwargs, :table_format)
        pretty_table(String, data; backend = :html, kwargs...)
    else
        pretty_table(String, data; kwargs...)
    end

    return HTML(str)
end

function pretty_table(::Type{Typstry}, pt::PrettyTable; kwargs...)
    # Get the named tuple with the configurations.
    dictkeys = (collect(keys(pt.configurations))...,)
    dictvals = (collect(values(pt.configurations))...,)
    nt = NamedTuple{dictkeys}(dictvals)

    return pretty_table(String, pt.data; color = color, merge(nt, kwargs)...)
end





end