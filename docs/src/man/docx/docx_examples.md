# Word Backend Examples

Here we show some examples of the Word back end. They require
[WriteDocx.jl](https://github.com/PumasAI/WriteDocx.jl) and write `.docx` files that can be
opened with Microsoft Word or LibreOffice.

```julia
using PrettyTables
import WriteDocx as W
```

## Writing a File

The keyword `filename` writes a document with a single section containing the table. An
existing file is only replaced if `overwrite = true`. The default font of the document is
Calibri, which can be changed with the keyword `default_font`. The fonts selected by the
table style and highlighters take precedence over it.

```julia
data = [
    "Atmospheric drag"          10.0 6.5
    "Gravity gradient"           3.0 3.0
    "Solar radiation pressure"   0.1 1.0
];

pretty_table(
    data;
    backend = :docx,
    column_labels = ["Effect", "Torque [10⁻⁶ Nm]", "Angular Momentum [10⁻³ Nms]"],
    default_font = "Arial",
    filename = "output.docx",
    overwrite = true,
    title = "Table 1. Disturbances acting on the satellite.",
)
```

## Embedding the Table in a Document

When `filename` is omitted, the back end returns a `WriteDocx.Table`, which can be placed
in a larger document together with other content. The method
`pretty_table(WriteDocx.Table, data; kwargs...)` always returns the table object. In this
case, the default font is defined by the styles of the document. Otherwise, Word uses Times
New Roman.

```julia
data = [
    1 2.0 "A"
    3 4.0 "B"
];

table_1 = pretty_table(W.Table, data; title = "Table 1. First results.");
table_2 = pretty_table(W.Table, 2 .* data[:, 1:2]; title = "Table 2. Second results.");

styles = W.Styles(W.Style[]; run = W.RunProperties(; fonts = W.Fonts("Calibri")));

doc = W.Document(
    W.Body([
        W.Section([
            W.Paragraph([W.Run([W.Text("The first results are:")])]),
            table_1,
            W.Paragraph([W.Run([W.Text("The second results are:")])]),
            table_2,
        ]),
    ]);
    styles,
);

W.save("output.docx", doc)
```

## Word Highlighters

```julia
t = 0:1:20;

data = hcat(t, ones(length(t)), t, 0.5 .* t .^ 2);

column_labels = [
    ["Time", "Acceleration", "Velocity", "Distance"],
    [ "[s]",     "[m / s²]",  "[m / s]",      "[m]"],
];

hl_p = DocxHighlighter(
    (data, i, j) -> (j == 4) && (data[i, j] > 9),
    ["color" => "000080", "bold" => "true"]
);

hl_v = DocxHighlighter(
    (data, i, j) -> (j == 3) && (data[i, j] > 9),
    ["color" => "800000", "bold" => "true"]
);

hl_10 = DocxHighlighter(
    (data, i, j) -> (i == 10),
    ["color" => "FFFFFF", "bold" => "true", "background" => "404040"]
);

# The general highlighter defined by a face also works with the Word back end.
hl_0 = Highlighter((data, i, j) -> data[i, j] == 0; foreground = :blue, slant = :italic);

pretty_table(
    data;
    backend = :docx,
    column_labels,
    filename = "output.docx",
    formatters = [fmt__printf("%.1f", [2, 3, 4])],
    highlighters = [hl_10, hl_p, hl_v, hl_0],
    overwrite = true,
    style = DocxTableStyle(;
        first_line_column_label = ["color" => "FFA500", "bold" => "true"]
    ),
)
```

## Word Table Style

```julia
data = [
    10.0 6.5
     3.0 3.0
     0.1 1.0
];

row_labels = [
    "Atmospheric drag"
    "Gravity gradient"
    "Solar radiation pressure"
];

column_labels = [
    [MultiColumn(2, "Value", :c)],
    ["Torque [10⁻⁶ Nm]", "Angular Momentum [10⁻³ Nms]"],
];

pretty_table(
    data;
    backend = :docx,
    column_labels,
    filename = "output.docx",
    overwrite = true,
    row_labels,
    stubhead_label = "Effect",
    style = DocxTableStyle(;
        first_line_merged_column_label = ["color" => "000080", "bold" => "true"],
        column_label                   = ["color" => "808080"],
        stubhead_label                 = ["color" => "000080", "bold" => "true"],
        summary_row_label              = ["color" => "FFA500", "bold" => "true"],
        data_cell                      = ["font" => "Courier New", "size" => "10.5"],
    ),
    summary_row_labels = ["Total"],
    summary_rows = [(data, i) -> sum(data[:, i])],
)
```

## Word Borders and Shading

The lines are selected by the fields of [`DocxTableFormat`](@ref) and designed by the fields
of [`DocxTableBorders`](@ref), whose sizes are given in eighths of a point.

```julia
data = rand(1:100, 6, 4);

table_format = DocxTableFormat(;
    @docx__no_vertical_lines,
    horizontal_lines_at_data_rows = [2, 4],
    borders = DocxTableBorders(;
        top_line    = ["style" => "double", "size" => "6", "color" => "1F4E79"],
        header_line = ["style" => "single", "size" => "12", "color" => "1F4E79"],
        middle_line = ["style" => "dotted", "size" => "4", "color" => "808080"],
        bottom_line = ["style" => "double", "size" => "6", "color" => "1F4E79"],
    ),
    cell_margins = (3.0, 8.0, 3.0, 8.0),
);

style = DocxTableStyle(;
    first_line_column_label = [
        "bold" => "true", "color" => "FFFFFF", "background" => "1F4E79"
    ],
    row_group_label = ["italic" => "true", "background" => "DDEBF7"],
);

pretty_table(
    data;
    backend = :docx,
    filename = "output.docx",
    overwrite = true,
    row_group_labels = [1 => "First group", 4 => "Second group"],
    style,
    table_format,
)
```

The backend-agnostic [`TableFormat`](@ref) and [`TableStyle`](@ref) are also accepted, so
that the same configuration can be used with every back end:

```julia
table_format = TableFormat(;
    @no_vertical_lines,
    header_line = LineStyle(; style = :dashed, width = :medium, color = :blue),
);

style = TableStyle(; first_line_column_label = Face(; weight = :bold, foreground = :blue));

pretty_table(
    data;
    backend = :docx,
    filename = "output.docx",
    overwrite = true,
    style,
    table_format,
)
```

## Column Widths

By default, Word adjusts the columns to the content. If any of the width keywords is set,
the table uses a fixed layout with the widths in points.

```julia
data = [
    "A short text"  "A very long text that will be wrapped because the column is narrow"
    "Another text"  "Short"
];

pretty_table(
    data;
    backend = :docx,
    column_labels = ["Fixed width", "Maximum width"],
    data_column_widths = [100, 0],
    filename = "output.docx",
    maximum_data_column_widths = [0, 150],
    overwrite = true,
)
```

## Putting It All Together

```julia
# == Creating the Table ====================================================================

v1_t = 0:5:20;
v1_a = ones(length(v1_t)) * 1.0;
v1_v = @. 0 + v1_a * v1_t;
v1_d = @. 0 + v1_a * v1_t^2 / 2;

v2_t = 0:5:20;
v2_a = ones(length(v2_t)) * 0.75;
v2_v = @. 0 + v2_a * v2_t;
v2_d = @. 0 + v2_a * v2_t^2 / 2;

table = [
    v1_t v1_a v1_v v1_d
    v2_t v2_a v2_v v2_d
];

# == Configuring the Table =================================================================

title = "Table 1. Data obtained from the test procedure.";

subtitle = "Comparison between two vehicles";

column_labels = [
    [EmptyCells(2), MultiColumn(2, "Estimated Data")],
    ["Time", "Acceleration", "Velocity", "Position"],
    ["[s]", "[m / s²]", "[m / s]", "[m]"],
];

row_group_labels = [1 => "Vehicle #1", 6 => "Vehicle #2"];

footnotes = [
    (:column_label, 1, 3) => "Estimated data based on the acceleration measurement.",
    (:data, 5, 4)         => "Maximum distance of the first vehicle.",
];

source_notes = "Source: Test procedure conducted on 2024-01-15.";

summary_rows = [(data, i) -> maximum(@view data[:, i])];

highlighters = [
    Highlighter((data, i, j) -> (j == 4) && (data[i, j] > 100); foreground = :red),
];

style = DocxTableStyle(;
    title               = ["bold" => "true", "size" => "14"],
    subtitle            = ["italic" => "true", "color" => "595959"],
    column_label        = ["italic" => "true", "color" => "808080"],
    row_group_label     = ["bold" => "true", "background" => "F2F2F2"],
    summary_row_label   = ["bold" => "true"],
    summary_row_cell    = ["bold" => "true"],
);

table_format = DocxTableFormat(; @docx__no_vertical_lines);

# == Printing the Table ====================================================================

docx_table = pretty_table(
    W.Table,
    table;
    column_labels,
    footnotes,
    formatters = [fmt__printf("%.1f", [2, 3, 4])],
    highlighters,
    merge_column_label_cells = :auto,
    row_group_labels,
    show_row_number_column = true,
    source_notes,
    style,
    subtitle,
    summary_row_labels = ["Max."],
    summary_rows,
    table_format,
    title,
);

W.save("output.docx", W.Document(W.Body([W.Section([docx_table])])))
```
