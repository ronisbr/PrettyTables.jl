## Description #############################################################################
#
# Markdown Back End: Test renderers.
#
############################################################################################

@testset "Renderers" verbose = true begin
    matrix = ['a' :a "a" missing nothing]

    @testset ":print" begin
        expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** | **Col. 5** |
|-----------:|-----------:|-----------:|-----------:|-----------:|
|          a |          a |          a |    missing |    nothing |
"""

        result = pretty_table(
            String,
            matrix;
            backend = :markdown
        )

        @test result == expected
    end

    @testset ":show" begin
        expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** | **Col. 5** |
|-----------:|-----------:|-----------:|-----------:|-----------:|
|        'a' |         :a |          a |    missing |    nothing |
"""

        result = pretty_table(
            String,
            matrix;
            backend = :markdown,
            renderer = :show
        )

        @test result == expected
    end
end

