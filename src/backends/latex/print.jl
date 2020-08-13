# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Print function of the LaTeX backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Low-level function to print the table using the LaTeX backend.
function _pt_latex(io, pinfo;
                   tf::LatexTableFormat = latex_default,
                   cell_alignment::Dict{Tuple{Int,Int},Symbol} = Dict{Tuple{Int,Int},Symbol}(),
                   highlighters::Union{LatexHighlighter,Tuple} = (),
                   hlines::AbstractVector{Int} = Int[],
                   longtable_footer::Union{Nothing,AbstractString} = nothing,
                   noheader::Bool = false,
                   nosubheader::Bool = false,
                   show_row_number::Bool = false,
                   table_type::Symbol = :tabular,
                   vlines::Union{Symbol,AbstractVector} = :none,
                   # Deprecated
                   formatter = nothing)

    @unpack_PrintInfo pinfo
    @unpack_LatexTableFormat tf

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
    data_str   = Matrix{AbstractString}(undef, num_printed_rows, num_printed_cols)

    @inbounds for i = 1:num_printed_cols
        # Index of the i-th printed column in `data`.
        ic = id_cols[i]

        if !noheader
            for j = 1:header_num_rows
                header_str[j,i] =
                    _str_latex_escaped(sprint(print, header[(ic-1)*header_num_rows + j];
                                              context = :compact => compact_printing))
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

            # Handle `nothing`, `missing`, and `undef`.
            if ismissing(data_ij)
                data_str_ij = "missing"
            elseif data_ij == nothing
                data_str_ij = "nothing"
            elseif data_ij == undef
                data_str_ij = "\\#undef"
            else
                data_str_ij = sprint(print, data_ij;
                                     context = :compact => compact_printing)
            end

            data_str_ij_esc = _str_latex_escaped(data_str_ij)
            data_str[j,i]   = data_str_ij_esc
        end
    end

    # Process `vlines`.
    if vlines == :all
        vlines = collect(0:1:(num_printed_cols + show_row_number))
    elseif vlines == :none
        vlines = Int[]
    elseif !(typeof(vlines) <: AbstractVector)
        error("`vlines` must be `:all`, `:none`, or a vector of integers.")
    end

    # The symbol `:begin` is replaced by 0 and the symbol `:end` is replaced by
    # the last column.
    vlines = replace(vlines, :begin => 0,
                             :end   => num_printed_cols + show_row_number)

    # If the user wants to show the row number, then we must add it to the
    # `alignment` vector.
    show_row_number && (alignment = pushfirst!(alignment, :l))

    # Print LaTeX header
    # ==========================================================================

    if table_type == :tabular
        println(buf, "\\begin{table}")
        length(title) > 0 && println(buf, "\\caption{$title}")
    end

    println(buf,"""
            \\begin{$table_env}$(_latex_table_desc(alignment,
                                                   vlines,
                                                   left_vline,
                                                   mid_vline,
                                                   right_vline))""")

    if table_type == :longtable
        length(title) > 0 && println(buf, "\\caption{$title}\\\\")
    end

    println(buf, top_line)

    # Data header
    # ==========================================================================

    # Header and sub-header texts
    # --------------------------------------------------------------------------

    if !noheader
        @inbounds @views for i = 1:header_num_rows
            # The text "Row" must appear only on the first line.
            if show_row_number
                if i == 1
                    print(buf, _latex_envs("Row", header_envs))
                end

                print(buf, " & ")
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

            if i != header_num_rows
                println(buf, " \\\\")
            else
                println(buf, " \\\\" * header_line)
            end
        end
    end

    # If we are using `longtable`, then we must mark the end of header and also
    # create the footer.
    if table_type == :longtable
        println(buf, "\\endhead")
        println(buf, bottom_line)

        # Check if the user wants a text on the footer.
        if longtable_footer != nothing
            lvline =            0 ∈ vlines ? left_vline : ""
            rvline = id_cols[end] ∈ vlines ? right_vline : ""

            env = "multicolumn{" * string(num_printed_cols) * "}" * "{r}"

            println(buf, _latex_envs(longtable_footer, env) * "\\\\")
            println(buf, bottom_line)
        end

        println(buf, "\\endfoot")
        println(buf, "\\endlastfoot")
    end

    # Data
    # ==========================================================================

    @inbounds @views for i = 1:num_printed_rows
        ir = id_rows[i]

        if show_row_number
            print(buf, string(ir) * " & ")
        end

        for j = 1:num_printed_cols
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

        if (i != num_printed_rows) && (i in hlines)
            # Check if we must draw a horizontal line here.
            println(buf, " \\\\" * mid_line)
        elseif (i != num_printed_rows)
            println(buf, " \\\\")
        else
            println(buf, " \\\\" * bottom_line)
        end
    end

    # Print LaTeX footer
    # ==========================================================================

    println(buf, "\\end{$table_env}")

    table_type == :tabular && println(buf, "\\end{table}")

    # Print the buffer into the io.
    # ==========================================================================

    print(io, String(take!(buf_io)))

    return nothing
end
