## Description #############################################################################
#
# Tests related to the internal functions that select the table lines.
#
############################################################################################

# Create a table data with the sections required by the tests. The keywords override the
# default values.
function _test_lines_table_data(;
    num_rows = 3,
    num_columns = 4,
    column_labels = [["1", "2", "3", "4"], ["1", "2", "3", "4"]],
    row_group_labels = [2 => "Row Group"],
    summary_rows = [(data, j) -> j, (data, j) -> 2j],
    footnotes = [(:data, 1, 1) => "Footnote 1", (:data, 2, 2) => "Footnote 2"],
    source_notes = "Source Notes",
    kwargs...,
)
    return PrettyTables.TableData(;
        data               = ones(num_rows, num_columns),
        title              = "Table Title",
        subtitle           = "Table Subtitle",
        column_labels      = column_labels,
        row_group_labels   = row_group_labels,
        summary_rows       = summary_rows,
        summary_row_labels = isnothing(summary_rows) ? nothing : PrettyTables.SummaryLabelIterator(summary_rows),
        footnotes          = footnotes,
        source_notes       = source_notes,
        num_rows           = num_rows,
        num_columns        = num_columns,
        first_row_index    = 1,
        first_column_index = 1,
        kwargs...,
    )
end

@testset "Table Lines" verbose = true begin
    @testset "Resolution of the Table Format" begin
        td = _test_lines_table_data(; column_labels = [["1", "2", "3", "4"] for _ in 1:3])

        # == Text Back End =================================================================

        lines = PrettyTables.TableLines(TextTableFormat(), td)

        @test lines.horizontal_line_at_beginning == true
        @test lines.horizontal_line_before_column_labels == true
        @test !(1 ∈ lines.horizontal_lines_at_column_labels)
        @test !(2 ∈ lines.horizontal_lines_at_column_labels)
        @test lines.horizontal_line_after_footnotes == false
        @test lines.horizontal_line_at_end == false
        @test lines.suppress_vertical_lines_at_column_labels == false
        @test all(j -> j ∈ lines.vertical_lines_at_data_columns, 1:4)
        @test !(5 ∈ lines.vertical_lines_at_data_columns)

        lines = PrettyTables.TableLines(
            TextTableFormat(;
                horizontal_line_at_beginning = false,
                horizontal_lines_at_column_labels = [2],
                horizontal_lines_at_data_rows = [1, 3],
                suppress_vertical_lines_at_column_labels = true,
                vertical_lines_at_data_columns = :none,
            ),
            td,
        )

        @test lines.horizontal_line_at_beginning == false
        @test lines.horizontal_line_before_column_labels == false
        @test !(1 ∈ lines.horizontal_lines_at_column_labels)
        @test 2 ∈ lines.horizontal_lines_at_column_labels
        @test 1 ∈ lines.horizontal_lines_at_data_rows
        @test !(2 ∈ lines.horizontal_lines_at_data_rows)
        @test 3 ∈ lines.horizontal_lines_at_data_rows
        @test lines.suppress_vertical_lines_at_column_labels == true
        @test !any(j -> j ∈ lines.vertical_lines_at_data_columns, 1:4)

        # == HTML Back End =================================================================

        lines = PrettyTables.TableLines(HtmlTableFormat(), td)

        @test lines.horizontal_line_at_beginning == false
        @test lines.horizontal_line_before_column_labels == false
        @test lines.horizontal_line_after_footnotes == false
        @test lines.horizontal_line_at_end == false
        @test !(1 ∈ lines.horizontal_lines_at_column_labels)

        lines = PrettyTables.TableLines(
            HtmlTableFormat(;
                horizontal_line_before_column_labels = true,
                horizontal_line_after_footnotes = true,
                horizontal_line_at_end = true,
            ),
            td,
        )

        @test lines.horizontal_line_at_beginning == false
        @test lines.horizontal_line_before_column_labels == true
        @test lines.horizontal_line_after_footnotes == true
        @test lines.horizontal_line_at_end == true

        # == LaTeX and Typst Back Ends =====================================================

        for tf in (LatexTableFormat(), TypstTableFormat())
            lines = PrettyTables.TableLines(tf, td)
            @test lines.horizontal_line_before_column_labels == true
            @test !(1 ∈ lines.horizontal_lines_at_column_labels)
            @test lines.suppress_vertical_lines_at_column_labels == false
        end

        # == Excel and Word Back Ends ======================================================

        for tf in (ExcelTableFormat(), DocxTableFormat())
            lines = PrettyTables.TableLines(tf, td)
            @test lines.horizontal_line_before_column_labels == true
            @test !(1 ∈ lines.horizontal_lines_at_column_labels)
            @test !(2 ∈ lines.horizontal_lines_at_column_labels)
        end

        for tf in (
            ExcelTableFormat(; horizontal_line_between_column_labels = true),
            DocxTableFormat(; horizontal_line_between_column_labels = true),
        )
            lines = PrettyTables.TableLines(tf, td)

            # The line after the last column label row is not selected here because it is
            # controlled by `horizontal_line_after_column_labels`.
            @test 1 ∈ lines.horizontal_lines_at_column_labels
            @test 2 ∈ lines.horizontal_lines_at_column_labels
            @test !(3 ∈ lines.horizontal_lines_at_column_labels)
        end
    end

    @testset "Presence of Lines" begin
        td = _test_lines_table_data()

        @test PrettyTables._has_any_table_line(
            PrettyTables.TableLines(TextTableFormat(), td)
        )

        @test !PrettyTables._has_any_table_line(
            PrettyTables.TableLines(
                TextTableFormat(; @text__no_horizontal_lines, @text__no_vertical_lines), td
            ),
        )

        @test !PrettyTables._has_any_table_line(
            PrettyTables.TableLines(HtmlTableFormat(), td)
        )

        @test PrettyTables._has_any_table_line(
            PrettyTables.TableLines(
                HtmlTableFormat(; horizontal_lines_at_data_rows = [2]), td
            ),
        )

        @test !PrettyTables._has_any_table_line(
            PrettyTables.TableLines(
                HtmlTableFormat(; horizontal_lines_at_data_rows = Int[]), td
            ),
        )

        @test PrettyTables._has_any_table_line(
            PrettyTables.TableLines(HtmlTableFormat(; horizontal_line_at_end = true), td)
        )

        # Suppressing the vertical lines at the column labels does not draw a line.
        @test !PrettyTables._has_any_table_line(
            PrettyTables.TableLines(
                TextTableFormat(;
                    @text__no_horizontal_lines,
                    @text__no_vertical_lines,
                    suppress_vertical_lines_at_column_labels = true,
                ),
                td,
            ),
        )
    end

    @testset "Next Row Section" begin
        # == Full Table ====================================================================

        td = _test_lines_table_data()

        @test PrettyTables._next_row_section(td, :column_labels, 1) == :column_labels
        @test PrettyTables._next_row_section(td, :column_labels, 2) == :data
        @test PrettyTables._next_row_section(td, :data, 1) == :row_group_label
        @test PrettyTables._next_row_section(td, :row_group_label, 2) == :data
        @test PrettyTables._next_row_section(td, :data, 2) == :data
        @test PrettyTables._next_row_section(td, :data, 3) == :summary_row
        @test PrettyTables._next_row_section(td, :summary_row, 1) == :summary_row
        @test PrettyTables._next_row_section(td, :summary_row, 2) == :table_footer

        # == Table Without Summary Rows and Footer =========================================

        td = _test_lines_table_data(;
            summary_rows = nothing, footnotes = nothing, source_notes = ""
        )

        @test PrettyTables._next_row_section(td, :data, 3) == :table_footer

        # == Table Without Data Rows =======================================================

        td = _test_lines_table_data(; num_rows = 0, row_group_labels = nothing)

        @test PrettyTables._next_row_section(td, :column_labels, 2) == :summary_row

        td = _test_lines_table_data(;
            num_rows = 0, row_group_labels = nothing, summary_rows = nothing
        )

        @test PrettyTables._next_row_section(td, :column_labels, 2) == :table_footer

        # == Bottom Cropping ===============================================================

        td = _test_lines_table_data(; maximum_number_of_rows = 2)

        @test PrettyTables._next_row_section(td, :data, 1) == :row_group_label
        @test PrettyTables._next_row_section(td, :data, 2) == :continuation_row
        @test PrettyTables._next_row_section(td, :continuation_row, 0) == :summary_row

        td = _test_lines_table_data(; maximum_number_of_rows = 2, summary_rows = nothing)

        @test PrettyTables._next_row_section(td, :continuation_row, 0) == :table_footer

        # == Middle Cropping ===============================================================

        td = _test_lines_table_data(;
            num_rows = 10,
            maximum_number_of_rows = 4,
            vertical_crop_mode = :middle,
            row_group_labels = nothing,
        )

        @test PrettyTables._next_row_section(td, :data, 2) == :continuation_row
        @test PrettyTables._next_row_section(td, :continuation_row, 0) == :data
        @test PrettyTables._next_row_section(td, :data, 9) == :data
        @test PrettyTables._next_row_section(td, :data, 10) == :summary_row

        # The first row after the continuation row can have a row group label.
        td = _test_lines_table_data(;
            num_rows = 10,
            maximum_number_of_rows = 4,
            vertical_crop_mode = :middle,
            row_group_labels = [9 => "Row Group"],
        )

        @test PrettyTables._next_row_section(td, :continuation_row, 0) == :row_group_label
    end

    @testset "Horizontal Lines" verbose = true begin
        td           = _test_lines_table_data()
        td_no_header = _test_lines_table_data(; title = "", subtitle = "")

        hline(tf, rs, next_rs, i = 0; data = td) = PrettyTables._horizontal_line_after_row(
            PrettyTables.TableLines(tf, data), data, rs, next_rs, i
        )

        @testset "All Lines" begin
            tf = TextTableFormat(; @text__all_horizontal_lines)

            # Lines outside the ruled area.
            @test hline(tf, :table_header, :table_header) == :none
            @test hline(tf, :table_footer, :table_footer, 1) == :none
            @test hline(tf, :table_footer, :table_footer, 2) == :none
            @test hline(tf, :table_footer, :end_printing, 2) == :none

            # Lines at the beginning of the ruled area.
            @test hline(tf, :table_header, :column_labels) == :top_line
            @test hline(tf, :table_header, :data) == :top_line
            @test hline(tf, :table_header, :summary_row) == :top_line
            @test hline(tf, :table_header, :column_labels; data = td_no_header) == :top_line
            @test hline(tf, :table_header, :data; data = td_no_header) == :top_line
            @test hline(tf, :table_header, :row_group_label; data = td_no_header) ==
                :top_line

            # Column labels.
            @test hline(tf, :column_labels, :column_labels, 1) == :header_line
            @test hline(tf, :column_labels, :data, 2) == :header_line
            @test hline(tf, :column_labels, :row_group_label, 2) == :header_line
            @test hline(tf, :column_labels, :continuation_row, 2) == :header_line
            @test hline(tf, :column_labels, :summary_row, 2) == :header_line
            @test hline(tf, :column_labels, :table_footer, 2) == :bottom_line

            # Data section.
            @test hline(tf, :data, :data, 1) == :middle_line
            @test hline(tf, :data, :row_group_label, 1) == :middle_line
            @test hline(tf, :row_group_label, :data, 2) == :middle_line
            @test hline(tf, :data, :continuation_row, 2) == :middle_line
            @test hline(tf, :continuation_row, :data, 2) == :middle_line
            @test hline(tf, :continuation_row, :row_group_label, 2) == :middle_line
            @test hline(tf, :data, :summary_row) == :middle_line
            @test hline(tf, :continuation_row, :summary_row) == :middle_line
            @test hline(tf, :data, :table_footer) == :bottom_line
            @test hline(tf, :continuation_row, :table_footer) == :bottom_line
            @test hline(tf, :data, :end_printing) == :bottom_line

            # Summary rows.
            @test hline(tf, :summary_row, :summary_row, 1) == :none
            @test hline(tf, :summary_row, :table_footer, 2) == :bottom_line
            @test hline(tf, :summary_row, :end_printing, 2) == :bottom_line
        end

        @testset "No Lines" begin
            tf = TextTableFormat(; @text__no_horizontal_lines)

            for (rs, next_rs) in (
                (:table_header, :column_labels),
                (:column_labels, :column_labels),
                (:column_labels, :data),
                (:column_labels, :row_group_label),
                (:column_labels, :table_footer),
                (:data, :data),
                (:data, :row_group_label),
                (:row_group_label, :data),
                (:data, :continuation_row),
                (:continuation_row, :data),
                (:data, :summary_row),
                (:data, :table_footer),
                (:summary_row, :table_footer),
            )
                @test hline(tf, rs, next_rs, 1) == :none
            end
        end

        @testset "Lines at Data Rows" begin
            tf = TextTableFormat(;
                @text__no_horizontal_lines, horizontal_lines_at_data_rows = [1]
            )

            @test hline(tf, :data, :data, 1) == :middle_line
            @test hline(tf, :data, :data, 2) == :none
            @test hline(tf, :data, :row_group_label, 1) == :middle_line
            @test hline(tf, :data, :row_group_label, 2) == :none
            @test hline(tf, :continuation_row, :data, 1) == :middle_line
            @test hline(tf, :continuation_row, :data, 2) == :none

            # The line after a data row is owned by the row group label of the next data row.
            # Hence, it is not drawn if the continuation row is printed instead of the label.
            @test hline(tf, :data, :continuation_row, 1) == :none

            tf = TextTableFormat(;
                @text__no_horizontal_lines, horizontal_lines_at_data_rows = :all
            )

            @test hline(tf, :data, :continuation_row, 1) == :none
            @test hline(tf, :data, :continuation_row, 2) == :middle_line

            # The line after the last data row is only controlled by
            # `horizontal_line_after_data_rows`.
            tf = TextTableFormat(;
                @text__no_horizontal_lines, horizontal_lines_at_data_rows = :all
            )

            @test hline(tf, :data, :summary_row, 3) == :none
            @test hline(tf, :data, :table_footer, 3) == :none
            @test hline(tf, :continuation_row, :summary_row, 3) == :none
        end

        @testset "Lines Around the Row Group Labels" begin
            tf = TextTableFormat(;
                @text__no_horizontal_lines, horizontal_line_before_row_group_label = true
            )

            @test hline(tf, :column_labels, :row_group_label, 2) == :middle_line
            @test hline(tf, :data, :row_group_label, 1) == :middle_line
            @test hline(tf, :continuation_row, :row_group_label, 2) == :middle_line
            @test hline(tf, :row_group_label, :data, 2) == :none

            # The line after the column labels has precedence over the line before the row
            # group label.
            tf = TextTableFormat(;
                @text__no_horizontal_lines,
                horizontal_line_after_column_labels = true,
                horizontal_line_before_row_group_label = true,
            )

            @test hline(tf, :column_labels, :row_group_label, 2) == :header_line

            tf = TextTableFormat(;
                @text__no_horizontal_lines, horizontal_line_after_row_group_label = true
            )

            @test hline(tf, :row_group_label, :data, 2) == :middle_line
            @test hline(tf, :data, :row_group_label, 1) == :none
        end

        @testset "Lines Around the Summary Rows" begin
            tf = TextTableFormat(;
                @text__no_horizontal_lines, horizontal_line_before_summary_rows = true
            )

            @test hline(tf, :data, :summary_row) == :middle_line
            @test hline(tf, :continuation_row, :summary_row) == :middle_line
            @test hline(tf, :column_labels, :summary_row, 2) == :none
            @test hline(tf, :summary_row, :table_footer, 2) == :none

            tf = TextTableFormat(;
                @text__no_horizontal_lines, horizontal_line_after_data_rows = true
            )

            @test hline(tf, :data, :summary_row) == :middle_line
            @test hline(tf, :data, :table_footer) == :bottom_line
            @test hline(tf, :summary_row, :table_footer, 2) == :none

            tf = TextTableFormat(;
                @text__no_horizontal_lines, horizontal_line_after_summary_rows = true
            )

            @test hline(tf, :summary_row, :summary_row, 1) == :none
            @test hline(tf, :summary_row, :table_footer, 2) == :bottom_line
            @test hline(tf, :data, :summary_row) == :none
        end

        @testset "Lines at Column Labels" begin
            tf = TextTableFormat(;
                @text__no_horizontal_lines, horizontal_lines_at_column_labels = [1]
            )

            @test hline(tf, :column_labels, :column_labels, 1) == :header_line
            @test hline(tf, :column_labels, :data, 2) == :none

            tf = TextTableFormat(;
                @text__no_horizontal_lines, horizontal_line_after_column_labels = true
            )

            @test hline(tf, :column_labels, :column_labels, 1) == :none
            @test hline(tf, :column_labels, :data, 2) == :header_line
            @test hline(tf, :column_labels, :table_footer, 2) == :bottom_line
        end

        @testset "HTML Only Lines" begin
            tf = HtmlTableFormat(;
                horizontal_line_before_column_labels = true,
                horizontal_line_after_footnotes = true,
                horizontal_line_at_end = true,
            )

            @test hline(tf, :table_header, :column_labels) == :top_line
            @test hline(tf, :table_header, :data) == :top_line

            # The line before the first row of a table without a header is the line at the
            # beginning of the table.
            @test hline(tf, :table_header, :column_labels; data = td_no_header) == :none
            @test hline(tf, :data, :summary_row) == :none
            @test hline(tf, :data, :table_footer) == :bottom_line
            @test hline(tf, :continuation_row, :table_footer) == :bottom_line
            @test hline(tf, :summary_row, :table_footer, 2) == :bottom_line
            @test hline(tf, :column_labels, :table_footer, 2) == :bottom_line
            @test hline(tf, :table_footer, :table_footer, 1) == :none
            @test hline(tf, :table_footer, :table_footer, 2) == :middle_line
            @test hline(tf, :table_footer, :end_printing, 2) == :middle_line

            # The line at the end of the table requires a ruled area.
            @test hline(tf, :table_header, :table_footer) == :none

            tf = HtmlTableFormat(; horizontal_line_at_beginning = true)

            @test hline(tf, :table_header, :column_labels) == :none
            @test hline(tf, :table_header, :column_labels; data = td_no_header) == :top_line
            @test hline(tf, :table_header, :table_footer; data = td_no_header) == :none
        end

        @testset "Lines Between the Column Label Rows" begin
            lline(tf, rs, i) = PrettyTables._line_between_column_label_rows(
                PrettyTables.TableLines(tf, td), td, rs, i
            )

            tf = TextTableFormat(; @text__all_horizontal_lines)

            @test lline(tf, :column_labels, 1) == :header_line
            @test lline(tf, :column_labels, 2) == :none
            @test lline(tf, :data, 1) == :none

            tf = TextTableFormat(; horizontal_lines_at_column_labels = :none)

            @test lline(tf, :column_labels, 1) == :none

            tf = ExcelTableFormat(; horizontal_line_between_column_labels = true)

            @test lline(tf, :column_labels, 1) == :header_line
            @test lline(tf, :column_labels, 2) == :none

            tf = DocxTableFormat(; horizontal_line_between_column_labels = false)

            @test lline(tf, :column_labels, 1) == :none
        end
    end

    @testset "Vertical Lines" verbose = true begin
        vline(tf, td, column, j = 0) = PrettyTables._vertical_line_after_column(
            PrettyTables.TableLines(tf, td), td, column, j
        )

        @testset "All Lines" begin
            tf = TextTableFormat(; @text__all_vertical_lines)

            td = _test_lines_table_data()

            @test vline(tf, td, :row_number) == :center_line
            @test vline(tf, td, :row_label) == :center_line
            @test vline(tf, td, :data, 1) == :center_line
            @test vline(tf, td, :data, 3) == :center_line
            @test vline(tf, td, :data, 4) == :right_line
            @test vline(tf, td, :last) == :right_line

            # Horizontally cropped table.
            td = _test_lines_table_data(; maximum_number_of_columns = 2)

            @test vline(tf, td, :data, 1) == :center_line
            @test vline(tf, td, :data, 2) == :center_line
            @test vline(tf, td, :continuation) == :right_line
            @test vline(tf, td, :last) == :right_line
        end

        @testset "No Lines" begin
            tf = TextTableFormat(; @text__no_vertical_lines)

            for td in (
                _test_lines_table_data(),
                _test_lines_table_data(; maximum_number_of_columns = 2),
            )
                @test vline(tf, td, :row_number) == :none
                @test vline(tf, td, :row_label) == :none
                @test vline(tf, td, :data, 1) == :none
                @test vline(tf, td, :data, 2) == :none
                @test vline(tf, td, :data, 4) == :none
                @test vline(tf, td, :continuation) == :none
                @test vline(tf, td, :last) == :none
            end
        end

        @testset "Line After the Data Columns" begin
            # The line after the last printed data column is only controlled by
            # `vertical_line_after_data_columns`.
            tf = TextTableFormat(;
                vertical_lines_at_data_columns = :all,
                vertical_line_after_data_columns = false,
            )

            td = _test_lines_table_data()

            @test vline(tf, td, :data, 3) == :center_line
            @test vline(tf, td, :data, 4) == :none
            @test vline(tf, td, :last) == :none

            td = _test_lines_table_data(; maximum_number_of_columns = 2)

            @test vline(tf, td, :data, 1) == :center_line
            @test vline(tf, td, :data, 2) == :none
            @test vline(tf, td, :continuation) == :right_line
            @test vline(tf, td, :last) == :right_line

            tf = TextTableFormat(;
                vertical_lines_at_data_columns = [2],
                vertical_line_after_data_columns = true,
            )

            td = _test_lines_table_data()

            @test vline(tf, td, :data, 1) == :none
            @test vline(tf, td, :data, 2) == :center_line
            @test vline(tf, td, :data, 3) == :none
            @test vline(tf, td, :data, 4) == :right_line

            tf = TextTableFormat(;
                vertical_line_after_data_columns = true,
                vertical_line_after_continuation_column = false,
            )

            td = _test_lines_table_data(; maximum_number_of_columns = 2)

            @test vline(tf, td, :data, 2) == :center_line
            @test vline(tf, td, :continuation) == :none
            @test vline(tf, td, :last) == :none
        end

        @testset "Other Back Ends" begin
            td = _test_lines_table_data()

            for tf in (
                HtmlTableFormat(; @html__all_vertical_lines),
                LatexTableFormat(),
                TypstTableFormat(),
                ExcelTableFormat(),
                DocxTableFormat(),
            )
                @test vline(tf, td, :row_number) == :center_line
                @test vline(tf, td, :data, 1) == :center_line
                @test vline(tf, td, :data, 4) == :right_line
            end
        end

        @testset "Lines After the Cells" begin
            vcell(tf, td, action, j = 0) = PrettyTables._vertical_line_after_cell(
                PrettyTables.TableLines(tf, td), td, action, j
            )

            tf = TextTableFormat(; @text__all_vertical_lines)
            td = _test_lines_table_data()

            for action in (
                :row_number_label,
                :row_number,
                :row_number_vertical_continuation_cell,
                :summary_row_number,
                :stubhead_label,
                :row_label,
                :row_label_vertical_continuation_cell,
                :summary_row_label,
            )
                @test vcell(tf, td, action) == :center_line
            end

            for action in
                (:column_label, :data, :vertical_continuation_cell, :summary_row_cell)
                @test vcell(tf, td, action, 1) == :center_line
                @test vcell(tf, td, action, 4) == :right_line
            end

            @test vcell(tf, td, :row_group_label) == :right_line

            # Actions that do not emit a cell in a column.
            @test vcell(tf, td, :title) == :none
            @test vcell(tf, td, :footnote) == :none
            @test vcell(tf, td, :end_row) == :none

            # Horizontally cropped table.
            td = _test_lines_table_data(; maximum_number_of_columns = 2)

            @test vcell(tf, td, :data, 2) == :center_line
            @test vcell(tf, td, :horizontal_continuation_cell) == :right_line
            @test vcell(tf, td, :diagonal_continuation_cell) == :right_line
            @test vcell(tf, td, :row_group_label) == :right_line

            tf = TextTableFormat(;
                vertical_line_after_row_number_column = false,
                vertical_line_after_row_label_column = false,
                vertical_line_after_continuation_column = false,
            )

            @test vcell(tf, td, :row_number) == :none
            @test vcell(tf, td, :row_label) == :none
            @test vcell(tf, td, :horizontal_continuation_cell) == :none
            @test vcell(tf, td, :row_group_label) == :none
        end
    end
end
