## Description #############################################################################
#
# Functions related to string processing
#
############################################################################################

# This function was adapted from `escape_string`.
function _escape_markdown_str(
    @nospecialize(io::IO),
    s::AbstractString,
    escape_markdown::Bool,
    replace_newline::Bool
)
    a = Iterators.Stateful(s)
    for c in a
        if isascii(c)
            c == '\n'          ? print(io, replace_newline ? "<br>" : "\\n") :
            c == '*'           ? print(io, escape_markdown ? "\\*" : "*") :
            c == '_'           ? print(io, escape_markdown ? "\\_" : "_") :
            c == '~'           ? print(io, escape_markdown ? "\\~" : "~") :
            c == '`'           ? print(io, escape_markdown ? "\\`" : "`") :
            c == '|'           ? print(io, escape_markdown ? "\\|" : "|") :
            '\a' <= c <= '\r'  ? print(io, "\\", "abtnvfr"[Int(c)-6]) :
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

function _escape_markdown_str(s::AbstractString, escape_markdown::Bool, replace_newline::Bool)
    return sprint(
        _escape_markdown_str,
        s,
        escape_markdown,
        replace_newline;
        sizehint = lastindex(s)
    )
end
