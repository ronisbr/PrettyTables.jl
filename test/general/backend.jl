# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Tests of back-end interface.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Back-end auto selection" begin
    data = rand(3,3)

    # Text
    # ==========================================================================

    auto   = pretty_table(String, data, tf = tf_unicode)
    manual = pretty_table(String, data, tf = tf_unicode, backend = :text)

    @test auto == manual

    # HTML
    # ==========================================================================

    auto   = pretty_table(String, data, tf = tf_html_simple)
    manual = pretty_table(String, data, tf = tf_html_simple, backend = :html)

    @test auto == manual

    # LaTeX
    # ==========================================================================

    auto   = pretty_table(String, data, tf = tf_latex_default)
    manual = pretty_table(String, data, tf = tf_latex_default, backend = :latex)

    @test auto == manual

    # Error
    # ==========================================================================

    @test_throws TypeError pretty_table(data, tf = [])
end
