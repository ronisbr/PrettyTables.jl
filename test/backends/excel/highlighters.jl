## Description #############################################################################
#
# Excel Back End: Test highlighters.
#
############################################################################################

@testset "Highlighters" verbose=true begin
    matrix = [
        1 2 3
        4 5 6
    ]

    result = pretty_table(
        XLSX.XLSXFile,
        matrix;
        highlighters = [
            ExcelHighlighter((data, i, j) -> (j == 1) && (data[i, j] > 3), [
                :font => [ "color"=>"red", "bold"=>"true"],
                :fill => [ "pattern" => "solid", "fgColor" => "grey90"],
                :border => ["style" => "thick", "color" => "red"],
            ]),
            ExcelHighlighter((data, i, j) -> (data[i, j] == 2), [
                :font => [ "color"=>"green", "bold"=>"true"],
                :border => ["style" => "thick", "color" => "green"],
            ]),
            ExcelHighlighter((data, i, j) -> (j == 3) && (data[i, j] > 3), 
                [ "color"=>"blue", "bold"=>"true"],
            ),
            ExcelHighlighter((data, i, j) -> (data[i, j] == 3), 
                "color"=>"red"
            )
        ]
    )

    @test XLSX.getFont(result[1], "B2").font["color"] == Dict("rgb" => "FF008000")
    border = XLSX.getBorder(result[1], "B2").border
    for side in ["top", "bottom", "left", "right"]
        @test border[side] == Dict("style" => "thick", "rgb" => "FF008000")
    end
    @test XLSX.getFont(result[1], "C2").font["color"] == Dict("rgb" => "FFFF0000")
    @test XLSX.getFill(result[1], "A3").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FFE5E5E5")
    @test XLSX.getFont(result[1], "C3").font["color"] == Dict("rgb" => "FF0000FF")

end

