# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Print function of the LaTeX backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Low-level function to print the table using the LaTeX backend.
function _pt_latex(io::IO, pinfo::PrintInfo;
                   tf::LatexTableFormat = latex_default,
                   body_hlines::Vector{Int} = Int[],
                   cell_alignment::Dict{Tuple{Int,Int},Symbol} = Dict{Tuple{Int,Int},Symbol}(),
                   highlighters::Union{LatexHighlighter,Tuple} = (),
                   hlines::Union{Nothing,Symbol,AbstractVector} = nothing,
                   longtable_footer::Union{Nothing,AbstractString} = nothing,
                   noheader::Bool = false,
                   nosubheader::Bool = false,
                   row_number_alignment::Symbol = :r,
                   table_type::Symbol = :tabular,
                   vlines::Union{Nothing,Symbol,AbstractVector} = nothing)

    @unpack_PrintInfo pinfo

    # We cannot use `@unpack_` here because it will overwrite `hlines` and
    # `vlines.`
    top_line       = tf.top_line
    header_line    = tf.header_line
    mid_line       = tf.mid_line
    bottom_line    = tf.bottom_line
    left_vline     = tf.left_vline
    mid_vline      = tf.mid_vline
    right_vline    = tf.right_vline
    header_envs    = tf.header_envs
    subheader_envs = tf.subheader_envs

    # Let's create a `IOBuffer` to write everything and then transfer to `io`.
    buf_io = IOBuffer()
    buf    = IOContext(buf_io)

    table_type ∉ [:tabular, :longtable] &&
    error("Unknown table type $table_type. Possible values are `:tabular` or `:longtable`.")

    table_env = table_type == :tabular ? "tabular" : "longtable"

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
    end

    # Make sure that `highlighters` is always a tuple.
    !(highlighters isa Tuple) && (highlighters = (highlighters,))

    # Get the string which is printed when `print` is called in each element of
    # the matrix. Notice that we must create only the matrix with the printed
    # rows and columns.
    header_str = Matrix{String}(undef, header_num_rows, num_printed_cols)
    data_str   = Matrix{String}(undef, num_printed_rows, num_printed_cols)

    @inbounds for i = 1:num_printed_cols
        # Index of the i-th printed column in `data`.
        ic = id_cols[i]

        if !noheader
            for j = 1:header_num_rows
                header_str[j,i] =
                    _parse_cell_latex(header[(ic-1)*header_num_rows + j],
                                      compact_printing = compact_printing,
                                      renderer = Val(:print))
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

            data_str[j,i] = _parse_cell_latex(data_ij;
                                              cell_first_line_only = cell_first_line_only,
                                              compact_printing = compact_printing,
                                              renderer = renderer)
        end
    end

    # Compute where the horizontal and vertical lines must be drawn
    # --------------------------------------------------------------------------

    hlines == nothing && (hlines = tf.hlines)
    hlines = _process_hlines(hlines, body_hlines, num_printed_rows, noheader)

    # Process `vlines`.
    #
    # TODO: `num_printed_cols` must consider the row number.
    vlines == nothing && (vlines = tf.vlines)
    vlines = _process_vlines(vlines, num_printed_cols + show_row_number)

    # Variables to store information about indentation
    # ==========================================================================

    il = 0 # ......................................... Current indentation level
    ns = 2 # ........................ Number of spaces in each indentation level

    # Print LaTeX header
    # ==========================================================================

    if table_type == :tabular
        _aprintln(buf, "\\begin{table}", il, ns)
        il += 1
        length(title) > 0 && _aprintln(buf, "\\caption{$title}", il, ns)
    end

    _aprintln(buf,"""
              \\begin{$table_env}$(_latex_table_desc(id_cols,
                                                     alignment,
                                                     show_row_number,
                                                     row_number_alignment,
                                                     vlines,
                                                     left_vline,
                                                     mid_vline,
                                                     right_vline))""",
              il, ns)
    il += 1

    if table_type == :longtable
        length(title) > 0 && _aprintln(buf, "\\caption{$title}\\\\", il, ns)
    end

    0 ∈ hlines && _aprintln(buf, top_line, il, ns)

    # Data header
    # ==========================================================================

    # Header and sub-header texts
    # --------------------------------------------------------------------------

    if !noheader
        @inbounds @views for i = 1:header_num_rows
            # The text "Row" must appear only on the first line.
            if show_row_number
                _aprint(buf, il, ns)

                if i == 1
                    print(buf, _latex_envs(row_number_column_title, header_envs))
                end

                print(buf, " & ")
            end

            for j = 1:num_printed_cols
                # Apply the alignment to this row.
                (!show_row_number && j == 1) && _aprint(buf, il, ns)

                # Index of the j-th printed column in `data`.
                jc = id_cols[j]

                # Configure the LaTeX environments for the header and
                # sub-headers.
                if i == 1
                    envs = header_envs
                else
                    envs = subheader_envs
                end

                header_str_ij = _latex_envs(header_str[i,j], envs)

                # Check the alignment of this cell.
                alignment_ij = header_alignment[jc]

                for f in header_cell_alignment
                    aux = f(header, i, jc)

                    if aux ∈ (:l, :c, :r, :L, :C, :R, :s, :S)
                        alignment_ij = aux
                        break
                    end
                end

                # If alignment is `:s`, then we must use the column alignment.
                alignment_ij ∈ (:s,:S) && (alignment_ij = alignment[jc])

                # Check if the alignment of the cell must be overridden.
                if alignment_ij != alignment[jc]
                    header_str_ij = _latex_apply_cell_alignment(header_str_ij,
                                                                alignment_ij, j,
                                                                num_printed_cols,
                                                                show_row_number,
                                                                vlines,
                                                                left_vline,
                                                                mid_vline,
                                                                right_vline)
                end

                print(buf, header_str_ij)

                j != num_printed_cols && print(buf, " & ")
            end

            print(buf, " \\\\")
            if (i == header_num_rows) && (1 ∈ hlines)
                print(buf, header_line)
            end
            println(buf, "")
        end
    end

    # If we are using `longtable`, then we must mark the end of header and also
    # create the footer.
    if table_type == :longtable
        _aprintln(buf, "\\endhead", il, ns)
        _aprintln(buf, bottom_line, il, ns)

        # Check if the user wants a text on the footer.
        if longtable_footer != nothing
            lvline =            0 ∈ vlines ? left_vline : ""
            rvline = id_cols[end] ∈ vlines ? right_vline : ""

            env = "multicolumn{" * string(num_printed_cols) * "}" * "{r}"

            _aprintln(buf, _latex_envs(longtable_footer, env) * "\\\\", il, ns)
            _aprintln(buf, bottom_line, il, ns)
        end

        _aprintln(buf, "\\endfoot", il, ns)
        _aprintln(buf, "\\endlastfoot", il, ns)
    end

    # Data
    # ==========================================================================

    @inbounds @views for i = 1:num_printed_rows
        ir = id_rows[i]

        if show_row_number
            _aprint(buf, string(ir) * " & ", il, ns)
        end

        for j = 1:num_printed_cols
            # Apply the alignment to this row.
            (!show_row_number && j == 1) && _aprint(buf, il, ns)

            jc = id_cols[j]

            # If we have highlighters defined, then we need to verify if this
            # data should be highlight.
            data_str_ij = data_str[i,j]

            for h in highlighters
                if h.f(_getdata(data), ir, jc)
                    data_str_ij = h.fd(_getdata(data), i, j, data_str[i,j])
                    break
                end
            end

            # Check the alignment of this cell.
            alignment_ij = alignment[jc]

            for f in cell_alignment
                aux = f(_getdata(data), ir, jc)

                if aux ∈ [:l, :c, :r, :L, :C, :R]
                    alignment_ij = aux
                    break
                end
            end

            # Check if the alignment of the cell must be overridden.
            if alignment_ij != alignment[jc]
                data_str_ij = _latex_apply_cell_alignment(data_str_ij,
                                                          alignment_ij, j,
                                                          num_printed_cols,
                                                          show_row_number,
                                                          vlines, left_vline,
                                                          mid_vline,
                                                          right_vline)
            end

            print(buf, data_str_ij)
            j != num_printed_cols && print(buf, " & ")
        end

        print(buf, " \\\\")

        # Check if the user wants a horizontal line here.
        if (i+!noheader) ∈ hlines
            if i != num_printed_rows
                # Check if we must draw a horizontal line here.
                print(buf, mid_line)
            else
                print(buf, bottom_line)
            end
        end
        println(buf, "")
    end

    # Print LaTeX footer
    # ==========================================================================

    il -= 1
    _aprintln(buf, "\\end{$table_env}", il, ns)

    if table_type == :tabular
        il -= 1
        _aprintln(buf, "\\end{table}", il, ns)
    end

    # Print the buffer into the io.
    # ==========================================================================

    print(io, String(take!(buf_io)))

    return nothing
end
