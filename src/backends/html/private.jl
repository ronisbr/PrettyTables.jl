## Description #############################################################################
#
# Private functions for the HTML back end.
#
############################################################################################

# == Strings ===============================================================================

raw"""
    _html__escape_str(
        @nospecialize(io::IO),
        s::AbstractString,
        replace_newline::Bool = false,
        escape_html_chars::Bool = true
    ) -> Nothing
    _html__escape_str(
        s::AbstractString,
        replace_newline::Bool = false,
        escape_html_chars::Bool = true
    ) -> String

Print the string `s` in `io` escaping the characters for the HTML back end. If `io` is
omitted, the escaped string is returned.

If `replace_newline` is `true`, `\n` is replaced with `<br>`. Otherwise, it is escaped when
`escape_html_chars` is `true`, leading to `\\n`, and kept unchanged otherwise.

If `escape_html_chars` is `true`, `&`, `<`, `>`, `"`, and `'` will be replaced by HTML
sequences.
"""
function _html__escape_str(
    io::IO, s::AbstractString, replace_newline::Bool = false, escape_html_chars::Bool = true
)
    a = Iterators.Stateful(s)
    for c in a
        if Base.isascii(c)
            # When `escape_html_chars` is `false`, the user asked for the cell content to be
            # emitted as raw HTML. Hence, we must keep the line breaks. Otherwise, we would
            # corrupt the HTML code with a literal `\n`.
            c == '\n'         ? (
                replace_newline ? print(io, "<br>") :
                escape_html_chars ? print(io, "\\n") : print(io, c)
            ) :
            c == '&'          ? (escape_html_chars ? print(io, "&amp;") : print(io, c))  :
            c == '<'          ? (escape_html_chars ? print(io, "&lt;") : print(io, c))   :
            c == '>'          ? (escape_html_chars ? print(io, "&gt;") : print(io, c))   :
            c == '"'          ? (escape_html_chars ? print(io, "&quot;") : print(io, c)) :
            c == '\''         ? (escape_html_chars ? print(io, "&apos;") : print(io, c)) :
            c == '\0'         ? print(io, Base.escape_nul(peek(a)))                      :
            c == '\e'         ? print(io, "\\e")                                         :
            # When `escape_html_chars` is `false`, the user asked for the cell content to be
            # emitted as raw HTML. Escaping the backslash would corrupt any inline CSS or
            # JavaScript in it.
            c == '\\'         ? (escape_html_chars ? print(io, "\\\\") : print(io, c))     :
            '\a' <= c <= '\r' ? print(io, '\\', "abtnvfr"[Int(c) - 6])                   :
            isprint(c)        ? print(io, c)                                             :
            print(io, "\\x", string(UInt32(c); base = 16, pad = 2))
        elseif !Base.isoverlong(c) && !Base.ismalformed(c)
            isprint(c)    ? print(io, c) :
            c <= '\x7f'   ? print(io, "\\x", string(UInt32(c); base = 16, pad = 2)) :
            c <= '\uffff' ? print(io, "\\u", string(UInt32(c); base = 16, pad = Base.need_full_hex(peek(a)) ? 4 : 2)) :
            print(io, "\\U", string(UInt32(c); base = 16, pad = Base.need_full_hex(peek(a)) ? 8 : 4))
        else # malformed or overlong
            u = bswap(reinterpret(UInt32, c))
            while true
                print(io, "\\x", string(u % UInt8; base = 16, pad = 2))
                (u >>= 8) == 0 && break
            end
        end
    end
end

function _html__escape_str(
    s::AbstractString, replace_newline::Bool = false, escape_html_chars::Bool = true
)
    return sprint(
        _html__escape_str, s, replace_newline, escape_html_chars; sizehint = lastindex(s)
    )
end

# == Styles ================================================================================

const _HTML__ALIGNMENT_MAP = Dict(
    :l => "left", :L => "left", :c => "center", :C => "center", :r => "right", :R => "right"
)

"""
    _html__add_alignment_to_style!(style::Vector{HtmlPair}, alignment::Symbol) -> Nothing

Add the HTML alignment property to `style` according to the `alignment` symbol.
"""
function _html__add_alignment_to_style!(style::Vector{HtmlPair}, alignment::Symbol)
    if (alignment == :n) || (alignment == :N)
        return nothing
    elseif haskey(_HTML__ALIGNMENT_MAP, alignment)
        return push!(style, "text-align" => _HTML__ALIGNMENT_MAP[alignment])
    else
        return push!(style, "text-align" => _HTML__ALIGNMENT_MAP[:r])
    end
end

"""
    _html__write_style(buf::IO, style::Union{Nothing, Vector{HtmlPair}}) -> Nothing

Write the HTML style attribute to `buf` using the information in the vector `style`.

Notice that this function writes directly to `buf` instead of building intermediate strings.
Otherwise, we would allocate multiple strings per printed cell.
"""
function _html__write_style(buf::IO, style::Vector{HtmlPair})
    # If there are no keys in the style vector, we have nothing to do.
    isempty(style) && return nothing

    # Make sure the style is sorted by key.
    sort!(style)

    # Every value can be empty, in which case there is no style to emit. Hence, we must
    # check it before writing the attribute opening.
    first_pair = true

    # NOTE: The separator is *prepended* to every entry but the first. Appending it and
    # skipping the last index left a trailing space whenever the last pair had an empty
    # value, as in `["a" => "1", "z" => ""]`.
    @inbounds for (key, value) in style
        # If the value is empty, then just continue.
        isempty(value) && continue

        if first_pair
            print(buf, " style = \"")
        else
            print(buf, ' ')
        end

        print(buf, key)
        print(buf, ": ")
        print(buf, value)
        print(buf, ';')

        first_pair = false
    end

    !first_pair && print(buf, '"')

    return nothing
end

_html__write_style(::IO, ::Nothing) = nothing

"""
    _html__create_style(style::Union{Nothing, Vector{HtmlPair}}) -> String

Create the HTML style string using the information in the vector `style`.
"""
function _html__create_style(style::Vector{HtmlPair})
    buf = IOBuffer()
    _html__write_style(buf, style)
    return String(take!(buf))
end

_html__create_style(::Nothing) = ""

# == Tags ==================================================================================

"""
    _html__open_tag(tag::String; kwargs...) -> String

Create the string that opens the HTML `tag`.

# Keywords

- `properties::Union{Nothing, Vector{HtmlPair}}`: Tag properties.
    (**Default**: `nothing`)
- `style::Union{Nothing, Vector{HtmlPair}}`: Tag style.
    (**Default**: `nothing`)
"""
function _html__open_tag(
    tag::String;
    properties::Union{Nothing, Vector{HtmlPair}} = nothing,
    style::Union{Nothing, Vector{HtmlPair}} = nothing,
)
    buf = IOBuffer()
    _html__write_open_tag(buf, tag, properties, style)
    return String(take!(buf))
end

"""
    _html__write_open_tag(
        buf::IO,
        tag::String,
        properties::Union{Nothing, Vector{HtmlPair}},
        style::Union{Nothing, Vector{HtmlPair}}
    ) -> Nothing

Write the string that opens the HTML `tag` to `buf`.

Notice that this function writes directly to `buf` instead of building intermediate strings.
Otherwise, we would allocate multiple strings per printed cell.
"""
function _html__write_open_tag(
    buf::IO,
    tag::String,
    properties::Union{Nothing, Vector{HtmlPair}},
    style::Union{Nothing, Vector{HtmlPair}},
)
    print(buf, '<')
    print(buf, tag)

    if !isnothing(properties)
        # Make sure the properties are sorted by key.
        sort!(properties)

        for (k, v) in properties
            if !isempty(v)
                print(buf, ' ')
                print(buf, k)
                print(buf, " = \"")
                _html__escape_str(buf, v)
                print(buf, '"')
            end
        end
    end

    _html__write_style(buf, style)

    print(buf, '>')

    return nothing
end

"""
    _html__close_tag(tag::String) -> String

Create the string that closes the HTML `tag`.
"""
_html__close_tag(tag::String) = "</$tag>"

"""
    _html__create_tag(tag::String, content::String; kwargs...) -> String

Create an HTML `tag` with the `content`.

# Keywords

- `properties::Union{Nothing, Vector{HtmlPair}}`: Tag properties.
    (**Default**: `nothing`)
- `style::Union{Nothing, Vector{HtmlPair}}`: Tag style.
    (**Default**: `nothing`)
"""
function _html__create_tag(
    tag::String,
    content::String;
    properties::Union{Nothing, Vector{HtmlPair}} = nothing,
    style::Union{Nothing, Vector{HtmlPair}} = nothing,
)
    buf = IOBuffer(; sizehint = 32 + ncodeunits(tag) * 2 + ncodeunits(content))
    _html__write_open_tag(buf, tag, properties, style)
    print(buf, content)
    print(buf, "</")
    print(buf, tag)
    print(buf, '>')
    return String(take!(buf))
end

# == Top Bar ===============================================================================

"""
    _html__print_top_bar_section(
        buf::IOContext,
        position::String,
        text::String,
        decoration::Union{Nothing, Vector{HtmlPair}},
        il::Int,
        ns::Int;
        kwargs...
    )

Print the HTML top bar section.

# Arguments

- `buf::IOContext`: Buffer to which the top bar will be printed.
- `position::String`: Buffer position. It can be "left" or "right".
- `text::String`: Text to be printed in the selected position.
- `decoration::Union{Nothing, Vector{HtmlPair}}`: Text decoration.
- `il::Int`: Indentation level.
- `ns::Int`: Number of space per indentation level.

# Keywords

- `minify::Bool`: If `true`, the output will be minified.
    (**Default**: `false`)
"""
function _html__print_top_bar_section(
    buf::IOContext,
    position::String,
    text::String,
    decoration::Union{Nothing, Vector{HtmlPair}},
    il::Int,
    ns::Int;
    minify::Bool = false,
)
    style = isnothing(decoration) ? HtmlPair[] : copy(decoration)
    push!(style, "float" => position)

    _aprintln(buf, _html__open_tag("div"; style), il, ns; minify)
    il += 1

    _aprintln(buf, _html__create_tag("span", _html__escape_str(text)), il, ns; minify)

    il -= 1
    return _aprintln(buf, _html__close_tag("div"), il, ns; minify)
end
