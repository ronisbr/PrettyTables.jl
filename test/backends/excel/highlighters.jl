## Description #############################################################################
#
# Excel Back End: Test highlighters.
#
############################################################################################

@testset "Highlighters" verbose = true begin
    matrix = [
        1 2 3
        4 5 6
        7 8 9
    ]

    # == Three Constructor Types ===========================================================

    @testset "Three Constructor Types" verbose = true begin
        result = pretty_table(
            XLSX.XLSXFile,
            matrix;
            row_group_labels = [3 => "Group 1"],
            highlighters = [
                ExcelHighlighter(
                    (data, i, j) -> (j == 1) && (data[i, j] > 3),
                    [
                        "color" => "red",
                        "bold" => "true",
                        "cell_fill_pattern" => "solid",
                        "cell_fill_fgColor" => "grey90",
                    ],
                ),
                ExcelHighlighter(
                    (data, i, j) -> (data[i, j] == 2),
                    ["color" => "green", "bold" => "true"],
                ),
                ExcelHighlighter(
                    (data, i, j) -> (j == 3) && (data[i, j] > 3),
                    ["color" => "blue", "bold" => "true"],
                ),
                ExcelHighlighter((data, i, j) -> (data[i, j] == 3), "color" => "red"),
            ],
        )

        @test XLSX.getFont(result[1], "C2").font["color"] == Dict("rgb" => "FF008000")
        @test XLSX.getFont(result[1], "D2").font["color"] == Dict("rgb" => "FFFF0000")
        @test XLSX.getFill(result[1], "B3").fill["patternFill"] ==
            Dict("patternType" => "solid", "fgrgb" => "FFE5E5E5")
        @test XLSX.getFont(result[1], "D5").font["color"] == Dict("rgb" => "FF0000FF")
    end

    # == With Source Note Row ==============================================================

    @testset "With Source Note Row" verbose = true begin
        result = pretty_table(
            XLSX.XLSXFile,
            matrix;
            row_group_labels = [3 => "Group 1"],
            source_notes = "This is a source note.",
            highlighters = [
                ExcelHighlighter(
                    (data, i, j) -> (j == 1) && (data[i, j] > 3),
                    [
                        "color" => "red",
                        "bold" => "true",
                        "cell_fill_pattern" => "solid",
                        "cell_fill_fgColor" => "grey90",
                    ],
                ),
                ExcelHighlighter(
                    (data, i, j) -> (data[i, j] == 2),
                    ["color" => "green", "bold" => "true", "size" => "18"],
                ),
                ExcelHighlighter(
                    (data, i, j) -> (j == 3) && (data[i, j] > 3),
                    ["color" => "blue", "bold" => "true"],
                ),
                ExcelHighlighter((data, i, j) -> (data[i, j] == 3), "color" => "red"),
            ],
        )

        @test XLSX.getFont(result[1], "C2").font["color"] == Dict("rgb" => "FF008000")
        @test XLSX.getFont(result[1], "C2").font["sz"] == Dict("val" => "18")
        @test XLSX.getFont(result[1], "D2").font["color"] == Dict("rgb" => "FFFF0000")
        @test XLSX.getFill(result[1], "B3").fill["patternFill"] ==
            Dict("patternType" => "solid", "fgrgb" => "FFE5E5E5")
        @test XLSX.getFont(result[1], "D5").font["color"] == Dict("rgb" => "FF0000FF")
    end
end
