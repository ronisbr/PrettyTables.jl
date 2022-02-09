# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Auxiliary functions to print cells.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Print the custom rext cell to the display.
#
# NOTE: `cell_str` must contain the printable text cell always.
function _print_custom_text_cell!(
    display::Display,
    cell_data::CustomTextCell,
    cell_processed_str::String,
    cell_crayon::Crayon,
    l::Int,
    (@nospecialize highlighters::Ref{Any}),
)
    cell_printable_textwidth = _printable_textwidth(cell_processed_str)

    # Compute the new string given the display size.
    str, suffix, ~ = _fit_str_to_display(
        display,
        cell_processed_str,
        false,
        cell_printable_textwidth
    )

    new_lstr = textwidth(str)

    # Check if we need to crop the string to fit the
    # display.
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
    return _write_to_display!(
        display,
        cell_crayon,
        rendered_str,
        suffix,
        new_lstr + textwidth(suffix)
    )
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

        _write_to_display!(display, omitted_cell_summary_crayon, cs_str, "")
        _nl!(display)
    end

    return nothing
end

# Process the cell by applying the correct alignment and also verifying the
# highlighters.
function _process_data_cell_text(
    ptable::ProcessedTable,
    cell_data::Any,
    cell_str::String,
    i::Int,
    j::Int,
    l::Int,
    column_width::Int,
    crayon::Crayon,
    alignment::Symbol,
    (@nospecialize highlighters::Ref{Any})
)
    lstr = -1

    # Check for highlighters.
    for h in highlighters.x
        if h.f(_getdata(ptable), i, j)
            crayon = h.fd(h, _getdata(ptable), i, j)::Crayon
            break
        end
    end

    # For Markdown cells, we will overwrite alignment and highlighters.
    if cell_data isa Markdown.MD
        alignment = :l
        crayon = Crayon()
        lstr = _printable_textwidth(cell_str)
    end

    if cell_data isa CustomTextCell
        # To align a custom text cell, we need to compute the alignment and
        # cropping data and apply it using the API functions.
        crop_chars, left_pad, right_pad = _str_compute_alignment_and_crop(
            cell_str,
            alignment,
            column_width,
            -1
        )

        if crop_chars > 0
            apply_line_padding!(cell_data, l, 0, 0)
            crop_line!(cell_data, l, crop_chars + 1)
            append_suffix_to_line!(cell_data, l, "…")
        else
            apply_line_padding!(cell_data, l, left_pad, right_pad)
        end

        cell_str = get_printable_cell_line(cell_data, l)::String
    else
        # Align the string to be printed.
        cell_str = _str_aligned(cell_str, alignment, column_width, lstr)
    end

    return cell_str, crayon
end
