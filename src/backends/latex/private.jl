# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Private functions and macros.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Apply an alignment to a LaTeX table cell.
function _latex_apply_cell_alignment(str, alignment, j, num_printed_cols,
                                     show_row_number, vlines, left_vline,
                                     mid_vline, right_vline)

    a = _latex_alignment(alignment)
    aux_j = show_row_number ? j+1 : j

    # We only need to add left vertical line if it is the first
    # column.
    lvline = (0 ∈ vlines) && (aux_j-1 == 0) ? left_vline : ""

    # For the right vertical line, we must check if it is a mid line
    # or right line.
    if aux_j ∈ vlines
        rvline = (j == num_printed_cols) ? right_vline : mid_vline
    else
        rvline = ""
    end

    # Wrap the data into the multicolumn environment.
    return _latex_envs(str, "multicolumn{1}{$(lvline)$(a)$(rvline)}")
end

# Convert the alignment symbol into a LaTeX alignment string.
function _latex_alignment(s::Symbol)
    if (s == :l) || (s == :L)
        return "l"
    elseif (s == :c) || (s == :C)
        return "c"
    elseif (s == :r) || (s == :R)
        return "r"
    else
        error("Invalid LaTeX alignment symbol: $s.")
    end
end

# Get the LaTeX table description (alignment and vertical columns).
function _latex_table_desc(id_cols::AbstractVector,
                           alignment::Vector{Symbol},
                           show_row_number::Bool,
                           vlines::AbstractVector,
                           left_vline::AbstractString,
                           mid_vline::AbstractString,
                           right_vline::AbstractString)

    Δc = show_row_number ? 1 : 0

    str = "{"

    0 ∈ vlines && (str *= left_vline)

    # Add the alignment information of the row number column if required.
    Δc = 0
    if show_row_number
        Δc = 1
        str *= "l"
        1 ∈ vlines && (str *= mid_vline)
    end

    # Process the alignment of all the other columns.
    for i = 1:length(id_cols)
        str *= _latex_alignment(alignment[id_cols[i]])

        if i+Δc ∈ vlines
            if i != length(id_cols)
                str *= mid_vline
            else
                str *= right_vline
            end
        end
    end

    str *= "}"

    return str
end

# Wrap the `text` into LaTeX environment(s).
_latex_envs(text::AbstractString, envs::Vector{String}) = _latex_envs(text, envs, length(envs))
_latex_envs(text::AbstractString, env::String) = "\\" * string(env) * "{" * text * "}"

function _latex_envs(text::AbstractString, envs::Vector{String}, i::Int)
    @inbounds if i > 0
        str = _latex_envs(text, envs[i])
        return _latex_envs(str, envs, i -= 1)
    end

    return text
end

# This was adapted from Julia `escape_string` function. In case of LaTeX, we
# should not escape the sequence `\\`, i.e. the backslash that is already
# escaped.
function _str_latex_escaped(io::IO, s::AbstractString, esc="")
    a = Iterators.Stateful(s)
    for c in a
        if c in esc
            print(io, '\\', c)
        elseif isascii(c)
            c == '\0'          ? print(io, escape_nul(peek(a))) :
            c == '\e'          ? print(io, "\\e") :
          # c == '\\'          ? print(io, "\\\\") :
            '\a' <= c <= '\r'  ? print(io, '\\', "abtnvfr"[Int(c)-6]) :
            isprint(c)         ? print(io, c) :
                                 print(io, "\\x", string(UInt32(c), base = 16, pad = 2))
        elseif !isoverlong(c) && !ismalformed(c)
            isprint(c)         ? print(io, c) :
            c <= '\x7f'        ? print(io, "\\x", string(UInt32(c), base = 16, pad = 2)) :
            c <= '\uffff'      ? print(io, "\\u", string(UInt32(c), base = 16, pad = need_full_hex(peek(a)) ? 4 : 2)) :
                                 print(io, "\\U", string(UInt32(c), base = 16, pad = need_full_hex(peek(a)) ? 8 : 4))
        else # malformed or overlong
            u = bswap(reinterpret(UInt32, c))
            while true
                print(io, "\\x", string(u % UInt8, base = 16, pad = 2))
                (u >>= 8) == 0 && break
            end
        end
    end
end

_str_latex_escaped(s::AbstractString, esc="") =
    sprint(_str_latex_escaped, s, esc, sizehint=lastindex(s))
