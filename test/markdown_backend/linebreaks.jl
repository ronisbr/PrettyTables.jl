## Description #############################################################################
#
# Tests of line breaks.
#
############################################################################################

@testset "Cells with multiple lines" begin
    data = ["This line contains\nthe velocity [m/s]" 10.0;
            "This line contains\nthe acceleration [m/s^2]" 1.0;
            "This line contains\nthe time from the\nbeginning of the simulation" 10;]

    header = ["Information", "Value"]

    # == Line Breaks =======================================================================

    expected = """
| **Information**                                                        | **Value** |
|-----------------------------------------------------------------------:|----------:|
| This line contains<br>the velocity [m/s]                               | 10.0      |
| This line contains<br>the acceleration [m/s^2]                         | 1.0       |
| This line contains<br>the time from the<br>beginning of the simulation | 10        |
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:markdown),
        header = header,
        linebreaks = true,
    )

    @test result == expected
end

