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
end
