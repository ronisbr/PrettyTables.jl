## Description #############################################################################
#
# Functions to process and print the table title.
#
############################################################################################

# Print the table title to the display.
function _print_title!(
    display::Display,
    title_tokens::Vector{String},
    # Configurations
    title_crayon::Crayon
)
    num_tokens = length(title_tokens)

    num_tokens == 0 && return nothing

    @inbounds for i in 1:num_tokens
        _write_to_display!(display, title_crayon, string(rstrip(title_tokens[i])), "")

        # In the last line we must not add the new line character because we need to reset
        # the crayon first if the display supports colors.
        i != num_tokens && _nl!(display)
    end

    _nl!(display)

    return nothing
end

# Split the table title into tokens considering the line break character.
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

        # If the title width is not higher than 0, then we should only print the title.
        if title_width ≤ 0
            push!(title_tokens, title)

            # Otherwise, we must check for the alignments.
        else
            title_tokens_raw = string.(split(title, '\n'))
            title_autowrap && (title_tokens_raw = _str_autowrap(title_tokens_raw, title_width))
            num_tokens = length(title_tokens_raw)

            @inbounds for i in 1:num_tokens
                token = title_tokens_raw[i]

                # Align and crop the title.
                token_pw  = printable_textwidth(token)
                token_str = align_string(
                    token,
                    title_width,
                    title_alignment;
                    printable_string_width = token_pw
                )
                token_str = fit_string_in_field(
                    token_str,
                    title_width;
                    printable_string_width = token_pw
                )

                push!(title_tokens, token_str)
            end
        end
    end

    return title_tokens
end
