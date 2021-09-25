# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Print function of the LaTeX backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Low-level function to print the table using the LaTeX backend.
function _pt_latex(
    r_io::Ref{Any}, pinfo::PrintInfo;
    tf::LatexTableFormat = tf_latex_default,
    body_hlines::Vector{Int} = Int[],
    cell_alignment::Dict{Tuple{Int, Int}, Symbol} = Dict{Tuple{Int, Int}, Symbol}(),
    highlighters::Union{LatexHighlighter, Tuple} = (),
    hlines::Union{Nothing, Symbol, AbstractVector} = nothing,
    label::AbstractString = "",
    longtable_footer::Union{Nothing, AbstractString} = nothing,
    noheader::Bool = false,
    nosubheader::Bool = false,
    row_number_alignment::Symbol = :r,
    table_type::Union{Nothing, Symbol} = nothing,
    vlines::Union{Nothing, Symbol, AbstractVector} = nothing,
    wrap_table::Union{Nothing, Bool} = true,
    wrap_table_environment::Union{Nothing, String} = nothing
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
    table_type === nothing             && (table_type = tf.table_type)
    wrap_table === nothing             && (wrap_table = tf.wrap_table)
    wrap_table_environment === nothing && (wrap_table_environment = tf.wrap_table_environment)

    # Let's create a `IOBuffer` to write everything and then transfer to `io`.
    buf_io = IOBuffer()
    buf    = IOContext(buf_io)

    if !haskey(_latex_table_env, table_type)
        error("Unknown table type $table_type.")
    end

    table_env = _latex_table_env[table_type]

    if !noheader && num_cols != header_num_cols
        error("The header length must be equal to the number of columns.")
    end

    # Additional processing necessary if the user wants to print the header.
    if !noheader
        # If the user do not want to print the sub-header but wants to print the
        # header, then just force the number of rows in header to be 1.
        if nosubheader
            header_num_rows = 1
        end
    end

    # Make sure that `highlighters` is always a Ref{Any}(Tuple).
    if !(highlighters isa Tuple)
        highlighters = Ref{Any}((highlighters,))
    else
        highlighters = Ref{Any}(highlighters)
    end

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
                header_str[j, i] = _parse_cell_latex(
                    header[j][ic],
                    compact_printing = compact_printing,
                    limit_printing = limit_printing,
                    renderer = Val(:print)
                )
            end
        end

        for j = 1:num_printed_rows
            # Index of the j-th printed row in `data`.
            jr = id_rows[j]

            # Apply the formatters.
            data_ij = isassigned(data,jr,ic) ? data[jr,ic] : undef

            for f in formatters.x
                data_ij = f(data_ij, jr, ic)
            end

            data_str[j, i] = _parse_cell_latex(
                data_ij;
                cell_first_line_only = cell_first_line_only,
                compact_printing = compact_printing,
                limit_printing = limit_printing,
                renderer = renderer
            )
        end
    end

    # Compute where the horizontal and vertical lines must be drawn
    # --------------------------------------------------------------------------

    if hlines === nothing
        hlines = _process_hlines(tf.hlines, body_hlines, num_printed_rows, noheader)
    else
        hlines = _process_hlines(hlines, body_hlines, num_printed_rows, noheader)
    end

    # Process `vlines`.
    #
    # TODO: `num_printed_cols` must consider the row number.
    if vlines === nothing
        vlines = _process_vlines(tf.vlines, num_printed_cols)
    else
        vlines = _process_vlines(vlines, num_printed_cols)
    end

    # Variables to store information about indentation
    # ==========================================================================

    il = 0 # ......................................... Current indentation level
    ns = 2 # ........................ Number of spaces in each indentation level

    # Print LaTeX header
    # ==========================================================================

    if table_type != :longtable && wrap_table == true
        _aprintln(buf, "\\begin{" * wrap_table_environment * "}", il, ns)
        il += 1

        # If available, add the title to the table.
        length(title) > 0 && _aprintln(buf, "\\caption{$title}", il, ns)
    end

    table_desc = _latex_table_desc(
        id_cols,
        alignment,
        show_row_names,
        row_name_alignment,
        show_row_number,
        row_number_alignment,
        vlines,
        left_vline,
        mid_vline,
        right_vline
    )

    _aprintln(buf,"\\begin{$table_env}$table_desc", il, ns)
    il += 1

    if table_type == :longtable
        # If available, add the title to the table.
        length(title) > 0 && _aprintln(buf, "\\caption{$title}\\\\", il, ns)
    end

    # If there is no column or row to be printed, then just exit.
    if (num_printed_cols == 0) || (num_printed_rows == 0)
        @goto print_to_output
    end

    # We use a separate buffer because if `:longtable` is used, then we need to
    # repeat the header. Otherwise the caption is repeated in every page and it
    # is also added to the TOC (see issue #95).

    buf_io_h = IOBuffer()
    buf_h    = IOContext(buf_io_h)

    0 ∈ hlines && _aprintln(buf_h, top_line, il, ns)

    # Data header
    # ==========================================================================

    # Header and sub-header texts
    # --------------------------------------------------------------------------

    if !noheader
        @inbounds @views for i = 1:header_num_rows
            _aprint(buf_h, il, ns)

            # The text "Row" must appear only on the first line.
            if show_row_number
                if i == 1
                    print(buf_h, _latex_envs(row_number_column_title, header_envs))
                end

                print(buf_h, " & ")
            end

            # The row name column title must appear only on the first  line.
            if show_row_names
                if i == 1
                    print(buf_h, _latex_envs(row_name_column_title, header_envs))
                end

                print(buf_h, " & ")
            end

            for j = 1:num_printed_cols
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
                alignment_ij::Symbol = header_alignment[jc]

                for f in header_cell_alignment.x
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
                    header_str_ij = _latex_apply_cell_alignment(
                        header_str_ij,
                        alignment_ij, j,
                        num_printed_cols,
                        show_row_number,
                        vlines,
                        left_vline,
                        mid_vline,
                        right_vline
                    )
                end

                print(buf_h, header_str_ij)

                j != num_printed_cols && print(buf_h, " & ")
            end

            print(buf_h, " \\\\")
            if (i == header_num_rows) && (1 ∈ hlines)
                print(buf_h, header_line)
            end
            println(buf_h, "")
        end
    end

    header_dump = String(take!(buf_io_h))

    print(buf, header_dump)

    # If we are using `longtable`, then we must mark the end of header and also
    # create the footer.
    if table_type == :longtable
        _aprintln(buf, "\\endfirsthead", il, ns)
        print(buf, header_dump)
        _aprintln(buf, "\\endhead", il, ns)
        _aprintln(buf, bottom_line, il, ns)

        # Check if the user wants a text on the footer.
        if longtable_footer !== nothing
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

        # Apply indentation to the current line.
        _aprint(buf, il, ns)

        if show_row_number
            print(buf, string(ir) * " & ")
        end

        if show_row_names
            # Due to the non-specialization of `row_names`, `row_name_i_str`
            # here is inferred as `Any`. However, we know that the output of
            # `_parse_cell_latex` must be a String.
            row_name_i_str::String = _parse_cell_latex(
                row_names[i];
                cell_first_line_only = false,
                compact_printing = compact_printing,
                renderer = renderer
            )
            print(buf, row_name_i_str * " & ")
        end

        for j = 1:num_printed_cols
            jc = id_cols[j]

            # If we have highlighters defined, then we need to verify if this
            # data should be highlight.
            data_str_ij = data_str[i,j]

            for h in highlighters.x
                if h.f(_getdata(data), ir, jc)
                    data_str_ij = h.fd(_getdata(data), i, j, data_str[i,j])::String
                    break
                end
            end

            # Check the alignment of this cell.
            alignment_ij::Symbol = alignment[jc]

            for f in cell_alignment.x
                aux = f(_getdata(data), ir, jc)

                if aux ∈ [:l, :c, :r, :L, :C, :R]
                    alignment_ij = aux
                    break
                end
            end

            # Check if the alignment of the cell must be overridden.
            if alignment_ij != alignment[jc]
                data_str_ij = _latex_apply_cell_alignment(
                    data_str_ij,
                    alignment_ij,
                    j,
                    num_printed_cols,
                    show_row_number,
                    vlines,
                    left_vline,
                    mid_vline,
                    right_vline
                )
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

    @label print_to_output

    # Print LaTeX footer
    # ==========================================================================

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

    # Print the buffer into the io.
    # ==========================================================================

    print(io, String(take!(buf_io)))

    return nothing
end
