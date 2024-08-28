## Description #############################################################################
#
# Miscellaneous functions.
#
############################################################################################

"""
    _aprint(buf::IO, str::String, indentation_level::Int = 0, indentation_spaces::Int = 2; kwargs...) -> Nothing

Print `str` in the buffer `buf` aligned to the `indentation_level`. Each indentation level
contains a number of spaces given by `indentation_spaces`.

# Keywords

- `minify::Bool`: If `true`, the output will be minified, meaning that it will be printed
    without indentation spaces or line breaks.
    (**Default**: `false`)
"""
function _aprint(
    buf::IO,
    str::String,
    indentation_level::Int = 0,
    indentation_spaces::Int = 2;
    minify::Bool = false
)
    tokens = split(str, '\n')

    if !minify
        padding = " "^max(indentation_level * indentation_spaces, 0)

        for i in eachindex(tokens)
            t = tokens[i]

            # If the token is empty, we do nothing to avoid unnecessary white spaces.
            if !isempty(t)
                print(buf, padding)
                print(buf, t)
            end

            i != last(eachindex(tokens)) && println(buf)
        end
    else
        for t in tokens
            !isempty(t) && print(buf, strip(t))
        end
    end

    return nothing
end

"""
    _aprintln(buf::IO, str::String, indentation_level::Int = 0, indentation_spaces::Int = 2; kwargs...) -> Nothing

Print `str` in the buffer `buf` aligned to the `indentation_level` and adding a line break
at the end. Each indentation level contains a number of spaces given by
`indentation_spaces`.

# Keywords

- `minify::Bool`: If `true`, the output will be minified, meaning that it will be printed
    without indentation spaces or line breaks.
    (**Default**: `false`)
"""
function _aprintln(
    buf::IO,
    str::String,
    indentation_level::Int = 0,
    indentation_spaces::Int = 2;
    minify::Bool = false
)
    _aprint(buf, str, indentation_level, indentation_spaces; minify)
    !minify && println(buf)
    return nothing
end

"""
    _align_column_with_regex!(column::AbstractVector{Vector{String}}, alignment_anchor_regex::Vector{Regex}, alignment_anchor_fallback::Symbol) -> Int

Align the lines in the `column` at the first match obtained by the regex vector
`alignment_anchor_regex`, falling back to `alignment_anchor_fallback` if a match is not
found for a specific line.

This function returns the largest cell width.

!!! note

    Each element in `column` must be a vector of `String`s, where each string is a line.
"""
function _align_column_with_regex!(
    column::AbstractVector{Vector{String}},
    alignment_anchor_regex::Vector{Regex},
    alignment_anchor_fallback::Symbol,
)
    # Variable to store in which column we must align the match.
    alignment_column = 0

    # We need to pass through the entire column searching for matches to compute in which
    # column we need to align them.
    for row in column
        for line in row
            m = nothing

            for r in alignment_anchor_regex
                m_r = findfirst(r, line)
                isnothing(m_r) && continue
                m = m_r
                break
            end

            if !isnothing(m)
                @show alignment_column_i = textwidth(@views line[1:first(m)])
            else
                # If a match is not found, the alignment column depends on the user
                # selection.

                if alignment_anchor_fallback == :c
                    line_len = textwidth(line)
                    alignment_column_i = cld(line_len, 2)

                elseif alignment_anchor_fallback == :r
                    line_len = textwidth(line)
                    alignment_column_i = line_len + 1

                else
                    alignment_column_i = 0
                end
            end

            alignment_column = max(alignment_column, alignment_column_i)
        end
    end

    # Variable to store the largest cell width after the alignment.
    largest_cell_width = 0

    # Now, we need to pass again applying the alignments.
    for i in eachindex(column)
        row = column[i]

        for l in eachindex(row)
            line = row[l]

            m = nothing

            for r in alignment_anchor_regex
                m_r = findfirst(r, line)
                isnothing(m_r) && continue
                m = m_r
                break
            end

            if !isnothing(m)
                match_column_k = textwidth(@views(line[1:first(m)]))
                pad = alignment_column - match_column_k
            else
                # If a match is not found, the alignment column depends on the user
                # selection.

                if alignment_anchor_fallback == :c
                    line_len = textwidth(line)
                    pad = alignment_column - cld(line_len, 2)

                elseif alignment_anchor_fallback == :r
                    line_len = textwidth(line)
                    pad = alignment_column - line_len - 1

                else
                    pad = alignment_column
                end
            end

            # `pad` must be positive.
            pad = max(pad, 0)

            # Apply the alignment to the line.
            row[l] = " "^pad * line
            line_len = textwidth(row[l])

            largest_cell_width = max(largest_cell_width, line_len)
        end
    end

    # The third pass aligns the elements correctly. This is performed by adding spaces to
    # the right so that all the cells have the same width.
    for i in eachindex(column)
        row = column[i]

        for l in eachindex(row)
            line = row[l]
            pad = largest_cell_width - textwidth(line)
            pad = min(pad, 0)
            row[l] = line * " "^pad
        end
    end

    return largest_cell_width
end

"""
    _compact_type_str(T) -> String

Return a string with a compact representation of type `T`.
"""
_compact_type_str(T) = string(T)

function _compact_type_str(T::Union)
    str = T >: Missing ? string(nonmissingtype(T)) * "?" : string(T)
    return replace(str, "Union" => "U")
end

"""
    _omitted_cell_summary(table_data::TableData, pspec::PrintingSpec) -> String

Return the omitted cell summary related to the `table_data` and printing specification
`pspec`.
"""
function _omitted_cell_summary(table_data::TableData, pspec::PrintingSpec)
    pspec.show_omitted_cell_summary || return ""

    num_rows    = table_data.num_rows
    num_columns = table_data.num_columns
    max_rows    = table_data.maximum_number_of_rows
    max_columns = table_data.maximum_number_of_columns

    # Compute the number of hidden rows and columns.
    num_hidden_columns = (max_columns > 0) ? num_columns - max_columns : 0
    num_hidden_rows    = (max_rows > 0)    ? num_rows    - max_rows    : 0
    has_hidden_columns = num_hidden_columns > 0
    has_hidden_rows    = num_hidden_rows > 0

    (has_hidden_columns || has_hidden_rows) || return ""

    buf = IOBuffer()

    if has_hidden_columns
        print(buf, num_hidden_columns)
        print(buf, num_hidden_columns == 1 ? " column" : " columns")
    end

    (has_hidden_columns && has_hidden_rows) && print(buf, " and ")

    if has_hidden_rows
        print(buf, num_hidden_rows)
        print(buf, num_hidden_rows == 1 ? " row" : " rows")
    end

    print(buf, " omitted")

    return String(take!(buf))
end
