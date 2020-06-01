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
                  columns_width::Union{Integer,AbstractVector{Int}} = 0,
                  highlighters::Union{Highlighter,Tuple} = (),
                  hlines::Union{Nothing,Symbol,AbstractVector} = nothing,
                  linebreaks::Bool = false,
                  overwrite::Bool = false,
                  noheader::Bool = false,
                  nosubheader::Bool = false,
                  row_name_crayon::Crayon = Crayon(bold = true),
                  row_name_header_crayon::Crayon = Crayon(bold = true),
                  same_column_size::Bool = false,
                  screen_size::Union{Nothing,Tuple{Int,Int}} = nothing,
                  show_row_number::Bool = false,
                  sortkeys::Bool = false,
                  tf::TextFormat = unicode,
                  vlines::Union{Nothing,Symbol,AbstractVector} = nothing,
                  # Deprecated
                  formatter = nothing)

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

    # Check which columns must have fixed sizes.
    typeof(columns_width) <: Integer && (columns_width = ones(Int, num_cols)*columns_width)
    length(columns_width) != num_cols && error("The length of `columns_width` must be the same as the number of columns.")
    fixed_col_width = map(w->w > 0, columns_width)

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
    data_str   = Matrix{Vector{AbstractString}}(undef,
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

        # Set the data of the row column.
        for i = 1:num_printed_rows
            data_str[i,1] = [string(id_rows[i])]
        end

        # The row number width depends on how many digits the total number of
        # rows # has and the length of the header "Row". Notice that if
        # `noheader` is set to `true`, then we should not take the word "Row"
        # into account.
        cols_width[1] = max(noheader ? 0 : 3, floor(Int, log10(num_rows)) + 1)

        # Add information about the row number column to the variables.
        push!(alignment_add, :r)
    end

    # Row names
    # --------------------------------------------------------------------------

    @inbounds @views if show_row_names
        # Escape the row name column title.
        header_str[1,Δc]      = _str_escaped(row_name_column_title)
        header_str[2:end,Δc] .= ""

        # Convert the row names to string.
        max_size = 0
        for i = 1:num_printed_rows
            data_str[i,Δc] = [_str_escaped(sprint(print, row_names[i]))]

            len_i = length(data_str[i,Δc][1])
            len_i > max_size && (max_size = len_i)
        end

        # Obtain the size of the row name column.
        cols_width[Δc] = max(length(header_str[1,Δc]), max_size)

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
                header_str[j,i] = _str_escaped(sprint(print, header[(ic-1)*header_num_rows + j]))

                # Compute the minimum column size to print this string.
                cell_width = length(header_str[j,i])

                # If the user wants a fixed column width, then we must verify if
                # the text must be cropped.
                if fixed_col_width[ic]
                    if cell_width > cols_width[i]
                        header_str[j,i] = header_str[j,i][1:cols_width[i] - 1] * "…"
                    end
                else
                    # Check if we need to increase the columns size.
                    cols_width[i] < cell_width && (cols_width[i] = cell_width)
                end
            end
        end

        for j = 1:num_printed_rows
            # Index of the j-th printed row in `data`.
            jr = id_rows[j]

            # Apply the formatters.
            data_ij = data[jr,ic]

            for f in formatters
                data_ij = f(data_ij, jr, ic)
            end

            # Handle `nothing` and `missing`.
            if ismissing(data_ij)
                data_str_ij = "missing"
            elseif data_ij == nothing
                data_str_ij = "nothing"
            else
                data_str_ij = sprint(print, data_ij)
            end

            if linebreaks
                tokens = _str_line_breaks(data_str_ij,
                                          autowrap && fixed_col_width[ic],
                                          columns_width[i])
                data_str[j,i] = tokens
                num_lines_ij  = length(tokens)

                # Check if we must update the number of lines in this row.
                num_lines_in_row[j] < num_lines_ij && (num_lines_in_row[j] = num_lines_ij)

                # Compute the maximum length to compute the column size.
                cell_width = maximum(length.(tokens))
            else
                data_str_ij_esc = _str_escaped(data_str_ij)
                data_str[j,i]   = [data_str_ij_esc]
                cell_width      = length(data_str_ij_esc)
            end

            # If the user wants a fixed columns width, then we must verify if
            # the text must be cropped.
            if fixed_col_width[ic]
                for k = 1:length(data_str[j,i])
                    if length(data_str[j,i][k]) > cols_width[i]
                        data_str[j,i][k] = data_str[j,i][k][1:cols_width[i] - 1] * "…"
                    end
                end
            else
                # Check if we need to increase the columns size.
                cols_width[i] < cell_width && (cols_width[i] = cell_width)
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
    same_column_size && (cols_width = [maximum(cols_width) for i = 1:num_printed_cols])

    # Compute where the horizontal and vertical lines must be drawn
    # --------------------------------------------------------------------------

    # Create the format of the horizontal lines.
    if body_hlines_format == nothing
        body_hlines_format = (tf.left_intersection, tf.middle_intersection,
                              tf.right_intersection, tf.row)
    end

    # Process `hlines`.
    if hlines == nothing
        hlines = tf.hlines
    elseif hlines == :all
        hlines = collect(0:1:num_printed_rows + !noheader)
    elseif hlines == :none
        hlines = Int[]
    elseif !(typeof(hlines) <: AbstractVector)
        error("`hlines` must be `:all`, `:none`, or a vector of integers.")
    end

    # The symbol `:begin` is replaced by 0, the symbol `:header` by the line
    # after the header, and the symbol `:end` is replaced by the last row.
    hlines = replace(hlines, :begin  => 0,
                             :header => noheader ? -1 : 1,
                             :end    => num_printed_rows + !noheader)

    # All numbers less than 1 and higher or equal the number of printed rows
    # must be # removed from `body_hlines`.
    body_hlines = filter(x -> (x ≥ 1) && (x < num_printed_rows), body_hlines)

    # Merge `hlines` with `body_hlines`.
    hlines = unique(vcat(hlines, body_hlines .+ !noheader))
    #                                               ^
    #                                               |
    # If we have header, then the index in `body_hlines` must be incremented.

    # Process `vlines`.
    vlines == nothing && (vlines = tf.vlines)

    if vlines == :all
        vlines = collect(0:1:num_printed_cols)
    elseif vlines == :none
        vlines = Int[]
    elseif !(typeof(vlines) <: AbstractVector)
        error("`vlines` must be `:all`, `:none`, or a vector of integers.")
    end

    # The symbol `:begin` is replaced by 0 and the symbol `:end` is replaced by
    # the last column.
    vlines = replace(vlines, :begin => 0,
                             :end   => num_printed_cols)

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
            0 ∈ vlines && _p!(screen, buf, border_crayon, tf.column)

            for j = 1:num_printed_cols
                # Get the information about the alignment and the crayon.
                if j ≤ Δc
                    if show_row_number && (j == 1)
                        crayon_ij    = rownum_header_crayon
                        alignment_ij = alignment[1]
                    elseif show_row_names
                        crayon_ij    = row_name_crayon
                        alignment_ij = alignment[Δc]
                    end
                else
                    jc = id_cols[j-Δc]
                    crayon_ij    = (i == 1) ? header_crayon[jc] : subheader_crayon[jc]
                    alignment_ij = alignment[jc+Δc]
                end

                # Prepare the text to be printed.
                header_i_str = " " * _str_aligned(header_str[i,j],
                                                  alignment_ij,
                                                  cols_width[j]) * " "

                flp = j == num_printed_cols

                # Print the text.
                _p!(screen, buf, crayon_ij, header_i_str)

                # Check if we need to draw a vertical line here.
                _pc!(j ∈ vlines, screen, buf, border_crayon, tf.column, " " , flp)

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
            0 ∈ vlines && _p!(screen, buf, border_crayon, tf.column)

            for j = 1:num_printed_cols
                # Get the information about the alignment and the crayon.
                if j ≤ Δc
                    if show_row_number && (j == 1)
                        crayon_ij    = text_crayon
                        alignment_ij = alignment[1]
                    elseif show_row_names
                        crayon_ij    = text_crayon
                        alignment_ij = alignment[Δc]
                    end
                else
                    jc = id_cols[j-Δc]
                    crayon_ij    = text_crayon
                    alignment_ij = alignment[jc+Δc]

                    # Check for highlighters.
                    for h in highlighters
                        if h.f(data, ir, jc)
                            crayon_ij = h.fd(h, data, ir, jc)
                            break
                        end
                    end

                    # Check for cell alignment override.
                    for f in cell_alignment
                        aux = f(data, ir, jc)

                        if aux ∈ [:l, :c, :r, :L, :C, :R]
                            alignment_ij = aux
                            break
                        end
                    end
                end

                # Align the string to be printed.
                if length(data_str[i,j]) >= l
                    data_ij_str = " " * _str_aligned(data_str[i,j][l], alignment_ij, cols_width[j]) * " "
                else
                    data_ij_str = " " * _str_aligned("", alignment_ij, cols_width[j]) * " "
                end

                # Print.
                _p!(screen, buf, crayon_ij, data_ij_str)

                flp = j == num_printed_cols

                # Check if we need to draw a vertical line here.
                _pc!(j ∈ vlines, screen, buf, border_crayon, tf.column, " " , flp)

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
                  
    # Optional overwrite - Should be used the 2nd use onwards, assumes the previous table had the same number of rows
    # ========================================================================== 
    if overwrite  
        for _ in 1:screen.row - 1
            print("\e[1F") # move cursor up one row
            print("\e[2K") # clear whole line
        end
    end
    
    # Print the buffer
    # ==========================================================================
    print(io, String(take!(buf_io)))

    return nothing
end
