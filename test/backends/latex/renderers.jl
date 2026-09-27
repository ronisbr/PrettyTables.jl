## Description #############################################################################
#
# LaTeX Back End: Test renderers.
#
############################################################################################

@testset "Renderers" verbose = true begin
    matrix = ['a' :a "a" missing nothing]

    @testset ":print" begin
        expected = """
\\begin{tabular}{|r|r|r|r|r|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} & \\textbf{Col. 5} \\\\
  \\hline
  a & a & a & missing & nothing \\\\
  \\hline
\\end{tabular}
"""
        result = pretty_table(String, matrix; backend = :latex)

        @test result == expected
    end

    @testset ":show" begin
        expected = """
\\begin{tabular}{|r|r|r|r|r|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} & \\textbf{Col. 5} \\\\
  \\hline
  'a' & :a & a & missing & nothing \\\\
  \\hline
\\end{tabular}
"""

        result = pretty_table(String, matrix; backend = :latex, renderer = :show)

        @test result == expected
    end
end

@testset "MIME Representation With the Show Renderer" begin
    # With the renderer `:show`, the Latex representation of a cell must be emitted without
    # escaping, whereas the text representation must be escaped.
    struct RendererMimeCellLatex end
    Base.show(io::IO, ::MIME"text/latex", ::RendererMimeCellLatex) = print(io, "\\textbf{foo}")
    Base.show(io::IO, ::RendererMimeCellLatex) = print(io, "FooCell")

    result = pretty_table(
        String, [RendererMimeCellLatex();;]; backend = :latex, renderer = :show
    )
    @test occursin("\\textbf{foo}", result)

    result = pretty_table(
        String, [RendererMimeCellLatex();;]; backend = :latex, renderer = :print
    )
    @test occursin("FooCell", result)
end
