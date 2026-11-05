## Description #############################################################################
#
# Typst Back End: Test of vertical lines.
#
############################################################################################

@testset "Line After the Last Printed Data Column" begin
    # The line after the last printed data column is only controlled by
    # `vertical_line_after_data_columns`, even if this column is in
    # `vertical_lines_at_data_columns` and even if the table is horizontally cropped.
    result = pretty_table(
        String,
        [1 2 3; 4 5 6];
        annotate = false,
        backend = :typst,
        table_format = TypstTableFormat(;
            vertical_lines_at_data_columns = :all, vertical_line_after_data_columns = false
        ),
    )

    vlines = filter(l -> occursin("table.vline", l), split(result, '\n'))

    @test vlines == [
        "    table.vline(x: 0, end: 3, stroke: 1.5pt),",
        "    table.vline(x: 1, end: 3, stroke: 0.8pt),",
        "    table.vline(x: 2, end: 3, stroke: 0.8pt),",
    ]

    result = pretty_table(
        String,
        [1 2 3; 4 5 6];
        annotate = false,
        backend = :typst,
        maximum_number_of_columns = 2,
        table_format = TypstTableFormat(;
            vertical_lines_at_data_columns = :all, vertical_line_after_data_columns = false
        ),
    )

    vlines = filter(l -> occursin("table.vline", l), split(result, '\n'))

    @test vlines == [
        "    table.vline(x: 0, end: 3, stroke: 1.5pt),",
        "    table.vline(x: 1, end: 3, stroke: 0.8pt),",
        "    table.vline(x: 3, end: 3, stroke: 1.5pt),",
    ]
end
