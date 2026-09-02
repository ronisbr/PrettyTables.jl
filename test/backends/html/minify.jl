## Description #############################################################################
#
# HTML Back End: Test with minification.
#
############################################################################################

@testset "Minify" begin
    matrix = [1 2]

    expected = """
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;"><colgroup><col style = "border-left: 2px solid black; border-right: 1px solid black;"><col style = "border-right: 2px solid black;"></colgroup><thead><tr class = "columnLabelRow" style = "border-bottom: 1px solid black;"><th style = "font-weight: bold; text-align: right;">Col. 1</th><th style = "font-weight: bold; text-align: right;">Col. 2</th></tr></thead><tbody><tr class = "dataRow" style = "border-bottom: 1px solid black;"><td style = "text-align: right;">1</td><td style = "text-align: right;">2</td></tr></tbody></table>"""

    result = pretty_table(String, matrix; backend = :html, minify = true)

    @test result == expected
end
