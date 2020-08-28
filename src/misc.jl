# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Description
#
#   Miscellaneous functions used by all back-ends.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
    _aprint(buf, v, indentation = 0, nspace = 2)

Print the variable `v` to the buffer `buf` at the indentation level
`indentation`. Each level has `nspaces` spaces.

"""
@inline function _aprint(buf, v, indentation = 0, nspaces = 2)
    print(buf, " "^(indentation*nspaces))
    print(buf, v)
end

"""
    _aprintln(buf, v, indentation = 0, nspaces = 2)

Same as `_aprint`, but a new line will be added at the end.

"""
@inline function _aprintln(buf, v, indentation = 0, nspaces = 2)
    print(buf, " "^(indentation*nspaces))
    println(buf, v)
end

"""
    _process_hlines(hlines, body_hlines, num_printed_rows, noheader)

Process the horizontal lines in `hlines` and `body_hlines` considering the
number of printed rows `num_printed_rows` and if the header is present
(`noheader`).

It returns a vector of `Int` stating where the horizontal lines must be drawn.

"""
function _process_hlines(hlines, body_hlines, num_printed_rows, noheader)
    if hlines == :all
        hlines = collect(0:1:num_printed_rows + !noheader)
    elseif hlines == :none
        hlines = Int[]
    elseif !(typeof(hlines) <: AbstractVector)
        error("`hlines` must be `:all`, `:none`, or a vector of integers.")
    end

    # The symbol `:begin` is replaced by 0, the symbol `:header` by the line
    # after the header, and the symbol `:end` is replaced by the last row.
    hlines = replace(hlines, :begin  => 0,
                             :header => noheader ? -1 : 1,
                             :end    => num_printed_rows + !noheader)

    # All numbers less than 1 and higher or equal the number of printed rows
    # must be # removed from `body_hlines`.
    body_hlines = filter(x -> (x ≥ 1) && (x < num_printed_rows), body_hlines)

    # Merge `hlines` with `body_hlines`.
    hlines = unique(vcat(hlines, body_hlines .+ !noheader))
    #                                               ^
    #                                               |
    # If we have header, then the index in `body_hlines` must be incremented.

    return hlines
end

"""
    _process_vlines(vlines, num_printed_cols)

Process the vertical lines `vlines` considerering the number of printed columns
`num_printed_cols`.

It returns a vector of `Int` stating where the vertical lines must be drawn.

"""
function _process_vlines(vlines, num_printed_cols)
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
    vlines = replace(vlines, :begin => 0,
                             :end   => num_printed_cols)

    return vlines
end

"""
    _str_escaped(str::AbstractString)

Return the escaped string representation of `str`.

"""
_str_escaped(str::AbstractString) =
    # NOTE: Here we cannot use `escape_string(str)` because it also adds the
    # character `"` to the list of characters to be escaped.
    sprint(escape_string, str, "", sizehint = lastindex(str))
