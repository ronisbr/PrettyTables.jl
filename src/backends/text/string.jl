# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions related to string processing.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
    _crop_str(str, crop_size, lstr = -1)

Return a cropped string of `str` with size `crop_size`. Notice that if the last
character before the crop does not fit due to its width, then blank spaces are
added.

The size of the string can be passed to `lstr` to save computational burden. If
`lstr = -1`, then the string length will be computed inside the function.

"""
function _crop_str(str::String, crop_size::Int, lstr::Int = -1)
    lstr < 0 && (lstr = textwidth(str))

    # If the `crop_size` is large than the string length, then just return the
    # current string.
    crop_size ≥ lstr && return str

    # Process every character of the string.
    cstr  = ""
    lcstr = 0

    # Find all ANSI escape sequences and split string there.
    #
    # The regex was obtained from here:
    #
    #     https://stackoverflow.com/questions/14693701/how-can-i-remove-the-ansi-escape-sequences-from-a-string-in-python
    #
    ansi   = collect(eachmatch(r"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])", str))
    tokens = split(str, r"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])")
    crop_finished = false

    for i = 1:length(tokens)
        for c in tokens[i]
            sc = textwidth(c)

            # Check if we can add the character without passing the crop size.
            if lcstr + sc ≤ crop_size
                cstr  *= c
                lcstr += sc

                # Fill the remaining spaces with blank characters.
            else
                Δ      = crop_size - lcstr
                cstr  *= " "^Δ
                crop_finished = true
                break
            end
        end

        crop_finished && break

        cstr *= ansi[i].match
    end

    return cstr
end

"""
    _printable_textwidth(str::AbstractString)

Compute the width of the string `str` neglecting all ANSI escape sequences that
are not printable.

"""
function _printable_textwidth(str::AbstractString)
    # Regex to remove ANSI escape sequences so that we can compute the printable
    # size of the cell.
    r_ansi_escape = r"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])"

    # Compute the field size considering only the printable characters.
    str_p = replace(str, r_ansi_escape => "")

    return textwidth(str_p)
end

"""
    _render_text(T, v; compact_printing::Bool = true, isstring::Bool = false, limit_printing::Bool = true, linebreaks::Bool = false)

Render the value `v` to strings using the rendered `T` to be displayed in the
text back-end.

`T` can be:

* `Val(:print)`: the function `print` will be used.
* `Val(:show)`: the function `show` will be used.

This function must return a vector of strings in which each element is a line
inside the rendered cell.

If `linebreaks` is `true`, then the rendered should split the created string
into multiple tokens.

In case `show` is used, if `isstring` is `false`, then it means that the
original data is not a string even if `v` is a string. Hence, the surrounding
quotes added by `show` will be removed. This is required to correctly handle
formatters.

If `limit_printing` is `true`, then `v` will be converted to string using the
property `:limit => true`.

"""
@inline function _render_text(::Val{:print}, v::Any;
                              compact_printing::Bool = true,
                              isstring::Bool = false,
                              limit_printing::Bool = true,
                              linebreaks::Bool = false)

    # Create the context that will be used when rendering the cell. Notice that
    # the `IOBuffer` will be neglected.
    context = IOContext(stdout,
                        :compact => compact_printing,
                        :limit => limit_printing)

    str = sprint(print, v; context = context)

    return _render_text(Val(:print), str;
                        compact_printing = compact_printing,
                        isstring = isstring,
                        linebreaks = linebreaks)
end

@inline function _render_text(::Val{:print}, str::AbstractString;
                              compact_printing::Bool = true,
                              isstring::Bool = false,
                              limit_printing::Bool = true,
                              linebreaks::Bool = false)

    if linebreaks
        vstr = string.(split(str, '\n'))
    else
        vstr = [str]
    end

    # NOTE: Here we cannot use `escape_string(str)` because it also adds the
    # character `"` to the list of characters to be escaped.
    return [sprint(escape_string, s, "", sizehint = lastindex(s)) for s in vstr]
end

@inline function _render_text(::Val{:show}, v::Any;
                              compact_printing::Bool = true,
                              linebreaks::Bool = false,
                              limit_printing::Bool = true,
                              isstring::Bool = false)

    # Create the context that will be used when rendering the cell. Notice that
    # the `IOBuffer` will be neglected.
    context = IOContext(stdout,
                        :compact => compact_printing,
                        :limit => limit_printing)

    if v isa AbstractString
        aux  = linebreaks ? string.(split(v, '\n')) : [v]
        vstr = sprint.(show, aux; context = context)

        if !isstring
            for i = 1:length(vstr)
                aux_i   = first(vstr[i], length(vstr[i])-1)
                vstr[i] = last(aux_i, length(aux_i)-1)
            end
        end
    else
        str  = sprint(show, v; context = context)
        vstr = linebreaks ? string.(split(str, '\n')) : [str]
    end

    return vstr
end

"""
    _str_aligned(data::String, alignment::Symbol, field_size::Integer, lstr::Integer = -1)

This function returns the string `data` with alignment `alignment` in a field
with size `field_size`. `alignment` can be `:l` or `:L` for left alignment, `:c`
or `:C` for center alignment, or `:r` or `:R` for right alignment. It defaults
to `:r` if `alignment` is any other symbol.

This function also returns the new size of the aligned string.

If the string is larger than `field_size`, then it will be cropped and `⋯` will
be added as the last character.

The size of the string can be passed to `lstr` to save computational burden. If
`lstr = -1`, then the string length will be computed inside the function.

"""
function _str_aligned(data::String, alignment::Symbol,
                      field_size::Integer, lstr::Integer = -1)

    lstr < 0 && (lstr = textwidth(data))
    Δ = field_size - lstr

    # If the length is larger than the field, then we will crop the string.
    if Δ < 0
        data  = _crop_str(data, lstr + Δ - 1, lstr)
        data *= "…"

        # In this case, the string has the same size of the field.
        lstr = lstr + Δ
        Δ = 0
    end

    # TODO: If Δ is 0, can we just return the string?

    if alignment == :l || alignment == :L
        return data * " "^Δ
    elseif alignment == :c || alignment == :C
        left  = div(Δ,2)
        right = Δ-left
        return " "^left * data * " "^right
    else
        return " "^Δ * data
    end
end

"""
    _str_autowrap(tokens_raw::Vector{String}, width::Int = 0)

Autowrap the tokens in `tokens_raw` considering a field width of `width`. It
returns a new vector with the new wrapped tokens.

"""
function _str_autowrap(tokens_raw::Vector{String}, width::Int = 0)
    # Check for errors.
    (width <= 0) && error("If `autowrap` is true, then the width must not be positive.")

    tokens = String[]

    for token in tokens_raw
        sub_tokens = String[]
        length_tok = length(token)

        # Get the list of valid indices to handle UTF-8 strings. In this
        # case, the n-th character of the string can be accessed by
        # `token[tok_ids[n]]`.
        tok_ids = collect(eachindex(token))

        if length_tok > width
            # First, let's analyze from the beginning of the token up to the
            # field width.
            #
            # k₀ is the character that will start the sub-token.
            # k₁ is the character that will end the sub-token.
            k₀ = 1
            k₁ = k₀ + width - 1

            while k₀ <= length_tok

                # Check if the remaining string fit in the available space.
                if k₁ == length_tok
                    push!(sub_tokens, token[tok_ids[k₀:k₁]])

                else
                    # If the remaining string does not fit into the
                    # available space, then we search for spaces to crop.
                    Δ = 0
                    for k = k₁:-1:k₀
                        if token[tok_ids[k]] == ' '
                            # If a space is found, then select `k₁` as this
                            # character and use `Δ` to remove it when
                            # printing, so that we hide the space.
                            k₁ = k
                            Δ  = 1

                            break
                        end
                    end

                    push!(sub_tokens, token[tok_ids[k₀:k₁-Δ]])
                end

                # Move to the next analysis window.
                k₀ = k₁+1
                k₁ = clamp(k₀ + width - 1, 0, length_tok)
            end
            push!(tokens, sub_tokens...)
        else
            push!(tokens, token)
        end
    end

    return tokens
end

################################################################################
#                             ANSI Escape Sequence
################################################################################

"""
    _get_composed_ansi_format(ansi::Vector{T}) where T<:AbstractString

Given a vector with a set of ANSI escape sequences, return a composed escape
sequence that leads to the same formatting.

!!! warning

    This function only works with the minimal set used by `Markdown` in
    `stdlib`.

"""
function _get_composed_ansi_format(ansi::Vector{T}) where T<:AbstractString
    bold = false
    underline = false
    color = 39

    for a in ansi
        length(a) ≤ 3  && continue
        a[1]   != '\e' && continue
        a[2]   != '['  && continue
        a[end] != 'm'  && continue

        code = parse(Int, a[3:end-1])

        if code == 0
            color = 39
            bold = false
            underline = false
        elseif code == 1
            bold = true
        elseif code == 4
            underline = true
        elseif code == 22
            bold  = false
            color = 39
        elseif code == 24
            underline = false
        elseif 30 ≤ code ≤ 37
            color = code
        elseif code == 39
            color = 39
        end
    end

    composed_ansi = ""

    bold        && (composed_ansi *= "\e[1m")
    underline   && (composed_ansi *= "\e[4m")
    color != 39 && (composed_ansi *= "\e[" * string(color) * "m")

    return composed_ansi
end

"""
    _reapply_ansi_format!(lines::Vector{T}) where T<:AbstractString

For each line in `lines`, reapply the ANSI format left by the previous line.

"""
function _reapply_ansi_format!(lines::Vector{T}) where T<:AbstractString
    length(lines) ≤ 1 && return nothing

    aux  = collect(eachmatch(r"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])", lines[1]))
    ansi = map(x->x.match, aux)

    lines[1] *= "\e[0m"

    @inbounds @views for i = 2:length(lines)
        composed_ansi = _get_composed_ansi_format(ansi)

        # Find the first non-blank character.
        id = findfirst(x->x ≠ ' ', lines[i])

        if (id == nothing) || (id == 1)
            lines[i] = composed_ansi * lines[i]
        else
            lines[i] = lines[i][1:id-1] * composed_ansi * lines[i][id:end]
        end

        aux  = collect(eachmatch(r"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])", lines[i]))
        ansi = map(x->x.match, aux)

        lines[i] *= "\e[0m"
    end

    return nothing
end
