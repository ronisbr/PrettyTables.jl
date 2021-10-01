# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Auxiliary functions to print the parts of the table.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Flush the content of `buf` to `io`.
function _flush_buffer!(
    io::IO,
    buf::IO,
    overwrite::Bool,
    newline_at_end::Bool,
    num_displayed_rows::Int
)
    # If `overwrite` is `true`, then delete the exact number of lines of the
    # table. This can be used to replace the table in the display continuously.
    str_overwrite = overwrite ? "\e[1F\e[2K"^(num_displayed_rows - 1) : ""

    output_str = String(take!(buf))

    # Check if the user does not want a newline at end.
    !newline_at_end && (output_str = String(chomp(output_str)))

    print(io, str_overwrite * output_str)

    return nothing
end

function _print_omitted_cell_summary(
    buf::IO,
    has_color::Bool,
    num_omitted_cols::Int,
    num_omitted_rows::Int,
    omitted_cell_summary_crayon::Crayon,
    show_omitted_cell_summary::Bool,
    table_width::Int
)
    if show_omitted_cell_summary && ((num_omitted_cols + num_omitted_rows) > 0)
        cs_str_col = ""
        cs_str_and = ""
        cs_str_row = ""

        if num_omitted_cols > 0
            cs_str_col = string(num_omitted_cols)
            cs_str_col *= num_omitted_cols > 1 ? " columns" : " column"
        end

        if num_omitted_rows > 0
            cs_str_row = string(num_omitted_rows)
            cs_str_row *= num_omitted_rows > 1 ? " rows" : " row"

            num_omitted_cols > 0 && (cs_str_and = " and ")
        end

        cs_str = cs_str_col * cs_str_and * cs_str_row * " omitted"

        if textwidth(cs_str) < table_width
            cs_str = _str_aligned(cs_str, :r, table_width)
        end

        has_color && print(buf, omitted_cell_summary_crayon)
        print(buf, cs_str)
        has_color && print(buf, _reset_crayon)
        println(buf)
    end

    return nothing
end

# Print the table header without the horizontal lines.
function _print_table_header!(
    buf::IO,
    display::Display,
    (@nospecialize header::Any),
    header_str::Matrix{String},
    id_cols::AbstractVector{Int},
    id_rows::AbstractVector{Int},
    num_printed_cols::Int,
    Δc::Int,
    cols_width::Vector{Int},
    vlines::Vector{Int},
    # Configurations.
    alignment::Vector{Symbol},
    header_alignment::Vector{Symbol},
    (@nospecialize header_cell_alignment::Ref{Any}),
    show_row_names::Bool,
    show_row_number::Bool,
    tf::TextFormat,
    # Crayons.
    border_crayon::Crayon,
    header_crayon::Vector{Crayon},
    subheader_crayon::Vector{Crayon},
    rownum_header_crayon::Crayon,
    row_name_header_crayon::Crayon
)
    header_num_rows, ~ = size(header_str)

    @inbounds @views for i = 1:header_num_rows
        0 ∈ vlines && _p!(display, border_crayon, tf.column, false)

        for j = 1:num_printed_cols
            # Get the information about the alignment and the crayon.
            if j ≤ Δc
                if show_row_number && (j == 1)
                    crayon_ij    = rownum_header_crayon
                    alignment_ij = alignment[1]
                elseif show_row_names
                    crayon_ij    = row_name_header_crayon
                    alignment_ij = alignment[Δc]
                end
            else
                jc = id_cols[j-Δc]
                crayon_ij    = (i == 1) ? header_crayon[jc] : subheader_crayon[jc]
                alignment_ij = header_alignment[jc]

                # Check for cell alignment override.
                for f in header_cell_alignment.x
                    aux = f(header, i, jc)

                    if aux ∈ (:l, :c, :r, :L, :C, :R, :s, :S)
                        alignment_ij = aux
                        break
                    end
                end

                # If alignment is `:s`, then we must use the column
                # alignment.
                alignment_ij ∈ (:s, :S) && (alignment_ij = alignment[jc + Δc])
            end

            # Prepare the text to be printed.
            header_ij_str = _str_aligned(header_str[i, j], alignment_ij, cols_width[j])
            header_ij_str = " " * header_ij_str * " "

            flp = j == num_printed_cols

            # Print the text.
            _p!(display, crayon_ij, header_ij_str, false)

            # Check if we need to draw a vertical line here.
            _pc!(j ∈ vlines, display, border_crayon, tf.column, "", flp, 1, 0)

            _eol(display) && break
        end

        i != header_num_rows && _nl!(display, buf)
    end

    _nl!(display, buf)

    return nothing
end

# Print the entire table data.
function _print_table_data(
    buf::IO,
    display::Display,
    (@nospecialize data::Any),
    data_str::Matrix{Vector{String}},
    id_cols::AbstractVector{Int},
    id_rows::AbstractVector{Int},
    Δc::Int,
    cols_width::Vector{Int},
    vlines::Vector{Int},
    row_printing_recipe::Vector{NTuple{4, Int}},
    col_printing_recipe::Vector{Int},
    # Configurations.
    alignment::Vector{Symbol},
    body_hlines_format::NTuple{4, Char},
    cell_alignment_override::Dict{Tuple{Int, Int}, Symbol},
    continuation_row_alignment::Symbol,
    ellipsis_line_skip::Integer,
    (@nospecialize highlighters::Ref{Any}),
    noheader::Bool,
    show_row_names::Bool,
    show_row_number::Bool,
    tf::TextFormat,
    # Crayons.
    border_crayon::Crayon,
    row_name_crayon::Crayon,
    text_crayon::Crayon
)
    line_count = 0

    for r in row_printing_recipe
        if r[1] < 0
            if r[1] == _ROW_LINE[1]
                _draw_line!(
                    display,
                    buf,
                    body_hlines_format...,
                    border_crayon,
                    cols_width,
                    vlines
                )
            elseif r[1] == _CONTINUATION_LINE[1]
                _draw_continuation_row(
                    display,
                    buf,
                    tf,
                    text_crayon,
                    border_crayon,
                    cols_width,
                    vlines,
                    continuation_row_alignment
                )
            else
                error("Internal error: wrong symbol in row printing recipe.")
            end

        else
            i, ir, num_lines, l₀ = r

            for l = l₀:(l₀ + num_lines - 1)

                # Check if we should print the ellipsis here.
                display.cont_char = if line_count % (ellipsis_line_skip + 1) == 0
                    '⋯'
                else
                    ' '
                end

                line_count += 1

                num_col_recipes = length(col_printing_recipe)

                for c_id = 1:num_col_recipes
                    c = col_printing_recipe[c_id]

                    flp = c_id == num_col_recipes

                    if c < 0
                        if c == _LEFT_LINE
                            _p!(display, border_crayon, tf.column, flp, 1)
                        elseif c == _COLUMN_LINE
                            _p!(display, border_crayon, tf.column, flp, 1)
                        elseif c == _RIGHT_LINE
                            _p!(display, border_crayon, tf.column, flp, 1)
                        else
                            error("Internal error: wrong symbol in column printing recipe.")
                        end
                    else
                        j = c

                        # Get the information about the alignment and the
                        # crayon.
                        #
                        # NOTE: The variable `data_cell` is used to avoid
                        # applying formatters and highlighters to the row number
                        # and row name columns.
                        if j ≤ Δc
                            if show_row_number && (j == 1)
                                crayon_ij    = text_crayon
                                alignment_ij = alignment[1]
                            elseif show_row_names
                                crayon_ij    = row_name_crayon
                                alignment_ij = alignment[Δc]
                            end
                            jc = 0
                            data_cell = false
                        else
                            jc = id_cols[j - Δc]

                            crayon_ij    = text_crayon
                            alignment_ij = alignment[jc + Δc]
                            data_cell    = true
                        end

                        # String to be processed.
                        if length(data_str[i, j]) >= l
                            data_ij_str = data_str[i, j][l]
                            line_has_data = true
                        else
                            data_ij_str = ""
                            line_has_data = false
                        end

                        # Check if the alignment of this cell is overridden by
                        # the user.
                        if haskey(cell_alignment_override, (ir, jc))
                            alignment_ij = cell_alignment_override[(ir, jc)]
                        end

                        # Check if we have a custom cell.
                        custom_cell =
                            data_cell &&
                            isassigned(data, ir, jc) &&
                            line_has_data &&
                            (data[ir, jc] isa CustomTextCell)

                        # Process the string with the correct alignment and also
                        # apply the highlighters.
                        data_ij_str, crayon_ij = _process_cell_text(
                            data,
                            ir,
                            jc,
                            l,
                            data_cell,
                            custom_cell,
                            data_ij_str,
                            cols_width[j],
                            crayon_ij,
                            alignment_ij,
                            highlighters
                        )

                        # Compute the printable size of the string.
                        data_ij_len = _printable_textwidth(data_ij_str)

                        # If we have a custom cell, then we need a custom
                        # printing function.
                        if custom_cell
                            _p!(display, _default_crayon, " ", false, 1)

                            # Compute the new string given the display size.
                            str, suffix, ~ = _fit_str_to_display(
                                display,
                                data_ij_str,
                                false,
                                data_ij_len
                            )

                            new_lstr = textwidth(str)

                            # Check if we need to crop the string to fit the
                            # display.
                            if data_ij_len > new_lstr
                                crop_line!(
                                    data[ir, jc],
                                    l,
                                    data_ij_len - new_lstr
                                )
                            end

                            # Get the rendered text.
                            rendered_str = get_rendered_line(
                                data[ir, jc],
                                l
                            )::String

                            # Write it to the display.
                            _write_to_display!(
                                display,
                                crayon_ij,
                                rendered_str,
                                suffix,
                                new_lstr + textwidth(suffix)
                            )

                            _p!(display, _default_crayon, " ", false, 1)
                        else
                            _p!(
                                display,
                                crayon_ij,
                                " " * data_ij_str * " ",
                                false,
                                data_ij_len + 2
                            )
                        end
                    end
                end

                _nl!(display, buf)
            end
        end
    end

    return nothing
end
