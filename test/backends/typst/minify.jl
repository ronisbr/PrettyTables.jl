## Description #############################################################################
#
# HTML Back End: Test with minification.
#
############################################################################################

@testset "Minify" begin
    matrix = [1 2]

    expected = """
<table><thead><tr class = "columnLabelRow"><th style = "font-weight: bold; text-align: right;">Col. 1</th><th style = "font-weight: bold; text-align: right;">Col. 2</th></tr></thead><tbody><tr class = "dataRow"><td style = "text-align: right;">1</td><td style = "text-align: right;">2</td></tr></tbody></table>"""

    result = pretty_table(String, matrix; backend = :html, minify = true)

    @test result == expected
end
