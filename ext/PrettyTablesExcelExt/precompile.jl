## Description #############################################################################
#
# Precompilation for the Excel back end.
#
# The Excel back end lives in this extension. Hence, it is not covered by the workload in
# `src/precompile.jl`, meaning that without this file the first Excel export would be fully
# cold.
#
############################################################################################

import PrecompileTools

PrecompileTools.@setup_workload begin
    matrix = ones(10, 10)

    # A named tuple is compliant with Tables.jl.
    table = (a = 1:1:10, b = ["S" for i in 1:10], c = ['C' for i in 1:10])

    PrecompileTools.@compile_workload begin
        # Passing `filename = nothing` keeps the workbook in memory, so the workload does not
        # touch the file system.
        pretty_table(matrix; backend = :excel, filename = nothing)

        pretty_table(
            matrix;
            backend = :excel,
            filename = nothing,
            highlighters = [
                ExcelHighlighter((data, i, j) -> i == 1, ["bold" => "true"]),
            ],
        )

        pretty_table(table; backend = :excel, filename = nothing)

        # The backend-agnostic table format and style must also be exercised so that the
        # first export using them is not fully cold.
        pretty_table(
            matrix;
            backend = :excel,
            filename = nothing,
            table_format = TableFormat(; horizontal_lines_at_data_rows = :all),
            style = TableStyle(; title = Face(; weight = :bold)),
        )

        @static if VERSION >= v"1.11"
            # Styled strings are converted to Excel's rich text format.
            pretty_table(
                [styled"{bold:Bold} and {red:red}" for i in 1:10, j in 1:2];
                backend = :excel,
                filename = nothing,
            )
        end
    end
end
