# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Tests related to general functions.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Backend inference
# ==============================================================================

# minimal other table interface
struct TestVec{T} <: AbstractArray{T,1}
    data::Array{T,1}
end
Base.IndexStyle(::Type{A}) where {A<:TestVec} = Base.IndexCartesian()
Base.size(A::TestVec) = size(getfield(A, :data))
Base.getindex(A::TestVec, index::Int) = getindex(getfield(A, :data), index)
Base.collect(::Type{T}, itr::TestVec) where {T} = TestVec(collect(T, getfield(itr, :data)))

struct MinimalTable
    data::Matrix
    colnames::TestVec
end

Tables.istable(x::MinimalTable) = true
Tables.columnaccess(::MinimalTable) = true
Tables.columnnames(x::MinimalTable) = getfield(x, :colnames)
Tables.columns(x::MinimalTable) = x
Base.getindex(x::MinimalTable, i1, i2) = getindex(getfield(x, :data), i1, i2)
Base.getproperty(x::MinimalTable, s::Symbol) = getindex(x, :, findfirst(==(s), Tables.columnnames(x)))
Base.convert(::Type{<:TestVec}, x::Array) = TestVec(x)

@testset "Back-end inference" begin
    data = rand(3,3)
    mt = MinimalTable(data, [Symbol("Col. 1"), Symbol("Col. 2"), Symbol("Col. 3")])

    # Text
    # ==========================================================================

    auto   = pretty_table(String, data, tf = unicode)
    manual = pretty_table(String, data, tf = unicode, backend = :text)
    mintable = pretty_table(String, mt, tf = unicode, backend = :text)

    @test auto == manual == mintable

    # HTML
    # ==========================================================================

    auto   = pretty_table(String, data, tf = html_simple)
    manual = pretty_table(String, data, tf = html_simple, backend = :html)
    mintable = pretty_table(String, mt, tf = html_simple, backend = :html)

    @test auto == manual == mintable

    # LaTeX
    # ==========================================================================

    auto   = pretty_table(String, data, tf = latex_default)
    manual = pretty_table(String, data, tf = latex_default, backend = :latex)
    mintable = pretty_table(String, mt, tf = latex_default, backend = :latex)

    @test auto == manual == mintable

    # Error
    # ==========================================================================

    @test_throws TypeError pretty_table(data, tf = [])
end

# Include table in file
# ==============================================================================

@testset "Include Pretty Table to file" begin

    # Text
    # ==========================================================================

    path = "test.txt"

    orig = """
    This is one line.

    This is "another" line.

    % <PrettyTables Table 1> This should be deleted.
    This should be deleted.
    This should be deleted.
    This should be deleted.
    This should be deleted.


    % </PrettyTables>

    <PrettyTables Table 2></PrettyTables>

    <PrettyTables Table 3>This should not be deleted.
    This should not be deleted.
    This should not be deleted.
    This should not be deleted."""

    open(path,"w") do f
        write(f, orig)
    end

    data_table_1 = [1 2 3
                    4 5 6]

    data_table_2 = [7 8 9
                    1 2 3]

    include_pt_in_file(path, "Table 2", data_table_2, tf = mysql,
                       body_hlines = [1])
    include_pt_in_file(path, "Table 1", data_table_1, alignment = :c,
                       show_row_number = true, backup_file = false)
    include_pt_in_file(path, "Table 3", data_table_2, alignment = :c,
                       show_row_number = true, backup_file = false)

    result = read(path, String)
    backup = read(path * "_backup", String)

    expected = """
    This is one line.

    This is "another" line.

    % <PrettyTables Table 1>
    ┌─────┬────────┬────────┬────────┐
    │ Row │ Col. 1 │ Col. 2 │ Col. 3 │
    ├─────┼────────┼────────┼────────┤
    │   1 │   1    │   2    │   3    │
    │   2 │   4    │   5    │   6    │
    └─────┴────────┴────────┴────────┘
    % </PrettyTables>

    <PrettyTables Table 2>
    +--------+--------+--------+
    | Col. 1 | Col. 2 | Col. 3 |
    +--------+--------+--------+
    |      7 |      8 |      9 |
    +--------+--------+--------+
    |      1 |      2 |      3 |
    +--------+--------+--------+
    </PrettyTables>

    <PrettyTables Table 3>This should not be deleted.
    This should not be deleted.
    This should not be deleted.
    This should not be deleted."""

    @test backup == orig
    @test result == expected

    # HTML (`tag_append` option)
    # ==========================================================================

    data_table_1 = [1 2 3
                    4 5 6]

    path = "test.html"

    orig = """
    <html>
    <body>

    <p>This is a table:</p>

    <!-- <PrettyTables Table 1> -->
    <!-- </PrettyTables> -->

    </body>
    </html>
    """

    open(path,"w") do f
        write(f, orig)
    end

    data_table_1 = [1 2 3
                    4 5 6]

    include_pt_in_file(path, "Table 1", data_table_1, backend = :html,
                       standalone = false, tag_append = " -->")

    result = read(path, String)
    backup = read(path * "_backup", String)

    expected = """
    <html>
    <body>

    <p>This is a table:</p>

    <!-- <PrettyTables Table 1> -->
    <table>
      <tr class = "header headerLastRow">
        <th style = "text-align: right; ">Col. 1</th>
        <th style = "text-align: right; ">Col. 2</th>
        <th style = "text-align: right; ">Col. 3</th>
      </tr>
      <tr>
        <td style = "text-align: right; ">1</td>
        <td style = "text-align: right; ">2</td>
        <td style = "text-align: right; ">3</td>
      </tr>
      <tr>
        <td style = "text-align: right; ">4</td>
        <td style = "text-align: right; ">5</td>
        <td style = "text-align: right; ">6</td>
      </tr>
    </table>
    <!-- </PrettyTables> -->

    </body>
    </html>
    """

    @test backup == orig
    @test result == expected

    # Markdown (`remove_tags` option)
    # ==========================================================================

    data_table_1 = [1 2 3
                    4 5 6]

    path = "test.md"

    orig = """
    # Markdown

    This is a markdown table.

    <PrettyTables Table 1> This should be removed.
    This should be removed.
    This should be removed.
    This should be removed.
    This should be removed.
    </PrettyTables>
    """

    open(path,"w") do f
        write(f, orig)
    end

    data_table_1 = [1 2 3
                    4 5 6]

    include_pt_in_file(path, "Table 1", data_table_1, tf = markdown,
                       remove_tags = true)

    result = read(path, String)
    backup = read(path * "_backup", String)

    expected = """
    # Markdown

    This is a markdown table.

    | Col. 1 | Col. 2 | Col. 3 |
    |--------|--------|--------|
    |      1 |      2 |      3 |
    |      4 |      5 |      6 |

    """

    @test backup == orig
    @test result == expected
end

# Print table to string
# ==============================================================================

@testset "Print table to string" begin
    data     = rand(10,4)
    header_m = [1 2 3 4]
    header_v = [1 2 3 4]

    expected = sprint(pretty_table, data)
    result   = pretty_table(String, data)
    @test result == expected

    expected = sprint((io,data)->pretty_table(io, data, header_m), data)
    result   = pretty_table(String, data, header_m)
    @test result == expected

    expected = sprint((io,data)->pretty_table(io, data, header_v), data)
    result   = pretty_table(String, data, header_v)
    @test result == expected

    dict = Dict(:a => 1,
                :b => 2,
                :c => 3,
                :d => 4)

    expected = sprint(pretty_table, data)
    result   = pretty_table(String, data)
    @test result == expected
end

# Compact types
# ==============================================================================

@testset "Compact types" begin
    # Dictionary
    # --------------------------------------------------------------------------

    data = Dict(:a => Int64(1), missing => Int64(2), :c => missing)

    expected = """
┌─────────┬─────────┐
│    Keys │  Values │
│ Symbol? │  Int64? │
├─────────┼─────────┤
│       a │       1 │
│       c │ missing │
│ missing │       2 │
└─────────┴─────────┘
"""
    result = pretty_table(String, data, sortkeys = true)
    @test result == expected

    # Tables.jl API
    # --------------------------------------------------------------------------

    df = DataFrame(a = [missing,Int64(1),Int64(2),Int64(3)],
                   b = [nothing,Int64(1),missing,Int64(1)])

    expected = """
┌─────────┬────────────────────┐
│       a │                  b │
│  Int64? │ U{Nothing, Int64}? │
├─────────┼────────────────────┤
│ missing │            nothing │
│       1 │                  1 │
│       2 │            missing │
│       3 │                  1 │
└─────────┴────────────────────┘
"""
    result = pretty_table(String, df)
    @test result == expected
end

# Configurations
# ==============================================================================

@testset "Configurations" begin
    data = [1 2 3
            4 5 6]

    conf1 = set_pt_conf(tf = markdown)
    conf2 = set_pt_conf(tf = ascii_dots, formatters = ft_printf("%5.3d"))
    set_pt_conf!(conf2, hlines = :none)

    expected = """
| Col. 1 | Col. 2 | Col. 3 |
|--------|--------|--------|
|      1 |      2 |      3 |
|      4 |      5 |      6 |
"""

    result = pretty_table_with_conf(conf1, String, data)
    @test result == expected

    expected = """
: Col. 1 : Col. 2 : Col. 3 :
:    001 :    002 :    003 :
:    004 :    005 :    006 :
"""

    clear_pt_conf!(conf2)
    expected = pretty_table(String, data)
    result = pretty_table_with_conf(conf2, String, data)

    @test result == expected
end

# Issue #65
# ==============================================================================

@testset "Issue #65 - Data type in filters with Tables.jl" begin
    df = DataFrame(A = Int64.(1:20), B = Float64.(1:20))
    rowfilter(data,i) = i <= div(size(data,1),2)

    result1 = pretty_table(String, df,                 filters_row = (rowfilter,))
    result2 = pretty_table(String, Tables.columns(df), filters_row = (rowfilter,))
    result3 = pretty_table(String, Tables.rows(df),    filters_row = (rowfilter,))

    expected = """
┌───────┬─────────┐
│     A │       B │
│ Int64 │ Float64 │
├───────┼─────────┤
│     1 │     1.0 │
│     2 │     2.0 │
│     3 │     3.0 │
│     4 │     4.0 │
│     5 │     5.0 │
│     6 │     6.0 │
│     7 │     7.0 │
│     8 │     8.0 │
│     9 │     9.0 │
│    10 │    10.0 │
└───────┴─────────┘
"""

    @test result1 == expected
    @test result2 == expected
    @test result3 == expected

    df = DataFrame(A = Int64.(1:10),
                   B = Float64.(1:10),
                   C = Int64.(1:10),
                   D = Float64.(1:10))
    colfilter1(data,j) = j <= div(size(data,2),2)

    # `size` applied to `Tables.rows(df)` returns only the number of rows.
    colfilter2(data,j) = j <= div(size(data[1],1),2)

    result1 = pretty_table(String, df,                 filters_col = (colfilter1,))
    result2 = pretty_table(String, Tables.columns(df), filters_col = (colfilter1,))
    result3 = pretty_table(String, Tables.rows(df),    filters_col = (colfilter2,))

    @test result1 == expected
    @test result2 == expected
    @test result3 == expected
end
