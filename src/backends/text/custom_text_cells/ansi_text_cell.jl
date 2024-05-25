## Description #############################################################################
#
# Text cell with ANSI escape sequences.
#
############################################################################################

export AnsiTextCell

"""
    AnsiTextCell

A text cell that supports rendering ANSI escape sequences without interfering with the table
layout.

# Fields

**Public**

- `string::String`: The string with the cell text that can contain ANSI escape sequences.

**Private**

- `_rendered_lines::Union{Nothing, Vector{String}}`: The lines with the rendered strings.
- `_stripped_lines::Union{Nothing, Vector{String}}`: The lines with the printable text.
- `_crops::Union{Nothing, Vector{Int}}`: Vector with the number of characters that must be
    cropped at each line.
- `_left_pads::Union{Nothing, Vector{Int}}`: Left padding to be applied to each line.
- `_right_pads::Union{Nothing, Vector{Int}}`: Right padding to be applied to each line.
- `_suffixes::Union{Nothing, Vector{String}}`: Suffixed to be applied to each line.
"""
mutable struct AnsiTextCell <: CustomTextCell
    string::String

    # Private
    _rendered_lines::Union{Nothing, Vector{String}}
    _stripped_lines::Union{Nothing, Vector{String}}
    _crops::Union{Nothing, Vector{Int}}
    _left_pads::Union{Nothing, Vector{Int}}
    _right_pads::Union{Nothing, Vector{Int}}
    _suffixes::Union{Nothing, Vector{String}}
end

"""
    AnsiTextCell(string::AbstractString)

Create an [`AnsiTextCell`](@ref) using `string`.

    AnsiTextCell(renderfn[; context])

Create an [`AnsiTextCell`](@ref) using a render function.

`renderfn` is a function with the following signature:

    renderfn(io)::String

that renders a string that can contain ANSI sequences into `io`.

`context` is a tuple of context arguments passed to an `IOContext` that `renderfn` receives.
See `IOContext` for details on what arguments are available.

Useful for supporting packages that have rich terminal outputs.

## Examples

Below are examples for wrappers around `AnsiTextCell` to print rich data into tables that
make use of packages with rich terminal output.

### Crayons.jl

Apply custom decoration to text inside a cell.

```julia
using Crayons, PrettyTables

b = crayon"blue bold"
y = crayon"yellow bold"
g = crayon"green bold"

pretty_table([AnsiTextCell("\$(g)This \$(y)is \$(b)awesome!") for _ in 1:5, _ in 1:5])
```

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
function AnsiTextCell(string::AbstractString)
    return AnsiTextCell(
        string,
        nothing,
        nothing,
        nothing,
        nothing,
        nothing,
        nothing
    )
end

function AnsiTextCell(renderfn::Function; context::Tuple = ())
    # Render the text and create the text cell.
    io = IOBuffer()
    renderfn(IOContext(io, context...))
    rendered = String(take!(io))
    return AnsiTextCell(rendered)
end

############################################################################################
#                                           API                                            #
############################################################################################

function get_printable_cell_line(cell::AnsiTextCell, l::Int)
    cell_stripped_lines = cell._stripped_lines
    isnothing(cell_stripped_lines) && return ""

    if l > length(cell_stripped_lines)
        return ""
    else
        cell_crops          = cell._crops
        cell_left_pads      = cell._left_pads
        cell_right_pads     = cell._right_pads
        cell_stripped_lines = cell._stripped_lines
        cell_suffixes       = cell._suffixes

        if isnothing(cell_crops) ||
            isnothing(cell_left_pads) ||
            isnothing(cell_right_pads) ||
            isnothing(cell_stripped_lines) ||
            isnothing(cell_suffixes)
            return ""
        end

        lpad   = cell_left_pads[l]
        rpad   = cell_right_pads[l]
        line   = " "^lpad * cell_stripped_lines[l] * " "^rpad
        suffix = cell_suffixes[l]

        # Compute the total size of the string.
        line_width = lpad + textwidth(cell_stripped_lines[l]) + rpad

        # Return the cropped string.
        cropped_line = fit_string_in_field(
            line,
            line_width - cell_crops[l];
            add_continuation_char = false,
            printable_string_width = line_width
        )

        return cropped_line * suffix
    end
end

function get_rendered_line(cell::AnsiTextCell, l::Int)
    cell_stripped_lines = cell._stripped_lines
    isnothing(cell_stripped_lines) && return ""

    if l > length(cell_stripped_lines)
        return ""
    else
        cell_crops          = cell._crops
        cell_left_pads      = cell._left_pads
        cell_right_pads     = cell._right_pads
        cell_stripped_lines = cell._stripped_lines
        cell_rendered_lines = cell._rendered_lines
        cell_suffixes       = cell._suffixes

        if isnothing(cell_crops) ||
            isnothing(cell_left_pads) ||
            isnothing(cell_right_pads) ||
            isnothing(cell_stripped_lines) ||
            isnothing(cell_rendered_lines) ||
            isnothing(cell_suffixes)
            return ""
        end

        lpad   = cell_left_pads[l]
        rpad   = cell_right_pads[l]
        suffix = cell_suffixes[l]

        # Compute the total size of the string.
        line_width = lpad + textwidth(cell_stripped_lines[l]) + rpad

        # Create the rendered line.
        line = " "^lpad * cell_rendered_lines[l] * " "^rpad

        # Crop the rendered line. Notice that we can discard the remaining ANSI sequence
        # because we reset everything after printing the cell.
        cropped_line = fit_string_in_field(
            line,
            line_width - cell_crops[l];
            add_continuation_char = false,
            keep_ansi = false,
            printable_string_width = line_width
        )

        # We must reset everything after rendering the cell to avoid messing with the
        # decoration of the table.
        return cropped_line * "\e[0m" * suffix
    end
end

function append_suffix_to_line!(cell::AnsiTextCell, l::Int, suffix::String)
    cell_suffixes = cell._suffixes

    if !isnothing(cell_suffixes)
        cell_suffixes[l] *= suffix
    end

    return nothing
end

function apply_line_padding!(cell::AnsiTextCell, l::Int, left_pad::Int, right_pad::Int)
    cell_left_pads = cell._left_pads

    if !isnothing(cell_left_pads)
        cell_left_pads[l] += left_pad
    end

    cell_right_pads = cell._right_pads

    if !isnothing(cell_right_pads)
        cell_right_pads[l] += right_pad
    end

    return nothing
end

function crop_line!(cell::AnsiTextCell, l::Int, num::Int)
    cell_crops = cell._crops

    if !isnothing(cell_crops) && (num ≥ 0)
        cell_crops[l] += num
    end

    return nothing
end

function parse_cell_text(cell::AnsiTextCell; kwargs...)
    _rendered_lines = map(String, split(cell.string, '\n'))
    _stripped_lines = remove_decorations.(_rendered_lines)

    num_lines = length(_rendered_lines)

    cell._rendered_lines = _rendered_lines
    cell._stripped_lines = _stripped_lines
    cell._crops          = zeros(Int, num_lines)
    cell._left_pads      = zeros(Int, num_lines)
    cell._right_pads     = zeros(Int, num_lines)
    cell._suffixes       = fill("", num_lines)

    return cell._stripped_lines
end

function reset!(cell::AnsiTextCell)
    cell._rendered_lines = nothing
    cell._stripped_lines = nothing
    cell._crops          = nothing
    cell._left_pads      = nothing
    cell._right_pads     = nothing
    cell._suffixes       = nothing

    return nothing
end

