## Description #############################################################################
#
# Tests of offset arrays.
#
############################################################################################

@testset "Default Printing" begin
    expected = """
| **Col. -2** | **Col. -1** | **Col. 0** | **Col. 1** |
|------------:|------------:|-----------:|-----------:|
| 1           | false       | 1.0        | 1          |
| 2           | true        | 2.0        | 2          |
| 3           | false       | 3.0        | 3          |
| 4           | true        | 4.0        | 4          |
| 5           | false       | 5.0        | 5          |
| 6           | true        | 6.0        | 6          |
"""

    result = pretty_table(
        String,
        odata;
        backend = Val(:markdown)
    )
    @test result == expected

    expected = """
| **1** | **2** | **3** | **4** |
|------:|------:|------:|------:|
| 1     | false | 1.0   | 1     |
| 2     | true  | 2.0   | 2     |
| 3     | false | 3.0   | 3     |
| 4     | true  | 4.0   | 4     |
| 5     | false | 5.0   | 5     |
| 6     | true  | 6.0   | 6     |
"""

    result = pretty_table(
        String,
        odata; 
        backend = Val(:markdown),
        header = 1:1:4
    )
    @test result == expected

    result = pretty_table(
        String,
        odata;
        backend = Val(:markdown),
        header = OffsetArray(1:1:4, -5:-2)
    )
    @test result == expected
end

@testset "Formatters" begin
    ft_row = (v, i, j) -> (i == -3) ? 0 : v

    expected = """
| **Col. -2** | **Col. -1** | **Col. 0** | **Col. 1** |
|------------:|------------:|-----------:|-----------:|
| 1           | 0.0         | 1.0        | 1          |
| 0           | 0           | 0          | 0          |
| 3           | 0.0         | 3.0        | 3          |
| 4           | 1.0         | 4.0        | 4          |
| 5           | 0.0         | 5.0        | 5          |
| 6           | 1.0         | 6.0        | 6          |
"""

    result = pretty_table(
        String,
        odata;
        backend = Val(:markdown),
        formatters = (ft_round(2, [-1]), ft_row)
    )
    @test result == expected
end

@testset "Highlighters" begin
    expected = """
| **Col. -2** | **Col. -1** | **Col. 0** | **Col. 1** |
|------------:|------------:|-----------:|-----------:|
| 1           | false       | 1.0        | **1**      |
| 2           | true        | 2.0        | **2**      |
| 3           | false       | 3.0        | **3**      |
| **4**       | **true**    | **4.0**    | **4**      |
| 5           | false       | 5.0        | **5**      |
| 6           | true        | 6.0        | **6**      |
"""

    c = MarkdownDecoration(bold = true)
    result = pretty_table(
        String,
        odata;
        backend = Val(:markdown),
        highlighters = (
            hl_row(-1, c),
            hl_col(1, c)
        )
    )
end

@testset "Row Labels" begin
    expected = """
| **Label** | **Col. -2** | **Col. -1** | **Col. 0** | **Col. 1** |
|----------:|------------:|------------:|-----------:|-----------:|
| 1         | 1           | false       | 1.0        | 1          |
| 3         | 2           | true        | 2.0        | 2          |
| 5         | 3           | false       | 3.0        | 3          |
| 7         | 4           | true        | 4.0        | 4          |
| 9         | 5           | false       | 5.0        | 5          |
| 11        | 6           | true        | 6.0        | 6          |
"""

    result = pretty_table(
        String,
        odata;
        backend = Val(:markdown),
        row_labels = 1:2:12,
        row_label_column_title = "Label"
    )
    @test result == expected

    result = pretty_table(
        String,
        odata;
        backend = Val(:markdown),
        row_labels = OffsetArray(1:2:12, -5:0),
        row_label_column_title = "Label"
    )
    @test result == expected
end

@testset "Row Numbers" begin
    expected = """
| **Row** | **Col. -2** | **Col. -1** | **Col. 0** | **Col. 1** |
|--------:|------------:|------------:|-----------:|-----------:|
| **-4**  | 1           | false       | 1.0        | 1          |
| **-3**  | 2           | true        | 2.0        | 2          |
| **-2**  | 3           | false       | 3.0        | 3          |
| **-1**  | 4           | true        | 4.0        | 4          |
| **0**   | 5           | false       | 5.0        | 5          |
| **1**   | 6           | true        | 6.0        | 6          |
"""

    result = pretty_table(
        String,
        odata;
        backend = Val(:markdown),
        show_row_number = true
    )
    @test result == expected
end

