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
    end
end
