## Description #############################################################################
#
# Tests of issues.
#
############################################################################################

struct SimpleTable{T}
    data::Matrix{T}
end

Tables.istable(::SimpleTable) = true
Tables.columnaccess(::SimpleTable) = true
Tables.columnnames(x::SimpleTable) = [Symbol(i) for i = 1:size(x.data, 2)]
Tables.columns(x::SimpleTable) = x
Tables.getcolumn(x::SimpleTable, i::Symbol) = tuple(x.data[parse(Int,string(i)),:]...)

table = SimpleTable([10.0^(i+j) for i in 1:10, j in 1:5])

struct NoTable end

Tables.istable(::NoTable) = true
Tables.rowaccess(::NoTable) = true
Tables.rows(t::NoTable) = t
Base.length(t) = 0

notable = NoTable()

@testset "Issue #90 - Tables.jl Returning Tuples as Columns" begin
    expected = """
┌──────────┬──────────┬──────────┬──────────┬────────┐
│        1 │        2 │        3 │        4 │      5 │
├──────────┼──────────┼──────────┼──────────┼────────┤
│    100.0 │   1000.0 │  10000.0 │ 100000.0 │  1.0e6 │
│   1000.0 │  10000.0 │ 100000.0 │    1.0e6 │  1.0e7 │
│  10000.0 │ 100000.0 │    1.0e6 │    1.0e7 │  1.0e8 │
│ 100000.0 │    1.0e6 │    1.0e7 │    1.0e8 │  1.0e9 │
│    1.0e6 │    1.0e7 │    1.0e8 │    1.0e9 │ 1.0e10 │
└──────────┴──────────┴──────────┴──────────┴────────┘
"""

    result = pretty_table(String, table)
    @test result == expected
end

@testset "Issue #156 - Print Empty Tables" begin
    # == Table with no rows ================================================================

    table  = rand(0, 4)
    header = ([1, 2, 3, 4], [5, 6, 7, 8])

    # -- Text back end ---------------------------------------------------------------------

    expected = """
┌───┬───┬───┬───┐
│ 1 │ 2 │ 3 │ 4 │
│ 5 │ 6 │ 7 │ 8 │
└───┴───┴───┴───┘
"""

    result = pretty_table(
        String,
        table;
        header = header
    )

    @test expected == result

    expected = """
 1  2  3  4
 5  6  7  8
────────────
"""

    result = pretty_table(
        String,
        table;
        hlines = [:header],
        header = header,
        vlines = :none
    )

    @test expected == result

    expected = """
 1  2  3  4
 5  6  7  8
────────────
"""

    result = pretty_table(
        String,
        table;
        hlines = [:end],
        header = header,
        vlines = :none
    )

    @test expected == result

    # -- HTML Back End ---------------------------------------------------------------------

    expected = """
<table>
  <thead>
    <tr class = "header">
      <th style = "text-align: right;">1</th>
      <th style = "text-align: right;">2</th>
      <th style = "text-align: right;">3</th>
      <th style = "text-align: right;">4</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th style = "text-align: right;">5</th>
      <th style = "text-align: right;">6</th>
      <th style = "text-align: right;">7</th>
      <th style = "text-align: right;">8</th>
    </tr>
  </thead>
  <tbody>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        table;
        backend = Val(:html),
        header = header
    )

    @test expected == result

    expected = """
"""

    # -- LaTeX Back End --------------------------------------------------------------------

    expected = """
\\begin{tabular}{rrrr}
  \\toprule
  \\textbf{1} & \\textbf{2} & \\textbf{3} & \\textbf{4} \\\\
  \\texttt{5} & \\texttt{6} & \\texttt{7} & \\texttt{8} \\\\\\bottomrule
\\end{tabular}
"""

    result = pretty_table(
        String,
        table;
        header = header,
        tf = tf_latex_booktabs
    )

    @test expected == result

    expected = """
\\begin{tabular}{rrrr}
  \\textbf{1} & \\textbf{2} & \\textbf{3} & \\textbf{4} \\\\
  \\texttt{5} & \\texttt{6} & \\texttt{7} & \\texttt{8} \\\\\\bottomrule
\\end{tabular}
"""

    result = pretty_table(
        String,
        table;
        hlines = [:header],
        header = header,
        vlines = :none,
        tf = tf_latex_booktabs
    )

    @test expected == result

    expected = """
\\begin{tabular}{rrrr}
  \\textbf{1} & \\textbf{2} & \\textbf{3} & \\textbf{4} \\\\
  \\texttt{5} & \\texttt{6} & \\texttt{7} & \\texttt{8} \\\\\\bottomrule
\\end{tabular}
"""

    result = pretty_table(
        String,
        table;
        hlines = [:end],
        header = header,
        vlines = :none,
        tf = tf_latex_booktabs
    )

    @test expected == result

    # == Table with no Columns =============================================================

    table = rand(4, 0)
    row_labels = [1, 2, 3, 4]

    # -- Text Back End ---------------------------------------------------------------------

    expected = """
┌───────────┐
│ Row label │
├───────────┤
│         1 │
│         2 │
│         3 │
│         4 │
└───────────┘
"""

    result = pretty_table(
        String,
        table;
        row_label_column_title = "Row label",
        row_labels = row_labels,
    )

    @test expected == result

    expected = """
 Row label │
         1 │
         2 │
         3 │
         4 │
"""

    result = pretty_table(
        String,
        table;
        hlines = :none,
        row_label_column_title = "Row label",
        row_labels = row_labels,
        vlines = [1]
    )

    @test expected == result

    expected = """
 Row label
         1
         2
         3
         4
"""

    result = pretty_table(
        String,
        table;
        hlines = :none,
        row_label_column_title = "Row label",
        row_labels = row_labels,
        vlines = :none
    )

    @test expected == result

    # -- HTML Back End ---------------------------------------------------------------------

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th class = "rowLabel" style = "font-weight: bold; text-align: right;">Row label</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class = "rowLabel" style = "font-weight: bold; text-align: right;">1</td>
    </tr>
    <tr>
      <td class = "rowLabel" style = "font-weight: bold; text-align: right;">2</td>
    </tr>
    <tr>
      <td class = "rowLabel" style = "font-weight: bold; text-align: right;">3</td>
    </tr>
    <tr>
      <td class = "rowLabel" style = "font-weight: bold; text-align: right;">4</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        table;
        backend = Val(:html),
        row_label_column_title = "Row label",
        row_labels = row_labels,
    )

    @test expected == result


    # -- LaTeX Back End --------------------------------------------------------------------

    expected = """
\\begin{tabular}{r}
  \\hline
  \\textbf{Row label} \\\\\\hline
  1 \\\\
  2 \\\\
  3 \\\\
  4 \\\\\\hline
\\end{tabular}
"""

    result = pretty_table(
        String,
        table;
        backend = Val(:latex),
        row_label_column_title = "Row label",
        row_labels = row_labels,
    )

    @test expected == result

    expected = """
\\begin{tabular}{r|}
  \\hline
  \\textbf{Row label} \\\\\\hline
  1 \\\\
  2 \\\\
  3 \\\\
  4 \\\\\\hline
\\end{tabular}
"""

    result = pretty_table(
        String,
        table;
        backend = Val(:latex),
        row_label_column_title = "Row label",
        row_labels = row_labels,
        vlines = [1],
    )

    @test expected == result

    expected = """
\\begin{tabular}{r|}
  \\hline
  \\textbf{Row label} \\\\\\hline
  1 \\\\
  2 \\\\
  3 \\\\
  4 \\\\\\hline
\\end{tabular}
"""

    result = pretty_table(
        String,
        table;
        backend = Val(:latex),
        row_label_column_title = "Row label",
        row_labels = row_labels,
        vlines = [:end]
    )

    # == Table with no Rows and Columns ====================================================

    table = rand(0, 0)

    # -- Text Back End ---------------------------------------------------------------------

    expected = """
Title
"""

    result = pretty_table(
        String,
        table;
        title = "Title"
    )

    @test expected == result

    # -- HTML Back End ---------------------------------------------------------------------

    expected = """
<table>
  <caption style = "text-align: left;">Title</caption>
</table>
"""

    result = pretty_table(
        String,
        table;
        backend = Val(:html),
        title = "Title"
    )

    @test expected == result

    # -- LaTeX Back End --------------------------------------------------------------------

    expected = """
\\begin{table}
  \\caption{Title}
  \\begin{tabular}{}
  \\end{tabular}
\\end{table}
"""

    result = pretty_table(
        String,
        table;
        backend = Val(:latex),
        title = "Title",
        wrap_table = true
    )

    @test expected == result
end

@testset "Issue #156 - Empty Tables.jl" begin
    table = @NamedTuple{x::Int, y::Int}[]

    expected = """
┌───────┬───────┐
│     x │     y │
│ Int64 │ Int64 │
└───────┴───────┘
"""

    result = pretty_table(String, table)

    @test expected == result

    expected = ""

    result = pretty_table(String, notable)

    @test expected == result
end

@testset "Issue #212 - Header Is Ignored for Dict" begin
    dict = Dict(:a => 1, :b => 2)

    expected = """
┌────────┬────────┐
│   Keys │ Values │
│ Symbol │  Int64 │
├────────┼────────┤
│      a │      1 │
│      b │      2 │
└────────┴────────┘
"""

    result = pretty_table(String, dict; sortkeys = true)
    @test result == expected

    expected = """
┌───┬───┐
│ A │ B │
├───┼───┤
│ a │ 1 │
│ b │ 2 │
└───┴───┘
"""

    result = pretty_table(String, dict; header = ["A", "B"], sortkeys = true)
    @test result == expected

    expected = """
┌───┬───┐
│ A │ B │
│ C │ D │
├───┼───┤
│ a │ 1 │
│ b │ 2 │
└───┴───┘
"""

    result = pretty_table(
        String,
        dict;
        header = (["A", "B"], ["C", "D"]),
        sortkeys = true
    )
    @test result == expected
end

@testset "Issue #220 - Matrix with NamedTuples" begin
    table = [
        (a = 1, b = 2) (a = 3, b = 4)
        (a = 5, b = 6) (a = 7, b = 8)
    ]

    expected = """
┌───┬───┐
│ a │ b │
├───┼───┤
│ 1 │ 2 │
│ 5 │ 6 │
│ 3 │ 4 │
│ 7 │ 8 │
└───┴───┘
"""

    result = pretty_table(String, table)
    @test result == expected
end
