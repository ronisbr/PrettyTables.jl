## Description #############################################################################
#
# Text Back End: Tests related with table cropping.
#
############################################################################################

@testset "Table Cropping" verbose = true begin
    matrix = [(i, j) for i in 1:100, j in 1:100]

    @testset "Without Display Cropping" verbose = true begin
        @testset "Bottom Cropping" begin
            expected = """
┌────────┬────────┬────────┬───┐
│ Col. 1 │ Col. 2 │ Col. 3 │ ⋯ │
├────────┼────────┼────────┼───┤
│ (1, 1) │ (1, 2) │ (1, 3) │ ⋯ │
│ (2, 1) │ (2, 2) │ (2, 3) │ ⋯ │
│      ⋮ │      ⋮ │      ⋮ │ ⋱ │
└────────┴────────┴────────┴───┘
  97 columns and 98 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                maximum_number_of_columns = 3,
                maximum_number_of_rows = 2
            )

            @test result == expected
        end

        @testset "Middle Cropping" verbose = true begin
            expected = """
┌──────────┬──────────┬──────────┬───┐
│   Col. 1 │   Col. 2 │   Col. 3 │ ⋯ │
├──────────┼──────────┼──────────┼───┤
│   (1, 1) │   (1, 2) │   (1, 3) │ ⋯ │
│        ⋮ │        ⋮ │        ⋮ │ ⋱ │
│ (100, 1) │ (100, 2) │ (100, 3) │ ⋯ │
└──────────┴──────────┴──────────┴───┘
        97 columns and 98 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                maximum_number_of_columns = 3,
                maximum_number_of_rows = 2,
                vertical_crop_mode = :middle
            )

            @test result == expected
        end

        @testset "Omitted Cell Summary" verbose = true begin
            expected = """
┌────────┬────────┬────────┬───┐
│ Col. 1 │ Col. 2 │ Col. 3 │ ⋯ │
├────────┼────────┼────────┼───┤
│ (1, 1) │ (1, 2) │ (1, 3) │ ⋯ │
│ (2, 1) │ (2, 2) │ (2, 3) │ ⋯ │
│      ⋮ │      ⋮ │      ⋮ │ ⋱ │
└────────┴────────┴────────┴───┘
"""

            result = pretty_table(
                String,
                matrix;
                maximum_number_of_columns = 3,
                maximum_number_of_rows = 2,
                show_omitted_cell_summary = false
            )

            @test result == expected
        end
    end

    @testset "With Display Cropping" verbose = true begin
        @testset "Bottom Cropping" begin
            expected = """
┌────────┬────────┬────────┬────────┬────────┬────────
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │ Col. 5 │ Col.  ⋯
├────────┼────────┼────────┼────────┼────────┼────────
│ (1, 1) │ (1, 2) │ (1, 3) │ (1, 4) │ (1, 5) │ (1, 6 ⋯
│ (2, 1) │ (2, 2) │ (2, 3) │ (2, 4) │ (2, 5) │ (2, 6 ⋯
│ (3, 1) │ (3, 2) │ (3, 3) │ (3, 4) │ (3, 5) │ (3, 6 ⋯
│ (4, 1) │ (4, 2) │ (4, 3) │ (4, 4) │ (4, 5) │ (4, 6 ⋯
│      ⋮ │      ⋮ │      ⋮ │      ⋮ │      ⋮ │       ⋱
└────────┴────────┴────────┴────────┴────────┴────────
                        95 columns and 96 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (12, 54)
            )

            @test result == expected

            expected = """
┌────────┬────────┬────────┬────────┬────────┬─────────
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │ Col. 5 │ Col. 6 ⋯
├────────┼────────┼────────┼────────┼────────┼─────────
│ (1, 1) │ (1, 2) │ (1, 3) │ (1, 4) │ (1, 5) │ (1, 6) ⋯
│ (2, 1) │ (2, 2) │ (2, 3) │ (2, 4) │ (2, 5) │ (2, 6) ⋯
│ (3, 1) │ (3, 2) │ (3, 3) │ (3, 4) │ (3, 5) │ (3, 6) ⋯
│ (4, 1) │ (4, 2) │ (4, 3) │ (4, 4) │ (4, 5) │ (4, 6) ⋯
│      ⋮ │      ⋮ │      ⋮ │      ⋮ │      ⋮ │      ⋮ ⋱
└────────┴────────┴────────┴────────┴────────┴─────────
                         94 columns and 96 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (12, 55),
                maximum_number_of_columns = 7,
                maximum_number_of_rows = 4,
            )

            @test result == expected

            # == Horizontal Lines ==========================================================

            expected = """
┌────────┬────────┬────────┬────────┬────────┬────────
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │ Col. 5 │ Col.  ⋯
├────────┼────────┼────────┼────────┼────────┼────────
│ (1, 1) │ (1, 2) │ (1, 3) │ (1, 4) │ (1, 5) │ (1, 6 ⋯
├────────┼────────┼────────┼────────┼────────┼────────
│ (2, 1) │ (2, 2) │ (2, 3) │ (2, 4) │ (2, 5) │ (2, 6 ⋯
├────────┼────────┼────────┼────────┼────────┼────────
│      ⋮ │      ⋮ │      ⋮ │      ⋮ │      ⋮ │       ⋱
└────────┴────────┴────────┴────────┴────────┴────────
                        95 columns and 98 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (12, 54),
                table_format = TextTableFormat(horizontal_lines_at_data_rows = :all)
            )

            @test result == expected

            expected = """
┌────────┬────────┬────────┬────────┬────────┬────────
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │ Col. 5 │ Col.  ⋯
├────────┼────────┼────────┼────────┼────────┼────────
│ (1, 1) │ (1, 2) │ (1, 3) │ (1, 4) │ (1, 5) │ (1, 6 ⋯
├────────┼────────┼────────┼────────┼────────┼────────
│ (2, 1) │ (2, 2) │ (2, 3) │ (2, 4) │ (2, 5) │ (2, 6 ⋯
├────────┼────────┼────────┼────────┼────────┼────────
│ (3, 1) │ (3, 2) │ (3, 3) │ (3, 4) │ (3, 5) │ (3, 6 ⋯
│      ⋮ │      ⋮ │      ⋮ │      ⋮ │      ⋮ │       ⋱
└────────┴────────┴────────┴────────┴────────┴────────
                        95 columns and 97 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (13, 54),
                table_format = TextTableFormat(horizontal_lines_at_data_rows = :all)
            )

            @test result == expected

            # == Fit Table in Display ======================================================

            expected = """
┌────────┬────────┬────────┬────────┬────────┬────────┬────────┬───┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │ Col. 5 │ Col. 6 │ Col. 7 │ ⋯ │
├────────┼────────┼────────┼────────┼────────┼────────┼────────┼───┤
│ (1, 1) │ (1, 2) │ (1, 3) │ (1, 4) │ (1, 5) │ (1, 6) │ (1, 7) │ ⋯ │
│ (2, 1) │ (2, 2) │ (2, 3) │ (2, 4) │ (2, 5) │ (2, 6) │ (2, 7) │ ⋯ │
│ (3, 1) │ (3, 2) │ (3, 3) │ (3, 4) │ (3, 5) │ (3, 6) │ (3, 7) │ ⋯ │
│ (4, 1) │ (4, 2) │ (4, 3) │ (4, 4) │ (4, 5) │ (4, 6) │ (4, 7) │ ⋯ │
│      ⋮ │      ⋮ │      ⋮ │      ⋮ │      ⋮ │      ⋮ │      ⋮ │ ⋱ │
└────────┴────────┴────────┴────────┴────────┴────────┴────────┴───┘
                                      93 columns and 96 rows omitted
"""
            result = pretty_table(
                String,
                matrix;
                display_size = (12, 55),
                fit_table_in_display_horizontally = false,
                maximum_number_of_columns = 7,
                maximum_number_of_rows = 5,
            )

            @test result == expected

            expected = """
┌────────┬────────┬────────┬────────┬────────┬────────┬────────┬───┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │ Col. 5 │ Col. 6 │ Col. 7 │ ⋯ │
├────────┼────────┼────────┼────────┼────────┼────────┼────────┼───┤
│ (1, 1) │ (1, 2) │ (1, 3) │ (1, 4) │ (1, 5) │ (1, 6) │ (1, 7) │ ⋯ │
│ (2, 1) │ (2, 2) │ (2, 3) │ (2, 4) │ (2, 5) │ (2, 6) │ (2, 7) │ ⋯ │
│ (3, 1) │ (3, 2) │ (3, 3) │ (3, 4) │ (3, 5) │ (3, 6) │ (3, 7) │ ⋯ │
│ (4, 1) │ (4, 2) │ (4, 3) │ (4, 4) │ (4, 5) │ (4, 6) │ (4, 7) │ ⋯ │
│      ⋮ │      ⋮ │      ⋮ │      ⋮ │      ⋮ │      ⋮ │      ⋮ │ ⋱ │
└────────┴────────┴────────┴────────┴────────┴────────┴────────┴───┘
                                      93 columns and 96 rows omitted
"""
            result = pretty_table(
                String,
                matrix;
                display_size = (13, 55),
                fit_table_in_display_horizontally = false,
                maximum_number_of_columns = 7,
                maximum_number_of_rows = 4,
            )

            @test result == expected

            expected = """
┌────────┬────────┬────────┬────────┬────────┬────────┬────────┬───┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │ Col. 5 │ Col. 6 │ Col. 7 │ ⋯ │
├────────┼────────┼────────┼────────┼────────┼────────┼────────┼───┤
│ (1, 1) │ (1, 2) │ (1, 3) │ (1, 4) │ (1, 5) │ (1, 6) │ (1, 7) │ ⋯ │
│ (2, 1) │ (2, 2) │ (2, 3) │ (2, 4) │ (2, 5) │ (2, 6) │ (2, 7) │ ⋯ │
│ (3, 1) │ (3, 2) │ (3, 3) │ (3, 4) │ (3, 5) │ (3, 6) │ (3, 7) │ ⋯ │
│ (4, 1) │ (4, 2) │ (4, 3) │ (4, 4) │ (4, 5) │ (4, 6) │ (4, 7) │ ⋯ │
│ (5, 1) │ (5, 2) │ (5, 3) │ (5, 4) │ (5, 5) │ (5, 6) │ (5, 7) │ ⋯ │
│      ⋮ │      ⋮ │      ⋮ │      ⋮ │      ⋮ │      ⋮ │      ⋮ │ ⋱ │
└────────┴────────┴────────┴────────┴────────┴────────┴────────┴───┘
                                      93 columns and 95 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (12, 55),
                fit_table_in_display_horizontally = false,
                fit_table_in_display_vertically = false,
                maximum_number_of_columns = 7,
                maximum_number_of_rows = 5,
            )

            @test result == expected

            # == Row Group Labels ==========================================================

            expected = """
┌────────┬────────┬────────┬────────┬────────┬────────
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │ Col. 5 │ Col.  ⋯
├────────┴────────┴────────┴────────┴────────┴────────
│ Row Group 1                                        
├────────┬────────┬────────┬────────┬────────┬────────
│ (1, 1) │ (1, 2) │ (1, 3) │ (1, 4) │ (1, 5) │ (1, 6 ⋯
├────────┼────────┼────────┼────────┼────────┼────────
│      ⋮ │      ⋮ │      ⋮ │      ⋮ │      ⋮ │       ⋱
└────────┴────────┴────────┴────────┴────────┴────────
                        95 columns and 99 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (13, 54),
                row_group_labels = [1 => "Row Group 1"],
                table_format = TextTableFormat(horizontal_lines_at_data_rows = :all)
            )

            @test result == expected

            expected = """
┌────────┬────────┬────────┬────────┬────────┬────────
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │ Col. 5 │ Col.  ⋯
├────────┼────────┼────────┼────────┼────────┼────────
│ (1, 1) │ (1, 2) │ (1, 3) │ (1, 4) │ (1, 5) │ (1, 6 ⋯
├────────┴────────┴────────┴────────┴────────┴────────
│ Row Group 1                                        
├────────┬────────┬────────┬────────┬────────┬────────
│ (2, 1) │ (2, 2) │ (2, 3) │ (2, 4) │ (2, 5) │ (2, 6 ⋯
│      ⋮ │      ⋮ │      ⋮ │      ⋮ │      ⋮ │       ⋱
└────────┴────────┴────────┴────────┴────────┴────────
                        95 columns and 98 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (13, 54),
                row_group_labels = [2 => "Row Group 1"],
                table_format = TextTableFormat(horizontal_lines_at_data_rows = :all)
            )

            @test result == expected

expected = """
┌────────┬────────┬────────┬────────┬────────┬────────
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │ Col. 5 │ Col.  ⋯
├────────┴────────┴────────┴────────┴────────┴────────
│ Row Group 1                                        
├────────┬────────┬────────┬────────┬────────┬────────
│ (1, 1) │ (1, 2) │ (1, 3) │ (1, 4) │ (1, 5) │ (1, 6 ⋯
│      ⋮ │      ⋮ │      ⋮ │      ⋮ │      ⋮ │       ⋱
└────────┴────────┴────────┴────────┴────────┴────────
                        95 columns and 99 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (13, 54),
                row_group_labels = [1 => "Row Group 1", 2 => "Row Group 2"],
                table_format = TextTableFormat(horizontal_lines_at_data_rows = :all)
            )

            @test result == expected

            # == Summary Rows ==============================================================

            expected = """
┌───────────┬───────────┬───────────┬───────────┬─────
│           │    Col. 1 │    Col. 2 │    Col. 3 │    ⋯
├───────────┼───────────┼───────────┼───────────┼─────
│           │    (1, 1) │    (1, 2) │    (1, 3) │    ⋯
│           │    (2, 1) │    (2, 2) │    (2, 3) │    ⋯
│         ⋮ │         ⋮ │         ⋮ │         ⋮ │    ⋱
├───────────┼───────────┼───────────┼───────────┼─────
│ Summary 1 │ Summary 1 │ Summary 2 │ Summary 3 │ Su ⋯
└───────────┴───────────┴───────────┴───────────┴─────
                        97 columns and 98 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (12, 54),
                summary_rows = [(data, i) -> "Summary $i"]
            )

            @test result == expected

            expected = """
┌───────────┬───────────┬───────────┬───────────┬─────
│           │    Col. 1 │    Col. 2 │    Col. 3 │    ⋯
├───────────┼───────────┼───────────┼───────────┼─────
│           │    (1, 1) │    (1, 2) │    (1, 3) │    ⋯
├───────────┼───────────┼───────────┼───────────┼─────
│         ⋮ │         ⋮ │         ⋮ │         ⋮ │    ⋱
├───────────┼───────────┼───────────┼───────────┼─────
│ Summary 1 │ Summary 1 │ Summary 2 │ Summary 3 │ Su ⋯
└───────────┴───────────┴───────────┴───────────┴─────
                        97 columns and 99 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (12, 54),
                summary_rows = [(data, i) -> "Summary $i"],
                table_format = TextTableFormat(horizontal_lines_at_data_rows = :all),
            )

            @test result == expected

            expected = """
┌───────────┬───────────┬───────────┬───────────┬─────
│           │    Col. 1 │    Col. 2 │    Col. 3 │    ⋯
├───────────┼───────────┼───────────┼───────────┼─────
│           │    (1, 1) │    (1, 2) │    (1, 3) │    ⋯
├───────────┼───────────┼───────────┼───────────┼─────
│           │    (2, 1) │    (2, 2) │    (2, 3) │    ⋯
│         ⋮ │         ⋮ │         ⋮ │         ⋮ │    ⋱
├───────────┼───────────┼───────────┼───────────┼─────
│ Summary 1 │ Summary 1 │ Summary 2 │ Summary 3 │ Su ⋯
└───────────┴───────────┴───────────┴───────────┴─────
                        97 columns and 98 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (13, 54),
                summary_rows = [(data, i) -> "Summary $i"],
                table_format = TextTableFormat(horizontal_lines_at_data_rows = :all),
            )

            @test result == expected
        end

        @testset "Middle Cropping" begin
            expected = """
┌──────────┬──────────┬──────────┬──────────┬─────────
│   Col. 1 │   Col. 2 │   Col. 3 │   Col. 4 │   Col. ⋯
├──────────┼──────────┼──────────┼──────────┼─────────
│   (1, 1) │   (1, 2) │   (1, 3) │   (1, 4) │   (1,  ⋯
│   (2, 1) │   (2, 2) │   (2, 3) │   (2, 4) │   (2,  ⋯
│        ⋮ │        ⋮ │        ⋮ │        ⋮ │        ⋱
│  (99, 1) │  (99, 2) │  (99, 3) │  (99, 4) │  (99,  ⋯
│ (100, 1) │ (100, 2) │ (100, 3) │ (100, 4) │ (100,  ⋯
└──────────┴──────────┴──────────┴──────────┴─────────
                        96 columns and 96 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (12, 54),
                vertical_crop_mode = :middle
            )


            expected = """
┌──────────┬──────────┬──────────┬──────────┬───────────
│   Col. 1 │   Col. 2 │   Col. 3 │   Col. 4 │   Col. 5 ⋯
├──────────┼──────────┼──────────┼──────────┼───────────
│   (1, 1) │   (1, 2) │   (1, 3) │   (1, 4) │   (1, 5) ⋯
│   (2, 1) │   (2, 2) │   (2, 3) │   (2, 4) │   (2, 5) ⋯
│        ⋮ │        ⋮ │        ⋮ │        ⋮ │        ⋮ ⋱
│  (99, 1) │  (99, 2) │  (99, 3) │  (99, 4) │  (99, 5) ⋯
│ (100, 1) │ (100, 2) │ (100, 3) │ (100, 4) │ (100, 5) ⋯
└──────────┴──────────┴──────────┴──────────┴───────────
                          95 columns and 96 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (12, 56),
                maximum_number_of_columns = 7,
                maximum_number_of_rows = 4,
                vertical_crop_mode = :middle
            )

            @test result == expected

            # == Horizontal Lines ==========================================================

            expected = """
┌──────────┬──────────┬──────────┬──────────┬─────────
│   Col. 1 │   Col. 2 │   Col. 3 │   Col. 4 │   Col. ⋯
├──────────┼──────────┼──────────┼──────────┼─────────
│   (1, 1) │   (1, 2) │   (1, 3) │   (1, 4) │   (1,  ⋯
├──────────┼──────────┼──────────┼──────────┼─────────
│        ⋮ │        ⋮ │        ⋮ │        ⋮ │        ⋱
├──────────┼──────────┼──────────┼──────────┼─────────
│ (100, 1) │ (100, 2) │ (100, 3) │ (100, 4) │ (100,  ⋯
└──────────┴──────────┴──────────┴──────────┴─────────
                        96 columns and 98 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (12, 54),
                table_format = TextTableFormat(horizontal_lines_at_data_rows = :all),
                vertical_crop_mode = :middle
            )

            @test result == expected

            expected = """
┌──────────┬──────────┬──────────┬──────────┬─────────
│   Col. 1 │   Col. 2 │   Col. 3 │   Col. 4 │   Col. ⋯
├──────────┼──────────┼──────────┼──────────┼─────────
│   (1, 1) │   (1, 2) │   (1, 3) │   (1, 4) │   (1,  ⋯
├──────────┼──────────┼──────────┼──────────┼─────────
│   (2, 1) │   (2, 2) │   (2, 3) │   (2, 4) │   (2,  ⋯
│        ⋮ │        ⋮ │        ⋮ │        ⋮ │        ⋱
├──────────┼──────────┼──────────┼──────────┼─────────
│ (100, 1) │ (100, 2) │ (100, 3) │ (100, 4) │ (100,  ⋯
└──────────┴──────────┴──────────┴──────────┴─────────
                        96 columns and 97 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (13, 54),
                table_format = TextTableFormat(horizontal_lines_at_data_rows = :all),
                vertical_crop_mode = :middle
            )

            @test result == expected

            # == Fit Table in Display ======================================================

            expected = """
┌──────────┬──────────┬──────────┬──────────┬──────────┬──────────┬──────────┬───┐
│   Col. 1 │   Col. 2 │   Col. 3 │   Col. 4 │   Col. 5 │   Col. 6 │   Col. 7 │ ⋯ │
├──────────┼──────────┼──────────┼──────────┼──────────┼──────────┼──────────┼───┤
│   (1, 1) │   (1, 2) │   (1, 3) │   (1, 4) │   (1, 5) │   (1, 6) │   (1, 7) │ ⋯ │
│   (2, 1) │   (2, 2) │   (2, 3) │   (2, 4) │   (2, 5) │   (2, 6) │   (2, 7) │ ⋯ │
│        ⋮ │        ⋮ │        ⋮ │        ⋮ │        ⋮ │        ⋮ │        ⋮ │ ⋱ │
│  (99, 1) │  (99, 2) │  (99, 3) │  (99, 4) │  (99, 5) │  (99, 6) │  (99, 7) │ ⋯ │
│ (100, 1) │ (100, 2) │ (100, 3) │ (100, 4) │ (100, 5) │ (100, 6) │ (100, 7) │ ⋯ │
└──────────┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────┴───┘
                                                    93 columns and 96 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (12, 55),
                fit_table_in_display_horizontally = false,
                maximum_number_of_columns = 7,
                maximum_number_of_rows = 5,
                vertical_crop_mode = :middle
            )

            @test result == expected

            expected = """
┌────────┬────────┬────────┬────────┬────────┬────────┬────────┬───┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │ Col. 5 │ Col. 6 │ Col. 7 │ ⋯ │
├────────┼────────┼────────┼────────┼────────┼────────┼────────┼───┤
│ (1, 1) │ (1, 2) │ (1, 3) │ (1, 4) │ (1, 5) │ (1, 6) │ (1, 7) │ ⋯ │
│ (2, 1) │ (2, 2) │ (2, 3) │ (2, 4) │ (2, 5) │ (2, 6) │ (2, 7) │ ⋯ │
│ (3, 1) │ (3, 2) │ (3, 3) │ (3, 4) │ (3, 5) │ (3, 6) │ (3, 7) │ ⋯ │
│ (4, 1) │ (4, 2) │ (4, 3) │ (4, 4) │ (4, 5) │ (4, 6) │ (4, 7) │ ⋯ │
│      ⋮ │      ⋮ │      ⋮ │      ⋮ │      ⋮ │      ⋮ │      ⋮ │ ⋱ │
└────────┴────────┴────────┴────────┴────────┴────────┴────────┴───┘
                                      93 columns and 96 rows omitted
"""
            result = pretty_table(
                String,
                matrix;
                display_size = (13, 55),
                fit_table_in_display_horizontally = false,
                maximum_number_of_columns = 7,
                maximum_number_of_rows = 4,
            )

            @test result == expected


            expected = """
┌──────────┬──────────┬──────────┬──────────┬──────────┬──────────┬──────────┬───┐
│   Col. 1 │   Col. 2 │   Col. 3 │   Col. 4 │   Col. 5 │   Col. 6 │   Col. 7 │ ⋯ │
├──────────┼──────────┼──────────┼──────────┼──────────┼──────────┼──────────┼───┤
│   (1, 1) │   (1, 2) │   (1, 3) │   (1, 4) │   (1, 5) │   (1, 6) │   (1, 7) │ ⋯ │
│   (2, 1) │   (2, 2) │   (2, 3) │   (2, 4) │   (2, 5) │   (2, 6) │   (2, 7) │ ⋯ │
│   (3, 1) │   (3, 2) │   (3, 3) │   (3, 4) │   (3, 5) │   (3, 6) │   (3, 7) │ ⋯ │
│        ⋮ │        ⋮ │        ⋮ │        ⋮ │        ⋮ │        ⋮ │        ⋮ │ ⋱ │
│  (99, 1) │  (99, 2) │  (99, 3) │  (99, 4) │  (99, 5) │  (99, 6) │  (99, 7) │ ⋯ │
│ (100, 1) │ (100, 2) │ (100, 3) │ (100, 4) │ (100, 5) │ (100, 6) │ (100, 7) │ ⋯ │
└──────────┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────┴───┘
                                                    93 columns and 95 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (12, 55),
                fit_table_in_display_horizontally = false,
                fit_table_in_display_vertically = false,
                maximum_number_of_columns = 7,
                maximum_number_of_rows = 5,
                vertical_crop_mode = :middle
            )

            @test result == expected

            # == Row Group Labels ==========================================================

expected = """
┌────────┬────────┬────────┬────────┬────────┬────────
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │ Col. 5 │ Col.  ⋯
├────────┴────────┴────────┴────────┴────────┴────────
│ Row Group 1                                        
├────────┬────────┬────────┬────────┬────────┬────────
│ (1, 1) │ (1, 2) │ (1, 3) │ (1, 4) │ (1, 5) │ (1, 6 ⋯
├────────┼────────┼────────┼────────┼────────┼────────
│      ⋮ │      ⋮ │      ⋮ │      ⋮ │      ⋮ │       ⋱
└────────┴────────┴────────┴────────┴────────┴────────
                        95 columns and 99 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (13, 54),
                row_group_labels = [1 => "Row Group 1"],
                table_format = TextTableFormat(horizontal_lines_at_data_rows = :all),
                vertical_crop_mode = :middle
            )

            @test result == expected

            expected = """
┌──────────┬──────────┬──────────┬──────────┬─────────
│   Col. 1 │   Col. 2 │   Col. 3 │   Col. 4 │   Col. ⋯
├──────────┴──────────┴──────────┴──────────┴─────────
│ Row Group 1                                        
├──────────┬──────────┬──────────┬──────────┬─────────
│   (1, 1) │   (1, 2) │   (1, 3) │   (1, 4) │   (1,  ⋯
├──────────┼──────────┼──────────┼──────────┼─────────
│        ⋮ │        ⋮ │        ⋮ │        ⋮ │        ⋱
│ (100, 1) │ (100, 2) │ (100, 3) │ (100, 4) │ (100,  ⋯
└──────────┴──────────┴──────────┴──────────┴─────────
                        96 columns and 98 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (14, 54),
                row_group_labels = [1 => "Row Group 1"],
                table_format = TextTableFormat(horizontal_lines_at_data_rows = :all),
                vertical_crop_mode = :middle
            )

            @test result == expected

            expected = """
┌────────┬────────┬────────┬────────┬────────┬────────
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │ Col. 5 │ Col.  ⋯
├────────┴────────┴────────┴────────┴────────┴────────
│ Row Group 1                                        
├────────┬────────┬────────┬────────┬────────┬────────
│ (1, 1) │ (1, 2) │ (1, 3) │ (1, 4) │ (1, 5) │ (1, 6 ⋯
├────────┼────────┼────────┼────────┼────────┼────────
│      ⋮ │      ⋮ │      ⋮ │      ⋮ │      ⋮ │       ⋱
└────────┴────────┴────────┴────────┴────────┴────────
                        95 columns and 99 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (14, 54),
                row_group_labels = [1 => "Row Group 1", 100 => "Row Group 100"],
                table_format = TextTableFormat(horizontal_lines_at_data_rows = :all),
                vertical_crop_mode = :middle
            )

            @test result == expected

            # == Summary Rows ==============================================================

            expected = """
┌───────────┬───────────┬───────────┬───────────┬─────
│           │    Col. 1 │    Col. 2 │    Col. 3 │    ⋯
├───────────┼───────────┼───────────┼───────────┼─────
│           │    (1, 1) │    (1, 2) │    (1, 3) │    ⋯
│         ⋮ │         ⋮ │         ⋮ │         ⋮ │    ⋱
│           │  (100, 1) │  (100, 2) │  (100, 3) │  ( ⋯
├───────────┼───────────┼───────────┼───────────┼─────
│ Summary 1 │ Summary 1 │ Summary 2 │ Summary 3 │ Su ⋯
└───────────┴───────────┴───────────┴───────────┴─────
                        97 columns and 98 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (12, 54),
                summary_rows = [(data, i) -> "Summary $i"],
                vertical_crop_mode = :middle
            )

            @test result == expected

            expected = """
┌───────────┬───────────┬───────────┬───────────┬─────
│           │    Col. 1 │    Col. 2 │    Col. 3 │    ⋯
├───────────┼───────────┼───────────┼───────────┼─────
│           │    (1, 1) │    (1, 2) │    (1, 3) │    ⋯
├───────────┼───────────┼───────────┼───────────┼─────
│         ⋮ │         ⋮ │         ⋮ │         ⋮ │    ⋱
├───────────┼───────────┼───────────┼───────────┼─────
│ Summary 1 │ Summary 1 │ Summary 2 │ Summary 3 │ Su ⋯
└───────────┴───────────┴───────────┴───────────┴─────
                        97 columns and 99 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (12, 54),
                summary_rows = [(data, i) -> "Summary $i"],
                table_format = TextTableFormat(horizontal_lines_at_data_rows = :all),
                vertical_crop_mode = :middle
            )

            @test result == expected

            expected = """
┌───────────┬───────────┬───────────┬───────────┬─────
│           │    Col. 1 │    Col. 2 │    Col. 3 │    ⋯
├───────────┼───────────┼───────────┼───────────┼─────
│           │    (1, 1) │    (1, 2) │    (1, 3) │    ⋯
├───────────┼───────────┼───────────┼───────────┼─────
│         ⋮ │         ⋮ │         ⋮ │         ⋮ │    ⋱
│           │  (100, 1) │  (100, 2) │  (100, 3) │  ( ⋯
├───────────┼───────────┼───────────┼───────────┼─────
│ Summary 1 │ Summary 1 │ Summary 2 │ Summary 3 │ Su ⋯
└───────────┴───────────┴───────────┴───────────┴─────
                        97 columns and 98 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (13, 54),
                summary_rows = [(data, i) -> "Summary $i"],
                table_format = TextTableFormat(horizontal_lines_at_data_rows = :all),
                vertical_crop_mode = :middle
            )

            @test result == expected

            expected = """
┌───────────┬───────────┬───────────┬───────────┬─────
│           │    Col. 1 │    Col. 2 │    Col. 3 │    ⋯
├───────────┼───────────┼───────────┼───────────┼─────
│           │    (1, 1) │    (1, 2) │    (1, 3) │    ⋯
├───────────┼───────────┼───────────┼───────────┼─────
│         ⋮ │         ⋮ │         ⋮ │         ⋮ │    ⋱
├───────────┼───────────┼───────────┼───────────┼─────
│           │  (100, 1) │  (100, 2) │  (100, 3) │  ( ⋯
│ Summary 1 │ Summary 1 │ Summary 2 │ Summary 3 │ Su ⋯
└───────────┴───────────┴───────────┴───────────┴─────
                        97 columns and 98 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (13, 54),
                summary_rows = [(data, i) -> "Summary $i"],
                table_format = TextTableFormat(
                    horizontal_line_after_data_rows = false,
                    horizontal_line_before_summary_rows = false,
                    horizontal_lines_at_data_rows = :all,
                ),
                vertical_crop_mode = :middle
            )

            @test result == expected

            expected = """
┌───────────┬───────────┬───────────┬───────────┬─────
│           │    Col. 1 │    Col. 2 │    Col. 3 │    ⋯
├───────────┼───────────┼───────────┼───────────┼─────
│           │    (1, 1) │    (1, 2) │    (1, 3) │    ⋯
├───────────┼───────────┼───────────┼───────────┼─────
│         ⋮ │         ⋮ │         ⋮ │         ⋮ │    ⋱
│           │  (100, 1) │  (100, 2) │  (100, 3) │  ( ⋯
├───────────┼───────────┼───────────┼───────────┼─────
│ Summary 1 │ Summary 1 │ Summary 2 │ Summary 3 │ Su ⋯
└───────────┴───────────┴───────────┴───────────┴─────
                        97 columns and 98 rows omitted
"""

            result = pretty_table(
                String,
                matrix;
                display_size = (13, 54),
                summary_rows = [(data, i) -> "Summary $i"],
                table_format = TextTableFormat(
                    horizontal_line_after_data_rows = false,
                    horizontal_line_before_summary_rows = true,
                    horizontal_lines_at_data_rows = :all,
                ),
                vertical_crop_mode = :middle
            )

            @test result == expected
        end

        @testset "Omitted Cell Summary" begin
                expected = """
┌──────────┬──────────┬──────────┬───┐
│   Col. 1 │   Col. 2 │   Col. 3 │ ⋯ │
├──────────┼──────────┼──────────┼───┤
│   (1, 1) │   (1, 2) │   (1, 3) │ ⋯ │
│        ⋮ │        ⋮ │        ⋮ │ ⋱ │
│ (100, 1) │ (100, 2) │ (100, 3) │ ⋯ │
└──────────┴──────────┴──────────┴───┘
"""

            result = pretty_table(
                String,
                matrix;
                maximum_number_of_columns = 3,
                maximum_number_of_rows = 2,
                show_omitted_cell_summary = false,
                vertical_crop_mode = :middle
            )

            @test result == expected
        end
    end

    @testset "With Multiple Lines" begin
        matrix = ["($i, $j, 1)\n($i, $j, 2)" for i in 1:5, j in 1:5]

        expected = """
┌───────────┬───────
│    Col. 1 │    C ⋯
├───────────┼───────
│ (1, 1, 1) │ (1,  ⋯
│ (1, 1, 2) │ (1,  ⋯
├───────────┼───────
│ (2, 1, 1) │ (2,  ⋯
│ (2, 1, 2) │ (2,  ⋯
├───────────┼───────
│ (3, 1, 1) │ (3,  ⋯
│         ⋮ │      ⋱
└───────────┴───────
4 columns and 3 rows omitted
"""

        result = pretty_table(
            String,
            matrix;
            line_breaks = true,
            display_size = (15, 20),
            table_format = TextTableFormat(; @text__all_horizontal_lines)
        )
        @test result == expected

        expected = """
┌───────────┬───────
│    Col. 1 │    C ⋯
├───────────┼───────
│ (1, 1, 1) │ (1,  ⋯
│ (1, 1, 2) │ (1,  ⋯
├───────────┼───────
│ (2, 1, 1) │ (2,  ⋯
│ (2, 1, 2) │ (2,  ⋯
├───────────┼───────
│ (3, 1, 1) │ (3,  ⋯
│ (3, 1, 2) │ (3,  ⋯
│         ⋮ │      ⋱
└───────────┴───────
4 columns and 2 rows omitted
"""

        result = pretty_table(
            String,
            matrix;
            line_breaks = true,
            display_size = (16, 20),
            table_format = TextTableFormat(; @text__all_horizontal_lines)
        )
        @test result == expected

        expected = """
┌───────────┬───────
│    Col. 1 │    C ⋯
├───────────┼───────
│ (1, 1, 1) │ (1,  ⋯
│ (1, 1, 2) │ (1,  ⋯
├───────────┼───────
│ (2, 1, 1) │ (2,  ⋯
│ (2, 1, 2) │ (2,  ⋯
├───────────┼───────
│ (3, 1, 1) │ (3,  ⋯
│ (3, 1, 2) │ (3,  ⋯
├───────────┼───────
│         ⋮ │      ⋱
└───────────┴───────
4 columns and 2 rows omitted
"""

        result = pretty_table(
            String,
            matrix;
            line_breaks = true,
            display_size = (17, 20),
            table_format = TextTableFormat(; @text__all_horizontal_lines)
        )
        @test result == expected
    end
end

@testset "Shrinkable Column" begin
    matrix = [
        "A"^20 "A"^10 "A"^5
        "B"^10 "B"^20 "B"^10
        "C"^5  "C"^5  "C"^20
    ]

    expected = pretty_table(
        String,
        matrix;
        column_labels = [MultiColumn(2, "H"^35, :r), "Col. 3"],
    )

    result = pretty_table(
        String,
        matrix;
        column_labels          = [MultiColumn(2, "H"^35, :r), "Col. 3"],
        display_size           = (-1, 70),
        shrinkable_data_column = 1,
    )

    @test result == expected

    result = pretty_table(
        String,
        matrix;
        column_labels          = [MultiColumn(2, "H"^35, :r), "Col. 3"],
        display_size           = (-1, 70),
        shrinkable_data_column = 2,
    )

    @test result == expected

    result = pretty_table(
        String,
        matrix;
        column_labels          = [MultiColumn(2, "H"^35, :r), "Col. 3"],
        display_size           = (-1, 70),
        shrinkable_data_column = 3,
    )

    @test result == expected

    # == Shrinking Column #1 ===============================================================

    expected = """
┌──────────────────────────────────────────┬──────────────────────┐
│      HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH │ Col. 3               │
├───────────────────┬──────────────────────┼──────────────────────┤
│ AAAAAAAAAAAAAAAA… │ AAAAAAAAAA           │ AAAAA                │
│ BBBBBBBBBB        │ BBBBBBBBBBBBBBBBBBBB │ BBBBBBBBBB           │
│ CCCCC             │ CCCCC                │ CCCCCCCCCCCCCCCCCCCC │
└───────────────────┴──────────────────────┴──────────────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment              = :l,
        column_labels          = [MultiColumn(2, "H"^35, :r), "Col. 3"],
        display_size           = (-1, 67),
        shrinkable_data_column = 1,
    )

    @test result == expected

    expected = """
┌───────────────────────────┬──────────────────────┐
│ HHHHHHHHHHHHHHHHHHHHHHHH… │ Col. 3               │
├────┬──────────────────────┼──────────────────────┤
│ A… │ AAAAAAAAAA           │ AAAAA                │
│ B… │ BBBBBBBBBBBBBBBBBBBB │ BBBBBBBBBB           │
│ C… │ CCCCC                │ CCCCCCCCCCCCCCCCCCCC │
└────┴──────────────────────┴──────────────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment              = :l,
        column_labels          = [MultiColumn(2, "H"^35, :r), "Col. 3"],
        display_size           = (-1, 52),
        shrinkable_data_column = 1,
    )

    @test result == expected

    expected = """
┌──────────────────────────┬────────────
│ HHHHHHHHHHHHHHHHHHHHHHH… │ Col. 3    ⋯
├───┬──────────────────────┼────────────
│ … │ AAAAAAAAAA           │ AAAAA     ⋯
│ … │ BBBBBBBBBBBBBBBBBBBB │ BBBBBBBBB ⋯
│ … │ CCCCC                │ CCCCCCCCC ⋯
└───┴──────────────────────┴────────────
                        1 column omitted
"""

    result = pretty_table(
        String,
        matrix;
        alignment              = :l,
        column_labels          = [MultiColumn(2, "H"^35, :r), "Col. 3"],
        display_size           = (-1, 40),
        shrinkable_data_column = 1,
    )

    @test result == expected

    expected = """
┌──────────────────────────────┬────────
│ HHHHHHHHHHHHHHHHHHHHHHHHHHH… │ Col.  ⋯
├───────┬──────────────────────┼────────
│ AAAA… │ AAAAAAAAAA           │ AAAAA ⋯
│ BBBB… │ BBBBBBBBBBBBBBBBBBBB │ BBBBB ⋯
│ CCCCC │ CCCCC                │ CCCCC ⋯
└───────┴──────────────────────┴────────
                        1 column omitted
"""

    result = pretty_table(
        String,
        matrix;
        alignment                       = :l,
        column_labels                   = [MultiColumn(2, "H"^35, :r), "Col. 3"],
        display_size                    = (-1, 40),
        shrinkable_column_minimum_width = 5,
        shrinkable_data_column          = 1,
    )

    @test result == expected

    # == Shrinking Column #2 ===============================================================

    expected = """
┌──────────────────────────────────────────┬──────────────────────┐
│      HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH │ Col. 3               │
├──────────────────────┬───────────────────┼──────────────────────┤
│ AAAAAAAAAAAAAAAAAAAA │ AAAAAAAAAA        │ AAAAA                │
│ BBBBBBBBBB           │ BBBBBBBBBBBBBBBB… │ BBBBBBBBBB           │
│ CCCCC                │ CCCCC             │ CCCCCCCCCCCCCCCCCCCC │
└──────────────────────┴───────────────────┴──────────────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment              = :l,
        column_labels          = [MultiColumn(2, "H"^35, :r), "Col. 3"],
        display_size           = (-1, 67),
        shrinkable_data_column = 2,
    )

    @test result == expected

    expected = """
┌───────────────────────────┬──────────────────────┐
│ HHHHHHHHHHHHHHHHHHHHHHHH… │ Col. 3               │
├──────────────────────┬────┼──────────────────────┤
│ AAAAAAAAAAAAAAAAAAAA │ A… │ AAAAA                │
│ BBBBBBBBBB           │ B… │ BBBBBBBBBB           │
│ CCCCC                │ C… │ CCCCCCCCCCCCCCCCCCCC │
└──────────────────────┴────┴──────────────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment              = :l,
        column_labels          = [MultiColumn(2, "H"^35, :r), "Col. 3"],
        display_size           = (-1, 52),
        shrinkable_data_column = 2,
    )

    @test result == expected

    expected = """
┌──────────────────────────┬────────────
│ HHHHHHHHHHHHHHHHHHHHHHH… │ Col. 3    ⋯
├──────────────────────┬───┼────────────
│ AAAAAAAAAAAAAAAAAAAA │ … │ AAAAA     ⋯
│ BBBBBBBBBB           │ … │ BBBBBBBBB ⋯
│ CCCCC                │ … │ CCCCCCCCC ⋯
└──────────────────────┴───┴────────────
                        1 column omitted
"""

    result = pretty_table(
        String,
        matrix;
        alignment              = :l,
        column_labels          = [MultiColumn(2, "H"^35, :r), "Col. 3"],
        display_size           = (-1, 40),
        shrinkable_data_column = 2,
    )

    @test result == expected

    expected = """
┌──────────────────────────────┬────────
│ HHHHHHHHHHHHHHHHHHHHHHHHHHH… │ Col.  ⋯
├──────────────────────┬───────┼────────
│ AAAAAAAAAAAAAAAAAAAA │ AAAA… │ AAAAA ⋯
│ BBBBBBBBBB           │ BBBB… │ BBBBB ⋯
│ CCCCC                │ CCCCC │ CCCCC ⋯
└──────────────────────┴───────┴────────
                        1 column omitted
"""

    result = pretty_table(
        String,
        matrix;
        alignment                       = :l,
        column_labels                   = [MultiColumn(2, "H"^35, :r), "Col. 3"],
        display_size                    = (-1, 40),
        shrinkable_column_minimum_width = 5,
        shrinkable_data_column          = 2,
    )

    @test result == expected

    # == Shrinking Column #3 ===============================================================

    expected = """
┌─────────────────────────────────────────────┬───────────────────┐
│         HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH │ Col. 3            │
├──────────────────────┬──────────────────────┼───────────────────┤
│ AAAAAAAAAAAAAAAAAAAA │ AAAAAAAAAA           │ AAAAA             │
│ BBBBBBBBBB           │ BBBBBBBBBBBBBBBBBBBB │ BBBBBBBBBB        │
│ CCCCC                │ CCCCC                │ CCCCCCCCCCCCCCCC… │
└──────────────────────┴──────────────────────┴───────────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment              = :l,
        column_labels          = [MultiColumn(2, "H"^35, :r), "Col. 3"],
        display_size           = (-1, 67),
        shrinkable_data_column = 3,
    )

    @test result == expected

    expected = """
┌─────────────────────────────────────────────┬────┐
│         HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH │ C… │
├──────────────────────┬──────────────────────┼────┤
│ AAAAAAAAAAAAAAAAAAAA │ AAAAAAAAAA           │ A… │
│ BBBBBBBBBB           │ BBBBBBBBBBBBBBBBBBBB │ B… │
│ CCCCC                │ CCCCC                │ C… │
└──────────────────────┴──────────────────────┴────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment              = :l,
        column_labels          = [MultiColumn(2, "H"^35, :r), "Col. 3"],
        display_size           = (-1, 52),
        shrinkable_data_column = 3,
    )

    @test result == expected

    expected = """
┌───────────────────────────────────────
│         HHHHHHHHHHHHHHHHHHHHHHHHHHHH ⋯
├──────────────────────┬────────────────
│ AAAAAAAAAAAAAAAAAAAA │ AAAAAAAAAA    ⋯
│ BBBBBBBBBB           │ BBBBBBBBBBBBB ⋯
│ CCCCC                │ CCCCC         ⋯
└──────────────────────┴────────────────
                       2 columns omitted
"""

    result = pretty_table(
        String,
        matrix;
        alignment              = :l,
        column_labels          = [MultiColumn(2, "H"^35, :r), "Col. 3"],
        display_size           = (-1, 40),
        shrinkable_data_column = 3,
    )

    @test result == expected

    result = pretty_table(
        String,
        matrix;
        alignment                       = :l,
        column_labels                   = [MultiColumn(2, "H"^35, :r), "Col. 3"],
        display_size                    = (-1, 40),
        shrinkable_column_minimum_width = 5,
        shrinkable_data_column          = 3,
    )

    @test result == expected
end
