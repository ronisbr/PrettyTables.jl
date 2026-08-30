## Description #############################################################################
#
# Tests related to the faces of StyledStrings.jl.
#
############################################################################################

@testset "Crayon to Face Conversion" begin
    to_face = PrettyTables._face_from_crayon

    # == Attributes ========================================================================

    @test to_face(Crayon()) == Face()
    @test to_face(crayon"bold") == Face(; weight = :bold)
    @test to_face(crayon"faint") == Face(; weight = :light)
    @test to_face(crayon"bold faint") == Face(; weight = :bold)
    @test to_face(Crayon(; bold = false)) == Face(; weight = :normal)
    @test to_face(crayon"italics") == Face(; slant = :italic)
    @test to_face(Crayon(; italics = false)) == Face(; slant = :normal)
    @test to_face(crayon"underline") == Face(; underline = true)
    @test to_face(Crayon(; underline = false)) == Face(; underline = false)
    @test to_face(crayon"strikethrough") == Face(; strikethrough = true)
    @test to_face(crayon"negative") == Face(; inverse = true)

    # The blink, conceal, and reset attributes are dropped.
    @test to_face(crayon"blink conceal") == Face()
    @test to_face(crayon"reset") == Face()
    @test to_face(crayon"bold underline") == Face(; weight = :bold, underline = true)

    # == Named Colors ======================================================================

    @test to_face(crayon"red") == Face(; foreground = :red)
    @test to_face(crayon"bg:blue") == Face(; background = :blue)
    @test to_face(crayon"fg:dark_gray") == Face(; foreground = :bright_black)
    @test to_face(crayon"fg:light_gray") == Face(; foreground = :white)
    @test to_face(crayon"fg:white") == Face(; foreground = :bright_white)
    @test to_face(crayon"fg:light_red") == Face(; foreground = :bright_red)
    @test to_face(crayon"fg:light_cyan bg:light_magenta") ==
        Face(; foreground = :bright_cyan, background = :bright_magenta)
    @test to_face(crayon"default") == Face(; foreground = :default)
    @test to_face(crayon"bold red") == Face(; weight = :bold, foreground = :red)

    # == 256-color Palette =================================================================

    @test to_face(Crayon(; foreground = 1)) == Face(; foreground = :red)
    @test to_face(Crayon(; foreground = 15)) == Face(; foreground = :bright_white)
    @test to_face(Crayon(; foreground = 16)) == Face(; foreground = 0x000000)
    @test to_face(Crayon(; foreground = 21)) == Face(; foreground = 0x0000ff)
    @test to_face(Crayon(; background = 196)) == Face(; background = 0xff0000)
    @test to_face(Crayon(; foreground = 243)) == Face(; foreground = 0x767676)
    @test to_face(Crayon(; foreground = 255)) == Face(; foreground = 0xeeeeee)

    # == 24-bit Colors =====================================================================

    @test to_face(Crayon(; foreground = 0x005f87)) == Face(; foreground = 0x005f87)
    @test to_face(Crayon(; background = (1, 2, 3))) == Face(; background = 0x010203)
end

@testset "Face from Keywords" begin
    from_kwargs = PrettyTables._face_from_kwargs

    @test from_kwargs() == Face()

    # == Face Keywords =====================================================================

    @test from_kwargs(; weight = :bold, slant = :italic, foreground = :bright_red) ==
        Face(; weight = :bold, slant = :italic, foreground = :bright_red)
    @test from_kwargs(; underline = (:red, :curly), inherit = :error) ==
        Face(; underline = (:red, :curly), inherit = :error)
    @test from_kwargs(; foreground = "#ff8800") == Face(; foreground = "#ff8800")

    # == Crayon Keywords ===================================================================

    @test from_kwargs(; bold = true) == Face(; weight = :bold)
    @test from_kwargs(; bold = false) == Face(; weight = :normal)
    @test from_kwargs(; faint = true) == Face(; weight = :light)
    @test from_kwargs(; bold = true, faint = true) == Face(; weight = :bold)
    @test from_kwargs(; faint = true, bold = true) == Face(; weight = :bold)
    @test from_kwargs(; italics = true) == Face(; slant = :italic)
    @test from_kwargs(; italics = false) == Face(; slant = :normal)
    @test from_kwargs(; negative = true) == Face(; inverse = true)
    @test from_kwargs(; underline = true, strikethrough = true) ==
        Face(; underline = true, strikethrough = true)
    @test from_kwargs(; blink = true, conceal = true, reset = true) == Face()
    @test from_kwargs(; bold = nothing, foreground = nothing) == Face()

    # == Crayon Colors =====================================================================

    @test from_kwargs(; foreground = :dark_gray) == Face(; foreground = :bright_black)
    @test from_kwargs(; background = :light_red) == Face(; background = :bright_red)
    @test from_kwargs(; foreground = :white) == Face(; foreground = :bright_white)
    @test from_kwargs(; foreground = 21) == Face(; foreground = 0x0000ff)
    @test from_kwargs(; foreground = 0xff0000) == Face(; foreground = 0xff0000)
    @test from_kwargs(; background = (1, 2, 3)) == Face(; background = 0x010203)
    @test_throws ArgumentError from_kwargs(; foreground = 256)

    # The mixed form is also supported.
    @test from_kwargs(; bold = true, foreground = :dark_gray, slant = :italic) ==
        Face(; weight = :bold, slant = :italic, foreground = :bright_black)
end

@testset "Face Helpers" begin
    @test PrettyTables._face_color_hex(nothing) === nothing
    @test PrettyTables._face_color_hex(SimpleColor(:default)) === nothing
    @test PrettyTables._face_color_hex(SimpleColor(0x0a5f87)) == "0a5f87"
    @test PrettyTables._face_color_hex(SimpleColor(0x0a5f87); uppercase = true) == "0A5F87"
    @test PrettyTables._face_color_hex(SimpleColor(:red)) == "a51c2c"

    @test PrettyTables._face_height_string(120, "pt", "em") == "12pt"
    @test PrettyTables._face_height_string(125, "pt", "em") == "12.5pt"
    @test PrettyTables._face_height_string(1.5, "pt", "em") == "1.5em"

    @test PrettyTables._face_is_bold(Face(; weight = :semibold))
    @test !PrettyTables._face_is_bold(Face(; weight = :light))
    @test !PrettyTables._face_is_bold(Face())
    @test PrettyTables._face_is_light(Face(; weight = :thin))
    @test PrettyTables._face_is_italic(Face(; slant = :oblique))
    @test !PrettyTables._face_is_italic(Face(; slant = :normal))
    @test PrettyTables._face_is_underlined(Face(; underline = true))
    @test PrettyTables._face_is_underlined(Face(; underline = :red))
    @test PrettyTables._face_is_underlined(Face(; underline = (:red, :curly)))
    @test !PrettyTables._face_is_underlined(Face(; underline = false))
    @test !PrettyTables._face_is_underlined(Face())
    @test PrettyTables._face_is_struck(Face(; strikethrough = true))
    @test !PrettyTables._face_is_struck(Face())
end

@testset "HTML Decoration" begin
    @test html_decoration(Face()) == Pair{String, String}[]

    @test html_decoration(Face(; weight = :bold, foreground = "#ff0000")) ==
        ["color" => "#ff0000", "font-weight" => "bold"]

    @test html_decoration(
        Face(;
            font          = "Fira Code",
            height        = 125,
            weight        = :light,
            slant         = :oblique,
            background    = 0x00ff00,
            underline     = true,
            strikethrough = true,
        )
    ) == [
        "background-color" => "#00ff00",
        "font-weight"      => "lighter",
        "font-style"       => "oblique",
        "font-family"      => "Fira Code",
        "font-size"        => "12.5pt",
        "text-decoration"  => "underline line-through",
    ]

    @test html_decoration(Face(; height = 1.5, weight = :normal, slant = :normal)) ==
        ["font-weight" => "normal", "font-style" => "normal", "font-size" => "1.5em"]
    @test html_decoration(Face(; underline = :red)) == ["text-decoration" => "underline"]
    @test html_decoration(Face(; strikethrough = true)) ==
        ["text-decoration" => "line-through"]

    # The default colors, the unknown names, and the unsupported attributes are ignored.
    @test html_decoration(Face(; foreground = :default, inverse = true, inherit = :error)) ==
        Pair{String, String}[]
    @test html_decoration(Face(; foreground = :red)) == ["color" => "#a51c2c"]
end

@testset "LaTeX Decoration" begin
    @test latex_decoration(Face()) == String[]

    @test latex_decoration(Face(; weight = :bold, foreground = "#ff0000")) ==
        ["textbf", "textcolor[HTML]{FF0000}"]

    @test latex_decoration(
        Face(;
            weight        = :semibold,
            slant         = :italic,
            foreground    = "#ff0000",
            background    = 0x00ff00,
            strikethrough = true,
            underline     = true,
        )
    ) == [
        "textbf",
        "textit",
        "underline",
        "sout",
        "textcolor[HTML]{FF0000}",
        "colorbox[HTML]{00FF00}",
    ]

    # The light weights, the default colors, and the unsupported attributes are ignored.
    @test latex_decoration(
        Face(; weight = :light, height = 120, font = "Fira", foreground = :default)
    ) == String[]
    @test latex_decoration(Face(; foreground = :red)) == ["textcolor[HTML]{A51C2C}"]
end

@testset "Typst Decoration" begin
    @test typst_decoration(Face()) == Pair{String, String}[]

    @test typst_decoration(Face(; weight = :bold, foreground = "#ff0000")) ==
        ["text-weight" => "bold", "text-fill" => "rgb(\"#ff0000\")"]

    @test typst_decoration(
        Face(;
            font       = "Fira Sans",
            height     = 120,
            weight     = :normal,
            slant      = :oblique,
            foreground = "#ff0000",
            background = 0x0000ff,
        )
    ) == [
        "text-font"   => "Fira Sans",
        "text-size"   => "12pt",
        "text-weight" => "regular",
        "text-style"  => "oblique",
        "text-fill"   => "rgb(\"#ff0000\")",
        "fill"        => "rgb(\"#0000ff\")",
    ]

    @test typst_decoration(Face(; height = 1.5, weight = :semilight)) ==
        ["text-size" => "1.5em", "text-weight" => "light"]

    # The default colors and the unsupported attributes are ignored.
    @test typst_decoration(
        Face(; foreground = :default, underline = true, strikethrough = true, inverse = true)
    ) == Pair{String, String}[]
    @test typst_decoration(Face(; foreground = :red)) == ["text-fill" => "rgb(\"#a51c2c\")"]
end
