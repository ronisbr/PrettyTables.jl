# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Print function of the text backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Low-level function to print the table using the text backend.
function _pt_text(
    r_io::Ref{Any}, pinfo::PrintInfo;
    border_crayon::Crayon = Crayon(),
    header_crayon::Union{Crayon, Vector{Crayon}} = Crayon(bold = true),
    subheader_crayon::Union{Crayon,Vector{Crayon}} = Crayon(foreground = :dark_gray),
    rownum_header_crayon::Crayon = Crayon(bold = true),
    text_crayon::Crayon = Crayon(),
    omitted_cell_summary_crayon::Crayon = Crayon(foreground = :cyan),
    alignment_anchor_fallback::Symbol = :l,
    alignment_anchor_fallback_override::Dict{Int, Symbol} = Dict{Int, Symbol}(),
    alignment_anchor_regex::Dict{Int, T} where T <:AbstractVector{Regex} = Dict{Int, Vector{Regex}}(),
    autowrap::Bool = false,
    body_hlines::Vector{Int} = Int[],
    body_hlines_format::Union{Nothing, NTuple{4, Char}} = nothing,
    continuation_row_alignment::Symbol = :c,
    crop::Symbol = get(r_io.x, :limit, false) ? :both : :none,
    crop_subheader::Bool = false,
    crop_num_lines_at_beginning::Int = 0,
    columns_width::Union{Int, AbstractVector{Int}} = 0,
    display_size::Tuple{Int, Int} = displaysize(r_io.x),
    equal_columns_width::Bool = false,
    ellipsis_line_skip::Integer = 0,
    highlighters::Union{Highlighter, Tuple} = (),
    hlines::Union{Nothing, Symbol, AbstractVector} = nothing,
    linebreaks::Bool = false,
    maximum_columns_width::Union{Int, AbstractVector{Int}} = 0,
    minimum_columns_width::Union{Int, AbstractVector{Int}} = 0,
    newline_at_end::Bool = true,
    overwrite::Bool = false,
    row_name_crayon::Crayon = Crayon(bold = true),
    row_name_header_crayon::Crayon = Crayon(bold = true),
    show_omitted_cell_summary::Bool = true,
    sortkeys::Bool = false,
    tf::TextFormat = tf_unicode,
    title_autowrap::Bool = false,
    title_crayon::Crayon = Crayon(bold = true),
    title_same_width_as_table::Bool = false,
    vcrop_mode::Symbol = :bottom,
    vlines::Union{Nothing, Symbol, AbstractVector} = nothing
)
    # `r_io` must always be a reference to `IO`. Here, we unpack it. This is
    # done to improve inference and reduce compilation time. Ideally, we need to
    # add the `@nospecialize` annotation to `io`. However, it returns the
    # message that this annotation is not supported with more than 32 arguments.
    io = r_io.x

    # Unpack fields of `pinfo`.
    ptable               = pinfo.ptable
    formatters           = pinfo.formatters
    compact_printing     = pinfo.compact_printing
    title                = pinfo.title
    title_alignment      = pinfo.title_alignment
    cell_first_line_only = pinfo.cell_first_line_only
    renderer             = pinfo.renderer
    limit_printing       = pinfo.limit_printing

    # Get size information from the processed table.
    num_rows, num_columns = _data_size(ptable)
    num_header_rows, ~ = _header_size(ptable)

    # Input variables verification and initial setup
    # ==========================================================================

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
        # If the table will not be cropped, then we should never show an omitted
        # cell summary.
        show_omitted_cell_summary = false
    end

    # Make sure that `vcrop_mode` is valid.
    vcrop_mode ∉ [:bottom, :middle] && (vcrop_mode = :bottom)

    crop_num_lines_at_beginning < 0 && (crop_num_lines_at_beginning = 0)

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

    # Process filters
    # ==========================================================================

    _process_filters!(ptable)

    # Get the number of rows and columns in the processed table.
    num_rows, num_columns = _size(ptable)

    # Process lines
    # ==========================================================================

    if hlines === nothing
        hlines = tf.hlines
    end
    hlines = _process_hlines(ptable, hlines)

    if vlines === nothing
        vlines = tf.vlines
    end
    vlines = _process_vlines(ptable, vlines)


    # Number of rows and columns that must be rendered
    # ==========================================================================

    num_rendered_rows = num_rows
    num_rendered_columns = num_columns

    if display.size[1] > 0
        num_rendered_rows = min(num_rows, display.size[1])
    end

    if display.size[2] > 0
        num_rendered_columns = min(
            num_columns,
            ceil(Int, display.size[2] / 4)
        )
    end

    # Create the string matrix that with the rendered cells
    # ==========================================================================

    # In text backend, we must convert all the matrix to text before printing.
    # This procedure is necessary to obtain the column width for example so that
    # we can align the table lines.
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
    # Previously, the algorithm to compute the table size and the number of
    # lines in the rows was a function called after the conversion of the input
    # matrix to the string matrix. Although this approach was cleaner, we had
    # problems when computing how many columns we can fit on the display to
    # avoid unnecessary processing. Hence, the functions that fill the data are
    # also responsible to compute the size of each column.

    # Table data
    # --------------------------------------------------------------------------

    # Fill the string matrix with the rendered cells. This function also returns
    # the updated number of rendered rows and columns given the user
    # specifications about cropping.
    num_rendered_rows, num_rendered_columns = _fill_matrix_data!(
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

    # Column alignment regex
    # --------------------------------------------------------------------------

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

    # If the user wants all the columns with the same size, then select the
    # larger.
    if equal_columns_width
        actual_columns_width = fill(
            maximum(actual_columns_width),
            num_rendered_columns
        )
    end

    # Compute where the horizontal and vertical lines must be drawn
    # --------------------------------------------------------------------------

    # Create the format of the horizontal lines.
    if body_hlines_format === nothing
        body_hlines_format = (
            tf.left_intersection,
            tf.middle_intersection,
            tf.right_intersection,
            tf.row
        )
    end

    # Check if the last horizontal line must be drawn. This is required when
    # computing the moment that the display will be cropped.
    draw_last_hline = _check_hline(ptable, hlines, body_hlines, num_rows)

    # Compute the table width and height
    # --------------------------------------------------------------------------

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

    # Process the title
    # --------------------------------------------------------------------------

    title_tokens = _tokenize_title(
        title,
        display.size[2],
        table_width,
        # Configurations
        title_alignment,
        title_autowrap,
        title_same_width_as_table
    )

    #                           Print the table
    # ==========================================================================

    # Title
    # ==========================================================================

    _print_title!(display, title_tokens, title_crayon)

    # If there is no column or row to be printed, then just exit.
    if (num_rows - num_header_rows == 0) || (num_columns == 0)
        @goto print_to_output
    end

    # Table
    # ==========================================================================

    # Number of additional lines that must be consider to crop the display
    # vertically.
    Δdisplay_lines =
        1 +
        newline_at_end +
        crop_num_lines_at_beginning +
        length(title_tokens)

    # Compute the number of omitted columns. We need this information to check
    # if we need to reserve a line after the table to print the omitted cell
    # summary
    num_omitted_columns = _compute_omitted_columns(
        ptable,
        display,
        actual_columns_width,
        vlines
    )

    need_omitted_cell_summary =
        show_omitted_cell_summary && (num_omitted_columns > 0)

    # Compute the position of the continuation line with respect to the printed
    # table line.
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

    # Now we can compute the number of omitted rows because we already computed
    # the continuation line.
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

    # Print the table.
    _print_table_data!(
        display,
        ptable,
        table_str,
        actual_columns_width,
        continuation_row_line,
        num_lines_in_row,
        vcrop_mode,
        table_height,
        Δdisplay_lines,
        # Configurations.
        body_hlines,
        body_hlines_format,
        continuation_row_alignment,
        ellipsis_line_skip,
        highlighters,
        hlines,
        tf,
        vlines,
        # Crayons.
        border_crayon,
        header_crayon,
        row_name_crayon,
        row_name_header_crayon,
        rownum_header_crayon,
        subheader_crayon,
        text_crayon,
    )

    # Summary of the omitted cells
    # ==========================================================================

    _print_omitted_cell_summary(
        display,
        num_omitted_columns,
        num_omitted_rows,
        omitted_cell_summary_crayon,
        show_omitted_cell_summary,
        table_width
    )

    @label print_to_output

    # Print the buffer
    # ==========================================================================

    _flush_display!(io, display, overwrite, newline_at_end, display.row)


    return nothing
end
