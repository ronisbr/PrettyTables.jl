## Description #############################################################################
#
# Word Back End: Documentation for the Word backend.
#
############################################################################################

"""
# Word Backend

The Word back end can be selected by passing the keyword `backend = :docx` to the function
[`pretty_table`](@ref). It renders the table as a Word (`.docx`) table, either written to a
file or returned as a `WriteDocx.Table` that can be embedded in a larger document.

The back end's return value depends on the keyword `filename`:

- `String` (the filename) when `filename` is a `String`.
- `WriteDocx.Table` when `filename` is `nothing`.

!!! note

    This back end requires [WriteDocx.jl](https://github.com/PumasAI/WriteDocx.jl) to be
    loaded.

## Keywords

- `filename::Union{Nothing, String}`: Path of the Word file to write, which must end in
    `.docx`. When `nothing`, the `WriteDocx.Table` is returned instead of being written to a
    document.
    (**Default**: `nothing`)
- `highlighters::Vector{AbstractHighlighter}`: Highlighters to apply to the data cells. See
    [`DocxHighlighter`](@ref).
    (**Default**: `AbstractHighlighter[]`)
- `style::DocxTableStyle`: Text and cell style of each table section. See
    [`DocxTableStyle`](@ref).
    (**Default**: `DocxTableStyle()`)
- `table_format::DocxTableFormat`: Border configuration of the table. See
    [`DocxTableFormat`](@ref).
    (**Default**: `DocxTableFormat()`)

## Examples

```julia
julia> using PrettyTables, WriteDocx

julia> pretty_table([1 2 3; 4 5 6]; backend = :docx, filename = "table.docx")
"table.docx"
```

The `WriteDocx.Table` returned when `filename` is `nothing` can be placed inside a document
together with other content:

```julia
julia> import WriteDocx as W

julia> table = pretty_table(W.Table, [1 2 3; 4 5 6]; title = "My Table")

julia> doc = W.Document(
           W.Body([
               W.Section([
                   W.Paragraph([W.Run([W.Text("The results are:")])]),
                   table,
               ]),
           ]),
       )

julia> W.save("report.docx", doc)
```

## Table Sections

The Word table has one row per table section. The title, the subtitle, the row group
labels, the footnotes, and the source notes are rendered in rows that span the entire table
width, whereas the other sections are rendered in the corresponding cells.

Word decides the column widths from the cell content. Hence, this back end has no keyword to
configure them.

Footnote markers are rendered as superscript text runs, and a line break inside a cell is
rendered as a Word line break, keeping the cell content in a single paragraph. A tab inside a
cell is rendered as a Word tab. The ANSI escape sequences and the characters that cannot be
written in a Word document (for example, the null character) are removed from the text.

Each region of a styled string of StyledStrings.jl (Julia 1.11 or newer) becomes a text run
with the attributes of its face (see [Faces](@ref)). As in the Excel back end, the attributes
of the table style and of the highlighter applied to the cell take precedence over the ones
of the regions.

## Table Format

The lines of the Word table are configured with the structure [`DocxTableFormat`](@ref),
which selects which lines are drawn and the border style of each line type (see
[`DocxTableBorders`](@ref)). Word draws no line unless the corresponding border is
requested. The helper macros [`@docx__all_horizontal_lines`](@ref),
[`@docx__no_horizontal_lines`](@ref), [`@docx__all_vertical_lines`](@ref), and
[`@docx__no_vertical_lines`](@ref) return the keywords to enable or suppress every line.

A backend-agnostic [`TableFormat`](@ref) is also accepted, in which case the line designs
are converted with [`docx_line_style`](@ref).

## Table Style

The style of each table section is configured with the structure [`DocxTableStyle`](@ref).
Each field is a vector of [`DocxPair`](@ref), *i.e.* `Pair{String, String}`, with the keys
`"bold"`, `"italic"`, `"strike"`, `"underline"`, `"color"`, `"background"`, `"font"`, and
`"size"`. For example, if we want the stubhead label to be bold and red, we must define:

```julia
style = DocxTableStyle(stubhead_label = ["bold" => "true", "color" => "FF0000"])
```

The colors accept a 6-digit hexadecimal string (with or without the leading `#`) or one of
the color names supported by Crayons.jl, whereas `"size"` is the font size in points.

Every keyword of the constructor of [`DocxTableStyle`](@ref) also accepts a `Face`, which is
converted to Word attributes with [`docx_decoration`](@ref) (see [Faces](@ref)).

!!! note

    Word shades an entire cell rather than a text run. Hence, `"background"` always shades
    the cell, and the background of the face of a section of a styled string is dropped.
"""
pretty_table_docx_backend
