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

    # Return "left" for :l for any other value.
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
    digits_str = string(n)
    return join([SUPERSCRIPT_DIGITS[parse(Int, d) + 1] for d in digits_str])
end

"""
    _excel__column_width_for_text(text_length::Number, font_size::Number) -> Number

Estimate the Excel column width needed to display text of `text_length` characters rendered
at `font_size`.
"""
function _excel__column_width_for_text(text_length::Number, font_size::Number)
    return (0.55 * text_length * font_size) / 7 + 2
end

"""
    _excel__row_height_for_text(line_count::Number, font_size::Number) -> Number

Estimate the Excel row height needed to accommodate `line_count` lines of text rendered at
`font_size`.
"""
function _excel__row_height_for_text(line_count::Number, font_size::Number)
    return line_count * (font_size * 1.2) + 3
end

"""
    _excel__text_lines(text::Any) -> Number

Determine the number of lines in `text` by counting newline occurrences. If `text` is not a
string, returns 1.
"""
_excel__text_lines(text::AbstractString) = count('\n', text) + 1
_excel__text_lines(::Any) = 1

"""
    _excel__multilength(text::AbstractString) -> Number

Return the length of the longest line in the multi-line string `text`. If `text` is not a
string, returns 0.
"""
function _excel__multilength(text::AbstractString)
    # TODO: Improve this algorithm.
    lines = split(text, "\n")
    maxlen = 0

    for line in lines
        maxlen = max(maxlen, length(line))
    end

    return maxlen
end

_excel__multilength(::Any) = 0

"""
    fmt__excel_stringify(
        columns::Union{Nothing, Int, AbstractVector{Int}} = nothing
    ) -> Function

Create a formatter function that converts values XLSX.jl cannot handle directly into their
string representation. When `columns` is `nothing`, all values are stringified; otherwise
only the columns listed in `columns` are converted.
"""
function fmt__excel_stringify(columns::Union{Nothing, Int, AbstractVector{Int}} = nothing)
    return (v, _, j) -> begin
        (v isa XLSX.CellConcreteType) && return v

        isnothing(columns) && return string(v)

        for c in columns
            j == c && return string(v)
        end

        return v
    end
end

"""
    _excel__cell_length_and_height(text::Any, fontsize::Number) -> Tuple{Float64, Float64}

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
            sym = Symbol(replace(k, "cell_fill_" => ""))
        else
            pv = font_attributes
            sym = Symbol(k)
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
        style_key::AbstractString,
        style_field::Any,
        alignment::Union{Nothing, Symbol},
        valign::String,
        wrap::Bool;
        kwargs...
    ) -> Number

Apply font and fill styling to the cell at (`row`, `col`) in `sheet` and return the
resolved font size.

# Keywords

- `col_idx::Union{Nothing, Int}`: Column index used to select a per-column entry when
    `style_field` is a `Vector{Vector{ExcelPair}}`.
    (**Default**: `nothing`)
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
        id = findfirst(==(:size), first.(font_attributes))
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
        table_data::TableData,
        excelFormatter::ExcelFormatter,
        current_row::Int,
        j::Int
    ) -> Union{Nothing, Vector{Pair{Symbol, Any}}}

Apply `excelFormatter` to the cell at row `current_row` and column `j` and return the
format attributes when the formatter condition is met, or `nothing` otherwise.
"""
function _excel__format_attributes(
    table_data::TableData, excelFormatter::ExcelFormatter, current_row::Int, j::Int
)
    attributes =
        excelFormatter.f(table_data.data, current_row, j) ? excelFormatter.numFmt : nothing

    isnothing(attributes) && return nothing

    font_attributes, _ = _excel__split_attributes(attributes)

    return font_attributes
end
