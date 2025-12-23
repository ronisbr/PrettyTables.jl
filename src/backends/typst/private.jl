"""
    _typst__escape_str(@nospecialize(io::IO), s::AbstractString, replace_newline::Bool = false, escape_typst_chars::Bool = true) -> Nothing
    _typst__escape_str(s::AbstractString, replace_newline::Bool = false, escape_typst_chars::Bool = true) -> String

Print the string `s` in `io` escaping the characters for the Typst back end. If `io` is
omitted, the escaped string is returned.

If `replace_newline` is `true`, `\n` is replaced with `<br>`. Otherwise, it is escaped,
leading to `\\n`.

If `escape_typst_chars` is `true`, `&`, `<`, `>`, `"`, and `'`  will be replaced by Typst
sequences.
"""
function _typst__escape_str(
    io::IO,
    s::AbstractString,
    replace_newline::Bool = false,
    escape_typst_chars::Bool = true,
)
    a = Iterators.Stateful(s)
    for c in a
        if Base.isascii(c)
            isprint(c)         ? print(io, c) : print(io, "\\x", string(UInt32(c), base = 16, pad = 2))
            # c == '\n'          ? (replace_newline ? print(io, "<br>") : print(io, "\\n")) :
            # c == '&'           ? (escape_typst_chars ? print(io, "&amp;")  : print(io, c)) :
            # c == '<'           ? (escape_typst_chars ? print(io, "&lt;")   : print(io, c)) :
            # c == '>'           ? (escape_typst_chars ? print(io, "&gt;")   : print(io, c)) :
            # c == '"'           ? (escape_typst_chars ? print(io, "&quot;") : print(io, c)) :
            # c == '\''          ? (escape_typst_chars ? print(io, "&apos;") : print(io, c)) :
            # c == '\0'          ? print(io, Base.escape_nul(peek(a))) :
            # c == '\e'          ? print(io, "\\e") :
            # c == '\\'          ? print(io, "\\\\") :
            # '\a' <= c <= '\r'  ? print(io, '\\', "abtnvfr"[Int(c)-6]) :
            # isprint(c)         ? print(io, c) :
            #                      print(io, "\\x", string(UInt32(c), base = 16, pad = 2))
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
function _typst__escape_str(
    s::AbstractString,
    replace_newline::Bool = false,
    escape_typst_chars::Bool = true
)
    return sprint(
        _typst__escape_str,
        s,
        replace_newline,
        escape_typst_chars;
        sizehint = lastindex(s)
    )
end



"""
    _typst__open_component(component::String; kwargs...) -> String

Create the string that opens the Typst `component`.

# Keywords

- `properties::Union{Nothing, Vector{TypstPair}}`: Tag properties.
    (**Default**: `nothing`)
- `style::Union{Nothing, Vector{TypstPair}}`: Tag style.
    (**Default**: `nothing`)
"""
function _typst__open_component(
    component::String, args...;
    properties::Union{Nothing, Vector{TypstPair}} = nothing
)
    # Compile the text with the properties.
    properties_str = ""
    args_str = if length(args) >0 
      join(args_str,", ")
    else
      ""
    end
    # Make sure the properties are sorted by key.
    if !isnothing(properties)
        sort!(properties)

        for (k, v) in properties
            if !isempty(v)
                v_str = _typst__escape_str(v)
                if occursin(r"^[0-9]",v_str) || k ∉ _TYPST_STRING_ATTRIBUTES
                    properties_str *= "$k: $v_str,"
                else
                    properties_str *= "$k: \"$v_str\","
                end
            end
        end
    end

    # Return the component.
    if args_str != ""
        return "$(component)($(args_str), $(properties_str))["
    else
        return "$(component)($(properties_str))["
    end
end

"""
    _typst__close_component() -> String

Create the string that closes the Typst `component`.
"""
_typst__close_component(comma=false) = "]$(comma ? "," : "")"



"""
    _typst__create_component(component::String, content::String; kwargs...) -> String

Create an HTML `component` with the `content`.

# Keywords

- `properties::Union{Nothing, Vector{TypstPair}}`: Tag properties.
    (**Default**: `nothing`)
- `style::Union{Nothing, Vector{TypstPair}}`: Tag style.
    (**Default**: `nothing`)
"""
function _typst__create_component(
    component::String,
    content::String;
    args::Union{Nothing,Vector{AbstractString}} = nothing,
    properties::Union{Nothing, Vector{TypstPair}} = nothing,
)
    if isnothing(args)
        return _typst__open_component(component; properties) * content * _typst__close_component()
    end
    return _typst__open_component(component, args...; properties) * content * _typst__close_component()
end


# == Styles ================================================================================

const _TYPST__ALIGNMENT_MAP = Dict(
    :l => "left",
    :L => "left",
    :c => "center",
    :C => "center",
    :r => "right",
    :R => "right"
)


"""
    _typst__add_alignment_to_style!(style::Vector{TypstPair}, alignment::Symbol) -> Nothing

Add the Typst alignment property to `style` according to the `alignment` symbol.
"""
function _typst__add_alignment_to_style!(style::Vector{TypstPair}, alignment::Symbol)
    if (alignment == :n) || (alignment == :N)
        return nothing
    elseif haskey(_TYPST__ALIGNMENT_MAP, alignment)
        return push!(style, "align" => _TYPST__ALIGNMENT_MAP[alignment])
    else
        return push!(style, "align" => _TYPST__ALIGNMENT_MAP[:r])
    end
end
