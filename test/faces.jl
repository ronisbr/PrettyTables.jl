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

@testset "Markdown Decoration" begin
    @test markdown_decoration(Face()) == MarkdownStyle()
    @test markdown_decoration(Face(; weight = :bold, foreground = :red)) ==
        MarkdownStyle(; bold = true)
    @test markdown_decoration(
        Face(; weight = :semibold, slant = :italic, strikethrough = true, underline = true)
    ) == MarkdownStyle(; bold = true, italic = true, strikethrough = true)
    @test markdown_decoration(Face(; weight = :light, slant = :oblique)) ==
        MarkdownStyle(; italic = true)
end

@testset "Excel Decoration" begin
    @test excel_decoration(Face()) == Pair{String, String}[]

    @test excel_decoration(Face(; weight = :bold, foreground = "#ff0000")) ==
        ["bold" => "true", "color" => "FFFF0000"]

    @test excel_decoration(
        Face(;
            font          = "Fira Sans",
            height        = 125,
            weight        = :semibold,
            slant         = :oblique,
            foreground    = "#ff0000",
            background    = 0x00ff00,
            underline     = true,
            strikethrough = true,
        )
    ) == [
        "bold"              => "true",
        "italic"            => "true",
        "under"             => "single",
        "strike"            => "true",
        "name"              => "Fira Sans",
        "size"              => "13",
        "color"             => "FFFF0000",
        "cell_fill_pattern" => "solid",
        "cell_fill_fgColor" => "FF00FF00",
    ]

    @test excel_decoration(Face(; height = 120)) == ["size" => "12"]
    @test excel_decoration(Face(; height = 4)) == ["size" => "1"]

    # The light weights, the default colors, and the unsupported attributes are ignored.
    @test excel_decoration(
        Face(; weight = :light, height = 1.5, foreground = :default, inverse = true)
    ) == Pair{String, String}[]
    @test excel_decoration(Face(; foreground = :red)) == ["color" => "FFA51C2C"]
end

@testset "General Highlighter" begin
    f = (data, i, j) -> i == 1

    h = Highlighter(f, Face(; weight = :bold, foreground = :red))
    @test h isa AbstractHighlighter
    @test h.f === f
    @test h.fd === PrettyTables._default_highlighter_fd
    @test h._decoration == Face(; weight = :bold, foreground = :red)
    @test h.fd(h, nothing, 1, 1) == Face(; weight = :bold, foreground = :red)
    @test PrettyTables._has_default_fd(h)

    # The general highlighter is converted to the native highlighters once per table.
    th = PrettyTables._text__native_highlighter(h)
    @test th isa TextHighlighter
    @test th._decoration == h._decoration
    @test PrettyTables._html__native_highlighter(h)._decoration == html_decoration(h._decoration)
    @test PrettyTables._latex__native_highlighter(h)._environments == latex_decoration(h._decoration)
    @test PrettyTables._markdown__native_highlighter(h)._decoration == markdown_decoration(h._decoration)
    @test PrettyTables._typst__native_highlighter(h)._decoration == typst_decoration(h._decoration)
    @test PrettyTables._excel__native_highlighter(h)._decoration == excel_decoration(h._decoration)

    hs = AbstractHighlighter[h, TextHighlighter(f, Face())]
    nhs = PrettyTables._text__native_highlighters(hs)
    @test nhs[1] isa TextHighlighter && nhs[2] === hs[2]
    v = AbstractHighlighter[hs[2]]
    @test PrettyTables._text__native_highlighters(v) === v

    h = Highlighter(f, crayon"bold red")
    @test h._decoration == Face(; weight = :bold, foreground = :red)

    h = Highlighter(f; weight = :bold, foreground = :red)
    @test h._decoration == Face(; weight = :bold, foreground = :red)

    h = Highlighter(f; bold = true, foreground = :dark_gray)
    @test h._decoration == Face(; weight = :bold, foreground = :bright_black)

    fd = (h, data, i, j) -> Face(; slant = :italic)
    h  = Highlighter(f, fd)
    @test h.fd === fd
    @test h._decoration == Face()
    @test !PrettyTables._has_default_fd(h)

    # A custom decoration function is called by the native highlighter.
    th = PrettyTables._text__native_highlighter(h)
    @test th.fd(th, nothing, 1, 1) == Face(; slant = :italic)
    @test PrettyTables._html__native_highlighter(h).fd(nothing, nothing, 1, 1) ==
        html_decoration(Face(; slant = :italic))
end

@static if VERSION >= v"1.11"
    @testset "Face Regions" begin
        regions = PrettyTables._face_regions(
            styled"a{red,bold:b}c{(fg=blue),(bg=green):d}{error:e}{unknown_face_name:f}"
        )

        @test regions == [
            ("a", nothing),
            ("b", Face(; weight = :bold, foreground = :red)),
            ("c", nothing),
            ("d", Face(; foreground = :blue, background = :green)),
            ("e", Face(; foreground = :bright_red)),
            ("f", nothing),
        ]

        @test PrettyTables._face_regions(styled"plain") == [("plain", nothing)]
        @test PrettyTables._face_regions(styled"") == [("", nothing)]

        # Annotations other than faces are ignored.
        str = Base.AnnotatedString("ab", [(1:1, :link, "https://ronanarraes.com")])
        @test PrettyTables._face_regions(str) == [("a", nothing), ("b", nothing)]
    end
end

@testset "Crayons in Styles and Highlighters" begin
    f    = (data, i, j) -> i == 1
    face = Face(; weight = :bold, foreground = :red)

    # The back end highlighters accept a face, a crayon, and the keywords of both.
    @test HtmlHighlighter(f, face)._decoration == html_decoration(face)
    @test HtmlHighlighter(f, crayon"bold red")._decoration == html_decoration(face)
    @test HtmlHighlighter(f; bold = true, foreground = :red)._decoration == html_decoration(face)

    @test LatexHighlighter(f, face)._environments == latex_decoration(face)
    @test LatexHighlighter(f, crayon"bold red")._environments == latex_decoration(face)
    @test LatexHighlighter(f; weight = :bold, foreground = :red)._environments ==
        latex_decoration(face)

    @test MarkdownHighlighter(f, face)._decoration == markdown_decoration(face)
    @test MarkdownHighlighter(f, crayon"bold")._decoration == MarkdownStyle(; bold = true)
    @test MarkdownHighlighter(f; italics = true)._decoration == MarkdownStyle(; italic = true)

    @test TypstHighlighter(f, face)._decoration == typst_decoration(face)
    @test TypstHighlighter(f, crayon"bold red")._decoration == typst_decoration(face)
    @test TypstHighlighter(f; bold = true, foreground = :red)._decoration ==
        typst_decoration(face)

    @test ExcelHighlighter(f, face)._decoration == excel_decoration(face)
    @test ExcelHighlighter(f, crayon"bold red")._decoration == excel_decoration(face)
    @test ExcelHighlighter(f; bold = true, foreground = :red)._decoration ==
        excel_decoration(face)

    # The table styles of every back end accept a crayon.
    @test HtmlTableStyle(; title = crayon"bold red").title == html_decoration(face)
    @test LatexTableStyle(; title = crayon"bold red").title == latex_decoration(face)
    @test MarkdownTableStyle(; row_label = crayon"bold").row_label == MarkdownStyle(; bold = true)
    @test TypstTableStyle(; title = crayon"bold red").title == typst_decoration(face)
    @test ExcelTableStyle(; title = crayon"bold red").title == excel_decoration(face)
    @test HtmlTableStyle(; first_line_column_label = [crayon"bold red", face]).first_line_column_label ==
        [html_decoration(face), html_decoration(face)]

    # The backend-agnostic style accepts crayons and vectors of crayons.
    style = TableStyle(; title = crayon"bold red", column_label = [crayon"bold red", face])
    @test style.title == face
    @test style.column_label == [face, face]
end
