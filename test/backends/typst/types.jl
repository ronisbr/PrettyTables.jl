## Description #############################################################################
#
# Typst Back End: Test highlighters.
#
############################################################################################
using PrettyTables: TypstLength, Pt, Mm, Cm, In, Em, Ex, Fr, Percent, Auto

@testset "Typst Types" begin
  @testset "Typst Length subtypes" begin
    # --- Constructors / basic invariants ---
    @test TypstLength() == TypstLength{Auto}(nothing)
    @test TypstLength(Auto) == TypstLength{Auto}(nothing)

    @test TypstLength(Pt, 12) == TypstLength{Pt}(12.0)
    @test TypstLength(Em, 2)  == TypstLength{Em}(2.0)
    @test TypstLength(Fr, 0.3) == TypstLength{Fr}(0.3)

    @test TypstLength(:pt, 10) == TypstLength{Pt}(10.0)
    @test TypstLength(:percent, 50) == TypstLength{Percent}(50.0)

    # --- tryparse / parse from string ---
    @test tryparse(TypstLength, "auto") == TypstLength{Auto}(nothing)
    @test parse(TypstLength, "auto") == TypstLength{Auto}(nothing)

    @test parse(TypstLength, "12pt") == TypstLength{Pt}(12.0)
    @test parse(TypstLength, "25mm") == TypstLength{Mm}(25.0)
    @test parse(TypstLength, "2cm")  == TypstLength{Cm}(2.0)
    @test parse(TypstLength, "1in")  == TypstLength{In}(1.0)

    @test parse(TypstLength, "2em")  == TypstLength{Em}(2.0)
    @test parse(TypstLength, "1.5ex") == TypstLength{Ex}(1.5)
    @test parse(TypstLength, "3fr")  == TypstLength{Fr}(3.0)
    @test parse(TypstLength, "50%")  == TypstLength{Percent}(50.0)

    # Whitespace tolerance
    @test parse(TypstLength, "  12 pt") == TypstLength{Pt}(12.0)
    @test parse(TypstLength, "0.5fr ") == TypstLength{Fr}(0.5)

    # number-only string uses numeric policy (>=1 => em ; 0<x<1 => fr)
    @test parse(TypstLength, "2") == TypstLength{Em}(2.0)
    @test parse(TypstLength, "0.3") == TypstLength{Fr}(0.3)

    # numeric tryparse uses same policy
    @test tryparse(TypstLength, 2) == TypstLength{Em}(2.0)
    @test tryparse(TypstLength, 0.3) == TypstLength{Fr}(0.3)

    # boundary cases
    @test tryparse(TypstLength, 1) == TypstLength{Em}(1.0)
    @test tryparse(TypstLength, 0) === nothing
    @test tryparse(TypstLength, -1) === nothing

    # invalid strings
    @test tryparse(TypstLength, "") === nothing
    @test tryparse(TypstLength, "  ") === nothing
    @test tryparse(TypstLength, "12px") === nothing
    @test tryparse(TypstLength, "foo") === nothing
    @test tryparse(TypstLength, "12 pt extra") === nothing

    @test_throws ArgumentError parse(TypstLength, "12px")
    @test_throws ArgumentError parse(TypstLength, "nope")
    @test_throws ArgumentError parse(TypstLength, 0)
    @test_throws ArgumentError parse(TypstLength, -0.1)

    # --- show (stringification to Typst) ---
    @test sprint(show, TypstLength(Auto)) == "auto"
    @test sprint(show, TypstLength(Pt, 12)) == "12pt"
    @test sprint(show, TypstLength(Em, 2))  == "2em"
    @test sprint(show, TypstLength(Fr, 0.3)) == "0.3fr"
    @test sprint(show, TypstLength(Percent, 50)) == "50%"

    # rounding behavior (assuming you use round(value; digits=2))
    # 1.234 -> "1.23em", 1.235 -> "1.24em" (bankers rounding depends; avoid edge)
    @test sprint(show, TypstLength(Em, 1.234)) == "1.23em"
    @test sprint(show, TypstLength(Em, 1.239)) == "1.24em"
  end
end