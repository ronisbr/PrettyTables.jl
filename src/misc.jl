# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Miscellaneous functions used by all back-ends.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export compact_type_str

"""
    compact_type_str(T)

Return a string with a compact representation of type `T`.
"""
compact_type_str(T) = string(T)

function compact_type_str(T::Union)
    if VERSION < v"1.3.0"
        str = if T >: Missing
            string(Core.Compiler.typesubtract(T, Missing)) * "?"
        else
            string(T)
        end
    else
        str = T >: Missing ? string(nonmissingtype(T)) * "?" : string(T)
    end

    str = replace(str, "Union" => "U")
    return str
end

################################################################################
#                              Private functions
################################################################################

"""
    _aprint(buf::IO, [v,] indentation = 0, nspace = 2, minify = false)

Print the variable `v` to the buffer `buf` at the indentation level
`indentation`. Each level has `nspaces` spaces. If `minify` is `true`, then the
text is printed without breaklines or padding.

If `v` is not present, then only the indentation spaces will be printed.
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
            # If the token is empty, then we do nothing to avoid unnecessary
            # white spaces.
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

function _aprint(
    buf::IO,
    indentation::Int = 0,
    nspaces::Int = 2,
    minify::Bool = false
)
    if !minify
        padding = " "^(indentation*nspaces)
        print(buf, padding)
    end

    return nothing
end

"""
    _aprintln(buf::IO, [v,] indentation = 0, nspaces = 2, minify = false)

Same as `_aprint`, but a new line will be added at the end. Notice that this
newline is not added if `minify` is `true` Notice that this newline is not added
if `minify` is `true`.
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

function _aprintln(
    buf::IO,
    indentation::Int = 0,
    nspaces::Int = 2,
    minify::Bool = false
)
    if !minify
        padding = " "^(indentation*nspaces)
        println(buf, padding)
    end

    return nothing
end

"""
    _process_hlines(hlines::Union{Symbol,AbstractVector}, body_hlines::AbstractVector, num_printed_rows::Int, noheader::Bool)

Process the horizontal lines in `hlines` and `body_hlines` considering the
number of filtered rows `num_filtered_rows` and if the header is present
(`noheader`).

It returns a vector of `Int` stating where the horizontal lines must be drawn.
"""
@inline function _process_hlines(
    hlines::Symbol,
    body_hlines::AbstractVector,
    num_filtered_rows::Int,
    noheader::Bool
)
    if hlines == :all
        vhlines = collect(0:1:num_filtered_rows + !noheader)
    elseif hlines == :none
        vhlines = Int[]
    else
        error("`hlines` must be `:all`, `:none`, or a vector of integers.")
    end

    return _process_hlines(vhlines, body_hlines, num_filtered_rows, noheader)
end

function _process_hlines(
    hlines::AbstractVector,
    body_hlines::AbstractVector,
    num_filtered_rows::Int,
    noheader::Bool
)
    # The symbol `:begin` is replaced by 0, the symbol `:header` by the line
    # after the header, and the symbol `:end` is replaced by the last row.
    hlines = replace(
        hlines,
        :begin  => 0,
        :header => noheader ? -1 : 1,
        :end    => num_filtered_rows + !noheader
    )

    # All numbers less than 1 and higher or equal the number of filtered rows
    # must be removed from `body_hlines`.
    body_hlines = filter(x -> (x ≥ 1) && (x < num_filtered_rows), body_hlines)

    # Merge `hlines` with `body_hlines`.
    hlines = unique(vcat(hlines, body_hlines .+ !noheader))
    #                                               ^
    #                                               |
    # If we have header, then the index in `body_hlines` must be incremented.

    # Make sure that the compiler knows that this function always returns a
    # vector of `Int`s.
    ret::Vector{Int} = Vector{Int}(hlines)

    return ret
end

"""
    _process_vlines(vlines::AbstractVector, num_printed_cols::Int)

Process the vertical lines `vlines` considerering the number of printed columns
`num_printed_cols`.

It returns a vector of `Int` stating where the vertical lines must be drawn.
"""
@inline function _process_vlines(vlines::Symbol, num_printed_cols::Int)
    # Process `vlines`.
    if vlines == :all
        vvlines = collect(0:1:num_printed_cols)
    elseif vlines == :none
        vvlines = Int[]
    else
        error("`vlines` must be `:all`, `:none`, or a vector of integers.")
    end

    return _process_vlines(vvlines, num_printed_cols)
end

function _process_vlines(vlines::AbstractVector, num_printed_cols::Int)
    # Process `vlines`.
    if vlines == :all
        vlines = collect(0:1:num_printed_cols)
    elseif vlines == :none
        vlines = Int[]
    elseif !(typeof(vlines) <: AbstractVector)
        error("`vlines` must be `:all`, `:none`, or a vector of integers.")
    end

    # The symbol `:begin` is replaced by 0 and the symbol `:end` is replaced by
    # the last column.
    vlines = replace(
        vlines,
        :begin => 0,
        :end   => num_printed_cols
    )

    return Vector{Int}(vlines)
end
