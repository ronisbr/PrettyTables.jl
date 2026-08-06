## Description #############################################################################
#
# Private functions for the LaTeX back end.
#
############################################################################################

# == Strings ===============================================================================

"""
    _latex__alignment_to_str(a::Symbol) -> String

Convert the alignment `a` to the corresponding string for LaTeX.
"""
function _latex__alignment_to_str(a::Symbol)
    return if a ∈ (:l, :L)
        "l"
    elseif a ∈ (:c, :C)
        "c"
    else
        "r"
    end
end

"""
    _latex__add_environments(str::String, envs::Union{Nothing, Vector{String}}) -> String

Apply the latex environments in `envs` to the string `str`. If `envs` is `nothing`, it
returns `str` unchanged.
"""
function _latex__add_environments(str::String, envs::Vector{String})
    # Do not apply any environment if the string is empty.
    isempty(str) && return str

    for env in envs
        str = "\\$env{$str}"
    end

    return str
end

_latex__add_environments(s::String, ::Nothing) = s

raw"""
    _latex__escape_str(io::IO, s::AbstractString, esc::String = "") -> Nothing
    _latex__escape_str(s::AbstractString, esc::String = "") -> String

Print the string `s` in `io` escaping the characters for the LaTeX back end. If `io` is
omitted, the escaped string is returned.

Every character in `esc` is escaped by prefixing it with a backslash. On top of that, the
LaTeX metacharacters `%`, `#`, `$`, `&`, `_`, `{`, and `}` are escaped, `^` and `~` are
replaced by `\textasciicircum{}` and `\textasciitilde{}`, and the backslash itself is
replaced by `\textbackslash{}`. Control and non-printable characters are emitted using a
`\textbackslash{}x`, `\textbackslash{}u`, or `\textbackslash{}U` sequence.

Notice that `<`, `>`, `"`, and `'` are **not** escaped. Under the OT1 font encoding, `<` and
`>` are typeset as `¡` and `¿`.
"""
function _latex__escape_str(io::IO, s::AbstractString, esc::String = "")
    a = Iterators.Stateful(s)
    for c in a
        if c in esc
            print(io, '\\', c)
        elseif isascii(c)
            c == '\0'         ? print(io, "\\textbackslash{}0") :
            c == '\e'         ? print(io, "\\textbackslash{}e") :
            c == '\\'         ? print(io, "\\textbackslash{}") :
            '\a' <= c <= '\r' ? print(io, "\\textbackslash{}", "abtnvfr"[Int(c) - 6]) :
            c == '%'          ? print(io, "\\%") :
            c == '#'          ? print(io, "\\#") :
            c == '\$'         ? print(io, "\\\$") :
            c == '&'          ? print(io, "\\&") :
            c == '_'          ? print(io, "\\_") :
            c == '^'          ? print(io, "\\textasciicircum{}") :
            c == '{'          ? print(io, "\\{") :
            c == '}'          ? print(io, "\\}") :
            c == '~'          ? print(io, "\\textasciitilde{}") :
            isprint(c)        ? print(io, c) :
            print(io, "\\textbackslash{}x", string(UInt32(c); base = 16, pad = 2))
        elseif !Base.isoverlong(c) && !Base.ismalformed(c)
            isprint(c)    ? print(io, c) :
            c <= '\x7f'   ? print(io, "\\textbackslash{}x", string(UInt32(c); base = 16, pad = 2)) :
            c <= '\uffff' ? print(io, "\\textbackslash{}u", string(UInt32(c); base = 16, pad = Base.need_full_hex(peek(a)) ? 4 : 2)) :
            print(io, "\\textbackslash{}U", string(UInt32(c); base = 16, pad = Base.need_full_hex(peek(a)) ? 8 : 4))
        else # malformed or overlong
            u = bswap(reinterpret(UInt32, c))
            while true
                print(io, "\\textbackslash{}x", string(u % UInt8; base = 16, pad = 2))
                (u >>= 8) == 0 && break
            end
        end
    end
end

function _latex__escape_str(s::AbstractString, esc::String = "")
    return sprint(_latex__escape_str, s, esc; sizehint = lastindex(s))
end

# == Table =================================================================================

"""
    _latex__table_header_description(
        td::TableData,
        tf::LatexTableFormat,
        vertical_lines_at_data_columns::AbstractVector{Int}
    ) -> String

Create the LaTeX table header description with the column alignments and vertical lines
considering the table data `td`, table format `tf`, and the processed information about
vertical lines at data columns `vertical_lines_at_data_columns`.
"""
function _latex__table_header_description(
    td::TableData, tf::LatexTableFormat, vertical_lines_at_data_columns::AbstractVector{Int}
)
    num_columns = td.num_columns

    desc = IOBuffer(; sizehint = 2num_columns + 3)

    # == Table Beginning ===================================================================

    tf.vertical_line_at_beginning && print(desc, '|')

    # == Row Number Column =================================================================

    if td.show_row_number_column
        print(desc, _row_number_column_alignment(td) |> _latex__alignment_to_str)

        if tf.vertical_line_after_row_number_column
            print(desc, '|')
        end
    end

    # == Row Labels ========================================================================

    if _has_row_labels(td)
        print(desc, _row_label_column_alignment(td) |> _latex__alignment_to_str)
        tf.vertical_line_after_row_label_column && print(desc, '|')
    end

    # == Data Columns ======================================================================

    nc = _number_of_printed_data_columns(td)

    for i in 1:nc
        print(desc, _data_column_alignment(td, i) |> _latex__alignment_to_str)

        vline = i in vertical_lines_at_data_columns

        if (i == nc) && tf.vertical_line_after_data_columns
            vline = true
        end

        vline && print(desc, '|')
    end

    # == Continuation Column ===============================================================

    if nc < num_columns
        print(desc, 'c')
        tf.vertical_line_after_continuation_column && print(desc, '|')
    end

    return String(take!(desc))
end
