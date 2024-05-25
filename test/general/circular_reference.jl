## Description #############################################################################
#
# Tests related with circular reference.
#
############################################################################################

struct CircularRef
    A1::Vector{Any}
    A2::Vector{Any}
    A3::Vector{Any}
    A4::Vector{Any}
end

Tables.istable(x::CircularRef) = true
Tables.columnaccess(::CircularRef) = true
Tables.columnnames(x::CircularRef) = [:A1, :A2, :A3, :A4]
Tables.columns(x::CircularRef) = x

function Base.show(io::IO, cf::CircularRef)
    context = IOContext(io, :color => false)
    pretty_table(context, cf; renderer = :show)
    return nothing
end

function Base.show(io::IO, ::MIME"text/plain", cf::CircularRef)
    context = IOContext(io, :color => false)
    pretty_table(
        context,
        cf;
        linebreaks = true,
        renderer = :show
    )
    return nothing
end

function Base.show(io::IO, ::MIME"text/html", cf::CircularRef)
    pretty_table(io, cf; backend = Val(:html), renderer = :show)
    return nothing
end

function Base.show(io::IO, ::MIME"text/latex", cf::CircularRef)
    pretty_table(io, cf; backend = Val(:latex), renderer = :show)
    return nothing
end

@testset "Circular Reference" begin
    a = CircularRef([1, 1], [2, 2], [3, 3], [4, 4])
    a.A1[1] = a

    # == Text Back end =====================================================================

    expected = """
┌──────────────────────────┬────┬────┬────┐
│                       A1 │ A2 │ A3 │ A4 │
├──────────────────────────┼────┼────┼────┤
│ #= circular reference =# │  2 │  3 │  4 │
│                        1 │  2 │  3 │  4 │
└──────────────────────────┴────┴────┴────┘
"""

    result = sprint(show, a)

    @test expected == result

    # == HTML Back End =====================================================================

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">A1</th>
      <th style = "text-align: right;">A2</th>
      <th style = "text-align: right;">A3</th>
      <th style = "text-align: right;">A4</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">#= circular reference =#</td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">4</td>
    </tr>
    <tr>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">4</td>
    </tr>
  </tbody>
</table>
"""

    result = sprint(show, "text/html", a)

    @test expected == result

    # == Latex Back End ====================================================================

    expected = """
\\begin{tabular}{rrrr}
  \\hline
  \\textbf{A1} & \\textbf{A2} & \\textbf{A3} & \\textbf{A4} \\\\\\hline
  \\#= circular reference =\\# & 2 & 3 & 4 \\\\
  1 & 2 & 3 & 4 \\\\\\hline
\\end{tabular}
"""

    result = sprint(show, "text/latex", a)

    @test expected == result
end

@testset "Circular Reference with Higher Degree" begin
    a = CircularRef([1,   1  ], [2,   2],   [3,   3],   [4,   4])
    b = CircularRef([1.1, 1.1], [2.1, 2.1], [3.1, 3.1], [4.1, 4.1])

    b.A1[1] = a
    a.A1[1] = b

    # == Text Back End =====================================================================

    expected = """
┌─────────────────────────────────────────────┬─────┬─────┬─────┐
│                                          A1 │  A2 │  A3 │  A4 │
├─────────────────────────────────────────────┼─────┼─────┼─────┤
│ ┌──────────────────────────┬────┬────┬────┐ │ 2.1 │ 3.1 │ 4.1 │
│ │                       A1 │ A2 │ A3 │ A4 │ │     │     │     │
│ ├──────────────────────────┼────┼────┼────┤ │     │     │     │
│ │ #= circular reference =# │  2 │  3 │  4 │ │     │     │     │
│ │                        1 │  2 │  3 │  4 │ │     │     │     │
│ └──────────────────────────┴────┴────┴────┘ │     │     │     │
│                                             │     │     │     │
│                                         1.1 │ 2.1 │ 3.1 │ 4.1 │
└─────────────────────────────────────────────┴─────┴─────┴─────┘
"""

    result = sprint(show, "text/plain", b)
    @test expected == result
end
