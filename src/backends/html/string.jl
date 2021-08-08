# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions related to string processing in HTML backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# This was adapted from Julia `escape_string` function. In case of HTML, we
# should replace some special characters like `<` and `>`.
#
# If `replace_newline` is `true`, then `\n` is replaced with `<br>`. Otherwise,
# it is escaped, leading to `\\n`.
function _str_html_escaped(
    io::IO,
    s::AbstractString,
    replace_newline::Bool = false,
    escape_html_chars::Bool = true,
)
    a = Iterators.Stateful(s)
    for c in a
        if isascii(c)
            c == '\n'          ? (replace_newline ? print(io, "<BR>") : print(io, "\\n")) :
            c == '&'           ? (escape_html_chars ? print(io, "&amp;")  : print(io, c)) :
            c == '<'           ? (escape_html_chars ? print(io, "&lt;")   : print(io, c)) :
            c == '>'           ? (escape_html_chars ? print(io, "&gt;")   : print(io, c)) :
            c == '"'           ? (escape_html_chars ? print(io, "&quot;") : print(io, c)) :
            c == '\''          ? (escape_html_chars ? print(io, "&apos;") : print(io, c)) :
            c == '\0'          ? print(io, escape_nul(peek(a))) :
            c == '\e'          ? print(io, "\\e") :
            c == '\\'          ? print(io, "\\\\") :
            '\a' <= c <= '\r'  ? print(io, '\\', "abtnvfr"[Int(c)-6]) :
            c == '%'           ? print(io, "\\%") :
            isprint(c)         ? print(io, c) :
                                 print(io, "\\x", string(UInt32(c), base = 16, pad = 2))
        elseif !isoverlong(c) && !ismalformed(c)
            isprint(c)         ? print(io, c) :
            c <= '\x7f'        ? print(io, "\\x", string(UInt32(c), base = 16, pad = 2)) :
            c <= '\uffff'      ? print(io, "\\u", string(UInt32(c), base = 16, pad = Base.need_full_hex(peek(a)) ? 4 : 2)) :
                                 print(io, "\\U", string(UInt32(c), base = 16, pad = Base.need_full_hex(peek(a)) ? 8 : 4))
        else # malformed or overlong
            u = bswap(reinterpret(UInt32, c))
            while true
                print(io, "\\x", string(u % UInt8, base = 16, pad = 2))
                (u >>= 8) == 0 && break
            end
        end
    end
end

function _str_html_escaped(
    s::AbstractString,
    replace_newline::Bool = false,
    escape_html_chars::Bool = true
)
    return sprint(
        _str_html_escaped,
        s,
        replace_newline,
        escape_html_chars;
        sizehint = lastindex(s)
    )
end
