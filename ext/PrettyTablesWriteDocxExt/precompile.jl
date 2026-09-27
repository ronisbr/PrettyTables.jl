## Description #############################################################################
#
# Precompilation for the Word back end.
#
# The Word back end lives in this extension. Hence, it is not covered by the workload in
# `src/precompile.jl`, meaning that without this file the first Word export would be fully
# cold.
#
############################################################################################

import PrecompileTools

PrecompileTools.@setup_workload begin
    matrix = ones(10, 10)

    # A named tuple is compliant with Tables.jl.
    table = (a = 1:1:10, b = ["S" for i in 1:10], c = ['C' for i in 1:10])

    PrecompileTools.@compile_workload begin
        # Passing `filename = nothing` returns the table object, so the workload does not
        # touch the file system.
        pretty_table(matrix; backend = :docx, filename = nothing)

        pretty_table(
            matrix;
            backend = :docx,
            filename = nothing,
            highlighters = [
                DocxHighlighter((data, i, j) -> i == 1, ["bold" => "true"]),
            ],
        )

        pretty_table(table; backend = :docx, filename = nothing)

        # The methods that return the WriteDocx objects are the main entry points to embed
        # the table in a larger document.
        pretty_table(W.Table, matrix)
        pretty_table(W.Document, matrix)

        # The backend-agnostic table format and style must also be exercised so that the
        # first export using them is not fully cold.
        pretty_table(
            matrix;
            backend = :docx,
            filename = nothing,
            table_format = TableFormat(; horizontal_lines_at_data_rows = :all),
            style = TableStyle(; title = Face(; weight = :bold)),
        )

        @static if VERSION >= v"1.11"
            # Each face region of a styled string becomes a text run.
            pretty_table(
                [styled"{bold:Bold} and {red:red}" for i in 1:10, j in 1:2];
                backend = :docx,
                filename = nothing,
            )
        end
    end
end
