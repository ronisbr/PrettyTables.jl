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
    _excel_alignment_string(column, col_alignment, table_alignment)

Convert the given alignment (Symbol) to a string for use in XLSX.setAlignment
"""
function _excel_alignment_string(s)
    if s == :l
        return "left"
    elseif s == :r
        return "right"
    elseif s == :c
        return "center"
    else
        throw(ArgumentError("Invalid alignment given: $s. Specify :l, :r or :c"))
    end
end

"""
    _excel_unempty_row(sheet, row, cols)

Ensure all cells in current row are not XLSX.EmptyCells to ensure formatting works completely.
Cols expected to be a unit range.
"""
_excel_unempty_row(sheet, row, cols) = sheet[row, cols] = ""

"""
    _excel_to_superscript(n::Int) -> String

Convert an integer to a superscript string using Unicode characters.
"""
function _excel_to_superscript(n::Int)
    digits_str = string(n)
    return join([SUPERSCRIPT_DIGITS[parse(Int, d) + 1] for d in digits_str])
end

"""
    _excel_column_width_for_text(text, fontsize)

Estimate the width of a cell in Excel needed to accommodate text of a given length.
"""
_excel_column_width_for_text(text_length, font_size) = (0.55 * text_length * font_size) / 7.0 + 2.0

"""
    _excel_row_height_for_text(text, fontsize)

Estimate the height of a cell in Excel needed to accommodate a given number of lines of text of a given font size.
"""
_excel_row_height_for_text(line_count, font_size) = line_count * (font_size * 1.2) + 3

"""
    _excel_text_lines(text)

Determine the number of lines in a text by counting new-line occurrences.
"""
function _excel_text_lines(text)
    count = findall("\n", text)
    if isnothing(count)
        return 1
    else
        return length(count)+1
    end
end

"""
    _excel_multilength(text)

Determines the length of the longest line in a multi-line text
"""
function _excel_multilength(text)
    if text isa AbstractString
        lines = split(text, "\n")
        maxlen = 0
        for line in lines
            maxlen = max(maxlen, length(line))
        end
        return maxlen
    else
        return 0
    end
end

"""
    _excel_newpairs(atts)

Convert a keys in avector to Symbols.
"""
function _excel_newpairs(atts)
    isnothing(atts) && return nothing
    newpairs = Vector{Pair{Symbol,Any}}()
    for (k, v) in atts
        newv = tryparse(Int, v)
        if isnothing(newv)
            newv = v == "true" ? true : v == "false" ? false : v
        end
        newk = Symbol(k)
        push!(newpairs, newk => newv)
    end
    return newpairs
end

function _excel_check_table_format(property, b)
    if !isnothing(b)
        return b
    else
        return getproperty(DEFAULT_EXCEL_TABLE_FORMAT, Symbol(property))
    end
end

"""
    _excel_tableformat_atts(property::String, format::Vector{ExcelPair})

Override those attributes of the default table format for this table element 
with those specified in ExcelTableFormat
"""
_excel_tableformat_atts(property, format) = _excel_override_properties(
    DEFAULT_EXCEL_TABLE_FORMAT, 
    property, 
    format,
)

"""
    _excel_tablestyle_atts(property::String, format::Vector{ExcelPair})
    _excel_tablestyle_atts(property::String, format::Vector{Vector{ExcelPair}}, j = nothing)

Override those attributes of the default table style for this table element 
with those specified in ExcelTableStyle
"""
function _excel_tablestyle_atts(property, format, j = nothing)
    if isnothing(format) || format isa Vector{Pair{String, String}}
        return _excel_override_properties(DEFAULT_EXCEL_TABLE_STYLE, property, format)
    end
    return _excel_override_properties(DEFAULT_EXCEL_TABLE_STYLE, property, format[j])
end

"""
    _excel_cell_fill_atts(field, j = nothing) -> Vector{ExcelPair}

Extract fill attributes from a style field value. Any pair whose key starts with
`"cell_fill_"` is collected with the prefix stripped; all other pairs are ignored.
If the field is a `Vector{Vector{ExcelPair}}`, column index `j` selects the entry.
Returns an empty vector when no fill attributes are present.
"""
function _excel_cell_fill_atts(field, j = nothing)
    isnothing(field) && return ExcelPair[]
    raw = (field isa Vector{Vector{ExcelPair}}) ? field[j] : field
    prefix = "cell_fill_"
    n = length(prefix)
    return ExcelPair[SubString(k, n + 1) => v for (k, v) in raw if startswith(k, prefix)]
end

function _excel_override_properties(default, property, format)
    v1 = getproperty(default, Symbol(property))
    isnothing(format) && return v1
    d = Dict(v1)
    for (k, v) in format
        startswith(k, "cell_fill_") && continue   # fill pairs are handled separately
        d[k] = v
    end
    return collect(d)
end

"""
    _excel_font_attributes(table_data, highlighter, current_row, j)

Get highlighter font attributes for current row and column (j)
"""
function _excel_highlighter_atts(table_data, highlighter, current_row, j)
    atts = highlighter.f(table_data.data, current_row, j) ? highlighter._decoration : nothing
    font_atts = Vector{Pair{Symbol,Any}}()
    fill_atts = Vector{Pair{Symbol,Any}}()
    border_atts = Vector{Pair{Symbol,Any}}()
        if !isnothing(atts)
            for (type, type_atts) in atts # type = :font, :fill, :border and type_atts = atts for that format type
    #            for (k, v) in type_atts
                    if type == :font
                        font_atts = _excel_newpairs(type_atts)
                    elseif type == :fill
                        fill_atts = _excel_newpairs(type_atts)
                    elseif type == :border
                        border_atts = type_atts
                    else
                        println("Unreachable reached")
                        error()
                    end
    #            end
            end
            return (font_atts, fill_atts, border_atts)
        else
            return nothing
        end
#    end
end

"""
    _excel_format_attributes(table_data, excelFormatter, current_row, j)

Get ExcelFormatter format attributes for current row and column (j)
"""
function _excel_format_attributes(table_data, excelFormatter, current_row, j)
    atts = excelFormatter.f(table_data.data, current_row, j) ? excelFormatter.numFmt : nothing
    if !isnothing(atts)
        return _excel_newpairs(atts)
    else
        return nothing
    end
end

"""
    _excel_update_fontsize!(atts, fontsize)

Update font size in a given set of font attributes
"""
function _excel_update_fontsize!(atts, fontsize)
    g = _excel_getsize(atts)
    isnothing(g) && push!(atts, :size => fontsize)
    fontsize = isnothing(g) ? fontsize : g
    return fontsize
end

"""
    fmt__excel_stringify(columns::AbstractVector(Int))

Create formatter function that turns data types XLSX.jl can't handle into their string representation.
"""
function fmt__excel_stringify(columns::Union{Nothing,Int,AbstractVector{Int}} = nothing)

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
    _excel_update_length_and_height!(max_row_lines, max_row_height, max_col_length, max_col_height, col, text, fontsize)

Return the column width and row height needed for a table cell value (in Excel units).
"""
function _excel_cell_length_and_height(text, fontsize)
    if text isa AbstractString
        lines = _excel_text_lines(text)
        col_length = _excel_column_width_for_text(_excel_multilength(text), fontsize)
    else
        lines = 1
        col_length = 0.0
    end
    row_height = _excel_row_height_for_text(lines, fontsize)
    return row_height, col_length
end

"""
    _excel_getsize(pairs::Vector{Pair{Symbol,Any}})

Extract the font size attribute from a vector of pairs.
"""
function _excel_getsize(pairs::Vector{Pair{Symbol,Any}})
    for (k, v) in pairs
        if k == :size
            return v
        end
    end
    return nothing
end

"""
    _excel_set_fontsize_and_alignment!(sheet, table_data, row, col, atts, alignment, valign, wrap)

Set the font size and alignment in a cell.
"""
function _excel_set_fontsize_and_alignment!(sheet, row, col, atts, alignment, valign, wrap)
    fontsize = DEFAULT_FONT_SIZE
    if !isnothing(atts)
        fontsize = _excel_update_fontsize!(atts, fontsize)
        XLSX.setFont(sheet, row, col; atts...)
    else
        XLSX.setFont(sheet, row, col; size = fontsize)
    end
    if !isnothing(alignment)
        XLSX.setAlignment(
            sheet, 
            row, 
            col; 
            vertical = valign, 
            horizontal = _excel_alignment_string(alignment), 
            wrapText = wrap,
        )
    end
    return fontsize
end

"""
    _excel_get_col_width(table_format, i, max_col_length, col_offset)

Resolve column width for data table columns.
"""
function _excel_get_col_width(table_format, col, max_col_length, col_offset)

    # Don't limit non-data cells
    if col <= col_offset
        return max_col_length[col]
    end

    # Always use explicitly set data cell widths
    if table_format.data_column_width isa Float64
        return table_format.data_column_width
    elseif table_format.data_column_width isa Vector{Float64}
        if length(table_format.data_column_width) == length(max_col_length)
            return table_format.data_column_width[col]
        else
            throw(ArgumentError("The table format property `data_column_width` shoud have the same number of elements as there are data columns. Expected $(length(max_col_length)): Got $(length(table_format.data_column_width))."))
        end
    end

    # Limit calculated values
    col_width = max_col_length[col]
    if table_format.min_data_column_width isa Float64 && table_format.min_data_column_width > 0.0
        col_width = max(col_width, table_format.min_data_column_width)
    elseif table_format.min_data_column_width isa Vector{Float64} && table_format.min_data_column_width[col] > 0.0
        if length(table_format.min_data_column_width) == length(max_col_length)
            col_width = max(col_width, table_format.min_data_column_width[col])
        else
            throw(ArgumentError("The table format property `min_data_column_width` shoud have the same number of elements as there are data columns. Expected $(length(max_col_length)): Got $(length(table_format.min_data_column_width))."))
        end
    end

    if table_format.max_data_column_width isa Float64 && table_format.max_data_column_width > 0.0
        col_width = min(col_width, table_format.max_data_column_width)
    elseif table_format.max_data_column_width isa Vector{Float64} && table_format.max_data_column_width[col] > 0.0
        if length(table_format.max_data_column_width) == length(max_col_length)
            col_width = min(col_width, table_format.max_data_column_width[col])
        else
            throw(ArgumentError("The table format property `max_data_column_width` shoud have the same number of elements as there are data columns. Expected $(length(max_col_length)): Got $(length(table_format.max_data_column_width))."))
        end
    end

    return col_width
    
end

"""
    _excel_compute_col_offset(table_data::TableData) -> Int

Return the number of leading columns before the data columns (row number column +
row label column). This offset is used when mapping data column indices to absolute
Excel column numbers.
"""
function _excel_compute_col_offset(table_data::TableData)
    col_offset = 0
    if table_data.show_row_number_column
        col_offset += 1
    end
    if table_data.row_labels !== nothing || table_data.summary_row_labels !== nothing
        col_offset += 1
    end
    if table_data.row_group_labels !== nothing && col_offset == 0
        col_offset += 1
    end
    return col_offset
end

"""
    _excel_try_border!(sheet, rows, cols, table_format, property, side)

Apply a border on `sheet` at `rows`×`cols` using `table_format.property` only when that
property is enabled. `side` is the keyword passed to `XLSX.setBorder` (e.g. `:bottom`).
"""
function _excel_try_border!(sheet, rows, cols, table_format, property, side::Symbol)
    field = getproperty(table_format, Symbol(property))
    _excel_check_table_format(property, field) || return
    type_field  = getproperty(table_format, Symbol(property * "_type"))
    border_type = _excel_tableformat_atts(property * "_type", type_field)
    XLSX.setBorder(sheet, rows, cols; Dict(side => border_type)...)
end

"""
    _excel_apply_cell_style!(sheet, row, col, style_key, style_field, alignment, valign, wrap; col_idx) -> fontsize

Apply font and fill styling to a single cell and return the resolved font size.
`col_idx` selects a per-column entry when `style_field` is a `Vector{Vector{ExcelPair}}`.
"""
function _excel_apply_cell_style!(
    sheet, row, col, style_key, style_field, alignment, valign, wrap;
    col_idx = nothing,
)
    font_atts = _excel_newpairs(_excel_tablestyle_atts(style_key, style_field, col_idx))
    fill_atts = _excel_newpairs(_excel_cell_fill_atts(style_field, col_idx))
    fontsize  = _excel_set_fontsize_and_alignment!(sheet, row, col, font_atts, alignment, valign, wrap)
    isempty(fill_atts) || XLSX.setFill(sheet, row, col; fill_atts...)
    return fontsize
end

"""
    _get_cell_value(data, i, j, table_data::TableData)

Get the value of a cell from the data structure, handling different data types.
"""
function _get_cell_value(table_data::TableData, i::Int, j::Int)
    data = table_data.data
    # Adjust indices based on the data structure's first indices
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
