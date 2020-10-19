# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Print function of the text backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Low-level function to print the table using the text backend.
function _pt_text(io::IO, pinfo::PrintInfo;
                  border_crayon::Crayon = Crayon(),
                  header_crayon::Union{Crayon,Vector{Crayon}} = Crayon(bold = true),
                  subheader_crayon::Union{Crayon,Vector{Crayon}} = Crayon(foreground = :dark_gray),
                  rownum_header_crayon::Crayon = Crayon(bold = true),
                  text_crayon::Crayon = Crayon(),
                  autowrap::Bool = false,
                  body_hlines::Vector{Int} = Int[],
                  body_hlines_format::Union{Nothing,NTuple{4,Char}} = nothing,
                  continuation_row_alignment::Symbol = :c,
                  crop::Symbol = :both,
                  crop_subheader::Bool = false,
                  crop_num_lines_at_beginning::Int = 0,
                  columns_width::Union{Int,AbstractVector{Int}} = 0,
                  equal_columns_width::Bool = false,
                  ellipsis_line_skip::Integer = 0,
                  highlighters::Union{Highlighter,Tuple} = (),
                  hlines::Union{Nothing,Symbol,AbstractVector} = nothing,
                  linebreaks::Bool = false,
                  maximum_columns_width::Union{Int,AbstractVector{Int}} = 0,
                  minimum_columns_width::Union{Int,AbstractVector{Int}} = 0,
                  newline_at_end::Bool = true,
                  overwrite::Bool = false,
                  noheader::Bool = false,
                  nosubheader::Bool = false,
                  row_name_crayon::Crayon = Crayon(bold = true),
                  row_name_header_crayon::Crayon = Crayon(bold = true),
                  row_number_alignment::Symbol = :r,
                  screen_size::Union{Nothing,Tuple{Int,Int}} = nothing,
                  sortkeys::Bool = false,
                  tf::TextFormat = unicode,
                  title_autowrap::Bool = false,
                  title_crayon::Crayon = Crayon(bold = true),
                  title_same_width_as_table::Bool = false,
                  vlines::Union{Nothing,Symbol,AbstractVector} = nothing)

    @unpack_PrintInfo pinfo

    # Input variables verification and initial setup
    # ==========================================================================

    # Let's create a `IOBuffer` to write everything and then transfer to `io`.
    io_has_color = get(io, :color, false)
    buf_io       = IOBuffer()
    buf          = IOContext(buf_io, :color => io_has_color)
    screen       = Screen(has_color = io_has_color)

    # If the user did not specified the screen size, then get the current
    # display size. However, if cropping is not desired, then just do nothing
    # since the size is initialized with -1.
    if crop != :none
        if screen_size == nothing
            # For files, the function `displaysize` returns the value of the
            # environments variables "LINES" and "COLUMNS". Hence, here we set
            # those to `-1`, so that we can use this information to avoid
            # limiting the output.
            withenv("LINES" => -1, "COLUMNS" => -1) do
                screen.size = displaysize(io)
            end
        else
            screen.size = screen_size
        end

        # If the user does not want to crop, then change the size to -1.
        if crop == :vertical
            screen.size = (screen.size[1],-1)
        elseif crop == :horizontal
            screen.size = (-1,screen.size[2])
        end
    end

    crop_num_lines_at_beginning < 0 && (crop_num_lines_at_beginning = 0)

    !noheader && num_cols != header_num_cols &&
    error("The header length must be equal to the number of columns.")

    # Additional processing necessary if the user wants to print the header.
    if !noheader
        # If the user do not want to print the sub-header but wants to print the
        # header, then just force the number of rows in header to be 1.
        if nosubheader
            # Now, `header` will be a view of the first line of the matrix that
            # has the header.
            header = @view header[1:header_num_rows:end]
            header_num_rows = 1
        end

        # Transform some keywords that are single elements to vectors.
        if typeof(header_crayon) == Crayon
            header_crayon = [header_crayon for i = 1:num_cols]
        else
            length(header_crayon) != num_cols &&
            error("The length of `header_crayon` must be the same as the number of columns.")
        end

        if typeof(subheader_crayon) == Crayon
            subheader_crayon = [subheader_crayon for i = 1:num_cols]
        else
            length(subheader_crayon) != num_cols &&
            error("The length of `subheader_crayon` must be the same as the number of columns.")
        end
    end

    # Make sure that `highlighters` is always a tuple.
    !(highlighters isa Tuple) && (highlighters = (highlighters,))

    # Make sure that `maximum_columns_width` is always a vector.
    typeof(maximum_columns_width) <: Integer &&
        (maximum_columns_width = ones(Int, num_cols)*maximum_columns_width)

    # Make sure that `minimum_columns_width` is always a vector.
    typeof(minimum_columns_width) <: Integer &&
        (minimum_columns_width = ones(Int, num_cols)*minimum_columns_width)

    # Check which columns must have fixed sizes.
    typeof(columns_width) <: Integer && (columns_width = ones(Int, num_cols)*columns_width)
    length(columns_width) != num_cols && error("The length of `columns_width` must be the same as the number of columns.")
    fixed_col_width = map(w->w > 0, columns_width)

    # The number of lines that must be skipped from printing ellipsis must be
    # greater of equal 0.
    (ellipsis_line_skip < 0) && (ellipsis_line_skip = 0)

    # Assign the minimum size to those columns that does not have a fixed size.
    for i = 1:num_cols
        !fixed_col_width[i] && (columns_width[i] = minimum_columns_width[i])
    end

    # Increase the number of printed columns if the user wants to show
    # additional columns.
    Δc = show_row_names + show_row_number
    num_printed_cols += Δc

    # If the user wants to horizontally crop the printing, then it is not
    # necessary to process all the lines. We will to process, at most, the
    # number of lines in the screen.
    if screen.size[1] > 0
        num_printed_rows = min(num_printed_rows, screen.size[1])
    end

    # If the user wants to vertically crop the printing, then it is not
    # necessary to process all the columns. However, we cannot know at this
    # stage the size of each column. Thus, this initial algorithm uses the fact
    # that each column printed will have at least 4 spaces.
    if screen.size[2] > 0
        num_printed_cols = min(num_printed_cols, ceil(Int, screen.size[2]/4))
    end

    # Create the string matrices that will be printed
    # ==========================================================================

    # Get the string which is printed when `print` is called in each element of
    # the matrix. Notice that we must create only the matrix with the printed
    # rows and columns.
    header_str = Matrix{String}(undef, header_num_rows, num_printed_cols)
    header_len = zeros(Int,header_num_rows, num_printed_cols)

    data_str   = Matrix{Vector{String}}(undef,
                                        num_printed_rows,
                                        num_printed_cols)
    data_len   = Matrix{Vector{Int}}(undef,
                                     num_printed_rows,
                                     num_printed_cols)

    num_lines_in_row = ones(Int, num_printed_rows)

    # The variable `columns_width` is the specification of the user for the
    # columns width. The variable `cols_width` contains the actual size of each
    # column. This is necessary because if the user asks for a width equal or
    # lower than 0 in a column, then the width will be automatically computed to
    # fit the longest field.
    #
    # By default, if the user wants to show the row number of the row names,
    # those columns will have the size computed automatically.
    cols_width = Vector{Int}(undef, num_printed_cols)

    for i = (Δc+1):num_printed_cols
        cols_width[i] = columns_width[id_cols[i-Δc]]
    end

    # Auxiliary variables to adjust `alignment` based on the new columns added
    # to the table.
    alignment_add = Symbol[]

    # Row numbers
    # --------------------------------------------------------------------------

    if show_row_number
        @inbounds _fill_row_number_column!(header_str, header_len, data_str,
                                           data_len, cols_width, id_rows,
                                           noheader, num_rows,
                                           row_number_column_title)

        # Add information about the row number column to the variables.
        push!(alignment_add, row_number_alignment)
    end

    # Row names
    # --------------------------------------------------------------------------

    if show_row_names
        @inbounds _fill_row_name_column!(header_str, header_len, data_str,
                                         data_len, cols_width, row_names, Δc,
                                         compact_printing, renderer,
                                         row_name_column_title)

        # Add information about the row name column to the variables.
        push!(alignment_add, row_name_alignment)
    end

    !isempty(alignment_add) && (alignment = vcat(alignment_add, alignment))

    # Table data
    # --------------------------------------------------------------------------

    num_printed_cols = @inbounds _fill_matrix_data!(header_str,
                                                    header_len,
                                                    data_str,
                                                    data_len,
                                                    cols_width,
                                                    id_cols,
                                                    id_rows,
                                                    num_lines_in_row,
                                                    Δc,
                                                    columns_width,
                                                    data,
                                                    header,
                                                    formatters,
                                                    screen,
                                                    # Configuration options.
                                                    autowrap,
                                                    cell_first_line_only,
                                                    compact_printing,
                                                    crop_subheader,
                                                    fixed_col_width,
                                                    linebreaks,
                                                    maximum_columns_width,
                                                    noheader,
                                                    renderer)

    # If the user wants all the columns with the same size, then select the
    # larger.
    equal_columns_width && (cols_width = [maximum(cols_width) for i = 1:num_printed_cols])

    # Compute where the horizontal and vertical lines must be drawn
    # --------------------------------------------------------------------------

    # Create the format of the horizontal lines.
    if body_hlines_format == nothing
        body_hlines_format = (tf.left_intersection, tf.middle_intersection,
                              tf.right_intersection, tf.row)
    end

    hlines == nothing && (hlines = tf.hlines)
    hlines = _process_hlines(hlines, body_hlines, num_printed_rows, noheader)

    # Check if the last horizontal line must be drawn. This is required when
    # computing the moment that the screen will be cropped.
    draw_last_hline = (num_printed_rows + !noheader) ∈ hlines

    # Process `vlines`.
    vlines == nothing && (vlines = tf.vlines)
    vlines = _process_vlines(vlines, num_printed_cols)

    #                           Print the table
    # ==========================================================================

    # Title
    # ==========================================================================

    if length(title) > 0
        # Compute the table width.
        table_width = sum(cols_width) + 2length(cols_width) + length(vlines)

        screen.size[2] > 0 && table_width > screen.size[2] &&
            (table_width = screen.size[2])

        # Compute the title width.
        title_width = title_same_width_as_table ? table_width : screen.size[2]

        screen.has_color && print(buf, title_crayon)

        # If the title width is not higher than 0, then we should only print the
        # title.
        if title_width ≤ 0
            print(buf, title)

        # Otherwise, we must check for the alignments.
        else
            title_tokens = string.(split(title, '\n'))
            title_autowrap && (title_tokens = _str_autowrap(title_tokens, title_width))
            num_tokens = length(title_tokens)

            @inbounds for i = 1:num_tokens
                token = title_tokens[i]
                token_str = _str_aligned(token, title_alignment, title_width)[1]
                print(buf, rstrip(token_str))

                # In the last line we must not add the new line character
                # because we need to reset the crayon first if the screen
                # supports colors.
                i != num_tokens && println(buf)
            end

            # Sum the number of lines in the title to the number of lines that
            # must be available at the beginning of the table.
            crop_num_lines_at_beginning += length(title_tokens)
        end

        screen.has_color && print(buf, _reset_crayon)
        println(buf)
    end

    # If there is no column or row to be printed, then just exit.
    if (num_printed_cols == 0) || (num_printed_rows == 0)
        @goto print_to_output
    end

    # Top table line
    # ==========================================================================

    0 ∈ hlines && _draw_line!(screen, buf, tf.up_left_corner,
                              tf.up_intersection, tf.up_right_corner, tf.row,
                              border_crayon, cols_width, vlines)


    # Header
    # ==========================================================================

    # Header and sub-header texts
    # --------------------------------------------------------------------------

    if !noheader
        _print_table_header!(buf,
                             screen,
                             header,
                             header_str,
                             header_len,
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
                             row_name_header_crayon)

        # Bottom header line
        #-----------------------------------------------------------------------

        1 ∈ hlines && _draw_line!(screen, buf, tf.left_intersection,
                                  tf.middle_intersection,
                                  tf.right_intersection, tf.row,
                                  border_crayon, cols_width, vlines)
    end

    # Data
    # ==========================================================================

    # Number of additional lines that must be consider to crop the screen
    # vertically.
    Δscreen_lines = 1 + newline_at_end + draw_last_hline + crop_num_lines_at_beginning

    @inbounds _print_table_data(buf,
                                screen,
                                data,
                                data_str,
                                data_len,
                                id_cols,
                                id_rows,
                                num_lines_in_row,
                                num_printed_cols,
                                Δc,
                                cols_width,
                                hlines,
                                vlines,
                                # Configurations.
                                alignment,
                                body_hlines_format,
                                cell_alignment,
                                continuation_row_alignment,
                                ellipsis_line_skip,
                                highlighters,
                                noheader,
                                show_row_names,
                                show_row_number,
                                tf,
                                Δscreen_lines,
                                # Crayons.
                                border_crayon,
                                row_name_crayon,
                                text_crayon)

    # Bottom table line
    # ==========================================================================

    draw_last_hline &&
        _draw_line!(screen, buf, tf.bottom_left_corner, tf.bottom_intersection,
                    tf.bottom_right_corner, tf.row, border_crayon, cols_width,
                    vlines)

    @label print_to_output

    # Overwrite table
    # ==========================================================================

    # If `overwrite` is `true`, then delete the exact number of lines of the
    # table. This can be used to replace the table in the screen continuously.

    str_overwrite = overwrite ? "\e[1F\e[2K"^(screen.row - 1) : ""

    # Print the buffer
    # ==========================================================================
    output_str = String(take!(buf_io))

    # Check if the user does not want a newline at end.
    if !newline_at_end && (output_str[end] == '\n')
        output_str = first(output_str, length(output_str)-1)
    end

    print(io, str_overwrite * output_str)

    return nothing
end
