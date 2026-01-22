## Description #############################################################################
#
# Typst Back End: Test highlighters.
#
############################################################################################
using PrettyTables: TypstLength, Pt, Mm, Cm, In, Em, Ex, Fr, Percent, Auto

@testset "Typst Types" verbose=true begin
  # ----------------------------------------------------------------------------
  # 1) Text attribute filter: only keeps `text-*` keys that map to _TYPST__TEXT_ATTRIBUTES
  # ----------------------------------------------------------------------------
  @testset "_typst__filter_text_atributes" verbose=true begin
    attrs = [
      "text-weight" => "bold",     # ok (weight)
      "text-style"  => "italic",   # ok (style)
      "text-fill"   => "gray",     # ok (fill)
      "text-size"   => "0.9em",    # ok (size)
      "stroke"      => "none",     # should be dropped (no text- prefix)
      "fill"        => "red",      # should be dropped (no text- prefix)
      "text-nope"   => "x",        # should be dropped (nope not in _TYPST__TEXT_ATTRIBUTES)
      "text-"       => "x",        # should be dropped (empty attribute name)
    ]

    filtered = PrettyTables._typst__filter_text_atributes(attrs)

    # Only allowed + prefixed survive
    @test all(p -> startswith(p.first, "text-"), filtered)

    _keys = map(x->x[1],filtered)
    @test "text-weight" in _keys
    @test "text-style"  in _keys
    @test "text-fill"   in _keys
    @test "text-size"   in _keys

    @test !("stroke" in _keys)
    @test !("fill" in _keys)
    @test !("text-nope" in _keys)
    @test !("text-" in _keys)

    # Ensure values are preserved
    dict = Dict(filtered)
    @test dict["text-weight"] == "bold"
    @test dict["text-style"]  == "italic"
    @test dict["text-fill"]   == "gray"
    @test dict["text-size"]   == "0.9em"
  end

  # ----------------------------------------------------------------------------
  # 2) TypstLength: constructors, tryparse/parse, show
  # ----------------------------------------------------------------------------
  @testset "TypstLength" begin
    @testset "Constructors / invariants" begin
      @test TypstLength() == TypstLength{Auto}(nothing)
      @test TypstLength(Auto) == TypstLength{Auto}(nothing)

      @test TypstLength(Pt, 12) == TypstLength{Pt}(12.0)
      @test TypstLength(Em, 2)  == TypstLength{Em}(2.0)
      @test TypstLength(Fr, 0.3) == TypstLength{Fr}(0.3)

      @test TypstLength(:pt, 10) == TypstLength{Pt}(10.0)
      @test TypstLength(:percent, 50) == TypstLength{Percent}(50.0)

      # Unknown symbol falls back to Auto by current implementation
      @test TypstLength(:unknown_unit, 5) == TypstLength{Auto}(5.0)
    end

    @testset "tryparse / parse from string" begin
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
    end

    @testset "show (Typst stringification)" begin
      @test sprint(show, TypstLength(Auto)) == "auto"
      @test sprint(show, TypstLength(Pt, 12)) == "12pt"
      @test sprint(show, TypstLength(Em, 2))  == "2em"
      @test sprint(show, TypstLength(Fr, 0.3)) == "0.3fr"
      @test sprint(show, TypstLength(Percent, 50)) == "50%"

      # rounding behavior (digits=2)
      @test sprint(show, TypstLength(Em, 1.234)) == "1.23em"
      @test sprint(show, TypstLength(Em, 1.239)) == "1.24em"

      # avoid trailing .0 for integer values
      @test sprint(show, TypstLength(Pt, 10.0)) == "10pt"
      @test sprint(show, TypstLength(Fr, 3.0)) == "3fr"
    end
  end

  # ----------------------------------------------------------------------------
  # 3) TypstCaption: constructors, gap parsing, show formatting
  # ----------------------------------------------------------------------------
  @testset "TypstCaption" begin
    @testset "Constructors / gap parsing" begin
      c = TypstCaption("Hello")
      @test c.caption == "Hello"
      @test c.kind isa Auto
      @test c.supplement === nothing
      @test c.gap isa Auto
      @test c.position === nothing

      # gap as AbstractString should be parsed into TypstLength
      c2 = TypstCaption("Hello"; gap="12pt")
      @test c2.gap == TypstLength{Pt}(12.0)

      c3 = TypstCaption("Hello"; gap="0.5fr")
      @test c3.gap == TypstLength{Fr}(0.5)

      # gap as AbstractTypstLength should be accepted
      g = TypstLength(Em, 2)
      c4 = TypstCaption("Hello"; gap=g)
      @test c4.gap == g
    end

    @testset "show output - default kind/auto" begin
      c = TypstCaption("Caption text")
      out = sprint(show, c)

      # basic structure
      @test occursin("caption: figure.caption(", out)
      @test occursin("[Caption text]", out)

      # kind printed as `auto` for Auto()
      @test occursin("kind: auto", out)

      # no supplement/gap/position unless provided
      @test !occursin("supplement:", out)
      @test !occursin("gap:", out)
      @test !occursin("position:", out)
    end

    @testset "show output - position + gap" begin
      c = TypstCaption("Cap"; position="bottom", gap="12pt")
      out = sprint(show, c)

      @test occursin("position: bottom", out)
      @test occursin("gap: 12pt", out)
      @test occursin("kind: auto", out)
    end

    @testset "show output - custom kind + default supplement" begin
      # For custom kind string (not in ["table","auto","image"])
      c = TypstCaption("Cap"; kind="chart")
      out = sprint(show, c)

      @test occursin("kind: \"chart\"", out)
      # Default supplement uses titlecase(kind) if supplement is nothing
      @test occursin("supplement: [Chart]", out)
    end

    @testset "show output - custom kind + explicit supplement" begin
      c = TypstCaption("Cap"; kind="chart", supplement="Gráfico")
      out = sprint(show, c)

      @test occursin("kind: \"chart\"", out)
      @test occursin("supplement: [Gráfico]", out)
    end

    @testset "show output - kind in whitelist prints without quotes" begin
      c1 = TypstCaption("Cap"; kind="table")
      out1 = sprint(show, c1)
      @test occursin("kind: table", out1)
      @test !occursin("kind: \"table\"", out1)

      c2 = TypstCaption("Cap"; kind="image")
      out2 = sprint(show, c2)
      @test occursin("kind: image", out2)
      @test !occursin("kind: \"image\"", out2)

      # kind="auto" string behaves as whitelisted too
      c3 = TypstCaption("Cap"; kind="auto")
      out3 = sprint(show, c3)
      @test occursin("kind: auto", out3)
      @test !occursin("kind: \"auto\"", out3)
    end
  end
  
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