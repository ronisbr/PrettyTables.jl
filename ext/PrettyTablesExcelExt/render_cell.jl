## Description #############################################################################
#
# Functions to render the table cells in excel end.
#
############################################################################################

"""
    _excel__render_cell(cell::Ts, renderer::Union{Val{:print}, Val{:show}}) -> Ts
    _excel__render_cell(cell::Any, renderer::Union{Val{:print}, Val{:show}}) -> String

Render the `cell` in excel back end. If the cell type `Ts` is
supported by Excel, we will return the cell itself. In this case,
`Ts <: Union{Missing, Bool, Float64, Int64, Dates.Date, Dates.DateTime, Dates.Time, String}`
or `Ts <: XLSX.CellValue`. Otherwise, we will convert it to a string using the `renderer`.
"""
function _excel__render_cell(
    cell::Union{
        Missing,
        Bool,
        Float64,
        Int64,
        XLSX.Dates.Date,
        XLSX.Dates.DateTime,
        XLSX.Dates.Time,
        AbstractString,
        XLSX.CellValue,
    },
    ::Union{Val{:print}, Val{:show}},
)
    return cell
end

function _excel__render_cell(cell::MergeCells, renderer::Union{Val{:print}, Val{:show}})
    return _excel__render_cell(cell.data, renderer)
end

function _excel__render_cell(cell::Any, renderer::Union{Val{:print}, Val{:show}})
    return renderer isa Val{:print} ? sprint(show, cell) :
           sprint(show, MIME("text/plain"), cell)
end
