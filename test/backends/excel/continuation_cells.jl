## Description #############################################################################
#
# Excel Back End: Test continuation cells (⋮, ⋯, ⋱).
#
############################################################################################

@testset "Continuation Cells" verbose = true begin
    # == Vertical Cropping Yields ⋮ Cells ==================================================

    @testset "Vertical cropping yields ⋮ cells with default style" verbose = true begin
        # With more rows than `maximum_number_of_rows`, a continuation row is appended.
        # The placeholder characters (\"⋮\") live in the continuation row at every column.
        # Under the default `ExcelTableStyle`, the continuation cells must inherit the
        # `data_cell` decoration (an empty `ExcelPair` vector), so the rendered font must
        # not contain the `b` (bold) key that `style.row_number_label` would introduce.
        data = reshape(1:9, 3, 3)  # 3 rows, 3 columns
        result = pretty_table(
            XLSX.XLSXFile, data; backend = :excel, maximum_number_of_rows = 1
        )

        # Find the continuation row (the row containing \"⋮\") in column A.
        sheet_range = result[1].dimension
        last_row = sheet_range.stop.row_number
        cont_row = nothing
        for r in 1:last_row
            v = result[1]["A$(r)"]
            if !ismissing(v) && v == "⋮"
                cont_row = r
                break
            end
        end
        @test cont_row !== nothing

        # The continuation cell's font must not carry the bold attribute that the
        # `row_number_label` style (default `[\"bold\" => \"true\"]`) would apply.
        for col in ("A", "B", "C")
            font = XLSX.getFont(result[1], "$(col)$(cont_row)").font
            @test !haskey(font, "b")
        end
    end
end
