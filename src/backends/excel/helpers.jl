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
_excel_column_width_for_text(text_length, font_size) = (0.6 * text_length * font_size + 15.0) / 7.0

"""
    _excel_row_height_for_text(text)

Estimate the height of a cell in Excel needed to accommodate a given number of lines of text of a given font size.
"""
_excel_row_height_for_text(line_count, font_size) = line_count * (font_size * 1.4) + 2

"""
    _excel_text_lines(text)

Determine the number of lines in a text by counting "\n" occurrences.
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
    lines=split(text, "\n")
    maxlen=0
    for line in lines
        maxlen = max(maxlen, length(line))
    end
    return maxlen
end

"""
    _excel_newpairs(atts)

Convert a keys in avector to Symbols.
"""
function _excel_newpairs(atts)
    newpairs = Vector{Pair{Symbol,Any}}()
    println(atts)
    for (k, v) in atts
        println(v)
        newv = tryparse(Int, v)
        if isnothing(newv)
            newv = v == "true" ? true : v == "false" ? false : v
        end
        newk = Symbol(k)
        push!(newpairs, newk => newv)
    end
    return newpairs
end

"""
    _excel_font_attributes(table_data, highlighter, current_row, j)

Get highlighter font attributes for current row and column (j)
"""
function _excel_font_attributes(table_data, highlighter, current_row, j)
    atts = highlighter.f(table_data.data, current_row, j) ? highlighter._decoration : nothing
    if !isnothing(atts)
        return _excel_newpairs(atts)
    else
        return nothing
    end
end
"""
    _excel_format_attributes(table_data, formatter, current_row, j)

Get formatter format attributes for current row and column (j)
"""
function _excel_format_attributes(table_data, formatter, current_row, j)
    atts = formatter.f(table_data.data, current_row, j) ? formatter.numFmt : nothing
    if !isnothing(atts)
        return _excel_newpairs(atts)
    else
        return nothing
    end
end

"""
    _excel_update_atts!(atts, max_row_height, max_col_height, row)

Update font size for given row
"""
function _excel_update_atts!(atts, fontsize)
    g = _excel_getsize(atts)
    isnothing(g) && push!(atts, :size => fontsize)
    fontsize = isnothing(g) ? fontsize : g
    return fontsize
end

function _excel_update_length_and_height!(max_row_lines, max_row_height, max_col_length, max_col_height, col, text, fontsize)
    lines=_excel_text_lines(text)
    if !isnothing(col)
        max_col_length[col] = max(_excel_multilength(text), max_col_length[col])
        max_col_height[col] = max(fontsize, max_col_height[col])
    end
    max_row_lines = max(max_row_lines, lines)
    max_row_height = max(max_row_height, fontsize)
    return max_row_lines, max_row_height
end

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
