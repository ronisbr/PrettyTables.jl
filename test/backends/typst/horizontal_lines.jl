## Description #############################################################################
#
# Typst Back End: Tests related to the horizontal and vertical line specifications.
#
############################################################################################

@testset "Line Specifications" verbose = true begin
    # `horizontal_lines_at_data_rows` and `vertical_lines_at_data_columns` accept either a
    # `Symbol` (`:all` / `:none`) or an explicit `Vector{Int}`. The vector branch is what
    # narrows the field type in the back end, and it must select exactly the requested rows
    # and columns.
    matrix = [1 2 3; 4 5 6]

    @testset "Vector of Indices" begin
        result = pretty_table(
            String,
            matrix;
            backend = :typst,
            table_format = TypstTableFormat(;
                horizontal_lines_at_data_rows = [1], vertical_lines_at_data_columns = [1]
            ),
        )

        # Only the line after the first data row is drawn with the middle stroke.
        @test occursin("table.hline(y: 2, stroke: 0.5pt,),", result)

        # Only the vertical line after the first data column is drawn, so there is no line
        # at `x: 2`.
        @test occursin("table.vline(x: 1, end: 3, stroke: 0.8pt),", result)
        @test !occursin("table.vline(x: 2,", result)
    end

    @testset "All Lines" begin
        result = pretty_table(
            String,
            matrix;
            backend = :typst,
            table_format = TypstTableFormat(;
                horizontal_lines_at_data_rows = :all, vertical_lines_at_data_columns = :all
            ),
        )

        @test occursin("table.hline(y: 2, stroke: 0.5pt,),", result)

        # Now every interior vertical line must be present.
        @test occursin("table.vline(x: 1, end: 3, stroke: 0.8pt),", result)
        @test occursin("table.vline(x: 2, end: 3, stroke: 0.8pt),", result)
    end
end

@testset "Line Before a Row Group Label" begin
    # `horizontal_line_before_row_group_label` had no coverage in this back end.
    result = pretty_table(
        String,
        [1 2 3; 4 5 6];
        backend = :typst,
        row_group_labels = [2 => "G"],
        table_format = TypstTableFormat(; horizontal_line_before_row_group_label = true),
    )

    # One line before the row group label, and one after it.
    @test occursin("table.hline(y: 2, stroke: 0.5pt,),", result)
    @test occursin("table.hline(y: 3, stroke: 0.5pt,),", result)
end

@testset "Line Roles" begin
    # The line after the title uses `top_line`, the line after the column labels uses
    # `header_line`, and the lines around the row group labels use `middle_line`.
    result = pretty_table(
        String,
        [1 2; 3 4];
        annotate = false,
        backend = :typst,
        row_group_labels = [2 => "G"],
        summary_row_labels = ["S"],
        summary_rows = [(data, j) -> sum(data[:, j])],
        table_format = TypstTableFormat(;
            borders = TypstTableBorders(;
                top_line    = "1pt",
                header_line = "2pt",
                middle_line = "3pt",
                bottom_line = "4pt",
            ),
        ),
        title = "T",
    )

    hlines = filter(l -> occursin("table.hline", l), split(result, '\n'))

    @test hlines == [
        "    table.hline(y: 1, stroke: 1pt,),",
        "    table.hline(y: 2, stroke: 2pt,),",
        "    table.hline(y: 3, stroke: 3pt,),",
        "    table.hline(y: 4, stroke: 3pt,),",
        "    table.hline(y: 5, stroke: 3pt,),",
        "    table.hline(y: 6, stroke: 4pt,),",
    ]
end

@testset "Shared Line Rules" verbose = true begin
    @testset "Line Before the Row Group Label at the First Row" begin
        # The line before a row group label at the first data row is drawn even if the line
        # after the column labels is disabled.
        result = pretty_table(
            String,
            [1 2; 3 4];
            annotate = false,
            backend = :typst,
            row_group_labels = [1 => "Group"],
            table_format = TypstTableFormat(;
                horizontal_line_after_column_labels = false,
                horizontal_line_before_row_group_label = true,
            ),
        )

        hlines = filter(l -> occursin("table.hline", l), split(result, '\n'))

        @test hlines == [
            "    table.hline(y: 0, stroke: 1.5pt,),",
            "    table.hline(y: 1, stroke: 0.5pt,),",
            "    table.hline(y: 2, stroke: 0.5pt,),",
            "    table.hline(y: 4, stroke: 1.5pt,),",
        ]
    end

    @testset "Line After the Continuation Row in the Middle Cropping" begin
        # The line above the first row printed after the continuation row is the line after
        # the data row before it.
        result = pretty_table(
            String,
            [i for i in 1:10, j in 1:2];
            annotate = false,
            backend = :typst,
            maximum_number_of_rows = 4,
            vertical_crop_mode = :middle,
            table_format = TypstTableFormat(; horizontal_lines_at_data_rows = :all),
        )

        hlines = filter(l -> occursin("table.hline", l), split(result, '\n'))

        @test hlines == [
            "    table.hline(y: 0, stroke: 1.5pt,),",
            "    table.hline(y: 1, stroke: 0.8pt,),",
            "    table.hline(y: 2, stroke: 0.5pt,),",
            "    table.hline(y: 3, stroke: 0.5pt,),",
            "    table.hline(y: 4, stroke: 0.5pt,),",
            "    table.hline(y: 5, stroke: 0.5pt,),",
            "    table.hline(y: 6, stroke: 1.5pt,),",
        ]

        result = pretty_table(
            String,
            [i for i in 1:10, j in 1:2];
            annotate = false,
            backend = :typst,
            maximum_number_of_rows = 4,
            vertical_crop_mode = :middle,
            table_format = TypstTableFormat(;
                @typst__no_horizontal_lines, horizontal_lines_at_data_rows = [8]
            ),
        )

        hlines = filter(l -> occursin("table.hline", l), split(result, '\n'))

        @test hlines == ["    table.hline(y: 4, stroke: 0.5pt,),"]
    end
end
