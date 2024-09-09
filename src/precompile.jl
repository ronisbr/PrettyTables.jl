## Description #############################################################################
#
# Precompilation.
#
############################################################################################

import PrecompileTools

PrecompileTools.@setup_workload begin
    types = [
        Int8(1),
        Int16(1),
        Int32(1),
        Int64(1),
        UInt8(1),
        UInt16(1),
        UInt32(1),
        UInt64(1),
        Float16(1),
        Float32(1),
        Float64(1),
        Bool(1),
        "S",
        'C',
        Int8[1, 2, 3],
        Int16[1, 2, 3],
        Int32[1, 2, 3],
        Int64[1, 2, 3],
        UInt8[1, 2, 3],
        UInt16[1, 2, 3],
        UInt32[1, 2, 3],
        UInt64[1, 2, 3],
        Float16[1, 2, 3],
        Float32[1, 2, 3],
        Float64[1, 2, 3],
        Bool[0, 1],
        ["S", "S"],
        ['C', 'C'],
        Int8[1 2; 3 4],
        Int16[1 2; 3 4],
        Int32[1 2; 3 4],
        Int64[1 2; 3 4],
        UInt8[1 2; 3 4],
        UInt16[1 2; 3 4],
        UInt32[1 2; 3 4],
        UInt64[1 2; 3 4],
        Float16[1 2; 3 4],
        Float32[1 2; 3 4],
        Float64[1 2; 3 4],
        Bool[0 1; 0 1],
        ["S" "S"; "S" "S"],
        ['C' 'C'; 'C' 'C']
    ]

    # A named tuple is compliant with Table.jl.
    table = (a = 1:1:10, b = ["S" for i = 1:10], c = ['C' for i = 1:10])

    dict = Dict(:a => (1, 1), :b => (2, 2), :c => (3, 3))

    # We will redirect the `stdout` and `stdin` so that we can execute the pager and input
    # some commands without making visible changes to the user.
    old_stdout = Base.stdout
    new_stdout = redirect_stdout(devnull)

    # In HTML, we use `display` if we are rendering to `stdout`. However, even if we are
    # redirecting it, the text is still begin shown in the display. Thus, we create a buffer
    # for those cases.
    html_buf = IOBuffer()

    PrecompileTools.@compile_workload begin
        # == Input: Arrays =================================================================

        matrix = randn(10, 10)

        # -- HTML --------------------------------------------------------------------------

        pretty_table(html_buf, matrix; backend = :html)

        pretty_table(
            html_buf,
            matrix;
            backend = :html,
            highlighters = [
                HtmlHighlighter((data, i, j) -> i == 1, ["font-weight" => "bold"])
            ]
        )

        pretty_table(html_buf, types; backend = :html)

        # -- Markdown ----------------------------------------------------------------------

        pretty_table(matrix; backend = :markdown)

        pretty_table(
            matrix;
            backend = :markdown,
            highlighters = [
                MarkdownHighlighter((data, i, j) -> i == 1, MarkdownDecoration(bold = :true))
            ]
        )

        pretty_table(types; backend = :markdown)

        # == Input: Tables.jl ==============================================================

        pretty_table(html_buf, table; backend = :html)
        pretty_table(table; backend = :markdown)
    end

    # Restore stdout.
    redirect_stdout(old_stdout)
end
