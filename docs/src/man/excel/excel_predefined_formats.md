# Pre-defined Formats

```@meta
CurrentModule = PrettyTables
```

```@setup text_backend_predefined_formats
using PrettyTables
```

The text backend has some predefined borders and formats to print tables.

```@setup text_backend_predefined_formats
data = Any[
    1    false      1.0     0x01
    2     true      2.0     0x02
    3    false      3.0     0x03
];
```

## Borders

We can change the printed table borders using the parameter `borders` in the structure
[`TextTableFormat`](@ref) passed to the keyword `table_format`.

`text_table_borders__ascii_dots`

```@repl text_backend_predefined_formats
pretty_table(
  data;
  backend = :text,
  table_format = TextTableFormat(borders = text_table_borders__ascii_dots)
)
```

`text_table_borders__ascii_rounded`

```@repl text_backend_predefined_formats
pretty_table(
  data;
  backend = :text,
  table_format = TextTableFormat(borders = text_table_borders__ascii_rounded)
)
```

`text_table_borders__borderless`

```@repl text_backend_predefined_formats
pretty_table(
  data;
  backend = :text,
  table_format = TextTableFormat(borders = text_table_borders__borderless)
)
```

`text_table_borders__compact`

```@repl text_backend_predefined_formats
pretty_table(
  data;
  backend = :text,
  table_format = TextTableFormat(borders = text_table_borders__compact)
)
```

`text_table_borders__matrix`

```@repl text_backend_predefined_formats
pretty_table(
  data;
  backend = :text,
  table_format = TextTableFormat(borders = text_table_borders__matrix)
)
```

`text_table_borders__mysql`

```@repl text_backend_predefined_formats
pretty_table(
  data;
  backend = :text,
  table_format = TextTableFormat(borders = text_table_borders__mysql)
)
```

`text_table_borders__simple`

```@repl text_backend_predefined_formats
pretty_table(
  data;
  backend = :text,
  table_format = TextTableFormat(borders = text_table_borders__simple)
)
```

`text_table_borders__unicode_rounded`

```@repl text_backend_predefined_formats
pretty_table(
  data;
  backend = :text,
  table_format = TextTableFormat(borders = text_table_borders__unicode_rounded)
)
```

## Formats

The text backend also defines some pre-defined formats to print tables that can be used
through the keyword `table_format` in [`pretty_table`](@ref).

`text_table_format__matrix`

```@repl text_backend_predefined_formats
pretty_table(
  ones(3, 3);
  backend = :text,
  show_column_labels = false,
  table_format = text_table_format__matrix
)
```
