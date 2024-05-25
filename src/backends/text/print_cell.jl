## Description #############################################################################
#
# Auxiliary functions to print cells.
#
############################################################################################

# Print the custom rext cell to the display.
#
# NOTE: `cell_str` must contain the printable text cell always.
function _print_custom_text_cell!(
    display::Display,
    cell_data::CustomTextCell,
    cell_processed_str::String,
    cell_crayon::Crayon,
    l::Int,
    @nospecialize(highlighters::Ref{Any}),
)
    cell_printable_textwidth = printable_textwidth(cell_processed_str)

    # Print the padding character before the cell.
    _p!(display, _default_crayon, " ", false, 1)

    # Compute the new string given the display size.
    str, suffix, ~ = _fit_string_in_display(
        display,
        cell_processed_str,
        false,
        cell_printable_textwidth
    )

    new_lstr = textwidth(str)

    # Check if we need to crop the string to fit the display.
    if cell_printable_textwidth > new_lstr
        crop_line!(
            cell_data,
            l,
            cell_printable_textwidth - new_lstr
        )
    end

    # Get the rendered text.
    rendered_str = get_rendered_line(cell_data, l)::String

    # Write it to the display.
    _write_to_display!(
        display,
        cell_crayon,
        rendered_str,
        suffix,
        new_lstr + textwidth(suffix)
    )

    # Print the padding character after the cell and return if the display has reached
    # end-of-line.
    return _p!(display, _default_crayon, " ", false, 1)
end

# Print the summary of the omitted rows and columns.
function _print_omitted_cell_summary(
    display::Display,
    num_omitted_cols::Int,
    num_omitted_rows::Int,
    omitted_cell_summary_crayon::Crayon,
    show_omitted_cell_summary::Bool,
    table_width::Int
)
    if show_omitted_cell_summary && ((num_omitted_cols + num_omitted_rows) > 0)
        cs_str = _get_omitted_cell_string(num_omitted_rows, num_omitted_cols)

        if display.size[2] > 0
            table_display_width = min(table_width, display.size[2])
        else
            table_display_width = table_width
        end

        if textwidth(cs_str) < table_display_width
            cs_str = align_string(cs_str, table_display_width, :r)
        end

        _write_to_display!(display, omitted_cell_summary_crayon, cs_str, "")
        _nl!(display)
    end

    return nothing
end

# Process the cell by applying the correct alignment and also verifying the highlighters.
function _text_process_data_cell(
    ptable::ProcessedTable,
    cell_data::Any,
    cell_str::String,
    i::Int,
    j::Int,
    l::Int,
    column_width::Int,
    crayon::Crayon,
    alignment::Symbol,
    @nospecialize(highlighters::Ref{Any})
)
    # Notice that `(i, j)` are the indices of the printed data. It means that it refers to
    # the ith data row and jth data column that will be printed. We need to convert those
    # indices to the actual indices in the input table.
    ti, tj = _convert_axes(ptable.data, i, j)

    # Check for highlighters.
    for h in highlighters.x
        if h.f(_getdata(ptable), ti, tj)
            crayon = h.fd(h, _getdata(ptable), ti, tj)::Crayon
            break
        end
    end

    # For Markdown cells, we will overwrite alignment and highlighters.
    if cell_data isa Markdown.MD
        alignment = :l
        crayon = Crayon()
        lstr = printable_textwidth(cell_str)
    else
        lstr = textwidth(cell_str)
    end

    if cell_data isa CustomTextCell
        # To align a custom text cell, we need to compute the alignment and cropping data
        # and apply it using the API functions.
        padding = get_padding_for_string_alignment(
            cell_str,
            column_width,
            alignment;
            fill = true,
            printable_string_width = lstr
        )

        if !isnothing(padding)
            left_pad, right_pad = padding
            crop_chars = 0
        else
            left_pad, right_pad = 0, 0

            crop_chars = get_crop_to_fit_string_in_field(
                cell_str,
                column_width;
                add_continuation_char = false,
                printable_string_width = lstr
            )
        end

        if crop_chars > 0
            apply_line_padding!(cell_data, l, 0, 0)
            crop_line!(cell_data, l, crop_chars + 1)
            append_suffix_to_line!(cell_data, l, "…")
        else
            apply_line_padding!(cell_data, l, left_pad, right_pad)
        end

        cell_str = get_printable_cell_line(cell_data, l)::String
    else
        # Align and crop the string to be printed.
        cell_str = align_string(
            cell_str,
            column_width,
            alignment;
            fill = true,
            printable_string_width = lstr
        )

        # If this is not a custom cell, we ensure it does not have any ANSI escape sequence.
        # Hence, we do not need to keep it after the cropping.
        cell_str = fit_string_in_field(
            cell_str,
            column_width;
            keep_ansi = false,
            printable_string_width = lstr
        )
    end

    return cell_str, crayon
end
