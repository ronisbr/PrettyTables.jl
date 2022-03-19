# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions related to string processing.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Render the value `v` to strings using the rendered `T` to be displayed in the
# text back-end.
#
# The first argument can be:
#
# - `Val(:print)`: the function `print` will be used.
# - `Val(:show)`: the function `show` will be used.
#
# This function must return a vector of strings in which each element is a line
# inside the rendered cell.
#
# If `linebreaks` is `true`, then the rendered should split the created string
# into multiple tokens.
#
# In case `show` is used, if `isstring` is `false`, then it means that the
# original data is not a string even if `v` is a string. Hence, the surrounding
# quotes added by `show` will be removed. This is required to correctly handle
# formatters.
#
# If `limit_printing` is `true`, then `v` will be converted to string using the
# property `:limit => true`.
function _render_text(
    ::Val{:print},
    v::Any;
    compact_printing::Bool = true,
    isstring::Bool = false,
    limit_printing::Bool = true,
    linebreaks::Bool = false
)
    # Create the context that will be used when rendering the cell. Notice that
    # the `IOBuffer` will be neglected.
    context = IOContext(stdout, :compact => compact_printing, :limit => limit_printing)

    str = sprint(print, v; context = context)

    return _render_text(
        Val(:print),
        str;
        compact_printing = compact_printing,
        isstring = isstring,
        linebreaks = linebreaks
    )
end

function _render_text(
    ::Val{:print},
    str::AbstractString;
    compact_printing::Bool = true,
    isstring::Bool = false,
    limit_printing::Bool = true,
    linebreaks::Bool = false
)
    vstr = linebreaks ? string.(split(str, '\n')) : [str]

    # NOTE: Here we cannot use `escape_string(str)` because it also adds the
    # character `"` to the list of characters to be escaped.
    output_str = Vector{String}(undef, length(vstr))

    @inbounds for i in 1:length(vstr)
        s = vstr[i]
        output_str[i] = sprint(escape_string, s, "", sizehint = lastindex(s))
    end

    return output_str
end

function _render_text(
    ::Val{:show}, v::Any;
    compact_printing::Bool = true,
    linebreaks::Bool = false,
    limit_printing::Bool = true,
    isstring::Bool = false
)
    # Create the context that will be used when rendering the cell. Notice that
    # the `IOBuffer` will be neglected.
    context = IOContext(stdout, :compact => compact_printing, :limit => limit_printing)

    if v isa AbstractString
        aux  = linebreaks ? string.(split(v, '\n')) : [v]
        vstr = sprint.(show, aux; context = context)

        if !isstring
            for i in 1:length(vstr)
                aux_i   = first(vstr[i], length(vstr[i]) - 1)
                vstr[i] = last(aux_i, length(aux_i) - 1)
            end
        end
    else
        str  = sprint(show, v; context = context)
        vstr = linebreaks ? string.(split(str, '\n')) : [str]
    end

    return vstr
end

# Autowrap the tokens in `tokens_raw` considering a field with a specific
# `width`. It returns a new vector with the new wrapped tokens.
function _str_autowrap(tokens_raw::Vector{String}, width::Int = 0)
    # Check for errors.
    width <= 0 && error("If `autowrap` is true, then the width must not be positive.")

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
