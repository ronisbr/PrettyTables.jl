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
# The native objects of this back end select it when `backend = :auto`.
_backend_of(::Union{TypstTableFormat, TypstTableStyle}) = :typst

_typst__table_style(style::TypstTableStyle) = style
_typst__table_style(style::TableStyle) = TypstTableStyle(; _table_style_kwargs(style)...)

function _typst__table_style(style::Any)
    throw(
        ArgumentError(
            "The Typst back end does not support a style of type `$(typeof(style))`. Use `TypstTableStyle` or the backend-agnostic `TableStyle`."
        )
    )
end

export typst_line_style

"""
    typst_line_style(line_style::LineStyle; default::String = "1pt") -> String

Convert `line_style` into a Typst stroke.

The `width` is converted to the thickness `"0.5pt"` (`:thin`), `"1pt"` (`:medium`), or
`"1.5pt"` (`:thick`). If it is unset, the thickness is `default` when the latter is a bare
length (for example, `"1.5pt"`), which is the form of the default strokes of
`TypstTableBorders`; otherwise, the thickness is omitted and Typst uses its own default. The
`style` is converted to the dash pattern `"solid"`, `"dashed"`, or `"dotted"`; `:double` has
no Typst counterpart and falls back to `"solid"`. The `color` is converted to the paint
`rgb("#rrggbb")`; a color that cannot be resolved to a 24-bit value is omitted.

If only the thickness is available, the function returns the bare thickness (for example,
`"1.5pt"`). Otherwise, it returns the dictionary stroke form with the available components
(for example, `"(thickness: 1.5pt, paint: rgb(\\"#ff0000\\"), dash: \\"dashed\\")"`).
"""
function typst_line_style(line_style::LineStyle; default::String = "1pt")
    thickness = if line_style.width == :thin
        "0.5pt"
    elseif line_style.width == :medium
        "1pt"
    elseif line_style.width == :thick
        "1.5pt"
    elseif occursin(r"^[0-9.]+[a-z]+$", default)
        default
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
    # fall back to the default stroke.
    isempty(components) && return default

    return "(" * join(components, ", ") * ")"
end

"""
    _typst__table_format(table_format::Union{TableFormat, TypstTableFormat}) -> TypstTableFormat

Convert `table_format` to a `TypstTableFormat`. A native `TypstTableFormat` is returned
unchanged, whereas the fields of a backend-agnostic [`TableFormat`](@ref) override the ones
of the default Typst table format.
"""
_typst__table_format(table_format::TypstTableFormat) = table_format

function _typst__table_format(table_format::Any)
    throw(
        ArgumentError(
            "The Typst back end does not support a table format of type `$(typeof(table_format))`. Use `TypstTableFormat` or the backend-agnostic `TableFormat`."
        )
    )
end

function _typst__table_format(table_format::TableFormat)
    def = _DEFAULT_TYPST_TABLE_FORMAT

    return TypstTableFormat(;
        borders = _table_format_borders(table_format, def.borders, typst_line_style),
        _table_format_presence_fields(table_format, def)...
    )
end
