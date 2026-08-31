## Description #############################################################################
#
# Typst Back End: Conversion of the backend-agnostic table format and style.
#
############################################################################################

"""
    _typst__table_style(style::Union{TableStyle, TypstTableStyle}) -> TypstTableStyle

Convert `style` to a `TypstTableStyle`. A native `TypstTableStyle` is returned unchanged,
whereas the fields of a backend-agnostic [`TableStyle`](@ref) override the ones of the
default Typst table style.
"""
_typst__table_style(style::TypstTableStyle) = style
_typst__table_style(style::TableStyle) = TypstTableStyle(; _table_style_kwargs(style)...)

export typst_line_style

"""
    typst_line_style(line_style::LineStyle) -> String

Convert `line_style` into a Typst stroke.

The `width` is converted to the thickness `"0.5pt"` (`:thin`), `"1pt"` (`:medium`), or
`"1.5pt"` (`:thick`). The `style` is converted to the dash pattern `"solid"`, `"dashed"`,
or `"dotted"`; `:double` has no Typst counterpart and falls back to `"solid"`. The `color`
is converted to the paint `rgb("#rrggbb")`; a color that cannot be resolved to a 24-bit
value is omitted.

If only the `width` is set, the function returns the bare thickness (for example,
`"1.5pt"`). Otherwise, it returns the dictionary stroke form with the set components (for
example, `"(thickness: 1.5pt, paint: rgb(\\"#ff0000\\"), dash: \\"dashed\\")"`).
"""
function typst_line_style(line_style::LineStyle)
    thickness = if line_style.width == :thin
        "0.5pt"
    elseif line_style.width == :medium
        "1pt"
    elseif line_style.width == :thick
        "1.5pt"
    else
        nothing
    end

    dash = if line_style.style ∈ (:solid, :double)
        "solid"
    elseif line_style.style == :dashed
        "dashed"
    elseif line_style.style == :dotted
        "dotted"
    else
        nothing
    end

    color = _face_color_hex(line_style.color)

    # If only the width is set, we can use the bare thickness form, which matches the
    # default strokes of `TypstTableBorders`.
    (isnothing(dash) && isnothing(color)) && !isnothing(thickness) && return thickness

    components = String[]
    isnothing(thickness) || push!(components, "thickness: " * thickness)
    isnothing(color)     || push!(components, "paint: rgb(\"#" * color * "\")")
    isnothing(dash)      || push!(components, "dash: \"" * dash * "\"")

    # If nothing can be expressed (for example, only an unresolvable color was set), we
    # fall back to the default Typst stroke.
    isempty(components) && return "1pt"

    return "(" * join(components, ", ") * ")"
end

"""
    _typst__table_format(table_format::Union{TableFormat, TypstTableFormat}) -> TypstTableFormat

Convert `table_format` to a `TypstTableFormat`. A native `TypstTableFormat` is returned
unchanged, whereas the fields of a backend-agnostic [`TableFormat`](@ref) override the ones
of the default Typst table format.
"""
_typst__table_format(table_format::TypstTableFormat) = table_format

function _typst__table_format(table_format::TableFormat)
    def = TypstTableFormat()
    db  = def.borders

    borders = TypstTableBorders(;
        top_line                = _table_format_border(
            table_format.top_line, typst_line_style, db.top_line
        ),
        header_line             = _table_format_border(
            table_format.header_line, typst_line_style, db.header_line
        ),
        merged_header_cell_line = _table_format_border(
            table_format.merged_header_cell_line,
            typst_line_style,
            db.merged_header_cell_line
        ),
        middle_line             = _table_format_border(
            table_format.middle_line, typst_line_style, db.middle_line
        ),
        bottom_line             = _table_format_border(
            table_format.bottom_line, typst_line_style, db.bottom_line
        ),
        left_line               = _table_format_border(
            table_format.left_line, typst_line_style, db.left_line
        ),
        center_line             = _table_format_border(
            table_format.center_line, typst_line_style, db.center_line
        ),
        right_line              = _table_format_border(
            table_format.right_line, typst_line_style, db.right_line
        ),
    )

    return TypstTableFormat(;
        borders,
        _table_format_presence_fields(table_format, def)...
    )
end
