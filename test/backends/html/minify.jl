## Description #############################################################################
#
# HTML Back End: Test with minification.
#
############################################################################################

@testset "Minify" begin
    matrix = [1 2]

    expected = """
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;"><thead><tr class = "columnLabelRow"><th style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Col. 1</th><th style = "border-bottom: 1px solid black; border-right: 2px solid black; font-weight: bold; text-align: right;">Col. 2</th></tr></thead><tbody><tr class = "dataRow"><td style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; text-align: right;">1</td><td style = "border-bottom: 1px solid black; border-right: 2px solid black; text-align: right;">2</td></tr></tbody></table>"""

    result = pretty_table(String, matrix; backend = :html, minify = true)

    @test result == expected
end
