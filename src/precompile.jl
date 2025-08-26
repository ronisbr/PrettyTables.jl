## Description #############################################################################
#
# Precompilation.
#
############################################################################################

import PrecompileTools

PrecompileTools.@setup_workload begin
    types = [
        Int8(1),
        Int16(1),
        Int32(1),
        Int64(1),
        UInt8(1),
        UInt16(1),
        UInt32(1),
        UInt64(1),
        Float16(1),
        Float32(1),
        Float64(1),
        Bool(1),
        "S",
        'C',
        Int8[1, 2, 3],
        Int16[1, 2, 3],
        Int32[1, 2, 3],
        Int64[1, 2, 3],
        UInt8[1, 2, 3],
        UInt16[1, 2, 3],
        UInt32[1, 2, 3],
        UInt64[1, 2, 3],
        Float16[1, 2, 3],
        Float32[1, 2, 3],
        Float64[1, 2, 3],
        Bool[0, 1],
        ["S", "S"],
        ['C', 'C'],
        Int8[1 2; 3 4],
        Int16[1 2; 3 4],
        Int32[1 2; 3 4],
        Int64[1 2; 3 4],
        UInt8[1 2; 3 4],
        UInt16[1 2; 3 4],
        UInt32[1 2; 3 4],
        UInt64[1 2; 3 4],
        Float16[1 2; 3 4],
        Float32[1 2; 3 4],
        Float64[1 2; 3 4],
        Bool[0 1; 0 1],
        ["S" "S"; "S" "S"],
        ['C' 'C'; 'C' 'C']
    ]

    # A named tuple is compliant with Table.jl.
    table = (a = 1:1:10, b = ["S" for i = 1:10], c = ['C' for i = 1:10])

    dict = Dict(:a => (1, 1), :b => (2, 2), :c => (3, 3))

    # We will redirect the `stdout` and `stdin` so that we can execute the pager and input
    # some commands without making visible changes to the user.
    old_stdout = Base.stdout
    new_stdout = redirect_stdout(devnull)

    # In HTML, we use `display` if we are rendering to `stdout`. However, even if we are
    # redirecting it, the text is still begin shown in the display. Thus, we create a buffer
    # for those cases.
    html_buf = IOBuffer()

    PrecompileTools.@compile_workload begin
        # == Input: Arrays =================================================================

        matrix = randn(10, 10)

        # -- General API -------------------------------------------------------------------

        pretty_table(matrix; column_labels = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        pretty_table(matrix; column_labels = [MultiColumn(5, "A"), EmptyCells(5)])

        # -- Text --------------------------------------------------------------------------

        pretty_table(matrix)

        pretty_table(
            types;
            alignment = :l,
            fit_table_in_display_horizontally = false,
            fit_table_in_display_vertically = false,
        )

        pretty_table(
            matrix;
            highlighters = [
                TextHighlighter((data, i, j) -> i == 1, crayon"bold")
            ]
        )

        pretty_table(types)

        # .. Text Table Styles .............................................................

        pretty_table(
            matrix;
            style = TextTableStyle(
                first_line_column_label = [crayon"bold yellow" for i = 1:10]
            )
        )

        pretty_table(
            matrix;
            style = TextTableStyle(
                column_label = [crayon"bold yellow" for i = 1:10]
            )
        )

        pretty_table(
            matrix;
            style = TextTableStyle(
                first_line_column_label = [crayon"bold yellow" for i = 1:10],
                column_label            = [crayon"bold yellow" for i = 1:10]
            )
        )

        # -- Options Used in DataFrames.jl -------------------------------------------------

        style = TextTableStyle(row_label = Crayon())

        table_format = TextTableFormat(
            ;
            ellipsis_line_skip                    = 3,
            horizontal_line_after_data_rows       = false,
            horizontal_line_at_beginning          = false,
            vertical_line_after_data_columns      = false,
            vertical_line_after_row_label_column  = false,
            vertical_line_after_row_number_column = true,
            vertical_line_at_beginning            = false,
            vertical_lines_at_data_columns        = :none,
        )

        pretty_table(
            table;
            alignment                   = [:l, :c, :r],
            column_label_alignment      = :l,
            display_size                = (15, 33),
            new_line_at_end             = false,
            reserved_display_lines      = 2,
            row_label_column_alignment  = :r,
            row_labels                  = ["row" for i = 1:10],
            row_number_column_alignment = :r,
            row_number_column_label     = "Row",
            show_row_number_column      = true,
            stubhead_label              = "Name",
            style                       = style,
            table_format                = table_format,
            title                       = "Test table",
            title_alignment             = :l,
            vertical_crop_mode          = :middle,
        )

        # -- HTML --------------------------------------------------------------------------

        pretty_table(html_buf, matrix; backend = :html)

        pretty_table(
            html_buf,
            matrix;
            backend = :html,
            highlighters = [
                HtmlHighlighter((data, i, j) -> i == 1, ["font-weight" => "bold"])
            ]
        )

        pretty_table(html_buf, types; backend = :html)

        # .. HTML Table Styles .............................................................

        pretty_table(
            html_buf,
            matrix;
            backend = :html,
            style = HtmlTableStyle(
                first_line_column_label = [["color" => "red"] for i = 1:10]
            )
        )

        pretty_table(
            html_buf,
            matrix;
            backend = :html,
            style = HtmlTableStyle(
                column_label = [["color" => "red"] for i = 1:10]
            )
        )

        pretty_table(
            html_buf,
            matrix;
            backend = :html,
            style = HtmlTableStyle(
                first_line_column_label = [["color" => "red"] for i = 1:10],
                column_label            = [["color" => "red"] for i = 1:10]
            )
        )

        # -- LaTeX -------------------------------------------------------------------------

        pretty_table(matrix; backend = :latex)

        pretty_table(
            matrix;
            backend = :latex,
            highlighters = [
                LatexHighlighter((data, i, j) -> i == 1, ["textbf"])
            ]
        )

        pretty_table(types; backend = :latex)

        # .. LaTeX Table Styles ............................................................

        pretty_table(
            matrix;
            backend = :latex,
            style = LatexTableStyle(
                first_line_column_label = [["textbf"] for i = 1:10]
            )
        )

        pretty_table(
            matrix;
            backend = :latex,
            style = LatexTableStyle(
                column_label = [["textbf"] for i = 1:10]
            )
        )

        pretty_table(
            matrix;
            backend = :latex,
            style = LatexTableStyle(
                first_line_column_label = [["textbf"] for i = 1:10],
                column_label            = [["textbf"] for i = 1:10]
            )
        )

        # -- Markdown ----------------------------------------------------------------------

        pretty_table(matrix; backend = :markdown)

        pretty_table(
            matrix;
            backend = :markdown,
            highlighters = [
                MarkdownHighlighter((data, i, j) -> i == 1, MarkdownStyle(bold = :true))
            ]
        )

        pretty_table(types; backend = :markdown)

        # .. Markdown Table Styles .........................................................

        pretty_table(
            matrix;
            backend = :markdown,
            style = MarkdownTableStyle(
                first_line_column_label = [MarkdownStyle(bold = true) for i = 1:10]
            )
        )

        pretty_table(
            matrix;
            backend = :markdown,
            style = MarkdownTableStyle(
                column_label = [MarkdownStyle(italic = true) for i = 1:10]
            )
        )

        pretty_table(
            matrix;
            backend = :markdown,
            style = MarkdownTableStyle(
                first_line_column_label = [MarkdownStyle(bold   = true) for i = 1:10],
                column_label            = [MarkdownStyle(italic = true) for i = 1:10]
            )
        )

        # == Input: Tables.jl ==============================================================

        pretty_table(html_buf, table)
        pretty_table(html_buf, table; backend = :html)
        pretty_table(table; backend = :markdown)
    end

    # Restore stdout.
    redirect_stdout(old_stdout)
end
