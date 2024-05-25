## Description #############################################################################
#
# Miscellaneous functions used by all back-ends.
#
############################################################################################

export compact_type_str

"""
    compact_type_str(T) -> String

Return a string with a compact representation of type `T`.
"""
compact_type_str(T) = string(T)

function compact_type_str(T::Union)
    str = T >: Missing ? string(nonmissingtype(T)) * "?" : string(T)
    return replace(str, "Union" => "U")
end

############################################################################################
#                                    Private Functions                                     #
############################################################################################

"""
    _aprint(buf::IO[, v]; indentation = 0, nspace = 2, minify = false) -> Nothing

Print the variable `v` to the buffer `buf` at the indentation level `indentation`. Each
level has `nspaces` spaces. If `minify` is `true`, then the text is printed without
breaklines or padding.

If `v` is not present, only the indentation spaces will be printed.
"""
function _aprint(
    buf::IO,
    v::String,
    indentation::Int = 0,
    nspaces::Int = 2,
    minify::Bool = false
)
    tokens  = split(v, '\n')
    ntokens = length(tokens)

    if !minify
        padding = " "^(indentation * nspaces)

        @inbounds for i in 1:ntokens
            # If the token is empty, then we do nothing to avoid unnecessary white spaces.
            if length(tokens[i]) != 0
                print(buf, padding)
                print(buf, tokens[i])
            end
            i != ntokens && println(buf)
        end
    else
        @inbounds for i in 1:ntokens
            if length(tokens[i]) != 0
                print(buf, strip(tokens[i]))
            end
        end
    end

    return nothing
end

function _aprint(buf::IO, indentation::Int = 0, nspaces::Int = 2, minify::Bool = false)
    if !minify
        padding = " "^(indentation*nspaces)
        print(buf, padding)
    end

    return nothing
end

"""
    _aprintln(buf::IO, [v,] indentation = 0, nspaces = 2, minify = false) -> Nothing

Same as `_aprint`, but a new line will be added at the end. Notice that this newline is not
added if `minify` is `true` Notice that this newline is not added if `minify` is `true`.
"""
function _aprintln(
    buf::IO,
    v::String,
    indentation::Int = 0,
    nspaces::Int = 2,
    minify::Bool = false
)
    if !minify
        tokens  = split(v, '\n')
        padding = " "^(indentation * nspaces)
        ntokens = length(tokens)

        @inbounds for i = 1:ntokens
            # If the token is empty, then we do nothing to avoid unnecessary white
            # spaces.
            if length(tokens[i]) != 0
                print(buf, padding)
                println(buf, tokens[i])
            else
                println(buf)
            end
        end
    else
        _aprint(buf, v, indentation, nspaces, minify)
    end

    return nothing
end

function _aprintln(buf::IO, indentation::Int = 0, nspaces::Int = 2, minify::Bool = false)
    if !minify
        padding = " "^(indentation*nspaces)
        println(buf, padding)
    end

    return nothing
end

"""
    _check_hline(ptable::ProcessedTable, hlines, body_hlines::AbstractVector, i::Int) -> Bool

Check if there is a horizontal line after the `i`th row of `ptable` considering the options
`hlines` and `body_hlines`.
"""
function _check_hline(
    ptable::ProcessedTable,
    hlines::Vector{Int},
    body_hlines::AbstractVector,
    i::Int
)
    num_header_rows = _header_size(ptable)[1]

    if (i == 0) && (0 ∈ hlines)
        return true

    elseif (num_header_rows > 0) && (i <= num_header_rows)
        if (i == num_header_rows)
            if 1 ∈ hlines
                return true
            elseif 0 ∈ body_hlines
                return true
            end
        end

    else
        Δ = num_header_rows > 0 ? 1 : 0
        i = i - num_header_rows + Δ

        if (i ∈ hlines)
            return true

        elseif ((i - Δ) ∈ body_hlines)
            return true
        end
    end

    return false
end

function _check_hline(
    ptable::ProcessedTable,
    hlines::Symbol,
    body_hlines::AbstractVector,
    i::Int
)
    if hlines == :all
        return true
    elseif hlines == :none
        return _check_hline(ptable, Int[], body_hlines, i)
    else
        error("`hlines` must be `:all`, `:none`, or a vector of integers.")
    end
end

"""
    _check_vline(ptable::ProcessedTable, vlines::AbstractVector, j::Int) -> Bool

Check if there is a vertical line after the `j`th column of `ptable` considering the option
`vlines`.
"""
function _check_vline(ptable::ProcessedTable, vlines::AbstractVector, j::Int)
    num_printed_columns = _size(ptable)[2]

    if (j == 0) && (:begin ∈ vlines)
        return true
    elseif (j == num_printed_columns) && (:end ∈ vlines)
        return true
    elseif (j ∈ vlines)
        return true
    else
        return false
    end
end

function _check_vline(ptable::ProcessedTable, vlines::Symbol, j::Int)
    if vlines == :all
        return true
    elseif vlines == :none
        return false
    else
        error("`vlines` must be `:all`, `:none`, or a vector of integers.")
    end
end

"""
    _count_hlines(ptable::ProcessedTable, hlines::Vector{Int}, body_hlines::Vector{Int}) -> Int

Count the number of horizontal lines.
"""
function _count_hlines(ptable::ProcessedTable, hlines::Vector{Int}, body_hlines::Vector{Int})
    num_header_lines = _header_size(ptable)[1]
    num_rows = _size(ptable)[1]
    Δ = num_header_lines > 0 ? 1 : 0

    merged_hlines = unique(sort(vcat(hlines, body_hlines .+ Δ)))

    total_hlines = 0

    for h in merged_hlines
        if 0 ≤ h ≤ num_rows
            total_hlines += 1
        end
    end

    return total_hlines
end

function _count_hlines(ptable::ProcessedTable, hlines::Symbol, body_hlines::Vector{Int})
    num_rows = _size(ptable)[1]

    if hlines == :all
        return num_rows + 1

    elseif hlines == :none
        num_header_lines = _header_size(ptable)[1]
        Δ = num_header_lines > 0 ? 1 : 0
        merged_hlines = unique(sort(body_hlines .+ Δ))
        total_hlines = 0

        for h in merged_hlines
            if 0 ≤ h ≤ num_rows
                total_hlines += 1
            end
        end

        return total_hlines
    end
end

"""
    _count_vlines(ptable::ProcessedTable, vlines::Vector{Int}) -> Int

Count the number of vertical lines.
"""
function _count_vlines(ptable::ProcessedTable, vlines::Vector{Int})
    num_columns = _size(ptable)[2]
    total_vlines = 0

    for h in vlines
        if 0 ≤ h ≤ num_columns
            total_vlines += 1
        end
    end

    return total_vlines
end

function _count_vlines(ptable::ProcessedTable, vlines::Symbol)
    num_columns = _size(ptable)[2]

    if vlines == :all
        return num_columns + 1

    elseif vlines == :none
        return 0

    end
end

# Return the string with the information about the number of omitted cells.
function _get_omitted_cell_string(num_omitted_rows::Int, num_omitted_columns::Int)
    cs_str_col = ""
    cs_str_and = ""
    cs_str_row = ""

    if num_omitted_columns > 0
        cs_str_col = string(num_omitted_columns)
        cs_str_col *= num_omitted_columns > 1 ? " columns" : " column"
    end

    if num_omitted_rows > 0
        cs_str_row = string(num_omitted_rows)
        cs_str_row *= num_omitted_rows > 1 ? " rows" : " row"

        num_omitted_columns > 0 && (cs_str_and = " and ")
    end

    cs_str = cs_str_col * cs_str_and * cs_str_row * " omitted"

    return cs_str
end

"""
    _process_hlines(ptable::ProcessedTable, hlines) -> Union{Symbol, Vector{Int}}

Process the horizontal lines `hlines` considering the processed table `ptable`.
"""
@inline function _process_hlines(ptable::ProcessedTable, hlines::Symbol)
    return hlines
end

@inline function _process_hlines(ptable::ProcessedTable, hlines::AbstractVector)
    # The symbol `:begin` is replaced by 0, the symbol `:header` by the line after the
    # header, and the symbol `:end` is replaced by the last row.
    num_header_rows = _header_size(ptable)[1]
    num_rows = _size(ptable)[1]
    Δ  = num_header_rows > 0 ? 1 : 0

    hlines = replace(
        hlines,
        :begin  => 0,
        :header => num_header_rows > 0 ? 1 : -1,
        :end    => num_rows - num_header_rows + Δ
    )

    return Vector{Int}(hlines)
end

"""
    _process_vlines(ptable::ProcessedTable, vlines) -> Union{Symbol, Vector{Int}}

Process the vertical lines `vlines` considering the processed table `ptable`.
"""
@inline function _process_vlines(ptable::ProcessedTable, vlines::Symbol)
    return vlines
end

function _process_vlines(ptable::ProcessedTable, vlines::AbstractVector)
    # The symbol `:begin` is replaced by 0 and the symbol `:end` is replaced by the last
    # column.
    vlines = replace(
        vlines,
        :begin => 0,
        :end   => _size(ptable)[2]
    )

    return Vector{Int}(vlines)
end
