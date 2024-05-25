## Description #############################################################################
#
# Tests of default printing.
#
############################################################################################

@testset "Default" begin
    expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** |
|-----------:|-----------:|-----------:|-----------:|
| 1          | false      | 1.0        | 1          |
| 2          | true       | 2.0        | 2          |
| 3          | false      | 3.0        | 3          |
| 4          | true       | 4.0        | 4          |
| 5          | false      | 5.0        | 5          |
| 6          | true       | 6.0        | 6          |
"""

    result = pretty_table(
        String,
        data,
        backend = Val(:markdown)
    )
    @test result == expected
end

@testset "Dictionaries" begin
    dict = Dict{Int64, String}(
        1 => "Jan",
        2 => "Feb",
        3 => "Mar",
        4 => "Apr",
        5 => "May",
        6 => "Jun"
    )

    expected = """
| **Keys**<br>`Int64` | **Values**<br>`String` |
|--------------------:|-----------------------:|
| 1                   | Jan                    |
| 2                   | Feb                    |
| 3                   | Mar                    |
| 4                   | Apr                    |
| 5                   | May                    |
| 6                   | Jun                    |
"""

    result = pretty_table(
        String,
        dict;
        backend = Val(:markdown),
        sortkeys = true,
    )

    @test result == expected
end

@testset "Vectors" begin

    vec = 0:1:5

    expected = """
| **Col. 1** |
|-----------:|
| 0          |
| 1          |
| 2          |
| 3          |
| 4          |
| 5          |
"""

    result = pretty_table(
        String,
        vec,
        backend = Val(:markdown)
    )
    @test result == expected

    expected = """
| **Row** | **Col. 1** |
|--------:|:----------:|
| **1**   | 0          |
| **2**   | 1          |
| **3**   | 2          |
| **4**   | 3          |
| **5**   | 4          |
| **6**   | 5          |
"""

    result = pretty_table(
        String,
        vec;
        alignment = :c,
        backend = Val(:markdown),
        show_row_number = true,
    )

    @test result == expected

    expected = """
| **A**<br>`B`<br>`C`<br>`D` |
|---------------------------:|
| 0                          |
| 1                          |
| 2                          |
| 3                          |
| 4                          |
| 5                          |
"""

    result = pretty_table(
        String,
        vec;
        backend = Val(:markdown),
        header = (["A"], ["B"], ["C"], ["D"]),
    )

    @test result == expected
end

@testset "Print missing, nothing, and #undef" begin
    matrix = Matrix{Any}(undef,3,3)
    matrix[1,1:2] .= missing
    matrix[2,1:2] .= nothing
    matrix[3,1]   = missing
    matrix[3,2]   = nothing

    expected = """
| **Col. 1** | **Col. 2** | **Col. 3** |
|-----------:|-----------:|-----------:|
| missing    | missing    | #undef     |
| nothing    | nothing    | #undef     |
| missing    | nothing    | #undef     |
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:markdown),
    )

    @test result == expected
end

@testset "Markdown Escaping" begin
    header = [
        "*1*",
        "_2_"
    ]

    matrix = [
        1 "**Bold**"
        2 "_Italic_"
        3 " `Code`"
    ]

    expected = """
| **\\*1\\*** | **\\_2\\_**    |
|----------:|-------------:|
| 1         | \\*\\*Bold\\*\\* |
| 2         | \\_Italic\\_   |
| 3         |  \\`Code\\`    |
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:markdown),
        header = header,
    )

    @test result == expected

    expected = """
| ***1*** | **_2_**  |
|--------:|---------:|
| 1       | **Bold** |
| 2       | _Italic_ |
| 3       |  `Code`  |
"""

    result = pretty_table(
        String,
        matrix;
        allow_markdown_in_cells = true,
        backend = Val(:markdown),
        header = header,
    )

    @test result == expected
end
