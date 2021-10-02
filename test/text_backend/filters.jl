# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#    Tests of filters.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Filters" begin
    expected = """
┌─────┬────────┬────────┐
│ Row │ Col. 1 │ Col. 3 │
├─────┼────────┼────────┤
│   2 │      2 │    2.0 │
│   4 │      4 │    4.0 │
│   6 │      6 │    6.0 │
└─────┴────────┴────────┘
"""

    result = pretty_table(
        String,
        data;
        filters_row     = ((data,i) -> i%2 == 0,),
        filters_col     = ((data,i) -> i%2 == 1,),
        formatters      = ft_printf("%.1f", 3),
        show_row_number = true
    )
    @test result == expected

    expected = """
┌─────┬────────┬────────┐
│ Row │ Col. 1 │ Col. 3 │
├─────┼────────┼────────┤
│   2 │   2    │ 2.0    │
│   4 │   4    │ 4.0    │
│   6 │   6    │ 6.0    │
└─────┴────────┴────────┘
"""

    result = pretty_table(
        String,
        data;
        filters_row     = ((data,i) -> i%2 == 0,),
        filters_col     = ((data,i) -> i%2 == 1,),
        formatters      = ft_printf("%.1f", 3),
        show_row_number = true,
        alignment       = [:c, :l, :l, :c]
    )
    @test result == expected

    # No data after filtering
    # --------------------------------------------------------------------------

    result = pretty_table(
        String,
        data;
        filters_row     = ((data,i) -> false,),
        filters_col     = ((data,i) -> i % 2 == 1,),
        formatters      = ft_printf("%.1f", 3),
        show_row_number = true,
        alignment       = [:c, :l, :l, :c]
    )
    @test result == ""

    result = pretty_table(
        String,
        data;
        filters_row     = ((data,i) -> false,),
        filters_col     = ((data,i) -> i % 2 == 1,),
        formatters      = ft_printf("%.1f", 3),
        show_row_number = true,
        alignment       = [:c, :l, :l, :c],
        title           = "Empty"
    )
    @test result == "Empty\n"
end
