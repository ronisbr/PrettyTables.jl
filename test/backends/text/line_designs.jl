## Description #############################################################################
#
# Text Back End: Test of line characters and line designs.
#
############################################################################################

@testset "Line Characters and Designs" verbose = true begin
    matrix = [1 2; 3 4]

    @testset "Native Line Characters" begin
        # == Sparse Override of a Single Character =========================================

        expected = """
┌────────┬────────┐
│ Col. 1 │ Col. 2 │
├========┼========┤
│      1 │      2 │
│      3 │      4 │
└────────┴────────┘
"""

        result = pretty_table(
            String,
            matrix;
            table_format = TextTableFormat(; header_line = TextLineBorders(; row = '='))
        )

        @test result == expected

        # == Complete Custom Horizontal Line ===============================================

        expected = """
┌────────┬────────┐
│ Col. 1 │ Col. 2 │
╞════════╪════════╡
│      1 │      2 │
│      3 │      4 │
└────────┴────────┘
"""

        result = pretty_table(
            String,
            matrix;
            table_format = TextTableFormat(;
                header_line = TextLineBorders(;
                    left_intersection   = '╞',
                    middle_intersection = '╪',
                    right_intersection  = '╡',
                    row                 = '═',
                )
            )
        )

        @test result == expected

        # == Custom Vertical Line Character ================================================

        expected = """
┌────────┬────────┐
│ Col. 1 ┊ Col. 2 │
├────────┼────────┤
│      1 ┊      2 │
│      3 ┊      4 │
└────────┴────────┘
"""

        result = pretty_table(
            String,
            matrix;
            table_format = TextTableFormat(; center_line = '┊')
        )

        @test result == expected

        # == Custom Borders With a Custom Line =============================================

        # The line characters must take precedence over the characters in `borders` for
        # that line, whereas the other lines must keep the custom characters.
        expected = """
.--------.--------.
| Col. 1 | Col. 2 |
╞════════╪════════╡
|      1 |      2 |
|      3 |      4 |
'--------'--------'
"""

        result = pretty_table(
            String,
            matrix;
            table_format = TextTableFormat(;
                borders     = text_table_borders__ascii_rounded,
                header_line = TextLineBorders(;
                    left_intersection   = '╞',
                    middle_intersection = '╪',
                    right_intersection  = '╡',
                    row                 = '═',
                ),
            )
        )

        @test result == expected
    end

    @testset "Generic Line Designs" begin
        # == Double Top and Bottom Lines ===================================================

        expected = """
╒════════╤════════╕
│ Col. 1 │ Col. 2 │
├────────┼────────┤
│      1 │      2 │
│      3 │      4 │
╘════════╧════════╛
"""

        result = pretty_table(
            String,
            matrix;
            table_format = TableFormat(;
                top_line    = LineStyle(; style = :double),
                bottom_line = LineStyle(; style = :double),
            )
        )

        @test result == expected

        # == Heavy Header Line and Heavy Center Line =======================================

        # `:medium` and `:thick` widths must map to the same heavy characters.
        expected = """
┌────────┰────────┐
│ Col. 1 ┃ Col. 2 │
┝━━━━━━━━╋━━━━━━━━┥
│      1 ┃      2 │
│      3 ┃      4 │
└────────┸────────┘
"""

        result = pretty_table(
            String,
            matrix;
            table_format = TableFormat(;
                header_line = LineStyle(; width = :thick),
                center_line = LineStyle(; width = :medium),
            )
        )

        @test result == expected

        # == Dashed Middle Line With Solid Junctions =======================================

        expected = """
┌────────┬────────┐
│ Col. 1 │ Col. 2 │
├────────┼────────┤
│      1 │      2 │
├╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┤
│      3 │      4 │
└────────┴────────┘
"""

        result = pretty_table(
            String,
            matrix;
            table_format = TableFormat(;
                middle_line                   = LineStyle(; style = :dashed),
                horizontal_lines_at_data_rows = :all,
            )
        )

        @test result == expected

        # == Designs for Each Vertical Line Role ===========================================

        expected = """
┎────────┬────────╖
┃ Col. 1 ┊ Col. 2 ║
┠────────┼────────╢
┃      1 ┊      2 ║
┃      3 ┊      4 ║
┖────────┴────────╜
"""

        result = pretty_table(
            String,
            matrix;
            table_format = TableFormat(;
                center_line = LineStyle(; style = :dotted),
                left_line   = LineStyle(; width = :thick),
                right_line  = LineStyle(; style = :double),
            )
        )

        @test result == expected

        # == Junction Without a Unicode Character ==========================================

        # A heavy line crossing a double line has no Unicode junction. Hence, the character
        # in `borders` must be used.
        expected = """
┌────────╥────────┐
│ Col. 1 ║ Col. 2 │
┝━━━━━━━━┼━━━━━━━━┥
│      1 ║      2 │
│      3 ║      4 │
└────────╨────────┘
"""

        result = pretty_table(
            String,
            matrix;
            table_format = TableFormat(;
                header_line = LineStyle(; width = :thick),
                center_line = LineStyle(; style = :double),
            )
        )

        @test result == expected
    end

    @testset "Line Faces and Colors" begin
        # == Precedence: Line Face > Line Design Color > Table Border ======================

        expected = """
\e[32m┌────────┬────────┐\e[0m
\e[32m│\e[0m\e[1m Col. 1 \e[0m\e[32m│\e[0m\e[1m Col. 2 \e[0m\e[32m│\e[0m
\e[32m├────────┼────────┤\e[0m
\e[32m│\e[0m      1 \e[32m│\e[0m      2 \e[32m│\e[0m
\e[34m├╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┤\e[0m
\e[32m│\e[0m      3 \e[32m│\e[0m      4 \e[32m│\e[0m
\e[32m└────────┴────────┘\e[0m
"""

        result = pretty_table(
            String,
            matrix;
            color = true,
            table_format = TableFormat(;
                middle_line                   = LineStyle(; style = :dashed, color = :red),
                horizontal_lines_at_data_rows = :all,
            ),
            style = TextTableStyle(;
                middle_line  = Face(; foreground = :blue),
                table_border = Face(; foreground = :green),
            )
        )

        @test result == expected

        # == Line Design Color =============================================================

        expected = """
┌────────┬────────┐
│\e[1m Col. 1 \e[0m│\e[1m Col. 2 \e[0m│
├────────┼────────┤
│      1 │      2 │
\e[31m├╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┤\e[0m
│      3 │      4 │
└────────┴────────┘
"""

        result = pretty_table(
            String,
            matrix;
            color = true,
            table_format = TableFormat(;
                middle_line                   = LineStyle(; style = :dashed, color = :red),
                horizontal_lines_at_data_rows = :all,
            )
        )

        @test result == expected

        # == Line Faces Accept Crayons =====================================================

        result_crayon = pretty_table(
            String,
            matrix;
            color = true,
            table_format = TextTableFormat(; horizontal_lines_at_data_rows = :all),
            style = TextTableStyle(; middle_line = Crayon(; foreground = :blue))
        )

        result_face = pretty_table(
            String,
            matrix;
            color = true,
            table_format = TextTableFormat(; horizontal_lines_at_data_rows = :all),
            style = TextTableStyle(; middle_line = Face(; foreground = :blue))
        )

        @test result_crayon == result_face

        # == Output Without Color Support ==================================================

        expected = """
┌────────┬────────┐
│ Col. 1 │ Col. 2 │
├────────┼────────┤
│      1 │      2 │
├╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┤
│      3 │      4 │
└────────┴────────┘
"""

        result = pretty_table(
            String,
            matrix;
            color = false,
            table_format = TableFormat(;
                middle_line                   = LineStyle(; style = :dashed, color = :red),
                horizontal_lines_at_data_rows = :all,
            ),
            style = TextTableStyle(; middle_line = Face(; foreground = :blue))
        )

        @test result == expected
    end

    @testset "Merged Column Labels" begin
        expected = """
┌─────────────────┬────────┬────────┐
│    Merged #1    │ Col. 3 │ Col. 4 │
│ ━━━━━━━┯━━━━━━━ │        │        │
│ Col. 1 │ Col. 2 │    Merged #2    │
├────────┼────────┼────────┬────────┤
│ (1, 1) │ (1, 2) │ (1, 3) │ (1, 4) │
│ (2, 1) │ (2, 2) │ (2, 3) │ (2, 4) │
└────────┴────────┴────────┴────────┘
"""

        result = pretty_table(
            String,
            [(i, j) for i in 1:2, j in 1:4];
            column_labels = [
                [MultiColumn(2, "Merged #1", :c), "Col. 3", "Col. 4"],
                ["Col. 1", "Col. 2", MultiColumn(2, "Merged #2", :c)],
            ],
            table_format = TableFormat(;
                horizontal_line_at_merged_column_labels = true,
                merged_header_cell_line                 = LineStyle(; width = :thick),
            )
        )

        @test result == expected
    end

    @testset "Suppressed Vertical Lines at Column Labels" begin
        # The suppressed vertical lines must remain a blank space without the character or
        # the color of the center line.
        expected = """
┌─────────────────┐
│\e[1m Col. 1 \e[0m \e[1m Col. 2 \e[0m│
├────────┬────────┤
│      1 \e[31m║\e[0m      2 │
│      3 \e[31m║\e[0m      4 │
└────────┴────────┘
"""

        result = pretty_table(
            String,
            matrix;
            color = true,
            table_format = TextTableFormat(;
                suppress_vertical_lines_at_column_labels = true,
                center_line = '║',
            ),
            style = TextTableStyle(; center_line = Face(; foreground = :red))
        )

        @test result == expected
    end

    @testset "Cropped Table" begin
        # The vertical line after the data columns is not at the right edge of the table
        # when we have a continuation column. Hence, it must use the center line design,
        # whereas the line after the continuation column must use the right line design.
        expected = """
┌────────┰────────┰───╖
│ Col. 1 ┃ Col. 2 ┃ ⋯ ║
├────────╂────────╂───╢
│      2 ┃      3 ┃ ⋯ ║
│      3 ┃      4 ┃ ⋯ ║
│      4 ┃      5 ┃ ⋯ ║
└────────┸────────┸───╜
      2 columns omitted
"""

        result = pretty_table(
            String,
            [i + j for i in 1:3, j in 1:4];
            maximum_number_of_columns = 2,
            maximum_number_of_rows = 2,
            table_format = TableFormat(;
                right_line  = LineStyle(; style = :double),
                center_line = LineStyle(; width = :thick),
            )
        )

        @test result == expected

        # If the display crops the table, the intersections that do not fit must be replaced
        # by the row character of the line design.
        expected = """
┌────────┬────────
│ Col. 1 │ Col.  ⋯
┝━━━━━━━━┿━━━━━━━━
│      2 │       ⋯
│      3 │       ⋯
│      4 │       ⋯
└────────┴────────
 3 columns omitted
"""

        result = pretty_table(
            String,
            [i + j for i in 1:3, j in 1:4];
            display_size = (-1, 18),
            fit_table_in_display_horizontally = true,
            table_format = TableFormat(; header_line = LineStyle(; width = :thick))
        )

        @test result == expected
    end

    @testset "Summary Rows and Row Group Labels" begin
        expected = """
┌───────────┬────────┬────────┒
│           │ Col. 1 │ Col. 2 ┃
├╌╌╌╌╌╌╌╌╌╌╌┴╌╌╌╌╌╌╌╌┴╌╌╌╌╌╌╌╌┨
│ Group                       ┃
├╌╌╌╌╌╌╌╌╌╌╌┬╌╌╌╌╌╌╌╌┬╌╌╌╌╌╌╌╌┨
│           │      1 │      2 ┃
│           │      3 │      4 ┃
├╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┨
│ Summary 1 │      4 │      6 ┃
╘═══════════╧════════╧════════┘
"""

        result = pretty_table(
            String,
            matrix;
            summary_rows = [(data, j) -> sum(data[:, j])],
            row_group_labels = [1 => "Group"],
            table_format = TableFormat(;
                middle_line = LineStyle(; style = :dashed),
                bottom_line = LineStyle(; style = :double),
                right_line  = LineStyle(; width = :thick),
            )
        )

        @test result == expected
    end

    @testset "Table Without Data Rows" begin
        # The line after the column labels is the bottom line of the table if there are no
        # data rows.
        expected = """
┌────────┬────────┐
│ Col. 1 │ Col. 2 │
╘════════╧════════╛
"""

        result = pretty_table(
            String,
            Matrix{Int}(undef, 0, 2);
            table_format = TableFormat(; bottom_line = LineStyle(; style = :double))
        )

        @test result == expected
    end
end
