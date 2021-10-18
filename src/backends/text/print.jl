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
    noheader::Bool = false,
    nosubheader::Bool = false,
    row_name_crayon::Crayon = Crayon(bold = true),
    row_name_header_crayon::Crayon = Crayon(bold = true),
    row_number_alignment::Symbol = :r,
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
    data                    = pinfo.data
    header                  = pinfo.header
    id_cols                 = pinfo.id_cols
    id_rows                 = pinfo.id_rows
    num_rows                = pinfo.num_rows
    num_cols                = pinfo.num_cols
    num_printed_cols        = pinfo.num_printed_cols
    num_printed_rows        = pinfo.num_printed_rows
    header_num_rows         = pinfo.header_num_rows
    header_num_cols         = pinfo.header_num_cols
    show_row_number         = pinfo.show_row_number
    row_number_column_title = pinfo.row_number_column_title
    show_row_names          = pinfo.show_row_names
    row_names               = pinfo.row_names
    row_name_alignment      = pinfo.row_name_alignment
    row_name_column_title   = pinfo.row_name_column_title
    alignment               = pinfo.alignment
    cell_alignment          = pinfo.cell_alignment
    formatters              = pinfo.formatters
    compact_printing        = pinfo.compact_printing
    title                   = pinfo.title
    title_alignment         = pinfo.title_alignment
    header_alignment        = pinfo.header_alignment
    header_cell_alignment   = pinfo.header_cell_alignment
    cell_first_line_only    = pinfo.cell_first_line_only
    renderer                = pinfo.renderer
    limit_printing          = pinfo.limit_printing

    # Input variables verification and initial setup
    # ==========================================================================

    # Let's create a `IOBuffer` to write everything and then transfer to `io`.
    io_has_color = get(io, :color, false)::Bool
    buf_io       = IOBuffer()
    buf          = IOContext(buf_io, :color => io_has_color)
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

    if !noheader && num_cols != header_num_cols
        error("The header length must be equal to the number of columns.")
    end

    # Additional processing necessary if the user wants to print the header.
    if !noheader
        # If the user do not want to print the sub-header but wants to print the
        # header, then just force the number of rows in header to be 1.
        if nosubheader
            # Now, `header` will be a view of the first line of the matrix that
            # has the header.
            header_num_rows = 1
        end

        # Transform some keywords that are single elements to vectors.
        if header_crayon isa Crayon
            header_crayon = fill(header_crayon, num_cols)
        else
            if length(header_crayon) != num_cols
                error("The length of `header_crayon` must be the same as the number of columns.")
            end
        end

        if subheader_crayon isa Crayon
            subheader_crayon = fill(subheader_crayon, num_cols)
        else
            if length(subheader_crayon) != num_cols
                error("The length of `subheader_crayon` must be the same as the number of columns.")
            end
        end
    end

    # Make sure that `highlighters` is always a Ref{Any}(Tuple).
    if !(highlighters isa Tuple)
        highlighters = Ref{Any}((highlighters,))
    else
        highlighters = Ref{Any}(highlighters)
    end

    # Make sure that `maximum_columns_width` is always a vector.
    if maximum_columns_width isa Integer
        maximum_columns_width = fill(maximum_columns_width, num_cols)
    end

    # Make sure that `minimum_columns_width` is always a vector.
    if minimum_columns_width isa Integer
        minimum_columns_width = fill(minimum_columns_width, num_cols)
    end

    # Check which columns must have fixed sizes.
    columns_width isa Integer && (columns_width = fill(columns_width, num_cols))

    if length(columns_width) != num_cols
        error("The length of `columns_width` must be the same as the number of columns.")
    end

    # The number of lines that must be skipped from printing ellipsis must be
    # greater of equal 0.
    (ellipsis_line_skip < 0) && (ellipsis_line_skip = 0)

    # Increase the number of printed columns if the user wants to show
    # additional columns.
    Δc = show_row_names + show_row_number
    num_printed_cols += Δc

    # If the user wants to horizontally crop the printing, then it is not
    # necessary to process all the lines. We will to process, at most, the
    # number of lines in the display.
    if display.size[1] > 0
        num_printed_rows = min(num_printed_rows, display.size[1])
    end

    # If the user wants to vertically crop the printing, then it is not
    # necessary to process all the columns. However, we cannot know at this
    # stage the size of each column. Thus, this initial algorithm uses the fact
    # that each column printed will have at least 4 spaces.
    if display.size[2] > 0
        num_printed_cols = min(num_printed_cols, ceil(Int, display.size[2] / 4))
    end

    # We need to process at least the row number and row name columns to avoid
    # errors.
    num_printed_cols < Δc && (num_printed_cols = Δc)

    # Number of rows and columns after filtering.
    num_filtered_rows = length(id_rows)
    num_filtered_cols = length(id_cols)

    # Create the string matrices that will be printed
    # ==========================================================================

    # Get the string which is printed when `print` is called in each element of
    # the matrix. Notice that we must create only the matrix with the printed
    # rows and columns.
    header_str = Matrix{String}(undef, header_num_rows, num_printed_cols)
    data_str   = Matrix{Vector{String}}(undef, num_printed_rows, num_printed_cols)

    # Auxiliary variables to adjust `alignment` based on the new columns added
    # to the table.
    alignment_add = Symbol[]

    # Vector that must contain the width of each column.
    cols_width = ones(Int, num_printed_cols)

    # Vector that must contain the number of lines in each printed row.
    num_lines_in_row = ones(Int, num_printed_rows)

    # NOTE: Algorithm to compute the table size and number of lines in the rows.
    # Previously, the algorithm to compute the table size and the number of
    # lines in the rows was a function called after the conversion of the input
    # matrix to the string matrix. Although this approach was cleaner, we had
    # problems when computing how many columns we can fit on the display to
    # avoid unnecessary processing. Hence, the functions that fill the data are
    # also responsible to compute the size of each column.

    # Vectors with the order that the rows must be filled
    # --------------------------------------------------------------------------

    # The vector `jvec` contains the indices in the printed matrix whereas the
    # vector `jrvec` contains the indices in the data matrix.
    #
    # NOTE: The vector `jvec` is not sorted when crop mode is `:middle`.
    # This format is required to make sure we always fill one row at the top and
    # one row in the bottom. Otherwise, we can have access to an undefined
    # reference.
    jvec, jrvec = _compute_row_fill_vectors(
        id_rows,
        num_printed_rows,
        vcrop_mode
    )

    # Cell alignment override
    # --------------------------------------------------------------------------

    # Compute the cells in which the alignment is overridden.
    cell_alignment_override = _compute_cell_alignment_override(
        data,
        id_cols,
        id_rows,
        Δc,
        num_printed_cols,
        num_printed_rows,
        # Configurations.
        cell_alignment
    )

    # Row numbers
    # --------------------------------------------------------------------------

    if show_row_number
        _fill_row_number_column!(
            header_str,
            data_str,
            cols_width,
            jvec,
            jrvec,
            noheader,
            row_number_column_title
        )

        # Add information about the row number column to the variables.
        push!(alignment_add, row_number_alignment)
    end

    # Row names
    # --------------------------------------------------------------------------

    if show_row_names
        _fill_row_name_column!(
            header_str,
            data_str,
            cols_width,
            row_names,
            jvec,
            jrvec,
            Δc,
            compact_printing,
            renderer,
            row_name_column_title
        )

        # Add information about the row name column to the variables.
        push!(alignment_add, row_name_alignment)
    end

    !isempty(alignment_add) && (alignment = vcat(alignment_add, alignment))

    # Table data
    # --------------------------------------------------------------------------

    num_printed_cols, num_printed_rows = _fill_matrix_data!(
        header_str,
        data_str,
        cols_width,
        num_lines_in_row,
        id_cols,
        jvec,
        jrvec,
        Δc,
        data,
        header,
        formatters,
        display,
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
        noheader,
        renderer,
        vcrop_mode
    )

    # Column alignment regex
    # --------------------------------------------------------------------------

    _apply_alignment_anchor_regex!(
        data_str,
        cols_width,
        id_cols,
        id_rows,
        Δc,
        # Configurations.
        alignment_anchor_fallback,
        alignment_anchor_fallback_override,
        alignment_anchor_regex,
        cell_alignment_override,
        columns_width,
        maximum_columns_width,
        minimum_columns_width
    )

    # If the user wants all the columns with the same size, then select the
    # larger.
    equal_columns_width && (cols_width = fill(maximum(cols_width), num_printed_cols))

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

    if hlines === nothing
        hlines = _process_hlines(tf.hlines, body_hlines, num_filtered_rows, noheader)
    else
        hlines = _process_hlines(hlines, body_hlines, num_filtered_rows, noheader)
    end

    # Check if the last horizontal line must be drawn. This is required when
    # computing the moment that the display will be cropped.
    draw_last_hline = (num_filtered_rows + !noheader) ∈ hlines

    # Process `vlines`.
    if vlines === nothing
        vlines = _process_vlines(tf.vlines, num_printed_cols)
    else
        vlines = _process_vlines(vlines, num_printed_cols)
    end

    # Compute the table width
    # --------------------------------------------------------------------------

    table_width = sum(cols_width) + 2length(cols_width) + length(vlines)

    if (display.size[2] > 0) && (table_width > display.size[2])
        table_width = display.size[2]
    end

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

    # Sum the number of lines in the title to the number of lines that must be
    # available at the beginning of the table.
    crop_num_lines_at_beginning += length(title_tokens)

    # Compute the table data printing recipe
    # --------------------------------------------------------------------------

    # Number of additional lines that must be consider to crop the display
    # vertically.
    Δdisplay_lines = 1 + newline_at_end + draw_last_hline + crop_num_lines_at_beginning

    row_printing_recipe, col_printing_recipe, num_omitted_rows, num_omitted_cols =
        _create_printing_recipe(
            display,
            header_num_rows,
            num_filtered_rows,
            num_filtered_cols,
            num_printed_rows,
            num_printed_cols,
            num_lines_in_row,
            cols_width,
            id_rows,
            hlines,
            vlines,
            Δdisplay_lines,
            Δc,
            # Configurations
            crop,
            noheader,
            show_omitted_cell_summary,
            vcrop_mode
        )

    #                           Print the table
    # ==========================================================================

    # Title
    # ==========================================================================

    _print_title(buf, title_tokens, display.has_color, title_crayon)

    # If there is no column or row to be printed, then just exit.
    if (num_printed_cols == 0) || (num_printed_rows == 0)
        @goto print_to_output
    end

    # Top table line
    # ==========================================================================

    if 0 ∈ hlines
        _draw_line!(
            display,
            buf,
            tf.up_left_corner,
            tf.up_intersection,
            tf.up_right_corner,
            tf.row,
            border_crayon,
            cols_width,
            vlines
        )
    end

    # Header
    # ==========================================================================

    # Header and sub-header texts
    # --------------------------------------------------------------------------

    if !noheader
        _print_table_header!(
            buf,
            display,
            header,
            header_str,
            id_cols,
            id_rows,
            num_printed_cols,
            Δc,
            cols_width,
            vlines,
            # Configurations.
            alignment,
            header_alignment,
            header_cell_alignment,
            show_row_names,
            show_row_number,
            tf,
            # Crayons.
            border_crayon,
            header_crayon,
            subheader_crayon,
            rownum_header_crayon,
            row_name_header_crayon
        )

        # Bottom header line
        #-----------------------------------------------------------------------

        if 1 ∈ hlines
            _draw_line!(
                display,
                buf,
                tf.left_intersection,
                tf.middle_intersection,
                tf.right_intersection,
                tf.row,
                border_crayon,
                cols_width,
                vlines
            )
        end
    end

    # Data
    # ==========================================================================

    @inbounds _print_table_data(
        buf,
        display,
        data,
        data_str,
        id_cols,
        id_rows,
        Δc,
        cols_width,
        vlines,
        row_printing_recipe,
        col_printing_recipe,
        # Configurations.
        alignment,
        body_hlines_format,
        cell_alignment_override,
        continuation_row_alignment,
        ellipsis_line_skip,
        highlighters,
        noheader,
        show_row_names,
        show_row_number,
        tf,
        # Crayons.
        border_crayon,
        row_name_crayon,
        text_crayon
    )

    # Bottom table line
    # ==========================================================================

    if draw_last_hline
        _draw_line!(
            display,
            buf,
            tf.bottom_left_corner,
            tf.bottom_intersection,
            tf.bottom_right_corner,
            tf.row,
            border_crayon,
            cols_width,
            vlines
        )
    end

    # Summary of the omitted cells
    # ==========================================================================

    _print_omitted_cell_summary(
        buf,
        display.has_color,
        num_omitted_cols,
        num_omitted_rows,
        omitted_cell_summary_crayon,
        show_omitted_cell_summary,
        table_width
    )

    @label print_to_output

    # Print the buffer
    # ==========================================================================

    _flush_buffer!(io, buf_io, overwrite, newline_at_end, display.row)

    return nothing
end
