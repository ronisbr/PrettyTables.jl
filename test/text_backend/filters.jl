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
        column_filters  = ((data, i) -> i % 2 == 1,),
        formatters      = ft_printf("%.1f", 3),
        row_filters     = ((data, i) -> i % 2 == 0,),
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
        alignment       = [:c, :l, :l, :c],
        column_filters  = ((data, i) -> i % 2 == 1,),
        formatters      = ft_printf("%.1f", 3),
        show_row_number = true,
        row_filters     = ((data, i) -> i % 2 == 0,)
    )
    @test result == expected

    # No data after filtering
    # --------------------------------------------------------------------------

    result = pretty_table(
        String,
        data;
        alignment       = [:c, :l, :l, :c],
        column_filters  = ((data, i) -> i % 2 == 1,),
        formatters      = ft_printf("%.1f", 3),
        show_row_number = true,
        row_filters     = ((data, i) -> false,)
    )
    @test result == ""

    result = pretty_table(
        String,
        data;
        alignment       = [:c, :l, :l, :c],
        column_filters  = ((data, i) -> i % 2 == 1,),
        formatters      = ft_printf("%.1f", 3),
        row_filters     = ((data, i) -> false,),
        show_row_number = true,
        title           = "Empty"
    )
    @test result == "Empty\n"
end
