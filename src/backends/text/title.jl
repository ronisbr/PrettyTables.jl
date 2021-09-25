# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions to process and print the table title.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
    _print_title(buf::IO, title_tokens::Vector{String}, has_color::Bool, title_crayon::Crayon)

Print the table title to the buffer `buf`.
"""
function _print_title(
    buf::IO,
    title_tokens::Vector{String},
    # Configurations
    has_color::Bool,
    title_crayon::Crayon
)
    num_tokens = length(title_tokens)

    num_tokens == 0 && return nothing

    has_color && print(buf, title_crayon)

    @inbounds for i in 1:num_tokens
        print(buf, rstrip(title_tokens[i]))

        # In the last line we must not add the new line character
        # because we need to reset the crayon first if the display
        # supports colors.
        i != num_tokens && println(buf)
    end

    has_color && print(buf, _reset_crayon)
    println(buf)

    return nothing
end

"""
    _tokenize_title(title::AbstractString, display_width::Int, table_width::Int, title_alignment::Symbol, title_autowrap::Bool, title_same_width_as_table::Bool)

Split the table title into tokens considering the line break character.
"""
function _tokenize_title(
    title::AbstractString,
    display_width::Int,
    table_width::Int,
    # Configurations
    title_alignment::Symbol,
    title_autowrap::Bool,
    title_same_width_as_table::Bool
)
    # Process the title separating the tokens.
    title_tokens = String[]

    if length(title) > 0
        # Compute the title width.
        title_width = title_same_width_as_table ? table_width : display_width

        # If the title width is not higher than 0, then we should only print the
        # title.
        if title_width ≤ 0
            push!(title_tokens, title)

            # Otherwise, we must check for the alignments.
        else
            title_tokens_raw = string.(split(title, '\n'))
            title_autowrap && (title_tokens_raw = _str_autowrap(title_tokens_raw, title_width))
            num_tokens = length(title_tokens_raw)

            @inbounds for i in 1:num_tokens
                token = title_tokens_raw[i]
                token_str = _str_aligned(token, title_alignment, title_width)
                push!(title_tokens, token_str)
            end
        end
    end

    return title_tokens
end
