## Description #############################################################################
#
# Word Back End: Helpers for building tables.
#
############################################################################################

# Border of a cell side that must not be drawn. It must never be mutated.
const _DOCX__NO_BORDER = DocxPair[]

"""
    struct DocxRun

One text run of a cell, with the `decoration` that applies to it in addition to the
decoration of the cell. `superscript` is `true` for the footnote markers.
"""
struct DocxRun
    text::String
    decoration::Vector{DocxPair}
    superscript::Bool
end

DocxRun(text::AbstractString) = DocxRun(String(text), _DOCX__NO_DECORATION, false)

"""
    mutable struct DocxCell

Cell of the Word table being built. The fields are mutated while the printing iterator
walks the table because the borders of a cell are only known after its row and column are
complete.
"""
mutable struct DocxCell
    runs::Vector{DocxRun}
    alignment::Symbol
    valign::Symbol
    decoration::Vector{DocxPair}
    gridspan::Int
    top::Vector{DocxPair}
    bottom::Vector{DocxPair}
    left::Vector{DocxPair}
    right::Vector{DocxPair}
end

function DocxCell(
    runs::Vector{DocxRun},
    alignment::Symbol,
    valign::Symbol,
    decoration::Vector{DocxPair};
    gridspan::Int = 1,
)
    return DocxCell(
        runs,
        alignment,
        valign,
        decoration,
        gridspan,
        _DOCX__NO_BORDER,
        _DOCX__NO_BORDER,
        _DOCX__NO_BORDER,
        _DOCX__NO_BORDER,
    )
end

"""
    mutable struct DocxRow

Row of the Word table being built. `content` is `false` for the rows of the table header and
footer (title, subtitle, footnotes, and source notes), which are not enclosed by the outer
borders of the table.
"""
mutable struct DocxRow
    cells::Vector{DocxCell}
    content::Bool
    header::Bool
end

DocxRow(content::Bool) = DocxRow(DocxCell[], content, false)

############################################################################################
#                                   Conversion Helpers                                     #
############################################################################################

"""
    _docx__hex_color(value::String) -> W.HexColor

Convert the color `value` of a [`DocxPair`](@ref) to a `WriteDocx.HexColor`. Besides the
6-digit hexadecimal string, with or without the leading `#`, the color names supported by
Crayons.jl are also accepted.
"""
function _docx__hex_color(value::String)
    hex = startswith(value, '#') ? value[2:end] : value

    if length(hex) == 6 && all(isxdigit, hex)
        return W.HexColor(uppercase(hex))
    end

    face      = _face_from_kwargs(; foreground = Symbol(value))
    named_hex = _face_color_hex(face.foreground; uppercase = true)

    isnothing(named_hex) && throw(
        ArgumentError(
            "The color \"$value\" is neither a 6-digit hexadecimal string nor a known color name."
        ),
    )

    return W.HexColor(named_hex)
end

"""
    _docx__parse_bool(value::String) -> Bool

Convert the `value` of a boolean [`DocxPair`](@ref) to a `Bool`.
"""
function _docx__parse_bool(value::String)
    (value == "true") && return true
    (value == "false") && return false

    throw(ArgumentError("The value \"$value\" must be either \"true\" or \"false\"."))
end

"""
    _docx__justification(alignment::Symbol) -> W.Justification.T

Convert the `alignment` of a cell to the Word justification.
"""
function _docx__justification(alignment::Symbol)
    (alignment == :r) && return W.Justification.stop
    (alignment == :c) && return W.Justification.center

    # Return the left justification for `:l` or any other value.
    return W.Justification.start
end

"""
    _docx__valign(valign::Symbol) -> W.VerticalAlign.T

Convert the vertical alignment `valign` of a cell to the Word vertical alignment.
"""
function _docx__valign(valign::Symbol)
    (valign == :bottom) && return W.VerticalAlign.bottom
    (valign == :center) && return W.VerticalAlign.center

    return W.VerticalAlign.top
end

"""
    _docx__border_style(name::String) -> W.BorderStyle.T

Convert the border style `name` of a [`DocxPair`](@ref) to the Word border style.
"""
function _docx__border_style(name::String)
    style = Symbol(name)

    isdefined(W.BorderStyle, style) || throw(
        ArgumentError(
            "\"$name\" is not a valid Word border style. See `WriteDocx.BorderStyle`."
        ),
    )

    return getproperty(W.BorderStyle, style)::W.BorderStyle.T
end

"""
    _docx__underline_pattern(name::String) -> W.UnderlinePattern.T

Convert the underline pattern `name` of a [`DocxPair`](@ref) to the Word underline pattern.
"""
function _docx__underline_pattern(name::String)
    pattern = Symbol(name)

    isdefined(W.UnderlinePattern, pattern) || throw(
        ArgumentError(
            "\"$name\" is not a valid Word underline pattern. See `WriteDocx.UnderlinePattern`."
        ),
    )

    return getproperty(W.UnderlinePattern, pattern)::W.UnderlinePattern.T
end

"""
    _docx__border(border::Vector{DocxPair}) -> Union{Nothing, W.TableCellBorder}

Convert `border` to a `WriteDocx.TableCellBorder`, returning `nothing` if `border` is empty,
meaning that the line must not be drawn.
"""
function _docx__border(border::Vector{DocxPair})
    isempty(border) && return nothing

    style = W.BorderStyle.single
    size  = nothing
    color = nothing

    for (k, v) in border
        if k == "style"
            style = _docx__border_style(v)
        elseif k == "size"
            size = parse(Float64, v) * W.eighthpt
        elseif k == "color"
            color = _docx__hex_color(v)
        else
            throw(ArgumentError("\"$k\" is not a valid Word border attribute."))
        end
    end

    return W.TableCellBorder(; style, size, color)
end

"""
    _docx__run_properties(decoration::Vector{DocxPair}, superscript::Bool) -> W.RunProperties

Convert `decoration` to the properties of a Word text run. The `"background"` attribute is
ignored because it is applied to the cell (see `_docx__shading`).
"""
function _docx__run_properties(decoration::Vector{DocxPair}, superscript::Bool)
    bold      = nothing
    italic    = nothing
    strike    = nothing
    underline = nothing
    color     = nothing
    size      = nothing
    fonts     = nothing

    for (k, v) in decoration
        if k == "bold"
            bold = _docx__parse_bool(v)
        elseif k == "italic"
            italic = _docx__parse_bool(v)
        elseif k == "strike"
            strike = _docx__parse_bool(v)
        elseif k == "underline"
            underline = W.Underline(; pattern = _docx__underline_pattern(v))
        elseif k == "color"
            color = _docx__hex_color(v)
        elseif k == "size"
            size = parse(Float64, v) * W.pt
        elseif k == "font"
            fonts = W.Fonts(v)
        elseif k == "background"
            continue
        else
            throw(ArgumentError("\"$k\" is not a valid Word style attribute."))
        end
    end

    valign = superscript ? W.VerticalAlignment.superscript : nothing

    return W.RunProperties(;
        bold, italic, strike, underline, color, size, fonts, valign
    )
end

"""
    _docx__shading(decoration::Vector{DocxPair}) -> Union{Nothing, W.Shading}

Return the shading described by the `"background"` attribute of `decoration`, or `nothing`
if it has none.
"""
function _docx__shading(decoration::Vector{DocxPair})
    background = nothing

    # The last occurrence wins so that a highlighter overrides the style of the section.
    for (k, v) in decoration
        (k == "background") && (background = v)
    end

    isnothing(background) && return nothing

    return W.Shading(;
        pattern = W.ShadingPattern.clear,
        fill    = _docx__hex_color(background),
        color   = W.automatic,
    )
end

"""
    _docx__runs(cell::DocxCell) -> Vector{W.Run}

Convert the runs of `cell` to Word text runs, merging the decoration of the cell with the
one of each run. A line break inside the text of a run becomes a Word line break so that
the entire cell content stays in one paragraph.
"""
function _docx__runs(cell::DocxCell)
    runs = W.Run[]

    for r in cell.runs
        decoration = if isempty(r.decoration)
            cell.decoration
        else
            vcat(cell.decoration, r.decoration)
        end

        properties = _docx__run_properties(decoration, r.superscript)
        children   = Any[]

        for (k, line) in enumerate(eachsplit(r.text, '\n'))
            (k > 1) && push!(children, W.Break())
            isempty(line) || push!(children, W.Text(String(line)))
        end

        push!(runs, W.Run(children, properties))
    end

    return runs
end

"""
    _docx__table_cell(cell::DocxCell) -> W.TableCell

Convert `cell` to a Word table cell.
"""
function _docx__table_cell(cell::DocxCell)
    paragraph = W.Paragraph(
        _docx__runs(cell);
        justification = _docx__justification(cell.alignment)
    )

    top    = _docx__border(cell.top)
    bottom = _docx__border(cell.bottom)
    start  = _docx__border(cell.left)
    stop   = _docx__border(cell.right)

    borders = if all(isnothing, (top, bottom, start, stop))
        nothing
    else
        W.TableCellBorders(; top, bottom, start, stop)
    end

    return W.TableCell(
        [paragraph];
        borders,
        shading  = _docx__shading(cell.decoration),
        valign   = _docx__valign(cell.valign),
        gridspan = cell.gridspan > 1 ? cell.gridspan : nothing,
    )
end

"""
    _docx__table(rows::Vector{DocxRow}, cell_margins::NTuple{4, Float64}) -> W.Table

Convert the accumulated `rows` to a Word table, applying `cell_margins`, in points, to every
cell.
"""
function _docx__table(rows::Vector{DocxRow}, cell_margins::NTuple{4, Float64})
    table_rows = map(rows) do row
        return W.TableRow(
            map(_docx__table_cell, row.cells);
            header = row.header ? true : nothing,
        )
    end

    top, start, bottom, stop = map(m -> m * W.pt, cell_margins)

    return W.Table(
        table_rows;
        margins = W.TableLevelCellMargins(; top, start, bottom, stop)
    )
end

"""
    _docx__document(table::W.Table) -> W.Document

Return a Word document with a single section containing `table`.
"""
function _docx__document(table::W.Table)
    return W.Document(W.Body([W.Section([table])]))
end
