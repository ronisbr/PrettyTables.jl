## Description #############################################################################
#
# Tests of renderers.
#
############################################################################################

@testset "Renderers - printf" begin
    matrix = Any[BigFloat(pi) float(pi) 10.0f0  Float16(1)
                 0x01         0x001     0x00001 0x000000001
                 true         false     true    false
                 "Teste" "Teste\nTeste" "Teste \"quote\" Teste" "Teste\n\"quote\"\nTeste"]

    header = (["C1", "C2", "C3", "C4"],
              ["S1", "S2", "S3", "S4"])

    row_labels = [1, 2, "3", '4']

    expected = """
| **#** | **Test** | **C1**<br>`S1`                                                                   | **C2**<br>`S2` | **C3**<br>`S3`      | **C4**<br>`S4`            |
|------:|---------:|---------------------------------------------------------------------------------:|---------------:|--------------------:|--------------------------:|
| **1** | 1        | 3.141592653589793238462643383279502884197169399375105820974944592307816406286198 | 3.14159        | 10.0                | 1.0                       |
| **2** | 2        | 1                                                                                | 1              | 1                   | 1                         |
| **3** | 3        | true                                                                             | false          | true                | false                     |
| **4** | 4        | Teste                                                                            | Teste<br>Teste | Teste "quote" Teste | Teste<br>"quote"<br>Teste |
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:markdown),
        linebreaks = true,
        header = header,
        row_labels = row_labels,
        row_label_column_title = "Test",
        row_number_column_title = "#",
        show_row_number = true,
    )

    @test expected == result

    expected = """
| **#** | **Test** | **C1**<br>`S1`                                                                   | **C2**<br>`S2`    | **C3**<br>`S3`      | **C4**<br>`S4`            |
|------:|---------:|---------------------------------------------------------------------------------:|------------------:|--------------------:|--------------------------:|
| **1** | 1        | 3.141592653589793238462643383279502884197169399375105820974944592307816406286198 | 3.141592653589793 | 10.0                | 1.0                       |
| **2** | 2        | 1                                                                                | 1                 | 1                   | 1                         |
| **3** | 3        | true                                                                             | false             | true                | false                     |
| **4** | 4        | Teste                                                                            | Teste<br>Teste    | Teste "quote" Teste | Teste<br>"quote"<br>Teste |
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:markdown),
        header = header,
        compact_printing = false,
        linebreaks = true,
        row_labels = row_labels,
        row_label_column_title = "Test",
        row_number_column_title = "#",
        show_row_number = true,
    )

    @test expected == result

    # == Limit Printing ====================================================================

    matrix = [[collect(1:1:30)] [collect(1:1:21)]
              [collect(1:1:20)] [collect(1:1:2)]]

    expected = """
| **Col. 1**                                                                 | **Col. 2**                                                                 |
|---------------------------------------------------------------------------:|---------------------------------------------------------------------------:|
| [1, 2, 3, 4, 5, 6, 7, 8, 9, 10  …  21, 22, 23, 24, 25, 26, 27, 28, 29, 30] | [1, 2, 3, 4, 5, 6, 7, 8, 9, 10  …  12, 13, 14, 15, 16, 17, 18, 19, 20, 21] |
| [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]    | [1, 2]                                                                     |
"""

    result = pretty_table(
        String,
        matrix,
        backend = Val(:markdown),
    )

    @test expected == result

    expected = """
| **Col. 1**                                                                                                      | **Col. 2**                                                                  |
|----------------------------------------------------------------------------------------------------------------:|----------------------------------------------------------------------------:|
| [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30] | [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21] |
| [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]                                         | [1, 2]                                                                      |
"""

    result = pretty_table(
        String,
        matrix,
        backend = Val(:markdown),
        limit_printing = false,
    )
    @test expected == result
end

@testset "Renderers - show" begin
    matrix = Any[BigFloat(pi) float(pi) 10.0f0  Float16(1)
                 0x01         0x001     0x00001 0x000000001
                 true         false     true    false
                 "Teste" "Teste\nTeste" "Teste \"quote\" Teste" "Teste\n\"quote\"\nTeste"]

    header = (["C1", "C2", "C3", "C4"],
              ["S1", "S2", "S3", "S4"])

    row_labels = [1, 2, "3", '4']

    expected = """
| **#** | **Test** | **C1**<br>`S1` | **C2**<br>`S2` | **C3**<br>`S3`      | **C4**<br>`S4`            |
|------:|---------:|---------------:|---------------:|--------------------:|--------------------------:|
| **1** | 1        | 3.14159        | 3.14159        | 10.0                | 1.0                       |
| **2** | 2        | 0x01           | 0x0001         | 0x00000001          | 0x0000000000000001        |
| **3** | 3        | true           | false          | true                | false                     |
| **4** | 4        | Teste          | Teste<br>Teste | Teste "quote" Teste | Teste<br>"quote"<br>Teste |
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:markdown),
        header = header,
        linebreaks = true,
        renderer = :show,
        row_labels = row_labels,
        row_label_column_title = "Test",
        row_number_column_title = "#",
        show_row_number = true,
    )

    @test expected == result

    expected = """
| **#** | **Test** | **C1**<br>`S1`                                                                   | **C2**<br>`S2`    | **C3**<br>`S3`      | **C4**<br>`S4`            |
|------:|---------:|---------------------------------------------------------------------------------:|------------------:|--------------------:|--------------------------:|
| **1** | 1        | 3.141592653589793238462643383279502884197169399375105820974944592307816406286198 | 3.141592653589793 | 10.0f0              | Float16(1.0)              |
| **2** | 2        | 0x01                                                                             | 0x0001            | 0x00000001          | 0x0000000000000001        |
| **3** | 3        | true                                                                             | false             | true                | false                     |
| **4** | 4        | Teste                                                                            | Teste<br>Teste    | Teste "quote" Teste | Teste<br>"quote"<br>Teste |
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:markdown),
        header = header,
        compact_printing = false,
        linebreaks = true,
        renderer = :show,
        row_labels = row_labels,
        row_label_column_title = "Test",
        row_number_column_title = "#",
        show_row_number = true
    )

    @test expected == result

    # -- Limit Printing --------------------------------------------------------------------

    matrix = [[collect(1:1:30)] [collect(1:1:21)]
              [collect(1:1:20)] [collect(1:1:2)]]

    expected = """
| **Col. 1**                                                                 | **Col. 2**                                                                 |
|---------------------------------------------------------------------------:|---------------------------------------------------------------------------:|
| [1, 2, 3, 4, 5, 6, 7, 8, 9, 10  …  21, 22, 23, 24, 25, 26, 27, 28, 29, 30] | [1, 2, 3, 4, 5, 6, 7, 8, 9, 10  …  12, 13, 14, 15, 16, 17, 18, 19, 20, 21] |
| [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]    | [1, 2]                                                                     |
"""

    result = pretty_table(
        String,
        matrix,
        backend = Val(:markdown),
        renderer = :show,
    )
    @test expected == result

    expected = """
| **Col. 1**                                                                                                      | **Col. 2**                                                                  |
|----------------------------------------------------------------------------------------------------------------:|----------------------------------------------------------------------------:|
| [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30] | [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21] |
| [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]                                         | [1, 2]                                                                      |
"""

    result = pretty_table(
        String,
        matrix,
        backend = Val(:markdown),
        limit_printing = false,
        renderer = :show,
    )
    @test expected == result
end

