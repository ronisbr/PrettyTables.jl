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
