# Text Backend Examples

```@meta
CurrentModule = PrettyTables
```

```@setup text_examples
using PrettyTables

function create_text_example(str::String, filename::String, width::Int = 92)
  write("tmp", str)
  run(`ansitoimg --width $width --title "PrettyTables.jl (generated by AnsiToImg)" tmp $filename`)
  run(`rm tmp`)
  return nothing
end
```

Here, we can see some examples of text tables generated by PrettyTables.jl. The `A` object,
when referenced, is defined as:

```julia-repl
julia> A = Any[
    1    false      1.0     0x01
    2     true      2.0     0x02
    3    false      3.0     0x03
    4     true      4.0     0x04
    5    false      5.0     0x05
    6     true      6.0     0x06
]
```

```@setup text_examples
A = Any[
    1    false      1.0     0x01
    2     true      2.0     0x02
    3    false      3.0     0x03
    4     true      4.0     0x04
    5    false      5.0     0x05
    6     true      6.0     0x06
]
```

---

```julia-repl
julia> pretty_table(A)
```

```@setup text_examples
table = pretty_table(
    String,
    A;
    color = true
)

create_text_example(table, "text_example_01.svg")
```

```@raw html
<img src="../text_example_01.svg" alt="Text Example 01">
```

---

```julia-repl
julia> pretty_table(A; style = TextTableStyle(; table_border = crayon"yellow"))
```

```@setup text_examples
table = pretty_table(
  String,
  A;
  color = true,
  style = TextTableStyle(; table_border = crayon"yellow")
)

create_text_example(table, "text_example_02.svg")
```

```@raw html
<img src="../text_example_02.svg" alt="Text Example 02">
```

---

```julia-repl
julia> data = [
    10.0 6.5
     3.0 3.0
     0.1 1.0
]

julia> row_labels = [
    "Atmospheric drag"
    "Gravity gradient"
    "Solar radiation pressure"
]

julia> column_labels = [
    [MultiColumn(2, "Value", :c)],
    [
        "Torque [10⁻⁶ Nm]",
        "Angular Momentum [10⁻³ Nms]"
    ]
]

julia> pretty_table(
    data;
    column_labels,
    merge_column_label_cells = :auto,
    row_labels,
    stubhead_label = "Effect",
    style = TextTableStyle(;
        first_line_merged_column_label = crayon"bold yellow",
        stubhead_label = crayon"bold yellow",
        summary_row_label = crayon"bold cyan"
    ),
    summary_row_labels = ["Total"],
    summary_rows = [(data, i) -> sum(data[:, i])],
    table_format = TextTableFormat(;
        @text__no_vertical_lines,
        horizontal_lines_at_column_labels = [1],
        vertical_line_after_row_label_column = true
    ),
)
```

```@setup text_examples
data = [
    10.0 6.5
     3.0 3.0
     0.1 1.0
]

row_labels = [
    "Atmospheric drag"
    "Gravity gradient"
    "Solar radiation pressure"
]

column_labels = [
    [MultiColumn(2, "Value", :c)],
    [
        "Torque [10⁻⁶ Nm]",
        "Angular Momentum [10⁻³ Nms]"
    ]
]

table = pretty_table(
    String,
    data;
    color = true,
    column_labels,
    merge_column_label_cells = :auto,
    row_labels,
    stubhead_label = "Effect",
    style = TextTableStyle(;
        first_line_merged_column_label = crayon"bold yellow",
        stubhead_label = crayon"bold yellow",
        summary_row_label = crayon"bold cyan"
    ),
    summary_row_labels = ["Total"],
    summary_rows = [(data, i) -> sum(data[:, i])],
    table_format = TextTableFormat(;
        @text__no_vertical_lines,
        horizontal_lines_at_column_labels = [1],
        vertical_line_after_row_label_column = true
    ),
)
create_text_example(table, "text_example_03.svg")
```

```@raw html
<img src="../text_example_03.svg" alt="Text Example 03">
```

---

```julia-repl
julia> t = 0:1:20

julia> data = hcat(t, ones(length(t) ), t, 0.5.*t.^2);

julia> column_labels = [
    ["Time", "Acceleration", "Velocity", "Distance"],
    [ "[s]",     "[m / s²]",  "[m / s]",      "[m]"]
]

julia> hl_p = TextHighlighter(
    (data, i, j) -> (j == 4) && (data[i, j] > 9),
    crayon"bold blue"
)

julia> hl_v = TextHighlighter(
    (data, i, j) -> (j == 3) && (data[i, j] > 9),
    crayon"bold red"
)

julia> pretty_table(
    data;
    column_labels = column_labels,
    highlighters  = [hl_p, hl_v],
    style = TextTableStyle(;
        first_line_column_label = crayon"bold yellow",
    )
)
```

```@setup text_examples
t = 0:1:20

data = hcat(t, ones(length(t) ), t, 0.5.*t.^2);

column_labels = [
    ["Time", "Acceleration", "Velocity", "Distance"],
    [ "[s]",     "[m / s²]",  "[m / s]",      "[m]"]
]

hl_p = TextHighlighter(
    (data, i, j) -> (j == 4) && (data[i, j] > 9),
    crayon"bold blue"
)

hl_v = TextHighlighter(
    (data, i, j) -> (j == 3) && (data[i, j] > 9),
    crayon"bold red"
)

table = pretty_table(
    String,
    data;
    color = true,
    column_labels = column_labels,
    highlighters  = [hl_p, hl_v],
    style = TextTableStyle(;
        first_line_column_label = crayon"bold yellow",
    )
)

create_text_example(table, "text_example_04.svg")
```

```@raw html
<img src="../text_example_04.svg" alt="Text Example 04">
```
