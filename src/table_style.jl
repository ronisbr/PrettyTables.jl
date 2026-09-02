## Description #############################################################################
#
# Backend-agnostic table style used to configure the table decorations in every back end.
#
############################################################################################

export TableStyle

"""
    struct TableStyle

Describe the table decorations independently from the back end using `Face` objects. This
object can be passed to the keyword `style` of `pretty_table` with any back end, allowing
the user to switch back ends without rewriting the style configuration. Whereas the table
format states how the table is printed, the table style states how it is decorated. The
keyword constructor also accepts crayons, which are converted to the equivalent faces.

Every field set to `nothing` keeps the default decoration of the selected back end. Hence,
a `TableStyle` never replaces the back end table style entirely: each set field overrides
only the corresponding field of the back end default style. The faces are converted to the
native decorations by the keyword constructors of the back end style types (see
[`html_decoration`](@ref), [`latex_decoration`](@ref), [`markdown_decoration`](@ref),
[`typst_decoration`](@ref), and [`excel_decoration`](@ref)).

The conversion is a best effort: the Markdown back end ignores `title`, `subtitle`,
`first_line_merged_column_label`, and `merged_column_label` because its style type does not
have those fields. The backend-specific style fields (for example, `table_border` of the
text back end and `data_cell` of the Excel back end) are not part of `TableStyle` and
remain available in the native table styles.

# Fields

- `title::Union{Nothing, Face}`: Face of the title.
    (**Default**: `nothing`)
- `subtitle::Union{Nothing, Face}`: Face of the subtitle.
    (**Default**: `nothing`)
- `row_number_label::Union{Nothing, Face}`: Face of the row number label.
    (**Default**: `nothing`)
- `row_number::Union{Nothing, Face}`: Face of the row numbers.
    (**Default**: `nothing`)
- `stubhead_label::Union{Nothing, Face}`: Face of the stubhead label.
    (**Default**: `nothing`)
- `row_label::Union{Nothing, Face}`: Face of the row labels.
    (**Default**: `nothing`)
- `row_group_label::Union{Nothing, Face}`: Face of the row group labels.
    (**Default**: `nothing`)
- `first_line_column_label::Union{Nothing, Face, Vector{Face}}`: Face of the first column
    label line, or a vector with one face per column.
    (**Default**: `nothing`)
- `column_label::Union{Nothing, Face, Vector{Face}}`: Face of the other column label
    lines, or a vector with one face per column.
    (**Default**: `nothing`)
- `first_line_merged_column_label::Union{Nothing, Face}`: Face of the merged cells at the
    first column label line.
    (**Default**: `nothing`)
- `merged_column_label::Union{Nothing, Face}`: Face of the merged cells at the other
    column label lines.
    (**Default**: `nothing`)
- `summary_row_label::Union{Nothing, Face}`: Face of the summary row labels.
    (**Default**: `nothing`)
- `summary_row_cell::Union{Nothing, Face}`: Face of the summary row cells.
    (**Default**: `nothing`)
- `footnote::Union{Nothing, Face}`: Face of the footnotes.
    (**Default**: `nothing`)
- `source_note::Union{Nothing, Face}`: Face of the source notes.
    (**Default**: `nothing`)
"""
struct TableStyle
    title::Union{Nothing, Face}
    subtitle::Union{Nothing, Face}
    row_number_label::Union{Nothing, Face}
    row_number::Union{Nothing, Face}
    stubhead_label::Union{Nothing, Face}
    row_label::Union{Nothing, Face}
    row_group_label::Union{Nothing, Face}
    first_line_column_label::Union{Nothing, Face, Vector{Face}}
    column_label::Union{Nothing, Face, Vector{Face}}
    first_line_merged_column_label::Union{Nothing, Face}
    merged_column_label::Union{Nothing, Face}
    summary_row_label::Union{Nothing, Face}
    summary_row_cell::Union{Nothing, Face}
    footnote::Union{Nothing, Face}
    source_note::Union{Nothing, Face}
end

"""
    TableStyle(; kwargs...) -> TableStyle

Create a `TableStyle` in which each field can be passed as a keyword. Every keyword accepts
a `Face` or a `Crayon`, which is converted to the equivalent face. The keywords
`first_line_column_label` and `column_label` also accept a vector of faces or crayons.
"""
function TableStyle(;
    title                          = nothing,
    subtitle                       = nothing,
    row_number_label               = nothing,
    row_number                     = nothing,
    stubhead_label                 = nothing,
    row_label                      = nothing,
    row_group_label                = nothing,
    first_line_column_label        = nothing,
    column_label                   = nothing,
    first_line_merged_column_label = nothing,
    merged_column_label            = nothing,
    summary_row_label              = nothing,
    summary_row_cell               = nothing,
    footnote                       = nothing,
    source_note                    = nothing,
)
    return TableStyle(
        _table_style_face(title),
        _table_style_face(subtitle),
        _table_style_face(row_number_label),
        _table_style_face(row_number),
        _table_style_face(stubhead_label),
        _table_style_face(row_label),
        _table_style_face(row_group_label),
        _table_style_faces(first_line_column_label),
        _table_style_faces(column_label),
        _table_style_face(first_line_merged_column_label),
        _table_style_face(merged_column_label),
        _table_style_face(summary_row_label),
        _table_style_face(summary_row_cell),
        _table_style_face(footnote),
        _table_style_face(source_note),
    )
end

"""
    _table_style_face(decoration::Union{Nothing, Face, Crayon}) -> Union{Nothing, Face}

Convert the `decoration` passed to `TableStyle`, a face or a crayon, into a face, keeping
`nothing` unchanged.
"""
_table_style_face(::Nothing)       = nothing
_table_style_face(face::Face)      = face
_table_style_face(crayon::Crayon)  = _face_from_crayon(crayon)

"""
    _table_style_faces(decorations::Any) -> Union{Nothing, Face, Vector{Face}}

Convert the `decorations` passed to the column label fields of `TableStyle`, a face, a
crayon, or a vector of them, into a face or a vector of faces, keeping `nothing` unchanged.
"""
_table_style_faces(decoration::Union{Nothing, Face, Crayon}) = _table_style_face(decoration)
_table_style_faces(faces::Vector{Face})                       = faces
_table_style_faces(decorations::AbstractVector) = Face[_table_style_face(d) for d in decorations]

"""
    _table_style_kwargs(style::TableStyle; drop::Tuple = ()) -> Vector{Pair{Symbol, Any}}

Return the fields of `style` that are not `nothing` as keyword pairs for the keyword
constructor of a back end table style, skipping the fields listed in `drop` (used by back
ends whose style type does not have every field of [`TableStyle`](@ref)).
"""
function _table_style_kwargs(style::TableStyle; drop::Tuple = ())
    kwargs = Pair{Symbol, Any}[]

    for f in fieldnames(TableStyle)
        f ∈ drop && continue
        v = getfield(style, f)
        isnothing(v) || push!(kwargs, f => v)
    end

    return kwargs
end
