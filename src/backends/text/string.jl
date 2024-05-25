## Description #############################################################################
#
# Functions related to string processing.
#
############################################################################################

# Autowrap the tokens in `tokens_raw` considering a field with a specific `width`. It
# returns a new vector with the new wrapped tokens.
function _str_autowrap(tokens_raw::Vector{String}, width::Int = 0)
    # Check for errors.
    width <= 0 && error("If `autowrap` is true, then the width must not be positive.")

    tokens = String[]

    for token in tokens_raw
        sub_tokens = String[]
        length_tok = length(token)

        # Get the list of valid indices to handle UTF-8 strings. In this case, the n-th
        # character of the string can be accessed by `token[tok_ids[n]]`.
        tok_ids = collect(eachindex(token))

        if length_tok > width
            # First, let's analyze from the beginning of the token up to the field width.
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
                    # If the remaining string does not fit into the available space, then we
                    # search for spaces to crop.
                    Δ = 0
                    for k = k₁:-1:k₀
                        if token[tok_ids[k]] == ' '
                            # If a space is found, then select `k₁` as this character and
                            # use `Δ` to remove it when printing, so that we hide the space.
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
