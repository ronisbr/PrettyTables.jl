## Description #############################################################################
#
# Print function of the LaTeX backend.
#
############################################################################################

# Low-level function to print the table using the LaTeX backend.
function _print_table_with_latex_back_end(
    pinfo::PrintInfo;
    tf::LatexTableFormat = tf_latex_default,
    body_hlines::Vector{Int} = Int[],
    highlighters::Union{LatexHighlighter, Tuple} = (),
    hlines::Union{Nothing, Symbol, AbstractVector} = nothing,
    label::AbstractString = "",
    longtable_footer::Union{Nothing, AbstractString} = nothing,
    sortkeys::Bool = false,
    table_type::Union{Nothing, Symbol} = nothing,
    vlines::Union{Nothing, Symbol, AbstractVector} = nothing,
    wrap_table::Union{Nothing, Bool} = false,
    wrap_table_environment::Union{Nothing, String} = nothing
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

    hidden_rows_at_end = _get_num_of_hidden_rows(ptable) > 0
    hidden_columns_at_end = _get_num_of_hidden_columns(ptable) > 0

    # Unpack fields of `tf`.
    top_line       = tf.top_line
    header_line    = tf.header_line
    mid_line       = tf.mid_line
    bottom_line    = tf.bottom_line
    left_vline     = tf.left_vline
    mid_vline      = tf.mid_vline
    right_vline    = tf.right_vline
    header_envs    = tf.header_envs
    subheader_envs = tf.subheader_envs

    # Unpack fields of `tf` that depends on the user options.
    if table_type === nothing
        table_type = tf.table_type
    end

    if wrap_table === nothing
        wrap_table = tf.wrap_table
    end

    if wrap_table_environment === nothing
        wrap_table_environment = tf.wrap_table_environment
    end

    if hlines === nothing
        hlines = tf.hlines
    end
    hlines = _process_hlines(ptable, hlines)

    if vlines === nothing
        vlines = tf.vlines
    end
    vlines = _process_vlines(ptable, vlines)

    # Let's create a `IOBuffer` to write everything and then transfer to `io`.
    buf_io = IOBuffer()
    buf    = IOContext(buf_io)

    if !haskey(_latex_table_env, table_type)
        error("Unknown table type $table_type.")
    end

    table_env = _latex_table_env[table_type]

    # Make sure that `highlighters` is always a Tuple.
    if !(highlighters isa Tuple)
        highlighters = (highlighters,)
    end

    # Get the number of lines and columns in the table.
    num_rows, num_columns = _size(ptable)

    # == Variables to Store Information About Indentation ==================================

    il = 0 # ..................................................... Current indentation level
    ns = 2 # .................................... Number of spaces in each indentation level

    # == Print LaTeX Header ================================================================

    if table_type != :longtable && wrap_table == true
        _aprintln(buf, "\\begin{" * wrap_table_environment * "}", il, ns)
        il += 1

        # If available, add the title to the table.
        length(title) > 0 && _aprintln(buf, "\\caption{$title}", il, ns)
    end

    # Obtain the table description with the alignments and vertical lines.
    table_desc = _latex_table_description(
        ptable,
        vlines,
        left_vline,
        mid_vline,
        right_vline,
        hidden_columns_at_end
    )

    _aprintln(buf,"\\begin{$table_env}$table_desc", il, ns)
    il += 1

    if table_type == :longtable
        # If available, add the title to the table.
        length(title) > 0 && _aprintln(buf, "\\caption{$title}\\\\", il, ns)
    end

    # We use a separate buffer because if `:longtable` is used, then we need to repeat the
    # header. Otherwise the caption is repeated in every page and it is also added to the
    # TOC (see issue #95).

    buf_io_h = IOBuffer()
    buf_h    = IOContext(buf_io_h)

    buf_io_b = IOBuffer()
    buf_b    = IOContext(buf_io_b)

    # If there is no column and no row to be printed, then just exit.
    if _data_size(ptable) == (0, 0)
        @goto print_to_output
    end

    if _check_hline(ptable, hlines, body_hlines, 0)
        _aprintln(buf_h, top_line, il, ns)
    end

    # == Print the Table ===================================================================

    # If the line is part of the header, we need to write to `buf_h`. Otherwise, we must
    # switch to `buf_b`.
    buf_aux = buf_h

    @inbounds for i in 1:num_rows
        # Get the identification of the current row.
        row_id = _get_row_id(ptable, i)

        if _is_header_row(row_id)
            buf_aux = buf_h
        else
            buf_aux = buf_b
        end

        # Apply the indentation.
        _aprint(buf_aux, il, ns)

        @inbounds for j in 1:num_columns
            # Get the identification of the current column.
            column_id = _get_column_id(ptable, j)

            # Get the column alignment.
            column_alignment = _get_column_alignment(ptable, j)

            # Get the alignment for the current cell.
            cell_alignment = _get_cell_alignment(ptable, i, j)

            # Get the cell data.
            cell_data = _get_element(ptable, i, j)

            # If we do not annotate the type here, then we get type instability
            # due to `_latex_parse_cell`.
            cell_str::String = ""

            if _is_header_row(row_id)
                if column_id == :__ORIGINAL_DATA__
                    cell_str = _latex_parse_cell(
                        io,
                        cell_data;
                        compact_printing = compact_printing,
                        limit_printing = limit_printing,
                        renderer = Val(:print)
                    )
                else
                    # For the additional cells, we just need to convert to
                    # string.
                    cell_str = string(cell_data)
                end

                # Get the LaTeX environments for this cell.
                envs = row_id == :__HEADER__ ? header_envs : subheader_envs

                # Apply the environments to the STR.
                cell_str = _latex_envs(cell_str, envs)

                # Check if the cell alignment must be changed with respect to
                # the column alignment.
                if cell_alignment != column_alignment
                    cell_str = _latex_cell_alignment(
                        ptable,
                        cell_str,
                        cell_alignment,
                        j,
                        vlines,
                        left_vline,
                        mid_vline,
                        right_vline
                    )
                end

                print(buf_h, cell_str)

                # Check if we need to draw the continuation character.
                if j != num_columns
                    print(buf_h, " & ")
                elseif hidden_columns_at_end
                    print(buf_h, " & \$\\cdots\$")
                end
            else

                ir = _get_data_row_index(ptable, i)
                jr = _get_data_column_index(ptable, j)

                if column_id == :__ORIGINAL_DATA__
                    # Notice that `(ir, jr)` are the indices of the printed data. It means
                    # that it refers to the ir-th data row and jr-th data column that will
                    # be printed. We need to convert those indices to the actual indices in
                    # the input table.
                    tir, tjr = _convert_axes(ptable.data, ir, jr)

                    # Apply the formatters.
                    for f in formatters.x
                        cell_data = f(cell_data, tir, tjr)
                    end

                    cell_str = _latex_parse_cell(
                        io,
                        cell_data;
                        cell_first_line_only = cell_first_line_only,
                        compact_printing = compact_printing,
                        limit_printing = limit_printing,
                        renderer = renderer
                    )

                    # Apply highlighters.
                    for h in highlighters
                        if h.f(_getdata(ptable), tir, tjr)
                            cell_str = h.fd(_getdata(ptable), tir, tjr, cell_str)::String
                            break
                        end
                    end

                    # Check if the cell alignment must be changed with respect to the column
                    # alignment.
                    if cell_alignment != column_alignment
                        cell_str = _latex_cell_alignment(
                            ptable,
                            cell_str,
                            cell_alignment,
                            j,
                            vlines,
                            left_vline,
                            mid_vline,
                            right_vline
                        )
                    end
                else
                    # For the additional cells, we just need to convert to string.
                    cell_str = string(cell_data)
                end

                print(buf_aux, cell_str)

                # Check if we need to draw the continuation character.
                if j != num_columns
                    print(buf_aux, " & ")
                elseif hidden_columns_at_end
                    print(buf_aux, " & \$\\cdots\$")
                end
            end
        end

        print(buf_aux, " \\\\")

        if (i == num_rows) && hidden_rows_at_end
            println(buf_aux)
            _aprint(buf_aux, il, ns)

            for j in 1:num_columns
                print(buf_aux, "\$\\vdots\$")

                # Check if we need to draw the continuation character.
                if j != num_columns
                    print(buf_aux, " & ")
                elseif hidden_columns_at_end
                    print(buf_aux, " & \$\\ddots\$")
                end
            end

            print(buf_aux, " \\\\")
        end

        # After the last line, we need to check if we are printing all the rows or not. In
        # the latter, we need to pass the last row index to check if the last horizontal
        # line must be drawn.
        i_hline = i == num_rows ? num_rows : i

        if _check_hline(ptable, hlines, body_hlines, i_hline)
            if i_hline == num_rows
                print(buf_aux, bottom_line)
            elseif _is_header_row(row_id)
                print(buf_aux, header_line)
            else
                print(buf_aux, mid_line)
            end
        end

        println(buf_aux)
    end

    @label print_to_output

    header_dump = String(take!(buf_io_h))
    body_dump   = String(take!(buf_io_b))

    print(buf, header_dump)

    # If we are using `longtable`, then we must mark the end of header and also
    # create the footer before printing the body.
    if table_type == :longtable
        _aprintln(buf, "\\endfirsthead", il, ns)
        print(buf, header_dump)
        _aprintln(buf, "\\endhead", il, ns)
        _aprintln(buf, bottom_line, il, ns)

        # Check if the user wants a text on the footer.
        if longtable_footer !== nothing
            lvline = _check_vline(ptable, vlines, 0) ? left_vline : ""
            rvline = _check_vline(ptable, vlines, num_columns) ? right_vline : ""

            env = "multicolumn{" * string(num_columns) * "}" * "{r}"

            _aprintln(buf, _latex_envs(longtable_footer, env) * "\\\\", il, ns)
            _aprintln(buf, bottom_line, il, ns)
        end

        _aprintln(buf, "\\endfoot", il, ns)
        _aprintln(buf, "\\endlastfoot", il, ns)
    end

    print(buf, body_dump)

    # == Print LaTeX Footer ================================================================

    # If available, add the label to the table if we are using `longtable`.
    if table_type == :longtable && !isempty(label)
        _aprintln(buf, "\\label{" * label * "}", il)
    end

    il -= 1
    _aprintln(buf, "\\end{$table_env}", il, ns)

    if table_type != :longtable && wrap_table == true
        # If available, add the label to the table.
        !isempty(label) && _aprintln(buf, "\\label{" * label * "}", il)

        il -= 1
        _aprintln(buf, "\\end{" * wrap_table_environment * "}", il, ns)
    end

    # == Print the Buffer Into The IO ======================================================

    print(io, String(take!(buf_io)))

    return nothing
end
