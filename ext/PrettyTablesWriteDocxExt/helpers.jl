## Description #############################################################################
#
# Word Back End: Helpers for building tables.
#
############################################################################################

# Border of a cell side that must not be drawn. It must never be mutated.
const _DOCX__NO_BORDER = DocxPair[]

# Font size [pt] used by Word when neither the document nor the decoration defines one. It is
# only used to estimate the column widths.
const _DOCX__DEFAULT_FONT_SIZE = 10.0

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

    # Notice that we must search the instances instead of checking whether `style` is
    # defined in the enum module. Otherwise, names like `T`, which is the enum type, would be
    # accepted.
    for s in instances(W.BorderStyle.T)
        (Symbol(s) === style) && return s
    end

    throw(
        ArgumentError(
            "\"$name\" is not a valid Word border style. See `WriteDocx.BorderStyle`."
        ),
    )
end

"""
    _docx__underline_pattern(name::String) -> W.UnderlinePattern.T

Convert the underline pattern `name` of a [`DocxPair`](@ref) to the Word underline pattern.
"""
function _docx__underline_pattern(name::String)
    pattern = Symbol(name)

    # See the note in `_docx__border_style`.
    for p in instances(W.UnderlinePattern.T)
        (Symbol(p) === pattern) && return p
    end

    throw(
        ArgumentError(
            "\"$name\" is not a valid Word underline pattern. See `WriteDocx.UnderlinePattern`."
        ),
    )
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
    _docx__is_valid_char(c::Char) -> Bool

Return `true` if the character `c` can be written in a Word document, *i.e.*, if it is
allowed in XML 1.0, or `false` otherwise. Notice that the carriage return is also rejected
because the line breaks are represented by the line feed.
"""
function _docx__is_valid_char(c::Char)
    isvalid(c) || return false

    return (c == '\t') ||
        (c == '\n') ||
        ('\x20' <= c <= '\ud7ff') ||
        ('\ue000' <= c <= '\ufffd') ||
        ('\U10000' <= c <= '\U10ffff')
end

"""
    _docx__sanitize_text(text::String) -> String

Remove from `text` the ANSI escape sequences and the characters that cannot be written in a
Word document (see [`_docx__is_valid_char`](@ref)). Otherwise, the XML library would either
throw an error (null character) or replace them with the replacement character.
"""
function _docx__sanitize_text(text::String)
    all(_docx__is_valid_char, text) && return text
    return filter(_docx__is_valid_char, remove_decorations(text))
end

"""
    _docx__runs(cell::DocxCell) -> Vector{W.Run}

Convert the runs of `cell` to Word text runs, merging the decoration of each run with the
one of the cell. Notice that the latter, which contains the section style and the
highlighter decoration, takes precedence as in the Excel back end. A line break inside the text of a run becomes a Word line break so that
the entire cell content stays in one paragraph, and a tab becomes a Word tab. The text is
sanitized with [`_docx__sanitize_text`](@ref).
"""
function _docx__runs(cell::DocxCell)
    runs = W.Run[]

    for r in cell.runs
        # The last occurrence of an attribute wins. Hence, the cell decoration must come
        # after the run decoration.
        decoration = if isempty(r.decoration)
            cell.decoration
        else
            vcat(r.decoration, cell.decoration)
        end

        properties = _docx__run_properties(decoration, r.superscript)
        children   = Any[]

        for (k, line) in enumerate(eachsplit(_docx__sanitize_text(r.text), '\n'))
            (k > 1) && push!(children, W.Break())

            for (l, segment) in enumerate(eachsplit(line, '\t'))
                (l > 1) && push!(children, W.Tab())
                isempty(segment) || push!(children, W.Text(String(segment)))
            end
        end

        push!(runs, W.Run(children, properties))
    end

    return runs
end

"""
    _docx__table_cell(cell::DocxCell, width::Union{Nothing, W.Length}) -> W.TableCell

Convert `cell` to a Word table cell with `width`. If `width` is `nothing`, Word decides the
width of the cell.
"""
function _docx__table_cell(cell::DocxCell, width::Union{Nothing, W.Length})
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
        width,
        borders,
        shading  = _docx__shading(cell.decoration),
        valign   = _docx__valign(cell.valign),
        gridspan = cell.gridspan > 1 ? cell.gridspan : nothing,
    )
end

"""
    _docx__table(rows::Vector{DocxRow}, cell_margins::NTuple{4, Float64}, column_widths::Vector{Float64}, fixed_layout::Bool) -> W.Table

Convert the accumulated `rows` to a Word table, applying `cell_margins`, in points, to every
cell. `column_widths` contains the width of each table column in points and it is written as
the table grid.

If `fixed_layout` is `true`, Word lays the columns out exactly at `column_widths`. Hence, the
width of the table and of each cell are also set to the ones computed from `column_widths`.
Otherwise, Word adjusts the columns to the content, using the grid only as the initial
widths.
"""
function _docx__table(
    rows::Vector{DocxRow},
    cell_margins::NTuple{4, Float64},
    column_widths::Vector{Float64},
    fixed_layout::Bool,
)
    table_rows = map(rows) do row
        cells = W.TableCell[]
        col   = 1

        for cell in row.cells
            last_col = min(col + cell.gridspan - 1, length(column_widths))

            width = if fixed_layout && (col <= last_col)
                sum(@view column_widths[col:last_col]) * W.pt
            else
                nothing
            end

            push!(cells, _docx__table_cell(cell, width))
            col += cell.gridspan
        end

        return W.TableRow(cells; header = row.header ? true : nothing)
    end

    top, start, bottom, stop = map(m -> m * W.pt, cell_margins)

    return W.Table(
        table_rows;
        grid    = W.Point[w * W.pt for w in column_widths],
        layout  = fixed_layout ? W.TableLayout.fixed : nothing,
        margins = W.TableLevelCellMargins(; top, start, bottom, stop),
        width   = fixed_layout ? sum(column_widths; init = 0.0) * W.pt : nothing,
    )
end

############################################################################################
#                                      Column Widths                                       #
############################################################################################

"""
    _docx__data_column_widths(widths::Union{Real, AbstractVector{<:Real}}, num_columns::Int) -> Vector{Float64}

Convert `widths` to a vector with the width of each of the `num_columns` data columns. A
scalar applies to all columns. Notice that the length of a vector must be checked before
calling this function.
"""
function _docx__data_column_widths(widths::Real, num_columns::Int)
    return fill(Float64(widths), num_columns)
end

function _docx__data_column_widths(widths::AbstractVector{<:Real}, ::Int)
    return collect(Float64, widths)
end

"""
    _docx__font_size(decoration::Vector{DocxPair}, fallback::Float64) -> Float64

Return the font size, in points, defined by the last `"size"` attribute in `decoration`, or
`fallback` if there is none.
"""
function _docx__font_size(decoration::Vector{DocxPair}, fallback::Float64)
    size = fallback

    for (k, v) in decoration
        (k == "size") && (size = parse(Float64, v))
    end

    return size
end

"""
    _docx__text_width(text::AbstractString, font_size::Float64) -> Float64

Estimate the width, in points, of the single-line `text` rendered with `font_size` points.
"""
function _docx__text_width(text::AbstractString, font_size::Float64)
    # Empirical approximation of the average character width of the proportional fonts,
    # equal to the one used by the Excel back end.
    return 0.55 * textwidth(text) * font_size
end

"""
    _docx__cell_width(cell::DocxCell, padding::Float64) -> Float64

Estimate the width, in points, required to display the content of `cell` in a single line
per line break, adding `padding`, which must contain the horizontal cell margins.
"""
function _docx__cell_width(cell::DocxCell, padding::Float64)
    cell_font_size = _docx__font_size(cell.decoration, 0.0)
    max_width      = 0.0
    line_width     = 0.0

    for r in cell.runs
        # The cell decoration takes precedence over the run decoration.
        font_size = if cell_font_size > 0
            cell_font_size
        else
            _docx__font_size(r.decoration, _DOCX__DEFAULT_FONT_SIZE)
        end

        for (k, line) in enumerate(eachsplit(r.text, '\n'))
            if k > 1
                max_width  = max(max_width, line_width)
                line_width = 0.0
            end

            line_width += _docx__text_width(line, font_size)
        end
    end

    return max(max_width, line_width) + padding
end

"""
    _docx__get_col_width(col::Int, max_col_length::Vector{Float64}, num_leading_columns::Int, num_printed_data_columns::Int, data_column_widths::AbstractVector{Float64}, minimum_data_column_widths::AbstractVector{Float64}, maximum_data_column_widths::AbstractVector{Float64}) -> Float64

Resolve the width, in points, of the table column `col`. The columns that are not data
columns (row number, row label, and continuation columns) keep the estimated width in
`max_col_length`. For the data columns, a positive entry in `data_column_widths` takes
precedence; otherwise the estimated width is clamped between the corresponding entries of
`minimum_data_column_widths` and `maximum_data_column_widths` (values ≤ 0 are ignored).
"""
function _docx__get_col_width(
    col::Int,
    max_col_length::Vector{Float64},
    num_leading_columns::Int,
    num_printed_data_columns::Int,
    data_column_widths::AbstractVector{Float64},
    minimum_data_column_widths::AbstractVector{Float64},
    maximum_data_column_widths::AbstractVector{Float64},
)
    j = col - num_leading_columns

    # Do not limit the columns that are not data columns.
    !(1 <= j <= num_printed_data_columns) && return max_col_length[col]

    # A positive explicit width overrides everything.
    dw = data_column_widths[j]
    dw > 0 && return dw

    # Clamp the estimated width between the minimum and the maximum.
    col_width = max_col_length[col]

    min_w = minimum_data_column_widths[j]
    min_w > 0 && (col_width = max(col_width, min_w))

    max_w = maximum_data_column_widths[j]
    max_w > 0 && (col_width = min(col_width, max_w))

    return col_width
end

"""
    _docx__document(table::W.Table) -> W.Document

Return a Word document with a single section containing `table`.
"""
function _docx__document(table::W.Table)
    return W.Document(W.Body([W.Section([table])]))
end
