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
    _excel__text_lines(text::AbstractString) -> Number

Determine the number of lines in `text` by counting newline occurrences.
"""
function _excel__text_lines(text::AbstractString)
    # TODO: Improve this algorithm.
    count = findall("\n", text)
    isnothing(count) && return 1
    return length(count) + 1
end

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
    _excel__newpairs(
        attributes::Union{Nothing, Vector{ExcelPair}}
    ) -> Union{Nothing, Vector{Pair{Symbol, Any}}}

Convert the string keys in `attributes` to `Symbol`s and parse numeric and boolean values.
Returns `nothing` when `attributes` is `nothing`.
"""
function _excel__newpairs(attributes::Union{Nothing, Vector{ExcelPair}})
    isnothing(attributes) && return nothing

    newpairs = Vector{Pair{Symbol,Any}}()

    for (k, v) in attributes
        newv = tryparse(Int, v)
        if isnothing(newv)
            newv = if v == "true"
                true
            elseif v == "false"
                false
            else
                v
            end
        end

        newk = Symbol(k)
        push!(newpairs, newk => newv)
    end

    return newpairs
end

"""
    _excel__check_table_format(property::AbstractString, b::Union{Nothing, Bool}) -> Bool

Return `b` if it is not `nothing`; otherwise return the default value of the `property`
field from `DEFAULT_EXCEL_TABLE_FORMAT`.
"""
function _excel__check_table_format(property::AbstractString, b::Union{Nothing, Bool})
    !isnothing(b) && return b
    return getproperty(DEFAULT_EXCEL_TABLE_FORMAT, Symbol(property))
end

"""
    _excel__tableformat_attributes(
        property::AbstractString,
        format::Union{Nothing, Vector{ExcelPair}}
    ) -> Vector{ExcelPair}

Override the default `ExcelTableFormat` attributes for the table element identified by
`property` with the pairs supplied in `format`.
"""
function _excel__tableformat_attributes(
    property::AbstractString, format::Union{Nothing, Vector{ExcelPair}}
)
    return _excel__override_properties(DEFAULT_EXCEL_TABLE_FORMAT, property, format)
end

"""
    _excel__tablestyle_attributes(
        property::AbstractString,
        format::Union{Nothing, Vector{ExcelPair}, Vector{Vector{ExcelPair}}},
        j::Union{Nothing, Int} = nothing
    ) -> Vector{ExcelPair}

Override the default `ExcelTableStyle` attributes for the table element identified by
`property` with the pairs supplied in `format`. When `format` is a
`Vector{Vector{ExcelPair}}`, column index `j` selects the per-column entry.
"""
function _excel__tablestyle_attributes(
    property::AbstractString,
    format::Union{Nothing, Vector{ExcelPair}},
    _::Union{Nothing, Int} = nothing,
)
    return _excel__override_properties(DEFAULT_EXCEL_TABLE_STYLE, property, format)
end

function _excel__tablestyle_attributes(
    property::AbstractString,
    format::Vector{Vector{ExcelPair}},
    j::Union{Nothing, Int} = nothing,
)
    return _excel__override_properties(DEFAULT_EXCEL_TABLE_STYLE, property, format[j])
end

"""
    _excel__cell_fill_attributes(
        field::Union{Nothing, Vector{ExcelPair}, Vector{Vector{ExcelPair}}},
        j::Union{Nothing, Int} = nothing
    ) -> Vector{ExcelPair}

Extract fill attributes from a style field value. Any pair whose key starts with
`"cell_fill_"` is collected with the prefix stripped; all other pairs are ignored. When
`field` is a `Vector{Vector{ExcelPair}}`, column index `j` selects the entry. Returns an
empty vector when no fill attributes are present.
"""
function _excel__cell_fill_attributes(
    field::Union{Vector{ExcelPair}, Vector{Vector{ExcelPair}}},
    j::Union{Nothing, Int} = nothing,
)
    raw = (field isa Vector{Vector{ExcelPair}}) ? field[j] : field
    prefix = "cell_fill_"
    n = length(prefix)

    return ExcelPair[SubString(k, n + 1) => v for (k, v) in raw if startswith(k, prefix)]
end

function _excel__cell_fill_attributes(_::Nothing, _::Union{Nothing, Int} = nothing)
    return ExcelPair[]
end

"""
    _excel__font_fill_attributes(
        style_key::AbstractString,
        field::Any,
        j::Union{Nothing, Int} = nothing
    ) -> Tuple{Vector{Pair{Symbol, Any}}, Vector{Pair{Symbol, Any}}}
    _excel__font_fill_attributes(
        pairs::Vector{ExcelPair}
    ) -> Tuple{Vector{Pair{Symbol, Any}}, Vector{Pair{Symbol, Any}}}

Split a style field or raw decoration vector into font and fill attribute vectors.

The first method merges `field` with the default table style via
`_excel__tablestyle_attributes` for font attributes, and extracts `"cell_fill_"` prefixed
entries for fill. Use this for `ExcelTableStyle` fields (title, column_label, table_cell,
…).

The second method performs a direct split on a flat `Vector{ExcelPair}` without merging
with defaults. Use this for `ExcelHighlighter` decorations.

Both methods return `(font_attributes, fill_attributes)` as `Vector{Pair{Symbol, Any}}`
ready for splatting into `XLSX.setFont` / `XLSX.setFill`.
"""
function _excel__font_fill_attributes(
    style_key::AbstractString,
    field::Any,
    j::Union{Nothing, Int} = nothing,
)
    return (
        _excel__newpairs(_excel__tablestyle_attributes(style_key, field, j)),
        _excel__newpairs(_excel__cell_fill_attributes(field, j)),
    )
end

function _excel__font_fill_attributes(pairs::Vector{ExcelPair})
    return (
        _excel__newpairs(filter(p -> !startswith(p.first, "cell_fill_"), pairs)),
        _excel__newpairs(_excel__cell_fill_attributes(pairs)),
    )
end

"""
    _excel__override_properties(
        default::Any,
        property::AbstractString,
        format::Union{Nothing, Vector{ExcelPair}}
    ) -> Vector{ExcelPair}

Merge `format` pairs into the default attribute vector for the field `property` in
`default`. Pairs whose key starts with `"cell_fill_"` are skipped (handled separately by
`_excel__cell_fill_attributes`). Returns the merged vector.
"""
function _excel__override_properties(
    default::Any,
    property::AbstractString,
    format::Union{Nothing, Vector{ExcelPair}},
)
    v1 = getproperty(default, Symbol(property))
    isnothing(format) && return v1

    d = Dict(v1)

    for (k, v) in format
        startswith(k, "cell_fill_") && continue # fill pairs are handled separately
        d[k] = v
    end

    return collect(d)
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
    table_data::TableData,
    excelFormatter::ExcelFormatter,
    current_row::Int,
    j::Int,
)
    attributes =
        excelFormatter.f(table_data.data, current_row, j) ? excelFormatter.numFmt : nothing

    !isnothing(attributes) && return _excel__newpairs(attributes)
    return nothing
end

"""
    _excel__update_fontsize!(
        attributes::Vector{Pair{Symbol, Any}},
        fontsize::Number
    ) -> Number

Ensure a `:size` entry is present in `attributes`, inserting `fontsize` if none exists.
Returns the resolved font size.
"""
function _excel__update_fontsize!(attributes::Vector{Pair{Symbol, Any}}, fontsize::Number)
    g = _excel__getsize(attributes)
    isnothing(g) && push!(attributes, :size => fontsize)
    fontsize = isnothing(g) ? fontsize : g
    return fontsize
end

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
    _excel__getsize(pairs::Vector{Pair{Symbol, Any}}) -> Union{Nothing, Number}

Extract the `:size` font attribute from `pairs`, returning `nothing` if not present.
"""
function _excel__getsize(pairs::Vector{Pair{Symbol, Any}})
    for (k, v) in pairs
        k == :size && return v
    end

    return nothing
end

"""
    _excel__set_fontsize_and_alignment!(
        sheet::XLSX.Worksheet,
        row::Int,
        col::Int,
        attributes::Union{Nothing, Vector{Pair{Symbol, Any}}},
        alignment::Union{Nothing, Symbol},
        valign::String,
        wrap::Bool
    ) -> Number

Set the font and alignment for cell (`row`, `col`) in `sheet`. Returns the resolved font
size.
"""
function _excel__set_fontsize_and_alignment!(
    sheet::XLSX.Worksheet,
    row::Int,
    col::Int,
    attributes::Union{Nothing, Vector{Pair{Symbol, Any}}},
    alignment::Union{Nothing, Symbol},
    valign::String,
    wrap::Bool,
)
    fontsize = DEFAULT_FONT_SIZE

    if !isnothing(attributes)
        fontsize = _excel__update_fontsize!(attributes, fontsize)
        XLSX.setFont(sheet, row, col; attributes...)
    else
        XLSX.setFont(sheet, row, col; size = fontsize)
    end

    if !isnothing(alignment)
        XLSX.setAlignment(
            sheet,
            row,
            col;
            vertical = valign,
            horizontal = _excel__alignment_string(alignment),
            wrapText = wrap,
        )
    end

    return fontsize
end

"""
    _excel__get_col_width(
        table_format::ExcelTableFormat,
        col::Int,
        max_col_length::Vector{Float64},
        col_offset::Int
    ) -> Float64

Resolve the Excel column width for column `col`, respecting any explicit, minimum, or
maximum widths configured in `table_format`. Columns at or before `col_offset` (row-number
and row-label columns) are returned as-is from `max_col_length`.
"""
function _excel__get_col_width(
    table_format::ExcelTableFormat,
    col::Int,
    max_col_length::Vector{Float64},
    col_offset::Int,
)

    # Don't limit non-data cells.
    col <= col_offset && return max_col_length[col]

    # Always use explicitly set data cell widths
    table_format.data_column_width isa Float64 && return table_format.data_column_width

    if table_format.data_column_width isa Vector{Float64}
        length(table_format.data_column_width) == length(max_col_length) &&
            return table_format.data_column_width[col]

        throw(ArgumentError(
            "The table format property `data_column_width` shoud have the same number of elements as there are data columns. Expected $(length(max_col_length)): Got $(length(table_format.data_column_width))."
        ))
    end

    # Limit calculated values
    col_width = max_col_length[col]

    if (
        table_format.min_data_column_width isa Float64 &&
        table_format.min_data_column_width > 0
    )
        col_width = max(col_width, table_format.min_data_column_width)

    elseif (
        table_format.min_data_column_width isa Vector{Float64} &&
        table_format.min_data_column_width[col] > 0
    )
        length(table_format.min_data_column_width) != length(max_col_length) &&
            throw(ArgumentError(
                "The table format property `min_data_column_width` shoud have the same number of elements as there are data columns. Expected $(length(max_col_length)): Got $(length(table_format.min_data_column_width)).",
            ))

        col_width = max(col_width, table_format.min_data_column_width[col])
    end

    if (
        table_format.max_data_column_width isa Float64 &&
        table_format.max_data_column_width > 0
    )
        col_width = min(col_width, table_format.max_data_column_width)

    elseif (
        table_format.max_data_column_width isa Vector{Float64} &&
        table_format.max_data_column_width[col] > 0
    )
        length(table_format.max_data_column_width) != length(max_col_length) &&
            throw(ArgumentError(
                "The table format property `max_data_column_width` shoud have the same number of elements as there are data columns. Expected $(length(max_col_length)): Got $(length(table_format.max_data_column_width))."
            ))

        col_width = min(col_width, table_format.max_data_column_width[col])
    end

    return col_width
end

"""
    _excel__compute_col_offset(table_data::TableData) -> Int

Return the number of leading columns before the data columns (row-number column plus
row-label column). This offset is used when mapping data column indices to absolute Excel
column numbers.
"""
function _excel__compute_col_offset(table_data::TableData)
    col_offset = 0

    if table_data.show_row_number_column
        col_offset += 1
    end

    if !isnothing(table_data.row_labels) || !isnothing(table_data.summary_row_labels)
        col_offset += 1
    end

    if !isnothing(table_data.row_group_labels) && col_offset == 0
        col_offset += 1
    end

    return col_offset
end

"""
    _excel__try_border!(
        sheet::XLSX.Worksheet,
        rows::Any,
        cols::Any,
        table_format::ExcelTableFormat,
        property::AbstractString,
        side::Symbol
    ) -> Nothing

Apply a border on `sheet` at `rows`×`cols` using the style from `table_format` for
`property`, but only when that property is enabled. `side` is the keyword passed to
`XLSX.setBorder` (e.g. `:bottom`).
"""
function _excel__try_border!(
    sheet::XLSX.Worksheet,
    rows::Any,
    cols::Any,
    table_format::ExcelTableFormat,
    property::AbstractString,
    side::Symbol,
)
    field = getproperty(table_format, Symbol(property))

    _excel__check_table_format(property, field) || return

    type_field  = getproperty(table_format, Symbol(property * "_type"))
    border_type = _excel__tableformat_attributes(property * "_type", type_field)

    XLSX.setBorder(sheet, rows, cols; Dict(side => border_type)...)

    return nothing
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
    style_key::AbstractString,
    style_field::Any,
    alignment::Union{Nothing, Symbol},
    valign::String,
    wrap::Bool;
    col_idx::Union{Nothing, Int} = nothing,
)
    font_attributes, fill_attributes = _excel__font_fill_attributes(
        style_key, style_field, col_idx
    )

    fontsize = _excel__set_fontsize_and_alignment!(
        sheet, row, col, font_attributes, alignment, valign, wrap
    )

    isempty(fill_attributes) || XLSX.setFill(sheet, row, col; fill_attributes...)

    return fontsize
end

"""
    _get_cell_value(table_data::TableData, i::Int, j::Int) -> Any

Extract the value at row `i` and column `j` from the data structure in `table_data`,
handling `ColumnTable`, `RowTable`, and array-like inputs.
"""
function _get_cell_value(table_data::TableData, i::Int, j::Int)
    data = table_data.data

    # Adjust indices based on the data structure's first indices.
    row_idx = i + table_data.first_row_index - 1
    col_idx = j + table_data.first_column_index - 1

    try
        if data isa ColumnTable
            # For ColumnTable, access via column name
            col_name = data.column_names[col_idx]
            col_data = Tables.getcolumn(data.table, col_name)
            return col_data[row_idx]
        elseif data isa RowTable
            # For RowTable, iterate to the right row
            rows = collect(Tables.rows(data.table))
            row = rows[row_idx]
            col_name = data.column_names[col_idx]
            return Tables.getcolumn(row, col_name)
        else
            # For regular arrays and matrices
            return data[row_idx, col_idx]
        end
    catch e
        # If there's an error accessing the data, return empty string
        return ""
    end
end
