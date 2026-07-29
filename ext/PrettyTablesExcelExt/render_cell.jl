## Description #############################################################################
#
# Functions to render the table cells in the Excel back end.
#
############################################################################################

# Renderers supported by the Excel back end. Notice that every `_excel__render_cell` method
# must annotate its renderer argument with this exact type so that the dispatch is decided
# solely by the cell type. Otherwise, we would introduce method ambiguities.
const _EXCEL__RENDERER = Union{Val{:print}, Val{:show}}

"""
    _excel__render_cell(cell::Any, context::IOContext, renderer::Union{Val{:print}, Val{:show}}) -> Union{Missing, Bool, Int64, Float64, Dates.Date, Dates.DateTime, Dates.Time, AbstractString, XLSX.CellValue}

Render the `cell` in the Excel back end. If the cell type is supported natively by Excel, we
return a value that Excel can store as such, that is, a value of type `Missing`, `Bool`,
`Int64`, `Float64`, `Dates.Date`, `Dates.DateTime`, `Dates.Time`, `AbstractString`, or
`XLSX.CellValue`. Integers and floating point numbers of any width are converted to `Int64`
and `Float64`, respectively, so that they remain numeric values in the spreadsheet.
Otherwise, we convert the cell to a `String` using the `renderer` and the IO `context`.
"""
function _excel__render_cell(
    cell::Union{
        Missing,
        XLSX.Dates.Date,
        XLSX.Dates.DateTime,
        XLSX.Dates.Time,
        AbstractString,
        XLSX.CellValue,
    },
    ::IOContext,
    ::_EXCEL__RENDERER,
)
    return cell
end

function _excel__render_cell(cell::Bool, ::IOContext, ::_EXCEL__RENDERER)
    return cell
end

# Any integer or floating point number must be widened to the types Excel supports natively.
# Otherwise, for example, an `Int32` would be written as text, losing the right alignment and
# becoming unusable in formulas. Notice that this is critical on 32-bit platforms, where
# `Int === Int32`.
function _excel__render_cell(cell::Integer, ::IOContext, ::_EXCEL__RENDERER)
    return Int64(cell)
end

function _excel__render_cell(cell::AbstractFloat, ::IOContext, ::_EXCEL__RENDERER)
    return Float64(cell)
end

# `nothing` must lead to a blank cell, exactly like `missing`.
function _excel__render_cell(::Nothing, ::IOContext, ::_EXCEL__RENDERER)
    return missing
end

function _excel__render_cell(
    cell::MergeCells,
    context::IOContext,
    renderer::_EXCEL__RENDERER,
)
    return _excel__render_cell(cell.data, context, renderer)
end

function _excel__render_cell(cell::Any, context::IOContext, renderer::_EXCEL__RENDERER)
    return _excel__cell_to_str(cell, context, renderer)
end

"""
    _excel__cell_to_str(cell::Any, context::IOContext, renderer::Union{Val{:print}, Val{:show}}) -> String

Convert `cell` to a `String` using `renderer` and the IO `context`. Notice that this function
must not be called directly; use [`_excel__render_cell`](@ref) instead.
"""
function _excel__cell_to_str(cell::Any, context::IOContext, ::Val{:print})
    return sprint(print, cell; context)
end

function _excel__cell_to_str(cell::Any, context::IOContext, ::Val{:show})
    return sprint(show, MIME("text/plain"), cell; context)
end
