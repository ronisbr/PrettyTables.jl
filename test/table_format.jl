## Description #############################################################################
#
# Tests related with the backend-agnostic table format.
#
############################################################################################

# Compare two table formats field by field, descending into the `borders` field since some
# border types contain vectors, which are not compared elementwise by the default `==` of
# immutable structures.
function _test_table_format_equal(a::T, b::T) where T
    for f in fieldnames(T)
        va = getfield(a, f)
        vb = getfield(b, f)

        if f == :borders
            for g in fieldnames(typeof(va))
                @test getfield(va, g) == getfield(vb, g)
            end
        else
            @test va == vb
        end
    end

    return nothing
end

@testset "LineStyle" begin
    ls = LineStyle()
    @test isnothing(ls.style)
    @test isnothing(ls.width)
    @test isnothing(ls.color)

    ls = LineStyle(; style = :dashed, width = :thick, color = :red)
    @test ls.style == :dashed
    @test ls.width == :thick
    @test ls.color == SimpleColor(:red)

    @testset "Color Normalization" begin
        @test LineStyle(; color = 0xff0000).color           == SimpleColor(0xff0000)
        @test LineStyle(; color = "#ff0000").color          == SimpleColor(0xff0000)
        @test LineStyle(; color = (255, 0, 0)).color        == SimpleColor(0xff0000)
        @test LineStyle(; color = SimpleColor(:cyan)).color == SimpleColor(:cyan)
    end

    @testset "Errors" begin
        @test_throws ArgumentError LineStyle(; style = :wavy)
        @test_throws ArgumentError LineStyle(; width = :huge)
        @test_throws ArgumentError LineStyle(; color = 1.0)
    end
end

@testset "Typst Line Style" begin
    @test typst_line_style(LineStyle(; width = :thin))   == "0.5pt"
    @test typst_line_style(LineStyle(; width = :medium)) == "1pt"
    @test typst_line_style(LineStyle(; width = :thick))  == "1.5pt"

    @test typst_line_style(LineStyle(; style = :solid))  == "(dash: \"solid\")"
    @test typst_line_style(LineStyle(; style = :dashed)) == "(dash: \"dashed\")"
    @test typst_line_style(LineStyle(; style = :dotted)) == "(dash: \"dotted\")"

    # Typst strokes have no double variant, so `:double` falls back to solid.
    @test typst_line_style(LineStyle(; style = :double)) == "(dash: \"solid\")"

    @test typst_line_style(LineStyle(; style = :dashed, width = :medium)) ==
        "(thickness: 1pt, dash: \"dashed\")"

    @test typst_line_style(
        LineStyle(; style = :dashed, width = :medium, color = 0x336699)
    ) == "(thickness: 1pt, paint: rgb(\"#336699\"), dash: \"dashed\")"

    @test typst_line_style(LineStyle(; width = :thick, color = :red)) ==
        "(thickness: 1.5pt, paint: rgb(\"#a51c2c\"))"

    # If only an unresolvable color is set, we fall back to the default Typst stroke.
    @test typst_line_style(LineStyle(; color = :default)) == "1pt"
end

@testset "Excel Line Style" begin
    # The full (style × width) matrix.
    for (kwargs, expected_style) in (
        ((;),                                  "thin"),
        ((; width = :medium),                  "medium"),
        ((; width = :thick),                   "thick"),
        ((; style = :dashed),                  "dashed"),
        ((; style = :dashed, width = :medium), "mediumDashed"),
        ((; style = :dashed, width = :thick),  "mediumDashed"),
        ((; style = :dotted),                  "dotted"),
        ((; style = :dotted, width = :thick),  "dotted"),
        ((; style = :double),                  "double"),
        ((; style = :double, width = :thick),  "double"),
    )
        @test excel_line_style(LineStyle(; kwargs...)) ==
            ["style" => expected_style, "color" => "Black"]
    end

    @test excel_line_style(LineStyle(; color = 0xff0000)) ==
        ["style" => "thin", "color" => "FFFF0000"]

    @test excel_line_style(LineStyle(; color = :red)) ==
        ["style" => "thin", "color" => "FFA51C2C"]

    # An unresolvable color falls back to black.
    @test excel_line_style(LineStyle(; color = :default)) ==
        ["style" => "thin", "color" => "Black"]
end

@testset "LaTeX Line Style" begin
    @test latex_line_style(LineStyle())                  == "\\hline"
    @test latex_line_style(LineStyle(; style = :solid))  == "\\hline"
    @test latex_line_style(LineStyle(; style = :double)) == "\\hline\\hline"
    @test latex_line_style(LineStyle(; style = :dashed)) == "\\hdashline"
    @test latex_line_style(LineStyle(; style = :dotted)) == "\\hdashline[1pt/1pt]"

    # The width and color are ignored.
    @test latex_line_style(LineStyle(; width = :thick, color = :red)) == "\\hline"
end

@testset "Sparse Merge" verbose = true begin
    @testset "Empty TableFormat Reproduces the Back End Defaults" begin
        for (converter, T) in (
            (PrettyTables._text__table_format,     TextTableFormat),
            (PrettyTables._html__table_format,     HtmlTableFormat),
            (PrettyTables._latex__table_format,    LatexTableFormat),
            (PrettyTables._markdown__table_format, MarkdownTableFormat),
            (PrettyTables._typst__table_format,    TypstTableFormat),
            (PrettyTables._excel__table_format,    ExcelTableFormat),
        )
            _test_table_format_equal(converter(TableFormat()), T())
        end
    end

    @testset "Native Formats Pass Through Unchanged" begin
        ttf = TextTableFormat()
        @test PrettyTables._text__table_format(ttf) === ttf

        htf = HtmlTableFormat()
        @test PrettyTables._html__table_format(htf) === htf

        ltf = LatexTableFormat()
        @test PrettyTables._latex__table_format(ltf) === ltf

        mtf = MarkdownTableFormat()
        @test PrettyTables._markdown__table_format(mtf) === mtf

        ytf = TypstTableFormat()
        @test PrettyTables._typst__table_format(ytf) === ytf

        etf = ExcelTableFormat()
        @test PrettyTables._excel__table_format(etf) === etf
    end

    @testset "Single Field Override" begin
        _test_table_format_equal(
            PrettyTables._latex__table_format(
                TableFormat(; vertical_lines_at_data_columns = :none)
            ),
            LatexTableFormat(; vertical_lines_at_data_columns = :none)
        )

        _test_table_format_equal(
            PrettyTables._typst__table_format(
                TableFormat(; horizontal_lines_at_data_rows = [1, 3])
            ),
            TypstTableFormat(; horizontal_lines_at_data_rows = [1, 3])
        )
    end

    @testset "Backend Default Divergences Are Preserved" begin
        # The text back end defaults `horizontal_line_at_merged_column_labels` to `false`,
        # whereas the other back ends default it to `true`. The sparse merge must keep both.
        for (converter, expected) in (
            (PrettyTables._text__table_format,  false),
            (PrettyTables._latex__table_format, true),
            (PrettyTables._typst__table_format, true),
            (PrettyTables._excel__table_format, true),
        )
            ntf = converter(TableFormat())
            @test ntf.horizontal_line_at_merged_column_labels == expected
        end
    end

    @testset "Empty LineStyle Keeps the Default Design" begin
        tf = TableFormat(; middle_line = LineStyle())

        @test PrettyTables._text__table_format(tf).middle_line === nothing

        @test PrettyTables._typst__table_format(tf).borders.middle_line ==
            TypstTableBorders().middle_line

        @test PrettyTables._latex__table_format(tf).borders.middle_line ==
            LatexTableBorders().middle_line

        @test PrettyTables._excel__table_format(tf).borders.middle_line ==
            ExcelTableBorders().middle_line
    end

    @testset "Markdown Mapping" begin
        @test PrettyTables._markdown__table_format(
            TableFormat(; horizontal_line_before_summary_rows = false)
        ).line_before_summary_rows == false
    end
end

# Compare two table styles field by field, skipping private fields (the text back end
# caches pre-rendered escape sequences in `_rendered`, which is not part of the public
# contract).
function _test_table_style_equal(a::Any, b::Any)
    for f in fieldnames(typeof(a))
        startswith(String(f), "_") && continue
        @test getfield(a, f) == getfield(b, f)
    end

    return nothing
end

@testset "TableStyle" verbose = true begin
    @testset "Empty TableStyle Reproduces the Back End Defaults" begin
        for (converter, T) in (
            (PrettyTables._text__table_style,     TextTableStyle),
            (PrettyTables._html__table_style,     HtmlTableStyle),
            (PrettyTables._latex__table_style,    LatexTableStyle),
            (PrettyTables._markdown__table_style, MarkdownTableStyle),
            (PrettyTables._typst__table_style,    TypstTableStyle),
            (PrettyTables._excel__table_style,    ExcelTableStyle),
        )
            _test_table_style_equal(converter(TableStyle()), T())
        end
    end

    @testset "Native Styles Pass Through Unchanged" begin
        ts = TextTableStyle()
        @test PrettyTables._text__table_style(ts) === ts

        hs = HtmlTableStyle()
        @test PrettyTables._html__table_style(hs) === hs

        ls = LatexTableStyle()
        @test PrettyTables._latex__table_style(ls) === ls

        ms = MarkdownTableStyle()
        @test PrettyTables._markdown__table_style(ms) === ms

        ys = TypstTableStyle()
        @test PrettyTables._typst__table_style(ys) === ys

        es = ExcelTableStyle()
        @test PrettyTables._excel__table_style(es) === es
    end

    @testset "Single Field Override" begin
        face = Face(; weight = :bold, foreground = :red)

        for (converter, T) in (
            (PrettyTables._text__table_style,     TextTableStyle),
            (PrettyTables._html__table_style,     HtmlTableStyle),
            (PrettyTables._latex__table_style,    LatexTableStyle),
            (PrettyTables._markdown__table_style, MarkdownTableStyle),
            (PrettyTables._typst__table_style,    TypstTableStyle),
            (PrettyTables._excel__table_style,    ExcelTableStyle),
        )
            _test_table_style_equal(
                converter(TableStyle(; row_label = face)),
                T(; row_label = face)
            )
        end
    end

    @testset "Column Label Vectors" begin
        faces = [Face(; foreground = :red), Face(; foreground = :blue)]

        _test_table_style_equal(
            PrettyTables._html__table_style(TableStyle(; column_label = faces)),
            HtmlTableStyle(; column_label = faces)
        )
    end

    @testset "Markdown Ignores Unsupported Fields" begin
        _test_table_style_equal(
            PrettyTables._markdown__table_style(
                TableStyle(; title = Face(; weight = :bold))
            ),
            MarkdownTableStyle()
        )
    end
end

@testset "Backend Resolution" begin
    resolve = PrettyTables._resolve_printing_backend

    @test resolve(Dict(:table_format => TableFormat())) == :text
    @test resolve(Dict(:table_format => TableFormat()); default = :html) == :html
    @test resolve(Dict{Symbol, Any}()) == :text
    @test resolve(Dict{Symbol, Any}(); default = :html) == :html
    @test resolve(Dict(:table_format => LatexTableFormat())) == :latex
    @test resolve(Dict(:table_format => LatexTableFormat()); default = :html) == :latex
end
