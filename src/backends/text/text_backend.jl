## Description #############################################################################
#
# Print function of the text backend.
#
############################################################################################

# Low-level function to print the table using the text back end.
function _print_table_with_text_back_end(
    pinfo::PrintInfo;
    alignment_anchor_fallback::Symbol = :l,
    alignment_anchor_fallback_override::Dict{Int, Symbol} = Dict{Int, Symbol}(),
    alignment_anchor_regex::Dict{Int, T} where T <:AbstractVector{Regex} = Dict{Int, Vector{Regex}}(),
    autowrap::Bool = false,
    body_hlines::Vector{Int} = Int[],
    body_hlines_format::Union{Nothing, NTuple{4, Char}} = nothing,
    continuation_row_alignment::Symbol = :c,
    crop::Symbol = get(pinfo.io, :limit, false) ? :both : :none,
    crop_subheader::Bool = false,
    columns_width::Union{Int, AbstractVector{Int}} = 0,
    display_size::Tuple{Int, Int} = displaysize(pinfo.io),
    equal_columns_width::Bool = false,
    ellipsis_line_skip::Integer = 0,
    highlighters::Union{Highlighter, Tuple} = (),
    hlines::Union{Nothing, Symbol, AbstractVector} = nothing,
    linebreaks::Bool = false,
    maximum_columns_width::Union{Int, AbstractVector{Int}} = 0,
    minimum_columns_width::Union{Int, AbstractVector{Int}} = 0,
    newline_at_end::Bool = true,
    overwrite::Bool = false,
    reserved_display_lines::Int = 0,
    show_omitted_cell_summary::Bool = true,
    sortkeys::Bool = false,
    tf::TextFormat = tf_unicode,
    title_autowrap::Bool = false,
    title_same_width_as_table::Bool = false,
    vcrop_mode::Symbol = :bottom,
    vlines::Union{Nothing, Symbol, AbstractVector} = nothing,
    # Crayons
    border_crayon::Crayon = Crayon(),
    header_crayon::Union{Crayon, Vector{Crayon}} = Crayon(bold = true),
    omitted_cell_summary_crayon::Crayon = Crayon(foreground = :cyan),
    row_label_crayon::Crayon = Crayon(bold = true),
    row_label_header_crayon::Crayon = Crayon(bold = true),
    row_number_header_crayon::Crayon = Crayon(bold = true),
    subheader_crayon::Union{Crayon, Vector{Crayon}} = Crayon(foreground = :dark_gray),
    text_crayon::Crayon = Crayon(),
    title_crayon::Crayon = Crayon(bold = true),
)
    # Unpack fields of `pinfo`.
    ptable               = pinfo.ptable
    cell_first_line_only = pinfo.cell_first_line_only
    compact_printing     = pinfo.compact_printing
    formatters           = pinfo.formatters
    io                   = pinfo.io
    limit_printing       = pinfo.limit_printing
    renderer             = pinfo.renderer
    title                = pinfo.title
    title_alignment      = pinfo.title_alignment

    # Get size information from the processed table.
    num_rows, num_columns = _data_size(ptable)
    num_header_rows, ~ = _header_size(ptable)

    # == Input Variables Verification and Initial Setup ====================================

    # Let's create a `IOBuffer` to write everything and then transfer to `io`.
    io_has_color = get(io, :color, false)::Bool
    display      = Display(has_color = io_has_color)

    # Check which type of cropping the user wants.
    if crop == :both
        display.size = display_size
    elseif crop == :vertical
        display.size = (display_size[1], -1)
    elseif crop == :horizontal
        display.size = (-1, display_size[2])
    else
        # If the table will not be cropped, we should never show an omitted cell summary.
        show_omitted_cell_summary = false
    end

    # Make sure that `vcrop_mode` is valid.
    vcrop_mode ∉ [:bottom, :middle] && (vcrop_mode = :bottom)

    reserved_display_lines < 0 && (reserved_display_lines = 0)

    # Make sure that `highlighters` is always a Ref{Any}(Tuple).
    if !(highlighters isa Tuple)
        highlighters = Ref{Any}((highlighters,))
    else
        highlighters = Ref{Any}(highlighters)
    end

    # Make sure that `maximum_columns_width` is always a vector.
    if maximum_columns_width isa Integer
        maximum_columns_width = fill(maximum_columns_width, num_columns)
    end

    # Make sure that `minimum_columns_width` is always a vector.
    if minimum_columns_width isa Integer
        minimum_columns_width = fill(minimum_columns_width, num_columns)
    end

    # Check which columns must have fixed sizes.
    columns_width isa Integer && (columns_width = fill(columns_width, num_columns))

    if length(columns_width) != num_columns
        error("The length of `columns_width` must be the same as the number of columns.")
    end

    # The number of lines that must be skipped from printing ellipsis must be
    # greater of equal 0.
    (ellipsis_line_skip < 0) && (ellipsis_line_skip = 0)

    # Check the size of the crayons related with the headers.
    if (header_crayon isa Vector) && (length(header_crayon) != num_columns)
        error("The length of `header_crayon` must be the same as the number of columns.")
    end

    if (subheader_crayon isa Vector) && (length(subheader_crayon) != num_columns)
        error("The length of `subheader_crayon` must be the same as the number of columns.")
    end

    # Structure that holds all the crayons in text backend.
    text_crayons = TextCrayons(
        border_crayon,
        header_crayon,
        omitted_cell_summary_crayon,
        row_label_crayon,
        row_label_header_crayon,
        row_number_header_crayon,
        subheader_crayon,
        text_crayon,
        title_crayon
    )

    # Get the number of rows and columns in the processed table.
    num_rows, num_columns = _size(ptable)

    # == Process Lines =====================================================================

    if hlines === nothing
        hlines = tf.hlines
    end
    hlines = _process_hlines(ptable, hlines)

    if vlines === nothing
        vlines = tf.vlines
    end
    vlines = _process_vlines(ptable, vlines)

    # == Number of Rows and Columns that Must be Rendered ==================================

    num_rendered_rows = num_rows
    num_rendered_columns = num_columns

    if display.size[1] > 0
        num_rendered_rows = min(num_rows, display.size[1])

        # We must render at least the header.
        num_rendered_rows = max(num_header_rows, num_rendered_rows)
    end

    if display.size[2] > 0
        num_rendered_columns = min(
            num_columns,
            ceil(Int, display.size[2] / 4)
        )
    end

    # == Create the String Matrix with the Rendered Cells ==================================

    # In text back end, we must convert all the matrix to text before printing. This
    # procedure is necessary to obtain the column width for example so that we can align the
    # table lines.
    table_str = Matrix{Vector{String}}(
        undef,
        num_rendered_rows,
        num_rendered_columns
    )

    # Vector that must contain the width of each column. Notice that the vector
    # `columns_width` is the user specification and must not be modified.
    actual_columns_width = ones(Int, num_rendered_columns)

    # Vector that must contain the number of lines in each rendered row.
    num_lines_in_row = zeros(Int, num_rendered_rows)

    # NOTE: Algorithm to compute the table size and number of lines in the rows.
    # Previously, the algorithm to compute the table size and the number of lines in the
    # rows was a function called after the conversion of the input matrix to the string
    # matrix. Although this approach was cleaner, we had problems when computing how many
    # columns we can fit on the display to avoid unnecessary processing. Hence, the
    # functions that fill the data are also responsible to compute the size of each column.

    # -- Table Data ------------------------------------------------------------------------

    # Fill the string matrix with the rendered cells. This function also returns the updated
    # number of rendered rows and columns given the user specifications about cropping.
    num_rendered_rows, num_rendered_columns = _text_fill_string_matrix!(
        io,
        table_str,
        ptable,
        actual_columns_width,
        display,
        formatters,
        num_lines_in_row,
        # Configuration options.
        autowrap,
        cell_first_line_only,
        columns_width,
        compact_printing,
        crop_subheader,
        limit_printing,
        linebreaks,
        maximum_columns_width,
        minimum_columns_width,
        renderer,
        vcrop_mode
    )

    # -- Column Alignment Regex ------------------------------------------------------------

    _apply_alignment_anchor_regex!(
        ptable,
        table_str,
        actual_columns_width,
        # Configurations.
        alignment_anchor_fallback,
        alignment_anchor_fallback_override,
        alignment_anchor_regex,
        columns_width,
        maximum_columns_width,
        minimum_columns_width
    )

    # If the user wants all the columns with the same size, select the larger.
    if equal_columns_width
        actual_columns_width = fill(
            maximum(actual_columns_width),
            num_rendered_columns
        )
    end

    # -- Compute Where the Horizontal and Vertical Lines Must be Drawn ---------------------

    # Create the format of the horizontal lines.
    if body_hlines_format === nothing
        body_hlines_format = (
            tf.left_intersection,
            tf.middle_intersection,
            tf.right_intersection,
            tf.row
        )
    end

    # Check if the last horizontal line must be drawn. This is required when computing the
    # moment that the display will be cropped.
    draw_last_hline = _check_hline(ptable, hlines, body_hlines, num_rows)

    # -- Compute the Table Width and Height ------------------------------------------------

    table_width = _compute_table_width(
        ptable,
        vlines,
        actual_columns_width,
    )

    table_height = _compute_table_height(
        ptable,
        hlines,
        body_hlines,
        num_lines_in_row
    )

    # -- Process the Title -----------------------------------------------------------------

    title_tokens = _tokenize_title(
        title,
        display.size[2],
        table_width,
        # Configurations
        title_alignment,
        title_autowrap,
        title_same_width_as_table
    )

    # == Print the Table ===================================================================

    # -- Title -----------------------------------------------------------------------------

    _print_title!(display, title_tokens, text_crayons.title_crayon)

    # If there is no column and no row to be printed, just exit.
    if _data_size(ptable) == (0, 0)
        @goto print_to_output
    end

    # -- Table -----------------------------------------------------------------------------

    # Number of additional lines that must be consider to crop the display vertically.
    Δdisplay_lines =
        1 +
        newline_at_end +
        reserved_display_lines +
        length(title_tokens)

    # Compute the number of omitted columns. We need this information to check if we need to
    # reserve a line after the table to print the omitted cell summary
    num_omitted_columns = _compute_omitted_columns(
        ptable,
        display,
        actual_columns_width,
        vlines
    )

    need_omitted_cell_summary = show_omitted_cell_summary && (num_omitted_columns > 0)

    # Compute the position of the continuation line with respect to the printed table line.
    if vcrop_mode != :middle
        continuation_row_line = _compute_continuation_row_in_bottom_vcrop(
            ptable,
            display,
            hlines,
            body_hlines,
            num_lines_in_row,
            table_height,
            draw_last_hline,
            need_omitted_cell_summary,
            show_omitted_cell_summary,
            Δdisplay_lines
        )
    else
        continuation_row_line = _compute_continuation_row_in_middle_vcrop(
            ptable,
            display,
            hlines,
            body_hlines,
            num_lines_in_row,
            table_height,
            need_omitted_cell_summary,
            show_omitted_cell_summary,
            Δdisplay_lines
        )
    end

    need_omitted_cell_summary =
        show_omitted_cell_summary &&
        ((num_omitted_columns > 0) || (continuation_row_line > 0))

    # Now we can compute the number of omitted rows because we already computed the
    # continuation line.
    num_omitted_rows = _compute_omitted_rows(
        ptable,
        display,
        continuation_row_line,
        num_lines_in_row,
        body_hlines,
        hlines,
        need_omitted_cell_summary,
        Δdisplay_lines
    )

    # Number of lines that must be saved before the title and after printing the table.
    num_lines_around_table =
        need_omitted_cell_summary +
        newline_at_end +
        reserved_display_lines

    # Print the table.
    _text_print_table!(
        display,
        ptable,
        table_str,
        actual_columns_width,
        continuation_row_line,
        num_lines_in_row,
        num_lines_around_table,
        # Configurations.
        body_hlines,
        body_hlines_format,
        continuation_row_alignment,
        ellipsis_line_skip,
        highlighters,
        hlines,
        tf,
        text_crayons,
        vlines
    )

    # -- Summary of the Omitted Cells ------------------------------------------------------

    _print_omitted_cell_summary(
        display,
        num_omitted_columns,
        num_omitted_rows,
        omitted_cell_summary_crayon,
        show_omitted_cell_summary,
        table_width
    )

    @label print_to_output

    # -- Print the Buffer ------------------------------------------------------------------

    _flush_display!(io, display, overwrite, newline_at_end, display.row)

    return nothing
end
