## Description #############################################################################
#
# Private functions for the HTML back end.
#
############################################################################################

# == Strings ===============================================================================

"""
    _html__escape_str(@nospecialize(io::IO), s::AbstractString, replace_newline::Bool = false, escape_html_chars::Bool = true) -> Nothing
    _html__escape_str(s::AbstractString, replace_newline::Bool = false, escape_html_chars::Bool = true) -> String

Print the string `s` in `io` escaping the characters for the HTML back end. If `io` is
omitted, the escaped string is returned.

If `replace_newline` is `true`, `\n` is replaced with `<br>`. Otherwise, it is escaped,
leading to `\\n`.

If `replace_html_chars` is `true`, `&`, `<`, `>`, `"`, and `'`  will be replaced by HTML
sequences.
"""
function _html__escape_str(
    io::IO,
    s::AbstractString,
    replace_newline::Bool = false,
    escape_html_chars::Bool = true,
)
    a = Iterators.Stateful(s)
    for c in a
        if Base.isascii(c)
            c == '\n'          ? (replace_newline ? print(io, "<br>") : print(io, "\\n")) :
            c == '&'           ? (escape_html_chars ? print(io, "&amp;")  : print(io, c)) :
            c == '<'           ? (escape_html_chars ? print(io, "&lt;")   : print(io, c)) :
            c == '>'           ? (escape_html_chars ? print(io, "&gt;")   : print(io, c)) :
            c == '"'           ? (escape_html_chars ? print(io, "&quot;") : print(io, c)) :
            c == '\''          ? (escape_html_chars ? print(io, "&apos;") : print(io, c)) :
            c == '\0'          ? print(io, Base.escape_nul(peek(a))) :
            c == '\e'          ? print(io, "\\e") :
            c == '\\'          ? print(io, "\\\\") :
            '\a' <= c <= '\r'  ? print(io, '\\', "abtnvfr"[Int(c)-6]) :
            isprint(c)         ? print(io, c) :
                                 print(io, "\\x", string(UInt32(c), base = 16, pad = 2))
        elseif !Base.isoverlong(c) && !Base.ismalformed(c)
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

function _html__escape_str(
    s::AbstractString,
    replace_newline::Bool = false,
    escape_html_chars::Bool = true
)
    return sprint(
        _html__escape_str,
        s,
        replace_newline,
        escape_html_chars;
        sizehint = lastindex(s)
    )
end

# == Styles ================================================================================

const _HTML__ALIGNMENT_MAP = Dict(
    :l => "left",
    :L => "left",
    :c => "center",
    :C => "center",
    :r => "right",
    :R => "right"
)

"""
    _html__add_alignment_to_style!(style::Dict{String, String}, alignment::Symbol) -> Nothing

Add the HTML alignment property to `style` according to the `alignment` symbol.
"""
function _html__add_alignment_to_style!(style::Dict{String, String}, alignment::Symbol)
    if (alignment == :n) || (alignment == :N)
        return nothing
    elseif haskey(_HTML__ALIGNMENT_MAP, alignment)
        return style["text-align"] = _HTML__ALIGNMENT_MAP[alignment]
    else
        return style["text-align"] = _HTML__ALIGNMENT_MAP[:r]
    end

    return nothing
end

"""
    _html__create_style(style::Dict{String, String}) -> String

Create the HTML style string using the information in the dictionary `style`.
"""
function _html__create_style(style::Dict{String, String})
    # If there is no keys in the style dictionary, just return the tag.
    isempty(style) && return ""

    # Create the style string.
    style_str = " style = \""

    # We must sort the keys so that we can provide stable outputs.
    v   = collect(values(style))
    k   = collect(keys(style))
    ind = sortperm(k)

    @inbounds for i in eachindex(ind)
        value = v[ind[i]]
        key   = k[ind[i]]

        # If the value is empty, then just continue.
        isempty(value) && continue

        style_str *= "$(key): $value;"
        i != last(eachindex(ind)) && (style_str *= " ")
    end

    return style_str * "\""
end

_html__create_style(::Nothing) = ""

# == Tags ==================================================================================

"""
    _html__open_tag(tag::String; kwargs...) -> String

Create the string that opens the HTML `tag`.

# Keywords

- `properties::Union{Nothing, Dict{String, String}}`: Tag properties.
    (**Default**: `nothing`)
- `style::Union{Nothing, Dict{String, String}}`: Tag style.
    (**Default**: `nothing`)
"""
function _html__open_tag(
    tag::String;
    properties::Union{Nothing, Dict{String, String}} = nothing,
    style::Union{Nothing, Dict{String, String}} = nothing
)
    # Compile the text with the properties.
    properties_str = ""

    if !isnothing(properties)
        for (k, v) in properties
            if !isempty(v)
                v_str = _html__escape_str(v)
                properties_str *= " $k = \"$v_str\""
            end
        end
    end

    # Compile the text with the style.
    style_str = _html__create_style(style)

    # Return the tag.
    return "<$(tag)$(properties_str)$(style_str)>"
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

- `properties::Union{Nothing, Dict{String, String}}`: Tag properties.
    (**Default**: `nothing`)
- `style::Union{Nothing, Dict{String, String}}`: Tag style.
    (**Default**: `nothing`)
"""
function _html__create_tag(
    tag::String,
    content::String;
    properties::Union{Nothing, Dict{String, String}} = nothing,
    style::Union{Nothing, Dict{String, String}} = nothing
)
    return _html__open_tag(tag; properties, style) * content * _html__close_tag(tag)
end

# == Top Bar ===============================================================================

"""
    _html__print_top_bar_section(buf::IOContext, position::String, text::String, decoration::Union{Nothing, Dict{String, String}}, il::Int, ns::Int; kwargs...)

Print the HTML top bar section.

# Arguments

- `buf::IOContext`: Buffer to which the top bar will be printed.
- `position::String`: Buffer position. It can be "left" or "right".
- `text::String`: Text to be printed in the selected position.
- `decoration::Union{Nothing, Dict{String, String}}`: Text decoration.
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
    decoration::Union{Nothing, Dict{String, String}},
    il::Int,
    ns::Int;
    minify::Bool = false
)
    style = isnothing(decoration) ? Dict{String, String}() : copy(decoration)
    style["float"] = position

    _aprintln(buf, _html__open_tag("div"; style), il, ns; minify)
    il += 1

    _aprintln(
        buf,
        _html__create_tag(
            "span",
            _html__escape_str(text)
        ),
        il,
        ns;
        minify
    )

    il -= 1
    _aprintln(buf, _html__close_tag("div"), il, ns; minify)
end
