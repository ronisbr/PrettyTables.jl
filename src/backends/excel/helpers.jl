## Description #############################################################################
#
# Helpers for designing tables in the Excel backend.
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
    _excel_column_alignment(col, col_alignment, table_alignment)

Return the alignment value to use for column labels.
"""
function _excel_column_alignment(col, col_alignment, table_alignment=nothing)
    if col_alignment isa Symbol
        return _excel_alignment_string(col_alignment)
    elseif col_alignment isa Vector{Symbol} && !isempty(col_alignment)
        if length(col_alignment) < col
            throw(ArgumentError("column_label_alignment vector has fewer entries than there are columns"))
        else
            return _excel_alignment_string(col_alignment[col])
        end
    else
        return _excel_column_alignment(col, table_alignment)
    end
end

"""
    _excel_cell_alignment(table_data::TableData, i::Int, j::Int) -> Symbol

Get the alignment for a data cell at position (i, j).

Returns one of `:l` (left), `:c` (center), or `:r` (right).

# Precedence (highest to lowest):
1. Cell-specific alignment from `cell_alignment` functions
2. Column-specific alignment from `data_alignment` for column j
3. Default alignment (`:r`)

# Arguments
- `table_data::TableData`: The table data structure
- `i::Int`: Row index (1-based)
- `j::Int`: Column index (1-based)
"""
function _excel_cell_alignment(table_data::TableData, i::Int, j::Int)

    # 1. Check cell-specific alignment (highest priority)
    if table_data.cell_alignment !== nothing
        for alignment_spec in table_data.cell_alignment
            if alignment_spec isa Function
                # Function with signature (data, i, j) -> Union{Symbol, Nothing}
                result = alignment_spec(table_data.data, i, j)
                if result !== nothing
                    return result
                end
            end
        end
    end
    
    # 2. Check column-specific alignment
    if table_data.data_alignment isa Symbol
        return table_data.data_alignment
    elseif table_data.data_alignment isa Vector && j <= length(table_data.data_alignment)
        return table_data.data_alignment[j]
    end
    
    # 3. Default alignment
    return :r
end

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
_excel_column_width_for_text(text_length, font_size) = (0.55 * text_length * font_size + 15.0) / 7.0

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
    if text isa String
        lines=split(text, "\n")
        maxlen=0
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
function _excel_tableformat_atts(property, format)
    v1 = getproperty(DEFAULT_EXCEL_TABLE_FORMAT, Symbol(property))
    isnothing(format) && return v1
    d = Dict(v1)              # first vector
    for (k, v) in format      # second vector overrides
        d[k] = v
    end
    result = collect(d)
    return result
end

"""
    _excel_tablestyle_atts(property::String, format::Vector{ExcelPair})

Override those attributes of the default table style for this table element 
with those specified in ExcelTableStyle
"""
function _excel_tablestyle_atts(property, format)
    v1 = getproperty(DEFAULT_EXCEL_TABLE_STYLE, Symbol(property))
    isnothing(format) && return v1
    d = Dict(v1)              # first vector
    for (k, v) in format      # second vector overrides
        d[k] = v
    end
    result = collect(d)
    return result
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
    _excel_apply_formatter(value, formatter, current_row, j)

Conditionally apply standard PrettyTables formatter to the given value.
"""
function _excel_apply_formatter(cell_value, formatter, current_row, j)
    v = formatter(cell_value, current_row, j)
    return v
end

"""
    _excel_update_fontsize!(atts, max_row_height, max_col_height, row)

Update font size for given row
"""
function _excel_update_fontsize!(atts, fontsize)
    g = _excel_getsize(atts)
    isnothing(g) && push!(atts, :size => fontsize)
    fontsize = isnothing(g) ? fontsize : g
    return fontsize
end

"""
    _excel_create_mergemap(table_data)

Create a Dict mapping merge firlds in the header rows
"""
function _excel_create_mergemap(table_data)
    merge_map = Dict{Tuple{Int, Int}, Tuple{Int, Any, Symbol}}()  # (row, col) => (span, data, alignment)
    if table_data.merge_column_label_cells !== nothing
        for merge_cell in table_data.merge_column_label_cells
            # merge_cell has fields: i (row), j (column), column_span, data, alignment
            merge_map[(merge_cell.i, merge_cell.j)] = (merge_cell.column_span, merge_cell.data, merge_cell.alignment)
        end
    end
    return merge_map
end

"""
    fmt__excel_stringify(columns)

Create formatter function that turns data types XLSX.jl can't handle into their string representation.
"""
function fmt__excel_stringify(columns::AbstractVector{Int})

    return (v, _, j) -> begin
        (v isa XLSX.CellConcreteType) && return v

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
    else
        lines = 1
    end
    col_length = _excel_column_width_for_text(_excel_multilength(text), fontsize)
    row_height = _excel_row_height_for_text(lines, fontsize)
    return row_height, col_length
end

#=
# Unnecessary?
function face_from_crayon(c::Crayon)
    return Face(
        foreground = c.fg === nothing ? nothing : SimpleColor(c.fg),
        background = c.bg === nothing ? nothing : SimpleColor(c.bg),
        weight     = c.bold      ? :bold   : nothing,
        slant      = c.italic    ? :italic : nothing,
        underline  = c.underline ? true    : nothing,
    )
end

# Unnecessary?
function styled_from_crayon(text::String, cr::Crayon)
    face = face_from_crayon(cr)
    return StyledString(text, face)
end
=#

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
    _excel_set_fontsize_and_alignment!(sheet, table_data, row, col, atts)

Set the font size and alignment in a cell.
"""
function _excel_set_fontsize_and_alignment!(sheet, row, col, atts, alignment, valign, wrap)
    fontsize=DEFAULT_FONT_SIZE
    if !isnothing(atts)
        fontsize = _excel_update_fontsize!(atts, fontsize)
        setFont(sheet, row, col; atts...)
    else
        setFont(sheet, row, col; size=fontsize)
    end
    if !isnothing(alignment)
        setAlignment(sheet, row, col; vertical = valign, horizontal = _excel_alignment_string(alignment), wrapText=wrap)
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
    if table_format.data_cell_width isa Float64
        return table_format.data_cell_width
    elseif table_format.data_cell_width isa Vector{Float64}
        length(table_format.data_cell_width) == length(max_col_length) || throw(ArgumentError("The table format property `data_cell_width` shoud have the same number of elements as there are data columns. Expected $(length(max_col_length)): Got $(length(table_format.data_cell_width))."))
        return table_format.data_cell_width[col]
    end

    # Limit calculated values
    col_width = max_col_length[col]
    if table_format.min_data_cell_width isa Float64 && table_format.min_data_cell_width > 0.0
        col_width = max(col_width, table_format.min_data_cell_width)
    elseif table_format.min_data_cell_width isa Vector{Float64} && table_format.min_data_cell_width[col] > 0.0
        length(table_format.min_data_cell_width) == length(max_col_length) || throw(ArgumentError("The table format property `min_data_cell_width` shoud have the same number of elements as there are data columns. Expected $(length(max_col_length)): Got $(length(table_format.min_data_cell_width))."))
        col_width = max(col_width, table_format.min_data_cell_width[col])
    end

    if table_format.max_data_cell_width isa Float64 && table_format.max_data_cell_width > 0.0
        col_width = min(col_width, table_format.max_data_cell_width)
    elseif table_format.max_data_cell_width isa Vector{Float64} && table_format.max_data_cell_width[col] > 0.0
        length(table_format.max_data_cell_width) == length(max_col_length) || throw(ArgumentError("The table format property `max_data_cell_width` shoud have the same number of elements as there are data columns. Expected $(length(max_col_length)): Got $(length(table_format.max_data_cell_width))."))
        col_width = min(col_width, table_format.max_data_cell_width[col])
    end

    return col_width
    
end