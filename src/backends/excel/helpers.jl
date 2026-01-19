## Description #############################################################################
#
# Helpers for designing tables in the Excel backend.
#
############################################################################################

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
    _excel__column_alignment(col, col_alignment, table_alignment)

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
    _excel_column_width_for_text(text)

Estimate the width of a cell in Excel needed to accommodate text of a given length.
"""
_excel_column_width_for_text(text_length, font_size) = text_length * font_size / 11.0

"""
    _excel_row_height_for_text(text)

Estimate the height of a cell in Excel needed to accommodate a given number of lines of text of a given font size.
"""
_excel_row_height_for_text(line_count, font_size) = line_count * (font_size * 1.2) + 2
