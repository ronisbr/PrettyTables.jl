# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Print function of the text backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Low-level function to print the table using the text backend.
function _pt_text(io, pinfo;
                  border_crayon::Crayon = Crayon(),
                  header_crayon::Union{Crayon,Vector{Crayon}} = Crayon(bold = true),
                  subheader_crayon::Union{Crayon,Vector{Crayon}} = Crayon(foreground = :dark_gray),
                  rownum_header_crayon::Crayon = Crayon(bold = true),
                  text_crayon::Crayon = Crayon(),
                  autowrap::Bool = false,
                  body_hlines::Vector{Int} = Int[],
                  body_hlines_format::Union{Nothing,NTuple{4,Char}} = nothing,
                  crop::Symbol = :both,
                  crop_subheader::Bool = false,
                  columns_width::Union{Integer,AbstractVector{Int}} = 0,
                  equal_columns_width::Bool = false,
                  highlighters::Union{Highlighter,Tuple} = (),
                  hlines::Union{Nothing,Symbol,AbstractVector} = nothing,
                  linebreaks::Bool = false,
                  maximum_columns_width::Union{Integer,AbstractVector{Int}} = 0,
                  minimum_columns_width::Union{Integer,AbstractVector{Int}} = 0,
                  overwrite::Bool = false,
                  noheader::Bool = false,
                  nosubheader::Bool = false,
                  row_name_crayon::Crayon = Crayon(bold = true),
                  row_name_header_crayon::Crayon = Crayon(bold = true),
                  row_number_alignment::Symbol = :r,
                  screen_size::Union{Nothing,Tuple{Int,Int}} = nothing,
                  show_row_number::Bool = false,
                  sortkeys::Bool = false,
                  tf::TextFormat = unicode,
                  title_autowrap::Bool = false,
                  title_crayon::Crayon = Crayon(bold = true),
                  title_same_width_as_table::Bool = false,
                  vlines::Union{Nothing,Symbol,AbstractVector} = nothing,
                  # Deprecated
                  formatter = nothing,
                  same_column_size = nothing)

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

    data_str   = Matrix{Vector{AbstractString}}(undef,
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

    # This variable stores the predicted table width. If the user wants
    # horizontal cropping, then it can be use to avoid unnecessary processing of
    # columns that will not be displayed.
    pred_tab_width = 0

    # Auxiliary variables to adjust `alignment` based on the new columns added
    # to the table.
    alignment_add = Symbol[]

    # Row numbers
    # --------------------------------------------------------------------------

    @inbounds if show_row_number
        # Set the header of the row column.
        header_str[1,1]      = "Row"
        header_str[2:end,1] .= ""
        header_len[1,1]      = 3

        # Set the data of the row column.
        for i = 1:num_printed_rows
            data_str[i,1] = [string(id_rows[i])]

            # Here we can use `length` because there will be no UTF-8 character
            # in this cell.
            data_len[i,1] = [length(data_str[i,1][1])]
        end

        # The row number width depends on how many digits the total number of
        # rows # has and the length of the header "Row". Notice that if
        # `noheader` is set to `true`, then we should not take the word "Row"
        # into account.
        cols_width[1] = max(noheader ? 0 : 3, floor(Int, log10(num_rows)) + 1)

        # Add information about the row number column to the variables.
        push!(alignment_add, row_number_alignment)
    end

    # Row names
    # --------------------------------------------------------------------------

    @inbounds @views if show_row_names
        # Escape the row name column title.
        header_str[1,Δc]      = _str_escaped(row_name_column_title)
        header_str[2:end,Δc] .= ""

        # Compute the length of the row name column title.
        str_len = textwidth(header_str[1,Δc])
        header_len[1,Δc] = str_len

        # Convert the row names to string.
        max_size = 0
        for i = 1:num_printed_rows
            row_names_i = isassigned(row_names,i) ? row_names[i] : undef
            row_name_str, row_name_lstr, cell_width =
                _parse_cell(row_names_i;
                            autowrap = false,
                            cell_first_line_only = false,
                            column_width = -1,
                            compact_printing = compact_printing,
                            linebreaks = false)

            data_str[i,Δc] = row_name_str
            data_len[i,Δc] = row_name_lstr

            cell_width > max_size && (max_size = cell_width)
        end

        # Obtain the size of the row name column.
        cols_width[Δc] = max(str_len, max_size)

        # Add information about the row name column to the variables.
        push!(alignment_add, row_name_alignment)
    end

    !isempty(alignment_add) && (alignment = vcat(alignment_add, alignment))

    # Table data
    # --------------------------------------------------------------------------

    @inbounds for i = (1+Δc):num_printed_cols
        # Index of the i-th printed column in `data`.
        ic = id_cols[i-Δc]

        if !noheader
            for j = 1:header_num_rows
                id = (ic-1)*header_num_rows + j
                header_ij = isassigned(header,id) ? header[id] : undef

                hstr, hlstr, cell_width =
                    _parse_cell(header_ij;
                                autowrap = false,
                                cell_first_line_only = false,
                                column_width = -1,
                                compact_printing = compact_printing,
                                linebreaks = false)

                header_str[j,i] = first(hstr)
                header_len[j,i] = first(hlstr)

                # If the user does not want a fixed column width, then we must
                # store the information to automatically compute the field size.
                if !fixed_col_width[ic]
                    # Check if we should consider the sub-header size when
                    # computing the column width.
                    if (j == 1) || (!crop_subheader)
                        # Check if we need to increase the columns size.
                        cols_width[i] < cell_width && (cols_width[i] = cell_width)

                        # Make sure that the maximum column width is respected.
                        if maximum_columns_width[ic] > 0 &&
                           maximum_columns_width[ic] < cols_width[i]
                            cols_width[i] = maximum_columns_width[ic]
                        end
                    end
                end
            end
        end

        for j = 1:num_printed_rows
            # Index of the j-th printed row in `data`.
            jr = id_rows[j]

            # Apply the formatters.
            data_ij = isassigned(data,jr,ic) ? data[jr,ic] : undef

            for f in formatters
                data_ij = f(data_ij, jr, ic)
            end

            # Parse the cell.
            data_str[j,i], data_len[j,i], cell_width =
                _parse_cell(data_ij;
                            autowrap = autowrap && fixed_col_width[ic],
                            cell_first_line_only = cell_first_line_only,
                            column_width = columns_width[ic],
                            compact_printing = compact_printing,
                            linebreaks = linebreaks)

            # Check if we must update the number of lines in this row.
            num_lines_ij = length(data_str[j,i])
            num_lines_in_row[j] < num_lines_ij && (num_lines_in_row[j] = num_lines_ij)

            # If the user does not want a fixed column width, then we must store
            # the information to automatically compute the field size.
            if !fixed_col_width[ic]
                # Check if we need to increase the columns size.
                cols_width[i] < cell_width && (cols_width[i] = cell_width)

                # Make sure that the maximum column width is respected.
                if maximum_columns_width[ic] > 0 && maximum_columns_width[ic] < cols_width[i]
                    cols_width[i] = maximum_columns_width[ic]
                end
            end
        end

        # If the user horizontal cropping, then check if we need to process
        # another column.
        #
        # TODO: Should we take into account the dividers?
        if screen.size[2] > 0
            pred_tab_width += cols_width[i]

            if pred_tab_width > screen.size[2]
                num_printed_cols = i
                break
            end
        end
    end

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

    # Process `vlines`.
    vlines == nothing && (vlines = tf.vlines)
    vlines = _process_vlines(vlines, num_printed_cols)

    #                           Print the table
    # ==========================================================================

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
        @inbounds @views for i = 1:header_num_rows
            0 ∈ vlines && _p!(screen, buf, border_crayon, tf.column, false, 1)

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
                    for f in header_cell_alignment
                        aux = f(header, i, jc)

                        if aux ∈ (:l, :c, :r, :L, :C, :R, :s, :S)
                            alignment_ij = aux
                            break
                        end
                    end

                    # If alignment is `:s`, then we must use the column
                    # alignment.
                    alignment_ij ∈ (:s,:S) && (alignment_ij = alignment[jc+Δc])
                end

                # Prepare the text to be printed.
                header_ij_str, header_ij_len = _str_aligned(header_str[i,j],
                                                            alignment_ij,
                                                            cols_width[j],
                                                            header_len[i,j])
                header_ij_str  = " " * header_ij_str * " "
                header_ij_len += 2

                flp = j == num_printed_cols

                # Print the text.
                _p!(screen, buf, crayon_ij, header_ij_str, false, header_ij_len)

                # Check if we need to draw a vertical line here.
                _pc!(j ∈ vlines, screen, buf, border_crayon, tf.column, " ",
                     flp, 1, 1)

                _eol(screen) && break
            end

            i != header_num_rows && _nl!(screen,buf)
        end

        _nl!(screen,buf)

        # Bottom header line
        #-----------------------------------------------------------------------

        1 ∈ hlines && _draw_line!(screen, buf, tf.left_intersection,
                                  tf.middle_intersection,
                                  tf.right_intersection, tf.row,
                                  border_crayon, cols_width, vlines)
    end

    # Data
    # ==========================================================================

    @inbounds @views for i = 1:num_printed_rows
        ir = id_rows[i]

        for l = 1:num_lines_in_row[i]
            0 ∈ vlines && _p!(screen, buf, border_crayon, tf.column, false, 1)

            for j = 1:num_printed_cols
                # Get the information about the alignment and the crayon.
                if j ≤ Δc
                    if show_row_number && (j == 1)
                        crayon_ij    = text_crayon
                        alignment_ij = alignment[1]
                    elseif show_row_names
                            crayon_ij    = row_name_crayon
                        alignment_ij = alignment[Δc]
                    end
                else
                    jc = id_cols[j-Δc]
                    crayon_ij    = text_crayon
                    alignment_ij = alignment[jc+Δc]

                    # Check for highlighters.
                    for h in highlighters
                        if h.f(_getdata(data), ir, jc)
                            crayon_ij = h.fd(h, _getdata(data), ir, jc)
                            break
                        end
                    end

                    # Check for cell alignment override.
                    for f in cell_alignment
                        aux = f(_getdata(data), ir, jc)

                        if aux ∈ [:l, :c, :r, :L, :C, :R]
                            alignment_ij = aux
                            break
                        end
                    end

                    # For Markdown cells, we will overwrite alignment and
                    # highlighters.
                    if isassigned(data,ir,jc) && (data[ir,jc] isa Markdown.MD)
                        alignment_ij = :l
                        crayon_ij = ""
                    end
                end

                # Align the string to be printed.
                if length(data_str[i,j]) >= l
                    data_ij_str, data_ij_len = _str_aligned(data_str[i,j][l],
                                                            alignment_ij,
                                                            cols_width[j],
                                                            data_len[i,j][l])
                else
                    data_ij_str, data_ij_len = _str_aligned("",
                                                            alignment_ij,
                                                            cols_width[j])
                end

                # Print.
                data_ij_str  = " " * data_ij_str * " "
                data_ij_len += 2
                _p!(screen, buf, crayon_ij, data_ij_str, false, data_ij_len)

                flp = j == num_printed_cols

                # Check if we need to draw a vertical line here.
                _pc!(j ∈ vlines, screen, buf, border_crayon, tf.column, " " ,
                     flp, 1, 1)

                _eol(screen) && break
            end

            _nl!(screen, buf)

        end

        # Check if we must draw a horizontal line here.
        i != num_printed_rows && (i+!noheader) in hlines &&
            _draw_line!(screen, buf, body_hlines_format..., border_crayon,
                        cols_width, vlines)

        # Here we must check if the vertical size of the screen has been
        # reached. Notice that we must add 4 to account for the command line,
        # the continuation line, the bottom table line, and the last blank line.
        if (screen.size[1] > 0) && (screen.row + 4 >= screen.size[1])
            _draw_continuation_row(screen, buf, tf, text_crayon, border_crayon,
                                   cols_width, vlines)
            break
        end
    end

    # Bottom table line
    # ==========================================================================

    (num_printed_rows + !noheader) ∈ hlines &&
        _draw_line!(screen, buf, tf.bottom_left_corner, tf.bottom_intersection,
                    tf.bottom_right_corner, tf.row, border_crayon, cols_width,
                    vlines)

    # Overwrite table
    # ==========================================================================

    # If `overwrite` is `true`, then delete the exact number of lines of the
    # table. This can be used to replace the table in the screen continuously.

    str_overwrite = overwrite ? "\e[1F\e[2K"^(screen.row - 1) : ""

    # Title
    # ==========================================================================

    if length(title) > 0
        title_width = title_same_width_as_table ? screen.max_col : screen.size[2]

        print(io, title_crayon)

        # If the title width is not higher than 0, then we should only print the
        # title.
        if title_width ≤ 0
            println(io,title)
        # Otherwise, we must check for the alignments.
        else
            title_tokens = _str_line_breaks(title, title_autowrap, title_width)
            for token in title_tokens
                println(io, _str_aligned(token, title_alignment, title_width)[1])
            end
        end

        print(io, text_crayon)
    end

    # Print the buffer
    # ==========================================================================
    print(io, str_overwrite * String(take!(buf_io)))

    return nothing
end
