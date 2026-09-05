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

    # An unset width keeps the default thickness.
    @test typst_line_style(LineStyle(; style = :solid))  == "(thickness: 1pt, dash: \"solid\")"
    @test typst_line_style(LineStyle(; style = :dashed)) == "(thickness: 1pt, dash: \"dashed\")"
    @test typst_line_style(LineStyle(; style = :dotted)) == "(thickness: 1pt, dash: \"dotted\")"

    # Typst strokes have no double variant, so `:double` falls back to solid.
    @test typst_line_style(LineStyle(; style = :double)) == "(thickness: 1pt, dash: \"solid\")"

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
        # The text and HTML back ends default `horizontal_line_at_merged_column_labels` to
        # `false`, whereas the other back ends default it to `true`. The sparse merge must
        # keep both.
        for (converter, expected) in (
            (PrettyTables._text__table_format,  false),
            (PrettyTables._html__table_format,  false),
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

    @testset "HTML-Only Presence Fields" begin
        # The HTML-only presence fields must be merged by the HTML converter and silently
        # ignored by the other back ends.
        tf = TableFormat(;
            horizontal_line_before_column_labels = false,
            horizontal_line_after_footnotes      = false,
            horizontal_line_at_end               = false,
        )

        htf = PrettyTables._html__table_format(tf)
        @test htf.horizontal_line_before_column_labels == false
        @test htf.horizontal_line_after_footnotes      == false
        @test htf.horizontal_line_at_end               == false

        _test_table_format_equal(PrettyTables._typst__table_format(tf), TypstTableFormat())
        _test_table_format_equal(PrettyTables._text__table_format(tf),  TextTableFormat())
    end
end

@testset "Helper Macros" verbose = true begin
    @testset "All Lines" begin
        tf = TableFormat(; @all_horizontal_lines, @all_vertical_lines)

        _test_table_format_equal(
            PrettyTables._html__table_format(tf),
            HtmlTableFormat(; @html__all_horizontal_lines, @html__all_vertical_lines)
        )

        _test_table_format_equal(
            PrettyTables._text__table_format(tf),
            # `TableFormat` has no counterpart of the text-only field
            # `horizontal_lines_at_column_labels`, which keeps the text default.
            TextTableFormat(;
                @text__all_horizontal_lines,
                @text__all_vertical_lines,
                horizontal_lines_at_column_labels = :none,
            )
        )

        _test_table_format_equal(
            PrettyTables._typst__table_format(tf),
            TypstTableFormat(; @typst__all_horizontal_lines, @typst__all_vertical_lines)
        )

        _test_table_format_equal(
            PrettyTables._latex__table_format(tf),
            LatexTableFormat(; @latex__all_horizontal_lines, @latex__all_vertical_lines)
        )

        # `@excel__all_horizontal_lines` also sets the Excel-only field
        # `horizontal_line_between_column_labels`, which the backend-agnostic table format
        # cannot express. Hence, we must reset it to the default before comparing.
        _test_table_format_equal(
            PrettyTables._excel__table_format(tf),
            ExcelTableFormat(;
                @excel__all_horizontal_lines,
                @excel__all_vertical_lines,
                horizontal_line_between_column_labels = false,
            )
        )
    end

    @testset "No Lines" begin
        tf = TableFormat(; @no_horizontal_lines, @no_vertical_lines)

        _test_table_format_equal(
            PrettyTables._html__table_format(tf),
            HtmlTableFormat(; @html__no_horizontal_lines, @html__no_vertical_lines)
        )

        # `@text__no_vertical_lines` also sets the text-only field
        # `suppress_vertical_lines_at_column_labels`, which the backend-agnostic table
        # format cannot express. Hence, we must reset it to the default before comparing.
        _test_table_format_equal(
            PrettyTables._text__table_format(tf),
            TextTableFormat(;
                @text__no_horizontal_lines,
                @text__no_vertical_lines,
                suppress_vertical_lines_at_column_labels = false,
            )
        )

        _test_table_format_equal(
            PrettyTables._typst__table_format(tf),
            TypstTableFormat(; @typst__no_horizontal_lines, @typst__no_vertical_lines)
        )

        _test_table_format_equal(
            PrettyTables._latex__table_format(tf),
            LatexTableFormat(; @latex__no_horizontal_lines, @latex__no_vertical_lines)
        )

        _test_table_format_equal(
            PrettyTables._excel__table_format(tf),
            ExcelTableFormat(; @excel__no_horizontal_lines, @excel__no_vertical_lines)
        )
    end

    @testset "Merging Overrides" begin
        tf = TableFormat(; @no_horizontal_lines, horizontal_line_at_beginning = true)
        @test tf.horizontal_line_at_beginning == true
        @test tf.horizontal_line_after_column_labels == false

        tf = TableFormat(; @all_vertical_lines, vertical_line_at_beginning = false)
        @test tf.vertical_line_at_beginning == false
        @test tf.vertical_lines_at_data_columns == :all
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

@testset "Line Style Defaults" begin
    # An unset aspect keeps the corresponding aspect of the back end default line.
    @test html_line_style(LineStyle(; color = :red); default = "2px solid black") ==
        "2px solid #a51c2c"
    @test html_line_style(LineStyle(; style = :dashed); default = "2px solid black") ==
        "2px dashed black"
    @test html_line_style(LineStyle(; width = :thick)) == "3px solid black"

    @test typst_line_style(LineStyle(; color = :red); default = "1.5pt") ==
        "(thickness: 1.5pt, paint: rgb(\"#a51c2c\"))"
    @test typst_line_style(LineStyle(; style = :dashed)) == "(thickness: 1pt, dash: \"dashed\")"
    @test typst_line_style(LineStyle(; width = :thick); default = "0.5pt") == "1.5pt"

    @test excel_line_style(
        LineStyle(; color = :red);
        default = ["style" => "thick", "color" => "Black"]
    ) == ["style" => "thick", "color" => "FFA51C2C"]
    @test excel_line_style(
        LineStyle(; style = :dashed);
        default = ["style" => "medium", "color" => "Black"]
    ) == ["style" => "mediumDashed", "color" => "Black"]

    @test latex_line_style(LineStyle(; style = :dashed); default = "\\hline") == "\\hdashline"

    tf = TableFormat(; top_line = LineStyle(; color = :red))
    @test PrettyTables._html__table_format(tf).borders.top_line == "2px solid #a51c2c"
    @test PrettyTables._typst__table_format(tf).borders.top_line ==
        "(thickness: 1.5pt, paint: rgb(\"#a51c2c\"))"
    @test PrettyTables._excel__table_format(tf).borders.top_line ==
        ["style" => "thick", "color" => "FFA51C2C"]
end

@testset "Line Style Validation" begin
    @test_throws ArgumentError LineStyle(:bogus, nothing, nothing)
    @test_throws ArgumentError LineStyle(nothing, :huge, nothing)
    @test_throws ArgumentError LineStyle(nothing, nothing, 1.0)

    ls = LineStyle(:dashed, :thick, :red)
    @test (ls.style == :dashed) && (ls.width == :thick) && (ls.color == SimpleColor(:red))
end

@testset "Foreign Styles and Formats" begin
    @test_throws ArgumentError pretty_table(String, [1 2]; backend = :text, style = HtmlTableStyle())
    @test_throws ArgumentError pretty_table(String, [1 2]; backend = :html, table_format = TextTableFormat())
    @test_throws ArgumentError pretty_table(String, [1 2]; backend = :latex, style = TypstTableStyle())
    @test_throws ArgumentError pretty_table(String, [1 2]; backend = :markdown, table_format = HtmlTableFormat())
    @test_throws ArgumentError pretty_table(String, [1 2]; backend = :typst, style = LatexTableStyle())

    # A native style selects the back end when the table format does not.
    resolve = PrettyTables._resolve_printing_backend
    @test resolve(Dict(:style => HtmlTableStyle())) == :html
    @test resolve(Dict(:style => TypstTableStyle(), :table_format => TableFormat())) == :typst
    @test resolve(Dict(:style => TableStyle())) == :text
    @test occursin("<table", pretty_table(String, [1 2]; style = HtmlTableStyle()))
end

@testset "Text Line Macros" begin
    tf = TextTableFormat(; @text__all_horizontal_lines)
    @test tf.horizontal_lines_at_column_labels == :all
    @test tf.horizontal_line_at_merged_column_labels

    tf = TextTableFormat(; @text__no_horizontal_lines)
    @test tf.horizontal_lines_at_column_labels == :none
    @test !tf.horizontal_line_at_merged_column_labels
end
