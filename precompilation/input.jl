# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Descriptions
# ==============================================================================
#
#   Function calls to create the precompilation statements using SnoopCompiler.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

function precompilation_input()
    # Input: Array
    # ==========================================================================

    data = Any[1    false      1.0     0x01 ;
               2     true      2.0     0x02 ;
               3    false      3.0     0x03 ;
               4     true      4.0     0x04 ;
               5    false      5.0     0x05 ;
               6     true      6.0     0x06 ;]

    pretty_table(data)

    # Pre-compile the most common types.
    #
    # The functions that parse the cells (`_parse_cell_text`,
    # `_parse_cell_html`) could not be despecialized because it degraded too
    # much the performance. Hence, there will be a small precompilation for each
    # different cell type.
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

    pretty_table(types; alignment = :l, crop = :none)
    pretty_table(types; backend = Val(:html))

    # Input: Tables.jl
    # ==========================================================================

    # A named tuple is compliant with Table.jl.
    table = (a = 1:1:10, b = ["S" for i = 1:10], c = ['C' for i = 1:10])

    # This example is created based on DataFrames.jl options.
    pretty_table(table,
                 alignment                   = [:l, :c, :r],
                 crop                        = :both,
                 crop_num_lines_at_beginning = 2,
                 display_size                = (15, 34),
                 ellipsis_line_skip          = 3,
                 header_alignment            = :l,
                 hlines                      = [:header],
                 newline_at_end              = false,
                 row_name_alignment          = :r,
                 row_name_crayon             = Crayon(),
                 row_name_column_title       = "Name",
                 row_names                   = ["row" for i = 1:10],
                 row_number_alignment        = :r,
                 row_number_column_title     = "Row",
                 show_row_number             = true,
                 title                       = "Test table",
                 vcrop_mode                  = :middle,
                 vlines                      = [1])
    println()

    # Input: Dictionary
    # ==========================================================================

    dict = Dict(:a => (1, 1),
                :b => (2, 2),
                :c => (3, 3))

    pretty_table(dict, sortkeys = true)

    # Input: Data with URLTextCell
    # ==========================================================================

    custom_cells = [
        1 "Ronan Arraes Jardim Chagas" URLTextCell("Ronan Arraes Jardim Chagas", "https://ronanarraes.com")
        2 "Google" URLTextCell("Google", "https://google.com")
        3 "Apple" URLTextCell("Apple", "https://apple.com")
        4 "Emojis!" URLTextCell("😃"^20, "https://emojipedia.org/github/")
    ]

    pretty_table(custom_cells)

    # Input: Data with AnsiCellText
    # ==========================================================================

    b = crayon"blue bold"
    y = crayon"yellow bold"
    g = crayon"green bold"

    ansi_table = [
        AnsiTextCell("$(g)This $(y)is $(b)awesome!")
        AnsiTextCell("$(g)😃😃 $(y)is $(b)awesome!")
        AnsiTextCell("$(g)σ𝛕θ⍺ $(y)is $(b)awesome!")
    ]

    pretty_table(ansi_table)

    # Input: Data with HtmlCell
    # ==========================================================================

    html_table = [
        html_cell"<b>Bold cell</b>"
        html_cell"<i>Italic cell</b>"
    ]

    pretty_table(html_table, backend = Val(:html))

    # Input: Data with LatexCell
    # ==========================================================================

    latex_table = [
        latex_cell"\textbf{a}"
        latex_cell"\emph{b}"
    ]

    pretty_table(latex_table, backend = Val(:latex))

    # Combination of types in `header_crayon` and `subheader_crayon`
    # ==========================================================================

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
end
