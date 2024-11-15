## Description #############################################################################
#
# Private functions for the LaTeX back end.
#
############################################################################################

# == Strings ===============================================================================

"""
    _latex__escape_str(@nospecialize(io::IO), s::AbstractString, replace_newline::Bool = false, escape_latex_chars::Bool = true) -> Nothing
    _latex__escape_str(s::AbstractString, replace_newline::Bool = false, escape_latex_chars::Bool = true) -> String

Print the string `s` in `io` escaping the characters for the latex back end. If `io` is
omitted, the escaped string is returned.

If `replace_newline` is `true`, `\n` is replaced with `<br>`. Otherwise, it is escaped,
leading to `\\n`.

If `escape_latex_chars` is `true`, `&`, `<`, `>`, `"`, and `'`  will be replaced by latex
sequences.
"""
function _latex__escape_str(
    io::IO,
    s::AbstractString,
    esc::String = ""
)
    a = Iterators.Stateful(s)
    for c in a
        if c in esc
            print(io, '\\', c)
        elseif isascii(c)
            c == '\0'          ? print(io, "\\textbackslash{}0") :
            c == '\e'          ? print(io, "\\textbackslash{}e") :
            c == '\\'          ? print(io, "\\textbackslash{}") :
            '\a' <= c <= '\r'  ? print(io, "\\textbackslash{}", "abtnvfr"[Int(c)-6]) :
            c == '%'           ? print(io, "\\%") :
            c == '#'           ? print(io, "\\#") :
            c == '\$'          ? print(io, "\\\$") :
            c == '&'           ? print(io, "\\&") :
            c == '_'           ? print(io, "\\_") :
            c == '^'           ? print(io, "\\^") :
            c == '{'           ? print(io, "\\{") :
            c == '}'           ? print(io, "\\}") :
            c == '~'           ? print(io, "\\textasciitilde{}") :
            isprint(c)         ? print(io, c) :
                                 print(io, "\\textbackslash{}x", string(UInt32(c), base = 16, pad = 2))
        elseif !Base.isoverlong(c) && !Base.ismalformed(c)
            isprint(c)         ? print(io, c) :
            c <= '\x7f'        ? print(io, "\\textbackslash{}x", string(UInt32(c), base = 16, pad = 2)) :
            c <= '\uffff'      ? print(io, "\\textbackslash{}u", string(UInt32(c), base = 16, pad = Base.need_full_hex(peek(a)) ? 4 : 2)) :
                                 print(io, "\\textbackslash{}U", string(UInt32(c), base = 16, pad = Base.need_full_hex(peek(a)) ? 8 : 4))
        else # malformed or overlong
            u = bswap(reinterpret(UInt32, c))
            while true
                print(io, "\\textbackslash{}x", string(u % UInt8, base = 16, pad = 2))
                (u >>= 8) == 0 && break
            end
        end
    end
end

function _latex__escape_str(s::AbstractString, esc::String = "")
    return sprint(
        _latex__escape_str,
        s,
        esc,
        sizehint = lastindex(s)
    )
end
