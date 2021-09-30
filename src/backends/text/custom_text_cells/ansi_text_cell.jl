

export ANSITextCell


Base.@kwdef mutable struct ANSITextCell <: CustomTextCell
    renderfn
    context = ()

    # Private
    _rendered = nothing
    _stripped = nothing
    _crops = Dict{Int, Int}()
    _left_pads = Dict{Int, Int}()
    _right_pads = Dict{Int, Int}()
    _suffixes = Dict{Int, String}()
end

ANSITextCell(renderfn) = ANSITextCell(renderfn=renderfn)

function PrettyTables.reset!(cell::ANSITextCell)
    cell._rendered = nothing
    cell._stripped = nothing
    cell._crops = Dict{Int, Int}()
    cell._left_pads = Dict{Int, Int}()
    cell._right_pads = Dict{Int, Int}()
    cell._suffixes = Dict{Int, String}()
end


function get_printable_cell_line(cell::ANSITextCell, l::Int)
    if l > length(cell._stripped)
        return ""
    else
        lpad, rpad = get(cell._left_pads, l, 0), get(cell._right_pads, l, 0)
        return " "^lpad * cell._stripped[l] * " "^rpad
    end
end


function get_rendered_line(cell::ANSITextCell, l::Int)
    if l > length(cell._stripped)
        return ""
    else
        lpad, rpad = get(cell._left_pads, l, 0), get(cell._right_pads, l, 0)
        suffix = get(cell._suffixes, l, "")
        return " "^lpad * cell._rendered[l] * " "^rpad * suffix
    end
end

function parse_cell_text(cell::ANSITextCell; kwargs...)
    io = IOBuffer()
    cell.renderfn(IOContext(io, cell.context...))
    rendered = String(take!(io))
    cell._rendered = map(String, split(rendered, '\n'))
    cell._stripped = map(_stripansi, cell._rendered)
    return cell._stripped
end


function append_suffix_to_line!(cell::ANSITextCell, l::Int, suffix::String)
    cell._suffixes[l] = get(cell._suffixes, l, "") * suffix
    return nothing
end

function apply_line_padding!(cell::ANSITextCell, l::Int, left_pad::Int, right_pad::Int)
    cell._left_pads[l] = get(cell._left_pads, l, 0) + left_pad
    cell._right_pads[l] = get(cell._right_pads, l, 0) + right_pad
    return nothing
end

function crop_line!(cell::ANSITextCell, l::Int, num::Int)
    l > length(cell._rendered) && return

    stripped = cell._stripped[l]
    rendered = cell._rendered[l]
    crop = length(stripped) - num
    cell._rendered[l] = _cropansi(rendered, crop)

    return nothing
end




"""
    _stripansi(str)

Strips all ANSI escape sequences from a string.
"""
function _stripansi(str::AbstractString)
    r_ansi_escape = r"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])"
    return replace(str, r_ansi_escape => "")
end

"""
    _cropansi(s, n)

Crops an ANSI string to `n` visible characters. Trailing ANSI sequences
are removed.
"""
_cropansi(s::AbstractString, n) = _crop_str(s, n) * "\e[0m"
