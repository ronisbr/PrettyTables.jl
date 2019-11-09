# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Print function of the text backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
**Pretty table text backend**

This backend produces text tables. This backend can be used by selectino
`backend = :text`.

# Keywords

* `border_crayon`: Crayon to print the border.
* `header_crayon`: Crayon to print the header.
* `subheaders_crayon`: Crayon to print sub-headers.
* `rownum_header_crayon`: Crayon for the header of the column with the row
                          numbers.
* `text_crayon`: Crayon to print default text.
* `autowrap`: If `true`, then the text will be wrapped on spaces to fit the
              column. Notice that this function requires `linebreaks = true` and
              the column must have a fixed size (see `columns_width`).
* `cell_alignment`: A dictionary of type `(i,j) => a` that overrides that
                    alignment of the cell `(i,j)` to `a` regardless of the
                    columns alignment selected. `a` must be a symbol like
                    specified in the section `Alignment`.
* `columns_width`: A set of integers specifying the width of each column. If the
                   width is equal or lower than 0, then it will be automatically
                   computed to fit the large cell in the column. If it is
                   a single integer, then this number will be used as the size
                   of all columns. (**Default** = 0)
* `crop`: Select the printing behavior when the data is bigger than the
          available screen size (see `screen_size`). It can be `:both` to crop
          on vertical and horizontal direction, `:horizontal` to crop only on
          horizontal direction, `:vertical` to crop only on vertical direction,
          or `:none` to do not crop the data at all.
* `formatter`: See the section `Formatter`.
* `highlighters`: An instance of `TextHighlighter` or a tuple with a list of
                  text highlighters (see the section `Text highlighters`).
* `hlines`: A vector of `Int` indicating row numbers in which an additional
            horizontal line should be drawn after the row. Notice that numbers
            lower than 1 and equal or higher than the number of rows will be
            neglected.
* `hlines_format`: A tuple of 4 characters specifying the format of the
                   horizontal lines. The characters must be the left
                   intersection, the middle intersection, the right
                   intersection, and the row. If it is `nothing`, then it will
                   use the same format specified in `tf`.
                   (**Default** = `nothing`)
* `linebreaks`: If `true`, then `\\n` will break the line inside the cells.
                (**Default** = `false`)
* `noheader`: If `true`, then the header will not be printed. Notice that all
              keywords and parameters related to the header and sub-headers will
              be ignored. (**Default** = `false`)
* `nosubheader`: If `true`, then the sub-header will not be printed, *i.e.* the
                 header will contain only one line. Notice that this option has
                 no effect if `noheader = true`. (**Default** = `false`)
* `same_column_size`: If `true`, then all the columns will have the same size.
                      (**Default** = `false`)
* `screen_size`: A tuple of two integers that defines the screen size (num. of
                 rows, num. of columns) that is available to print the table. It
                 is used to crop the data depending on the value of the keyword
                 `crop`. If it is `nothing`, then the size will be obtained
                 automatically. Notice that if a dimension is not positive, then
                 it will be treated as unlimited. (**Default** = `nothing`)
* `show_row_number`: If `true`, then a new column will be printed showing the
                     row number. (**Default** = `false`)
* `tf`: Table format used to print the table (see `TextFormat`).
        (**Default** = `unicode`)

The keywords `header_crayon` and `subheaders_crayon` can be a `Crayon` or a
`Vector{Crayon}`. In the first case, the `Crayon` will be applied to all the
elements. In the second, each element can have its own crayon, but the length of
the vector must be equal to the number of columns in the data.

# Crayons

A `Crayon` is an object that handles a style for text printed on terminals. It
is defined in the package
[Crayons.jl](https://github.com/KristofferC/Crayons.jl). There are many options
available to customize the style, such as foreground color, background color,
bold text, etc.

A `Crayon` can be created in two different ways:

```julia-repl
julia> Crayon(foreground = :blue, background = :black, bold = :true)

julia> crayon"blue bg:black bold"
```

For more information, see the package documentation.

# Formatter

The keyword `formatter` can be used to pass functions to format the values in
the columns. It must be a `Dict{Number,Function}()`. The key indicates the
column number in which its elements will be converted by the function in the
value of the dictionary. The function must have the following signature:

    f(value, i)

in which `value` is the data and `i` is the row number. It must return the
formatted value.

For example, if we want to multiply all values in odd rows of the column 2 by π,
then the formatter should look like:

    Dict(2 => (v,i)->isodd(i) ? v*π : v)

If the key `0` is present, then the corresponding function will be applied to
all columns that does not have a specific key.

# Text highlighters

A set of highlighters can be passed as a `Tuple` to the `highlighter` keyword.
Each highlighter is an instance of the structure `TextHighlighter` that contains
two fields:

* `f`: Function with the signature `f(data,i,j)` in which should return `true`
       if the element `(i,j)` in `data` must be highlighted, or `false`
       otherwise.
* `crayon`: Crayon with the style of a highlighted element.

The function `f` has the following signature:

    f(data, i, j)

in which `data` is a reference to the data that is being printed, `i` and `j`
are the element coordinates that are being tested. If this function returns
`true`, then the highlight style will be applied to the `(i,j)` element.
Otherwise, the default style will be used.

Notice that if multiple highlighters are valid for the element `(i,j)`, then the
applied style will be equal to the first match considering the order in the
Tuple `highlighters`.

If only a single highlighter is wanted, then it can be passed directly to the
keyword `highlighter` without being inside a `Tuple`.

"""
pretty_table

# Low-level function to print the table using the text backend.
function _pt_text(io, pinfo;
                  border_crayon::Crayon = Crayon(),
                  header_crayon::Union{Crayon,Vector{Crayon}} = Crayon(bold = true),
                  subheader_crayon::Union{Crayon,Vector{Crayon}} = Crayon(foreground = :dark_gray),
                  rownum_header_crayon::Crayon = Crayon(bold = true),
                  text_crayon::Crayon = Crayon(),
                  autowrap::Bool = false,
                  cell_alignment::Dict{Tuple{Int,Int},Symbol} = Dict{Tuple{Int,Int},Symbol}(),
                  crop::Symbol = :both,
                  columns_width::Union{Integer,AbstractVector{Int}} = 0,
                  formatter::Dict = Dict(),
                  highlighters::Union{TextHighlighter,Tuple} = (),
                  hlines::AbstractVector{Int} = Int[],
                  hlines_format::Union{Nothing,NTuple{4,Char}} = nothing,
                  linebreaks::Bool = false,
                  noheader::Bool = false,
                  nosubheader::Bool = false,
                  same_column_size::Bool = false,
                  screen_size::Union{Nothing,Tuple{Int,Int}} = nothing,
                  show_row_number::Bool = false,
                  sortkeys::Bool = false,
                  tf::TextFormat = unicode)

    @unpack_PrintInfo pinfo

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

    # Get the string which is printed when `print` is called in each element of
    # the matrix. Notice that we must create only the matrix with the printed
    # rows and columns.
    header_str       = Matrix{String}(undef, header_num_rows, num_printed_cols)
    data_str         = Matrix{Vector{AbstractString}}(undef,
                                                      num_printed_rows,
                                                      num_printed_cols)
    num_lines_in_row = ones(Int, num_printed_rows)

    # Check which columns must have fixed sizes.
    typeof(columns_width) <: Integer && (columns_width = ones(Int, num_cols)*columns_width)
    length(columns_width) != num_cols && error("The length of `columns_width` must be the same as the number of columns.")
    fixed_col_width = map(w->w > 0, columns_width)

    # The variable `columns_width` is the specification of the user for the
    # columns width. The variable `cols_width` contains the actual size of each
    # column. This is necessary because if the user asks for a width equal or
    # lower than 0 in a column, then the width will be automatically computed to
    # fit the longest field.
    cols_width = [ columns_width[id_cols[i]] for i = 1:num_printed_cols ]

    # This variable stores the predicted table width. If the user wants
    # horizontal cropping, then it can be use to avoid unnecessary processing of
    # columns that will not be displayed.
    pred_tab_width = 0

    @inbounds for i = 1:num_printed_cols
        # Index of the i-th printed column in `data`.
        ic = id_cols[i]

        fi = haskey(formatter, i) ? formatter[i] :
                (haskey(formatter, 0) ? formatter[0] : nothing)

        if !noheader
            for j = 1:header_num_rows
                header_str[j,i] = escape_string(sprint(print, header[(ic-1)*header_num_rows + j]))

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

            data_ij = fi != nothing ? fi(data[jr,ic], jr) : data[jr,ic]

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
                data_str_ij_esc = escape_string(data_str_ij)
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

    # The row number width depends on how many digits the total number of rows
    # has and the length of the header "Row". Notice that if `noheader` is set
    # to `true`, then we should not take the word "Row" into account.
    row_number_width = max(noheader ? 0 : 3, floor(Int, log10(num_rows)) + 1)

    # If the user wants all the columns with the same size, then select the
    # larger.
    same_column_size && (cols_width = [maximum(cols_width) for i = 1:num_printed_cols])

    # Create the format of the horizontal lines.
    if hlines_format == nothing
        hlines_format = (tf.left_intersection, tf.middle_intersection,
                         tf.right_intersection, tf.row)
    end

    # Top table line
    # ==========================================================================

    tf.top_line && _draw_line!(screen, buf, tf.up_left_corner,
                               tf.up_intersection, tf.up_right_corner, tf.row,
                               border_crayon, num_printed_cols, cols_width,
                               show_row_number, row_number_width)

    # Header
    # ==========================================================================

    # Header and sub-header texts
    # --------------------------------------------------------------------------

    if !noheader
        @inbounds @views for i = 1:header_num_rows
            _p!(screen, buf, border_crayon, tf.column)

            if show_row_number
                # The text "Row" must appear only on the first line.
                if i == 1
                    header_row_i_str = " " * _str_aligned("Row", :r, row_number_width) * " "
                    _p!(screen, buf, rownum_header_crayon, header_row_i_str)
                else
                    _p!(screen, buf, rownum_header_crayon, " "^(row_number_width+2))
                end

                _p!(screen, buf, border_crayon, tf.column)
            end

            for j = 1:num_printed_cols
                # Index of the j-th printed column in `data`.
                jc = id_cols[j]

                header_i_str = " " * _str_aligned(header_str[i,j], alignment[jc], cols_width[j]) * " "

                # Check if we are printing the header or the sub-headers and select
                # the styling accordingly.
                crayon = (i == 1) ? header_crayon[jc] : subheader_crayon[jc]

                flp = j == num_printed_cols

                _p!(screen, buf, crayon,        header_i_str)
                _p!(screen, buf, border_crayon, tf.column, flp)

                _eol(screen) && break
            end

            i != header_num_rows && _nl!(screen,buf)
        end

        _nl!(screen,buf)

        # Bottom header line
        #-----------------------------------------------------------------------

        tf.header_line && _draw_line!(screen, buf, tf.left_intersection,
                                      tf.middle_intersection,
                                      tf.right_intersection, tf.row,
                                      border_crayon, num_printed_cols,
                                      cols_width, show_row_number,
                                      row_number_width)
    end

    # Data
    # ==========================================================================

    @inbounds @views for i = 1:num_printed_rows
        ir = id_rows[i]

        for l = 1:num_lines_in_row[i]
            _p!(screen, buf, border_crayon, tf.column)

            if show_row_number
                if l == 1
                    row_number_i_str = " " * _str_aligned(string(ir), :r, row_number_width) * " "
                else
                    row_number_i_str = " " * _str_aligned("", :r, row_number_width) * " "
                end

                _p!(screen, buf, text_crayon,   row_number_i_str)
                _p!(screen, buf, border_crayon, tf.column)
            end

            for j = 1:num_printed_cols
                jc = id_cols[j]

                # Check the alignment of this cell.
                if haskey(cell_alignment, (i,j))
                    alignment_ij = cell_alignment[(i,j)]
                else
                    alignment_ij = alignment[jc]
                end

                if length(data_str[i,j]) >= l
                    data_ij_str = " " * _str_aligned(data_str[i,j][l], alignment_ij, cols_width[j]) * " "
                else
                    data_ij_str = " " * _str_aligned("", alignment_ij, cols_width[j]) * " "
                end

                # If we have highlighters defined, then we need to verify if
                # this data should be highlight.
                printed = false
                crayon  = text_crayon

                for h in highlighters
                    if h.f(data, ir, jc)
                        crayon = h.crayon
                        _p!(screen, buf, crayon, data_ij_str)
                        printed = true
                        break
                    end
                end

                !printed && _p!(screen, buf, text_crayon, data_ij_str)

                flp = j == num_printed_cols

                _p!(screen, buf, border_crayon, tf.column, flp)

                _eol(screen) && break
            end

            _nl!(screen, buf)

        end

        # Check if we must draw a horizontal line here.
        i != num_rows && i in hlines &&
        _draw_line!(screen, buf, hlines_format..., border_crayon,
                    num_printed_cols, cols_width, show_row_number,
                    row_number_width)

        # Here we must check if the vertical size of the screen has been
        # reached. Notice that we must add 4 to account for the command line,
        # the continuation line, the bottom table line, and the last blank line.
        if (screen.size[1] > 0) && (screen.row + 4 >= screen.size[1])
            _draw_continuation_row(screen, buf, tf, text_crayon, border_crayon,
                                   num_printed_cols, cols_width,
                                   show_row_number, row_number_width)
            break
        end
    end

    # Bottom table line
    # ==========================================================================

    tf.bottom_line && _draw_line!(screen, buf, tf.bottom_left_corner,
                                  tf.bottom_intersection,
                                  tf.bottom_right_corner, tf.row, border_crayon,
                                  num_printed_cols, cols_width, show_row_number,
                                  row_number_width)

    # Print the buffer
    # ==========================================================================
    print(io, String(take!(buf_io)))

    return nothing
end
