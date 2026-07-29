## Description #############################################################################
#
# Tests related to the internal functions that guard user-observed performance.
#
############################################################################################

@testset "Horizontal Line Counting" verbose = true begin
    # `_text__count_horizontal_lines` replaced a scan over every row of the source table.
    # Hence, it must reproduce that scan exactly while being independent of `last_row`.
    naive(hlines, last_row) = count(i -> i ∈ hlines, 1:last_row)

    @testset "Ranges" begin
        for hlines in (1:0, 1:1, 1:5, 3:7, 1:1000), last_row in (0, 1, 4, 10)
            @test PrettyTables._text__count_horizontal_lines(hlines, last_row) ==
                naive(hlines, last_row)
        end
    end

    @testset "Vectors" begin
        for hlines in (Int[], [1], [2, 4], [1, 2, 3], [5, 1, 9], [-3, 0, 2]),
            last_row in (0, 1, 4, 10)

            @test PrettyTables._text__count_horizontal_lines(hlines, last_row) ==
                naive(hlines, last_row)
        end
    end

    @testset "Duplicated Entries Are Counted Once" begin
        @test PrettyTables._text__count_horizontal_lines([2, 2, 2], 5) == 1
        @test PrettyTables._text__count_horizontal_lines([1, 2, 2, 3], 5) == 3
    end
end

@testset "Printing a Cropped Table Is Independent of the Number of Rows" begin
    # `_text__number_of_required_lines` used to walk every row of the source table, twice,
    # with no early exit. Hence, `pretty_table(1:10^7)` took tens of milliseconds even though
    # only a screenful is ever shown.
    #
    # This is asserted through the allocation count, which is deterministic, instead of
    # through the elapsed time.
    function allocations_for(n)
        io = IOContext(IOBuffer(), :displaysize => (25, 80), :color => false, :limit => true)

        # Warm up so that compilation is not measured.
        pretty_table(io, 1:n)
        take!(io.io)

        a = @allocated pretty_table(io, 1:n)
        take!(io.io)

        return a
    end

    small = allocations_for(10^3)
    large = allocations_for(10^7)

    @test small == large
end
