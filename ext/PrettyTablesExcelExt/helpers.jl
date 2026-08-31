## Description #############################################################################
#
# Excel Back End: Helpers for building tables.
#
############################################################################################

# Used when otherwise unspecified
const DEFAULT_FONT_SIZE = 12

# Unicode superscript digits for footnote references
const SUPERSCRIPT_DIGITS = ['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹']

"""
    _excel__alignment_string(s::Symbol) -> String

Convert the alignment symbol `s` to a string for use in `XLSX.setAlignment`.
"""
function _excel__alignment_string(s::Symbol)
    s == :r && return "right"
    s == :c && return "center"

    # Return "left" for `:l` or any other value.
    return "left"
end

"""
    _excel__unempty_row!(sheet::XLSX.Worksheet, row::Number, cols::UnitRange) -> Nothing

Ensure all cells of `sheet` inside the column range `cols` in `row` are not `XLSX.EmptyCell`
so that formatting applies correctly.
"""
function _excel__unempty_row!(sheet::XLSX.Worksheet, row::Number, cols::UnitRange)
    sheet[row, cols] = ""
    return nothing
end

"""
    _excel__to_superscript(n::Int) -> String

Convert the integer `n` to a superscript string using Unicode characters.
"""
function _excel__to_superscript(n::Int)
    return join(SUPERSCRIPT_DIGITS[parse(Int, c) + 1] for c in string(n))
end

"""
    _excel__append_superscript(cell::Any, fn_str::String) -> Union{String, XLSX.RichTextString}

Append the footnote superscript `fn_str` to the rendered `cell`. Rich text strings receive
the superscript as an additional unstyled run so the existing runs are preserved, whereas
any other value is converted to a `String` before the concatenation.
"""
_excel__append_superscript(cell::Any, fn_str::String) = string(cell) * fn_str

function _excel__append_superscript(cell::XLSX.RichTextString, fn_str::String)
    return cell * XLSX.RichTextString([XLSX.RichTextRun(fn_str, Pair{Symbol, Any}[])])
end

"""
    _excel__column_width_for_text(text_length::Number, font_size::Number) -> Number

Estimate the Excel column width needed to display text of `text_length` characters rendered
at `font_size`.
"""
function _excel__column_width_for_text(text_length::Number, font_size::Number)
    # Empirical approximation of Excel's column-width units for ASCII characters in the
    # default font, derived from a pixel-to-character ratio of 0.55/7 with a constant
    # padding of 2 for margins.
    return (0.55 * text_length * font_size) / 7 + 2
end

"""
    _excel__row_height_for_text(line_count::Number, font_size::Number) -> Number

Estimate the Excel row height needed to accommodate `line_count` lines of text rendered at
`font_size`.
"""
function _excel__row_height_for_text(line_count::Number, font_size::Number)
    # Standard Excel row height in points: line_count × (1.2 × font_size), plus a 3-point
    # padding that approximates the row margins Excel uses by default.
    return line_count * (font_size * 1.2) + 3
end

"""
    _excel__text_lines(text::Any) -> Number

Determine the number of lines in `text` by counting newline occurrences. If `text` is not a
string, returns 1.
"""
_excel__text_lines(text::AbstractString) = count('\n', text) + 1
_excel__text_lines(::Any) = 1

# Rich text strings do not support all the string operations used to compute the cell
# dimensions. Hence, we must convert them to `String` first.
_excel__text_lines(text::XLSX.RichTextString) = _excel__text_lines(String(text))

"""
    _excel__multilength(text::AbstractString) -> Number

Return the length of the longest line in the multi-line string `text`. If `text` is not a
string, returns 0.
"""
function _excel__multilength(text::AbstractString)
    return maximum(length, split(text, '\n'); init = 0)
end

_excel__multilength(::Any) = 0

# See the note in `_excel__text_lines` about rich text strings.
_excel__multilength(text::XLSX.RichTextString) = _excel__multilength(String(text))

"""
    fmt__excel_stringify(
        columns::Union{Nothing, Int, AbstractVector{Int}} = nothing
    ) -> Function

Create a formatter function that converts values XLSX.jl cannot handle directly into their
string representation. When `columns` is `nothing`, all values are stringified; otherwise
only the columns listed in `columns` are converted.
"""
function PrettyTables.fmt__excel_stringify(
    columns::Union{Nothing, Int, AbstractVector{Int}} = nothing
)
    return (v, _, j) -> begin
        (v isa XLSX.CellConcreteType) && return v

        isnothing(columns) && return string(v)

        j ∈ columns && return string(v)

        return v
    end
end

"""
    _excel__cell_length_and_height(text::Any, fontsize::Number) -> Tuple{Float64, Float64}

Notice that the returned tuple is `(row_height, col_length)`, in that order.

Compute the estimated Excel row height and column width for a cell containing `text`
rendered at `fontsize`.

# Returns

- `Tuple{Float64, Float64}`: `(row_height, col_length)` in Excel units. `col_length` is
    zero for non-string values.
"""
function _excel__cell_length_and_height(text::AbstractString, fontsize::Number)
    lines      = _excel__text_lines(text)
    col_length = _excel__column_width_for_text(_excel__multilength(text), fontsize)
    row_height = _excel__row_height_for_text(lines, fontsize)

    return row_height, col_length
end

function _excel__cell_length_and_height(_::Any, fontsize::Number)
    lines      = 1
    col_length = 0.0
    row_height = _excel__row_height_for_text(lines, fontsize)

    return row_height, col_length
end

"""
    _excel__get_col_width(
        col::Int,
        max_col_length::Vector{Float64},
        col_offset::Int,
        data_column_widths::AbstractVector{Float64},
        min_data_column_widths::AbstractVector{Float64},
        max_data_column_widths::AbstractVector{Float64}
    ) -> Float64

Resolve the Excel column width for column `col`. Columns at or before `col_offset`
(row-number and row-label columns) are returned as-is from `max_col_length`. For data
columns, a positive entry in `data_column_widths` takes precedence; otherwise the
auto-calculated width is clamped between the corresponding entries of
`min_data_column_widths` and `max_data_column_widths` (values ≤ 0 are ignored).
"""
function _excel__get_col_width(
    col::Int,
    max_col_length::Vector{Float64},
    col_offset::Int,
    data_column_widths::AbstractVector{Float64},
    min_data_column_widths::AbstractVector{Float64},
    max_data_column_widths::AbstractVector{Float64},
)
    # Don't limit non-data cells.
    col <= col_offset && return max_col_length[col]

    j = col - col_offset

    # A positive explicit width overrides everything.
    dw = data_column_widths[j]
    dw > 0.0 && return dw

    # Clamp auto-calculated width between min and max.
    col_width = max_col_length[col]

    min_w = min_data_column_widths[j]
    min_w > 0.0 && (col_width = max(col_width, min_w))

    max_w = max_data_column_widths[j]
    max_w > 0.0 && (col_width = min(col_width, max_w))

    return col_width
end

function _excel__split_attributes(attributes::Vector{ExcelPair})
    font_attributes = Pair{Symbol, Any}[]
    fill_attributes = Pair{Symbol, Any}[]

    for (k, v) in attributes
        if startswith(k, "cell_fill_")
            pv = fill_attributes
            sym = Symbol(@view k[(ncodeunits("cell_fill_") + 1):end])
        else
            pv = font_attributes
            sym = Symbol(k)
        end

        # `XLSX.setFormat` only accepts strings in the `format` keyword. Hence, we must not
        # convert purely numeric values like "0" (a format code) or "39" (a built-in format
        # ID) to `Int` here.
        if k == "format"
            push!(pv, sym => v)
            continue
        end

        processed_attribute = tryparse(Int, v)

        if isnothing(processed_attribute)
            processed_attribute = if v == "true"
                true
            elseif v == "false"
                false
            else
                v
            end
        end

        push!(pv, sym => processed_attribute)
    end

    return font_attributes, fill_attributes
end

"""
    _excel__apply_cell_style!(
        sheet::XLSX.Worksheet,
        row::Int,
        col::Int,
        style::Vector{ExcelPair},
        alignment::Union{Nothing, Symbol},
        valign::String,
        wrap::Bool,
    ) -> Number

Apply font and fill styling to the cell at (`row`, `col`) in `sheet` and return the
resolved font size.

The font size is taken from the `:size` entry of `style` when present, and from
`DEFAULT_FONT_SIZE` otherwise. When `style` carries no font attributes, no font is written
and a highlighter's prior font settings are preserved. The `:cell_fill_*` entries of
`style` are routed to `XLSX.setFill` and the remaining entries to `XLSX.setFont`.
`alignment`, when not `nothing`, is applied via `XLSX.setAlignment` together with `valign`
and `wrap`.
"""
function _excel__apply_cell_style!(
    sheet::XLSX.Worksheet,
    row::Int,
    col::Int,
    style::Vector{ExcelPair},
    alignment::Union{Nothing, Symbol},
    valign::String,
    wrap::Bool,
)
    font_attributes, fill_attributes = _excel__split_attributes(style)

    if !isempty(font_attributes)
        id = findfirst(p -> first(p) == :size, font_attributes)
        fontsize = isnothing(id) ? DEFAULT_FONT_SIZE : last(font_attributes[id])

        XLSX.setFont(sheet, row, col; font_attributes...)
    else
        # Preserve any font previously applied (e.g., by a highlighter) by not calling
        # `setFont`. The default size is used only as a fallback for cell sizing.
        fontsize = DEFAULT_FONT_SIZE
    end

    !isnothing(alignment) && XLSX.setAlignment(
        sheet,
        row,
        col;
        vertical = valign,
        horizontal = _excel__alignment_string(alignment),
        wrapText = wrap,
    )

    isempty(fill_attributes) || XLSX.setFill(sheet, row, col; fill_attributes...)

    return fontsize
end

"""
    _excel__format_attributes(
        @nospecialize(data::Any),
        excelFormatter::ExcelFormatter,
        current_row::Int,
        j::Int
    ) -> Union{Nothing, Vector{Pair{Symbol, Any}}}

Compute the format attributes `excelFormatter` yields for the cell at row `current_row` and
column `j` of `data`, or return `nothing` when the formatter condition is not met. Notice
that `data` must be the object the user passed to `pretty_table`, so that the formatter
condition sees the same object in every back end.
"""
function _excel__format_attributes(
    @nospecialize(data::Any),
    excelFormatter::ExcelFormatter,
    current_row::Int,
    j::Int,
)
    attributes = excelFormatter.f(data, current_row, j) ? excelFormatter.numFmt : nothing

    isnothing(attributes) && return nothing

    font_attributes, _ = _excel__split_attributes(attributes)

    return font_attributes
end
