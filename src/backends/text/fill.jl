# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions to fill data in the table that will be printed.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Compute the vectors that will be used to fill the rows of the matrix that will
# be printed. This is required due to the different crop modes available.
function _compute_row_fill_vectors(id_rows::Vector{Int},
                                   num_printed_rows::Int,
                                   vcrop_mode::Symbol)

    # Compute the array separation if the vertical crop mode is `:middle`.
    num_rows = length(id_rows)
    Δ₀ = cld(num_printed_rows, 2)

    # Create the vector that will be used to fill the rows given the crop mode.
    jvec  = Vector{Int}(undef, num_printed_rows)
    jrvec = Vector{Int}(undef, num_printed_rows)

    if vcrop_mode == :bottom
        for i = 1:num_printed_rows
            jvec[i]  = i
            jrvec[i] = id_rows[i]
        end
    elseif vcrop_mode == :middle
        i  = 1
        i₀ = 1
        i₁ = 1

        len₀ = Δ₀
        len₁ = num_printed_rows - Δ₀

        while (i₀ ≤ len₀) || (i₁ ≤ len₁)
            if i₀ ≤ len₀
                j        = i₀
                jvec[i]  = j
                jrvec[i] = id_rows[j]

                i  += 1
                i₀ += 1
            end

            if i₁ ≤ len₁
                j = num_printed_rows - i₁ + 1
                jvec[i]  = j
                jrvec[i] = id_rows[num_rows - i₁ + 1]

                i  += 1
                i₁ += 1
            end
        end
    else
        error("Unknown vertical crop mode.")
    end

    return jvec, jrvec
end

# Fill the header and matrix data.
function _fill_matrix_data!(header_str::Matrix{String},
                            data_str::Matrix{Vector{String}},
                            id_cols::Vector{Int},
                            jvec::Vector{Int},
                            jrvec::Vector{Int},
                            Δc::Int,
                            (@nospecialize data::Any),
                            (@nospecialize header::Any),
                            (@nospecialize formatters::Tuple),
                            display::Display,
                            # Configuration options.
                            autowrap::Bool,
                            cell_first_line_only::Bool,
                            columns_width::Vector{Int},
                            compact_printing::Bool,
                            crop_subheader::Bool,
                            limit_printing::Bool,
                            linebreaks::Bool,
                            noheader::Bool,
                            renderer::Union{Val{:print}, Val{:show}},
                            vcrop_mode::Symbol)

    num_printed_rows, num_printed_cols = size(data_str)
    header_num_rows, ~ = size(header_str)

    # This variable stores the predicted table width. If the user wants
    # horizontal cropping, then it can be use to avoid unnecessary processing of
    # columns that will not be displayed.
    pred_tab_width = 0

    @inbounds for i = (1+Δc):num_printed_cols
        # Here we store the number of processed rows. This is used to save
        # processing if the user wants to crop the output and has cells with
        # multiple lines.
        num_processed_rows = 0

        # Index of the i-th printed column in `data`.
        ic = id_cols[i-Δc]

        # Store the largest cell width in this column. This leads to a double
        # computation of the cell size, here and in the
        # `_update_text_table_lengths`. However, we need this to stop processing
        # columns when cropping horizontally.
        largest_cell_width = 0

        if !noheader
            for j = 1:header_num_rows
                id = (ic-1)*header_num_rows + j
                header_ij = isassigned(header,id) ? header[id] : undef

                # NOTE: For headers, we always use `print` instead of `show` to
                # avoid quotes.
                hstr = _parse_cell_text(header_ij;
                                        autowrap = false,
                                        cell_first_line_only = false,
                                        column_width = -1,
                                        compact_printing = compact_printing,
                                        has_color = display.has_color,
                                        limit_printing = limit_printing,
                                        linebreaks = false,
                                        renderer = Val(:print))

                header_str[j,i] = first(hstr)
                num_processed_rows += 1

                largest_cell_width = max(largest_cell_width,
                                         textwidth(header_str[j,i]))
            end
        end

        for k = 1:num_printed_rows
            j  = jvec[k]
            jr = jrvec[k]

            # Apply the formatters.
            data_ij = isassigned(data,jr,ic) ? data[jr,ic] : undef

            data_ij_type = typeof(data_ij)

            for f in formatters
                data_ij = f(data_ij, jr, ic)
            end

            # Check if this is a columns with fixed size.
            fixed_col_width = columns_width[ic] > 0

            # Parse the cell.
            data_str[j,i] = _parse_cell_text(data_ij;
                                             autowrap = autowrap && fixed_col_width,
                                             cell_data_type = data_ij_type,
                                             cell_first_line_only = cell_first_line_only,
                                             column_width = columns_width[ic],
                                             compact_printing = compact_printing,
                                             has_color = display.has_color,
                                             limit_printing = limit_printing,
                                             linebreaks = linebreaks,
                                             renderer = renderer)

            # Compute the number of lines so that we can avoid process
            # unnecessary cells due to cropping.
            num_processed_rows += length(data_str[j,i])

            if data_ij isa Markdown.MD
                largest_cell_width =
                    max(largest_cell_width,
                        maximum(_printable_textwidth.(data_str[j,i])))
            else
                largest_cell_width = max(largest_cell_width,
                                         maximum(textwidth.(data_str[j,i])))
            end

            # If the crop mode if `:middle`, then we need to always process a
            # row in the top and in another in the bottom before stopping due to
            # display size. This is required to avoid printing from a cell that
            # is undefined. Notice that due to the printing order in `jvec` we
            # just need to check if `k` is even.
            if ( (vcrop_mode == :bottom) ||
                 ( (vcrop_mode == :middle) && (k % 2 == 0) ) ) &&
                (display.size[1] > 0) && (num_processed_rows ≥ display.size[1])
                break
            end
        end

        # If the user horizontal cropping, then check if we need to process
        # another column.
        #
        # TODO: Should we take into account the dividers?
        if display.size[2] > 0
            pred_tab_width += largest_cell_width

            if pred_tab_width > display.size[2]
                num_printed_cols = i
                break
            end
        end
    end

    return num_printed_cols, num_printed_rows
end

# Fill the information related to the row number column.
function _fill_row_number_column!(header_str::Matrix{String},
                                  data_str::Matrix{Vector{String}},
                                  id_rows::Vector{Int},
                                  jvec::Vector{Int},
                                  jrvec::Vector{Int},
                                  noheader::Bool,
                                  num_rows::Int,
                                  row_number_column_title::String)

    num_printed_rows = size(data_str)[1]

    num_printed_rows == 0 && return nothing

    # Set the header of the row column.
    @inbounds header_str[1,1]      = row_number_column_title
    @inbounds header_str[2:end,1] .= ""

    # Set the data of the row column.
    @inbounds for i = 1:num_printed_rows
        j  = jvec[i]
        jr = jrvec[i]

        data_str[j,1] = [string(jr)]
    end

    return nothing
end

# Fill the information related to the row name column.
function _fill_row_name_column!(header_str::Matrix{String},
                                data_str::Matrix{Vector{String}},
                                (@nospecialize row_names::AbstractVector),
                                jvec::Vector{Int},
                                jrvec::Vector{Int},
                                Δc::Int,
                                compact_printing::Bool,
                                renderer::Union{Val{:print}, Val{:show}},
                                row_name_column_title::String)

    num_printed_rows = size(data_str)[1]

    num_printed_rows == 0 && return nothing

    # Escape the row name column title.
    @inbounds header_str[1,Δc] =
        first(_render_text(Val(:print),
                           row_name_column_title,
                           compact_printing = compact_printing,
                           linebreaks = false))
    @inbounds header_str[2:end,Δc] .= ""

    # Convert the row names to string.
    @inbounds for i = 1:num_printed_rows
        j  = jvec[i]
        jr = jrvec[i]

        row_names_j = isassigned(row_names,jr) ? row_names[jr] : undef
        row_name_str = _parse_cell_text(row_names_j;
                                        autowrap = false,
                                        cell_first_line_only = false,
                                        column_width = -1,
                                        compact_printing = compact_printing,
                                        linebreaks = false,
                                        renderer = Val(:print))

        data_str[j,Δc] = row_name_str
    end

    return nothing
end
