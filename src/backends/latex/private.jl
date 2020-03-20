# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Private functions and macros.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Convert the alignment symbol into a LaTeX alignment string.
function _latex_alignment(s::Symbol)
    if s == :l
        return "l"
    elseif s == :c
        return "c"
    elseif s == :r
        return "r"
    else
        error("Invalid LaTeX alignment symbol: $s.")
    end
end

# Get the LaTeX table description (alignment and vertical columns).
function _latex_table_desc(alignment::Vector{Symbol},
                           vlines::AbstractVector,
                           left_vline::AbstractString,
                           mid_vline::AbstractString,
                           right_vline::AbstractString)
    str = "{"

    0 ∈ vlines && (str *= left_vline)

    for i = 1:length(alignment)
        str *= _latex_alignment(alignment[i])

        if i ∈ vlines
            if i != length(alignment)
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
