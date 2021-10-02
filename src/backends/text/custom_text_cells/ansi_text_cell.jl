# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Text cell with ANSI escape sequences.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export AnsiTextCell

"""
    AnsiTextCell(renderfn[; context]) <: CustomTextCell

A text cell that supports rendering ANSI escape sequences without interfering
with the table layout.

`renderfn` is a function with the following signature:

    renderfn(io)::String

that renders a string that can contain ANSI sequences into `io`.

`context` is a tuple of context arguments passed to an `IOContext` that
`renderfn` receives. See [`IOContext`](@ref) for details on what arguments are
available.

Useful for supporting packages that have rich terminal outputs.

## Examples

Below are examples for wrappers around `AnsiTextCell` to print rich data into
tables that make use of packages with rich terminal output.

### ImageInTerminal.jl

Show images inside a table.

```julia
using ImageInTerminal, PrettyTables

function ImageCell(img, size)
    return AnsiTextCell(
        io -> ImageInTerminal.imshow(io, img),
        context = (:displaysize => size,),)
end

using TestImages
img = testimage("lighthouse")
pretty_table([ImageCell(img, (20, 20)) ImageCell(img, (40, 40))])
```

### UnicodePlots.jl

Show a variety of plots in a table.

```julia
using UnicodePlots, PrettyTables

function UnicodePlotCell(p)
    return AnsiTextCell(
        io -> show(io, p),
        context = (:color => true,)
    )
end

pretty_table([
    UnicodePlotCell(barplot(Dict("x" => 10, "y" => 20)))
    UnicodePlotCell(boxplot([1, 3, 3, 4, 6, 10]))
])
```

### CommonMark.jl

Use rich Markdown inside tables.

```julia
using CommonMark, PrettyTables

function MarkdownCell(md)
    return AnsiTextCell(
        renderfn = io -> display(TextDisplay(io), md),
        context = (:color => true,)
    )
end

pretty_table([MarkdownCell(cm"**Hi**") MarkdownCell(cm"> quote")])
```
"""
mutable struct AnsiTextCell <: CustomTextCell
    renderfn
    context

    # Private
    _rendered
    _stripped
    _crops
    _left_pads
    _right_pads
    _suffixes
end

function AnsiTextCell(
    renderfn;
    context = ()
)
    return AnsiTextCell(
        renderfn,
        context,
        nothing,
        nothing,
        Dict{Int, Int}(),
        Dict{Int, Int}(),
        Dict{Int, Int}(),
        Dict{Int, String}()
    )
end

function PrettyTables.reset!(cell::AnsiTextCell)
    cell._rendered   = nothing
    cell._stripped   = nothing
    cell._crops      = Dict{Int, Int}()
    cell._left_pads  = Dict{Int, Int}()
    cell._right_pads = Dict{Int, Int}()
    cell._suffixes   = Dict{Int, String}()
end

function get_printable_cell_line(cell::AnsiTextCell, l::Int)
    if l > length(cell._stripped)
        return ""
    else
        lpad, rpad = get(cell._left_pads, l, 0), get(cell._right_pads, l, 0)
        return " "^lpad * cell._stripped[l] * " "^rpad
    end
end

function get_rendered_line(cell::AnsiTextCell, l::Int)
    if l > length(cell._stripped)
        return ""
    else
        lpad, rpad = get(cell._left_pads, l, 0), get(cell._right_pads, l, 0)
        suffix = get(cell._suffixes, l, "")
        return " "^lpad * cell._rendered[l] * " "^rpad * suffix
    end
end

function parse_cell_text(cell::AnsiTextCell; kwargs...)
    io = IOBuffer()
    cell.renderfn(IOContext(io, cell.context...))
    rendered = String(take!(io))
    cell._rendered = filter(!isempty, map(String, split(rendered, '\n')))
    cell._stripped = map(_stripansi, cell._rendered)
    return cell._stripped
end

function append_suffix_to_line!(cell::AnsiTextCell, l::Int, suffix::String)
    cell._suffixes[l] = get(cell._suffixes, l, "") * suffix
    return nothing
end

function apply_line_padding!(cell::AnsiTextCell, l::Int, left_pad::Int, right_pad::Int)
    cell._left_pads[l] = get(cell._left_pads, l, 0) + left_pad
    cell._right_pads[l] = get(cell._right_pads, l, 0) + right_pad
    return nothing
end

function crop_line!(cell::AnsiTextCell, l::Int, num::Int)
    l > length(cell._rendered) && return nothing

    stripped = cell._stripped[l]
    rendered = cell._rendered[l]
    length(stripped) == 0 && return nothing
    crop = length(stripped) - num
    crop < 0 && return nothing
    cell._rendered[l] = _cropansi(rendered, crop; lstr = textwidth(rendered))

    return nothing
end

################################################################################
#                              Private functions
################################################################################

"""
    _stripansi(str)

Strip all ANSI escape sequences from a string.
"""
function _stripansi(str::AbstractString)
    r_ansi_escape = r"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])"
    return replace(str, r_ansi_escape => "")
end

"""
    _cropansi(s, n)

Crop an ANSI string to `n` visible characters. Trailing ANSI sequences are
removed.
"""
_cropansi(s::AbstractString, n; lstr = -1) = _crop_str(s, n, lstr) * "\e[0m"
