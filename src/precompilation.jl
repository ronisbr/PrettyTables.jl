## Description #############################################################################
#
# Precompilation.
#
############################################################################################

import PrecompileTools

PrecompileTools.@setup_workload begin
    data = Any[1    false      1.0     0x01 ;
               2     true      2.0     0x02 ;
               3    false      3.0     0x03 ;
               4     true      4.0     0x04 ;
               5    false      5.0     0x05 ;
               6     true      6.0     0x06 ;]

    types = [Int8(1),
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
            ['C' 'C'; 'C' 'C']]

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
        # == Input: Array ==================================================================

        pretty_table(data)

        # Pre-compile the most common types.
        #
        # The functions that parse the cells (`_text_parse_cell`, `_html_parse_cell`) could
        # not be despecialized because it degraded too much the performance. Hence, there
        # will be a small precompilation for each different cell type.
        pretty_table(types; alignment = :l, crop = :none)
        pretty_table(html_buf, types; backend = Val(:html))

        # == Input: Tables.jl ==============================================================

        # This example is created based on DataFrames.jl options.
        pretty_table(
            table,
            alignment               = [:l, :c, :r],
            crop                    = :both,
            reserved_display_lines  = 2,
            display_size            = (15, 34),
            ellipsis_line_skip      = 3,
            header_alignment        = :l,
            hlines                  = [:header],
            newline_at_end          = false,
            row_label_alignment     = :r,
            row_label_crayon        = Crayon(),
            row_label_column_title  = "Name",
            row_labels              = ["row" for i = 1:10],
            row_number_alignment    = :r,
            row_number_column_title = "Row",
            show_row_number         = true,
            title                   = "Test table",
            vcrop_mode              = :middle,
            vlines                  = [1]
        )

        # This example is created based on DataFrames.jl options.
        pretty_table(
            html_buf,
            table;
            alignment                 = [:l, :c, :r],
            backend                   = Val(:html),
            compact_printing          = false,
            header_alignment          = :l,
            header_cell_titles        = (nothing, ["A", "B", "C"]),
            max_num_of_columns        = 2,
            max_num_of_rows           = 5,
            minify                    = true,
            row_label_column_title    = "Row",
            row_labels                = ["row" for i = 1:10],
            row_number_alignment      = :r,
            row_number_column_title   = "Row",
            show_omitted_cell_summary = true,
            show_row_number           = true,
            standalone                = false,
            table_class               = "data-frame",
            table_div_class           = "data-frame",
            top_left_str              = "Test table",
            top_right_str_decoration  = HtmlDecoration(font_style = "italic"),
            vcrop_mode                = :middle,
            wrap_table_in_div         = true
        )

        # == Input: Dictionary =============================================================

        pretty_table(dict, sortkeys = true)

        # == Input: Data with UrlTextCell ==================================================

        custom_cells = [
            1 "Ronan Arraes Jardim Chagas" UrlTextCell("Ronan Arraes Jardim Chagas", "https://ronanarraes.com")
            2 "Google" UrlTextCell("Google", "https://google.com")
            3 "Apple" UrlTextCell("Apple", "https://apple.com")
            4 "Emojis!" UrlTextCell("😃"^20, "https://emojipedia.org/github/")
        ]

        pretty_table(custom_cells)

        # == Input: Data with AnsiCellText =================================================

        b = crayon"blue bold"
        y = crayon"yellow bold"
        g = crayon"green bold"

        ansi_table = [
            AnsiTextCell("$(g)This $(y)is $(b)awesome!")
            AnsiTextCell("$(g)😃😃 $(y)is $(b)awesome!")
            AnsiTextCell("$(g)σ𝛕θ⍺ $(y)is $(b)awesome!")
        ]

        pretty_table(ansi_table)

        # == Input: Data with HtmlCell =====================================================

        html_table = [
            html_cell"<b>Bold cell</b>"
            html_cell"<i>Italic cell</b>"
        ]

        pretty_table(html_buf, html_table; backend = Val(:html))

        # == Input: Data with LatexCell ====================================================

        latex_table = [
            latex_cell"\textbf{a}"
            latex_cell"\emph{b}"
        ]

        pretty_table(latex_table; backend = Val(:latex))

        # == Combination of Types in `header_crayon` and `subheader_crayon` ================

        header = (
            ["Column $i" for i in 1:4],
            ["Sub $i" for i in 1:4]
        )

        pretty_table(
            data;
            header = header,
            header_crayon = [crayon"yellow bold" for _ in 1:4]
        )

        pretty_table(
            data;
            header = header,
            subheader_crayon = [crayon"yellow bold" for _ in 1:4]
        )

        pretty_table(
            data;
            header = header,
            header_crayon = [crayon"yellow bold" for _ in 1:4],
            subheader_crayon = [crayon"yellow bold" for _ in 1:4]
        )

        # == Helpers =======================================================================

        @pt data
    end

    # Restore stdout.
    redirect_stdout(old_stdout)
end
