## Description #############################################################################
#
# Tests of row numbers.
#
############################################################################################

@testset "Show Row Number" begin
    expected = """
| **Row** | **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** |
|--------:|:-----------|-----------:|:----------:|-----------:|
| **1**   | 1          | false      | 1.0        | 1          |
| **2**   | 2          | true       | 2.0        | 2          |
| **3**   | 3          | false      | 3.0        | 3          |
| **4**   | 4          | true       | 4.0        | 4          |
| **5**   | 5          | false      | 5.0        | 5          |
| **6**   | 6          | true       | 6.0        | 6          |
"""
    result = pretty_table(
        String,
        data;
        alignment = [:l, :r, :c, :r],
        backend = Val(:markdown),
        show_row_number = true
    )

    @test result == expected

    expected = """
| **Row number** | **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** |
|---------------:|:-----------|-----------:|:----------:|-----------:|
| **1**          | 1          | false      | 1.0        | 1          |
| **2**          | 2          | true       | 2.0        | 2          |
| **3**          | 3          | false      | 3.0        | 3          |
| **4**          | 4          | true       | 4.0        | 4          |
| **5**          | 5          | false      | 5.0        | 5          |
| **6**          | 6          | true       | 6.0        | 6          |
"""
    result = pretty_table(
        String,
        data;
        alignment = [:l, :r, :c, :r],
        backend = Val(:markdown),
        row_number_column_title = "Row number",
        show_row_number = true
    )

    @test result == expected
end

