## Description #############################################################################
#
# Backend-agnostic table format used to configure the table lines in every back end.
#
############################################################################################

export LineStyle, TableFormat

# Valid values for the `style` and `width` fields of `LineStyle`.
const _LINE_STYLE_STYLES = (:solid, :dashed, :dotted, :double)
const _LINE_STYLE_WIDTHS = (:thin, :medium, :thick)

"""
    struct LineStyle

Describe the design of a table line independently from the back end, including its style,
width, and color. Every field set to `nothing` means that the back end default for that
aspect of the line must be kept.

Each back end converts this object to its native line design using the same approach as the
conversion of `Face` to decorations. The conversion is a best effort: aspects a back end
cannot express are silently ignored (for example, the text back end ignores the entire line
design, and the LaTeX back end ignores `width` and `color`).

# Fields

- `style::Union{Nothing, Symbol}`: Line style: `:solid`, `:dashed`, `:dotted`, or
    `:double`.
    (**Default**: `nothing`)
- `width::Union{Nothing, Symbol}`: Line width: `:thin`, `:medium`, or `:thick`.
    (**Default**: `nothing`)
- `color::Union{Nothing, SimpleColor}`: Line color. The keyword constructor also accepts a
    `Symbol` with a named color, an `UInt32` with a 24-bit color, a string like
    `"#rrggbb"`, or a tuple `(r, g, b)` of integers, all normalized to `SimpleColor`.
    (**Default**: `nothing`)
"""
struct LineStyle
    style::Union{Nothing, Symbol}
    width::Union{Nothing, Symbol}
    color::Union{Nothing, SimpleColor}
end

"""
    LineStyle(; kwargs...) -> LineStyle

Create a `LineStyle` from the keywords `style`, `width`, and `color`, validating the values
and normalizing `color` to `SimpleColor`. The function throws an `ArgumentError` if `style`
or `width` is not supported, or if `color` cannot be converted to a color.

# Keywords

- `style::Union{Nothing, Symbol}`: Line style: `:solid`, `:dashed`, `:dotted`, or
    `:double`.
    (**Default**: `nothing`)
- `width::Union{Nothing, Symbol}`: Line width: `:thin`, `:medium`, or `:thick`.
    (**Default**: `nothing`)
- `color::Any`: Line color as a `SimpleColor`, a `Symbol` with a named color, an `UInt32`
    with a 24-bit color, a string like `"#rrggbb"`, or a tuple `(r, g, b)` of integers.
    (**Default**: `nothing`)
"""
function LineStyle(; style = nothing, width = nothing, color = nothing)
    (isnothing(style) || style ∈ _LINE_STYLE_STYLES) || throw(
        ArgumentError(
            "The line style `:$style` is not supported. Valid values are `:solid`, " *
            "`:dashed`, `:dotted`, and `:double`."
        )
    )

    (isnothing(width) || width ∈ _LINE_STYLE_WIDTHS) || throw(
        ArgumentError(
            "The line width `:$width` is not supported. Valid values are `:thin`, " *
            "`:medium`, and `:thick`."
        )
    )

    return LineStyle(style, width, _line_style_color(color))
end

"""
    _line_style_color(color::Any) -> Union{Nothing, SimpleColor}

Normalize `color` to the object used by `LineStyle`, throwing an `ArgumentError` if the
value cannot be converted to a color.
"""
_line_style_color(::Nothing) = nothing
_line_style_color(color::SimpleColor) = color
_line_style_color(color::Symbol) = SimpleColor(color)
_line_style_color(color::UInt32) = SimpleColor(color)
_line_style_color(color::NTuple{3, Integer}) = SimpleColor(color...)

function _line_style_color(color::AbstractString)
    c = tryparse(SimpleColor, String(color))

    isnothing(c) && throw(
        ArgumentError("The string \"$color\" cannot be converted to a color.")
    )

    return c
end

function _line_style_color(color::Any)
    throw(
        ArgumentError(
            "A line color cannot be created from an object of type `$(typeof(color))`."
        )
    )
end

"""
    _line_style_is_empty(line_style::LineStyle) -> Bool

Return whether every field of `line_style` is `nothing`, meaning that the back end default
line design must be kept.
"""
function _line_style_is_empty(line_style::LineStyle)
    return isnothing(line_style.style) &&
        isnothing(line_style.width) &&
        isnothing(line_style.color)
end

############################################################################################
#                                       TableFormat                                        #
############################################################################################

"""
    struct TableFormat

Describe the table lines (presence and design) independently from the back end. This object
can be passed to the keyword `table_format` of `pretty_table` with any back end, allowing
the user to switch back ends without rewriting the line configuration.

Every field set to `nothing` keeps the default behavior of the selected back end. Hence, a
`TableFormat` never replaces the back end table format entirely: each set field overrides
only the corresponding field of the back end default format. For example, leaving
`horizontal_line_at_merged_column_labels` as `nothing` keeps the text back end default
(`false`) and the default of the other back ends (`true`).

Notice that `nothing` differs from `:none` in the fields that accept a `Symbol`: `nothing`
keeps the back end default, whereas `:none` explicitly disables the lines.

The conversion to the back end native format is a best effort: the manual page **Table
Format** describes which fields each back end honors. In particular, the text back end
ignores the line design fields, and the Markdown back end only supports
`horizontal_line_before_summary_rows`.

# Fields

## Line Design

Each field below describes the design of one line role using a [`LineStyle`](@ref):

- `top_line::Union{Nothing, LineStyle}`: Line at the top of the table.
    (**Default**: `nothing`)
- `header_line::Union{Nothing, LineStyle}`: Line after the column labels.
    (**Default**: `nothing`)
- `merged_header_cell_line::Union{Nothing, LineStyle}`: Line under merged column label
    cells.
    (**Default**: `nothing`)
- `middle_line::Union{Nothing, LineStyle}`: Lines drawn inside the table body.
    (**Default**: `nothing`)
- `bottom_line::Union{Nothing, LineStyle}`: Line at the bottom of the table.
    (**Default**: `nothing`)
- `left_line::Union{Nothing, LineStyle}`: Line at the left of the table.
    (**Default**: `nothing`)
- `center_line::Union{Nothing, LineStyle}`: Vertical lines drawn inside the table body.
    (**Default**: `nothing`)
- `right_line::Union{Nothing, LineStyle}`: Line at the right of the table.
    (**Default**: `nothing`)

## Line Presence

- `horizontal_line_at_beginning::Union{Nothing, Bool}`: Whether to draw a horizontal line
    at the beginning of the table.
    (**Default**: `nothing`)
- `horizontal_line_before_column_labels::Union{Nothing, Bool}`: Whether to draw a
    horizontal line before the column labels when the table has a title or subtitle. This
    field is only honored by the HTML back end, which places the title inside the ruled
    area.
    (**Default**: `nothing`)
- `horizontal_line_after_column_labels::Union{Nothing, Bool}`: Whether to draw a horizontal
    line after the column labels.
    (**Default**: `nothing`)
- `horizontal_line_at_merged_column_labels::Union{Nothing, Bool}`: Whether to draw a
    horizontal line under the merged column label cells.
    (**Default**: `nothing`)
- `horizontal_lines_at_data_rows::Union{Nothing, Symbol, Vector{Int}}`: Data rows after
    which a horizontal line must be drawn: `:all`, `:none`, or a vector of row indices.
    (**Default**: `nothing`)
- `horizontal_line_before_row_group_label::Union{Nothing, Bool}`: Whether to draw a
    horizontal line before the row group labels.
    (**Default**: `nothing`)
- `horizontal_line_after_row_group_label::Union{Nothing, Bool}`: Whether to draw a
    horizontal line after the row group labels.
    (**Default**: `nothing`)
- `horizontal_line_after_data_rows::Union{Nothing, Bool}`: Whether to draw a horizontal
    line after the data rows.
    (**Default**: `nothing`)
- `horizontal_line_before_summary_rows::Union{Nothing, Bool}`: Whether to draw a horizontal
    line before the summary rows.
    (**Default**: `nothing`)
- `horizontal_line_after_summary_rows::Union{Nothing, Bool}`: Whether to draw a horizontal
    line after the summary rows.
    (**Default**: `nothing`)
- `horizontal_line_after_footnotes::Union{Nothing, Bool}`: Whether to draw a horizontal
    line after the footnotes. This field is only honored by the HTML back end, which places
    the footer inside the ruled area.
    (**Default**: `nothing`)
- `horizontal_line_at_end::Union{Nothing, Bool}`: Whether to draw a horizontal line at the
    end of the table, below the footnotes and source notes. This field is only honored by
    the HTML back end, which places the footer inside the ruled area.
    (**Default**: `nothing`)
- `vertical_line_at_beginning::Union{Nothing, Bool}`: Whether to draw a vertical line at
    the beginning of the table.
    (**Default**: `nothing`)
- `vertical_line_after_row_number_column::Union{Nothing, Bool}`: Whether to draw a vertical
    line after the row number column.
    (**Default**: `nothing`)
- `vertical_line_after_row_label_column::Union{Nothing, Bool}`: Whether to draw a vertical
    line after the row label column.
    (**Default**: `nothing`)
- `vertical_lines_at_data_columns::Union{Nothing, Symbol, Vector{Int}}`: Data columns after
    which a vertical line must be drawn: `:all`, `:none`, or a vector of column indices.
    (**Default**: `nothing`)
- `vertical_line_after_data_columns::Union{Nothing, Bool}`: Whether to draw a vertical line
    after the data columns.
    (**Default**: `nothing`)
- `vertical_line_after_continuation_column::Union{Nothing, Bool}`: Whether to draw a
    vertical line after the continuation column.
    (**Default**: `nothing`)
"""
@kwdef struct TableFormat
    # == Line Design =======================================================================

    top_line::Union{Nothing, LineStyle}                = nothing
    header_line::Union{Nothing, LineStyle}             = nothing
    merged_header_cell_line::Union{Nothing, LineStyle} = nothing
    middle_line::Union{Nothing, LineStyle}             = nothing
    bottom_line::Union{Nothing, LineStyle}             = nothing
    left_line::Union{Nothing, LineStyle}               = nothing
    center_line::Union{Nothing, LineStyle}             = nothing
    right_line::Union{Nothing, LineStyle}              = nothing

    # == Line Presence =====================================================================

    horizontal_line_at_beginning::Union{Nothing, Bool}                 = nothing
    horizontal_line_before_column_labels::Union{Nothing, Bool}         = nothing
    horizontal_line_after_column_labels::Union{Nothing, Bool}          = nothing
    horizontal_line_at_merged_column_labels::Union{Nothing, Bool}      = nothing
    horizontal_lines_at_data_rows::Union{Nothing, Symbol, Vector{Int}} = nothing
    horizontal_line_before_row_group_label::Union{Nothing, Bool}       = nothing
    horizontal_line_after_row_group_label::Union{Nothing, Bool}        = nothing
    horizontal_line_after_data_rows::Union{Nothing, Bool}              = nothing
    horizontal_line_before_summary_rows::Union{Nothing, Bool}          = nothing
    horizontal_line_after_summary_rows::Union{Nothing, Bool}           = nothing
    horizontal_line_after_footnotes::Union{Nothing, Bool}              = nothing
    horizontal_line_at_end::Union{Nothing, Bool}                       = nothing
    vertical_line_at_beginning::Union{Nothing, Bool}                   = nothing
    vertical_line_after_row_number_column::Union{Nothing, Bool}        = nothing
    vertical_line_after_row_label_column::Union{Nothing, Bool}         = nothing
    vertical_lines_at_data_columns::Union{Nothing, Symbol, Vector{Int}} = nothing
    vertical_line_after_data_columns::Union{Nothing, Bool}             = nothing
    vertical_line_after_continuation_column::Union{Nothing, Bool}      = nothing
end

"""
    _table_format_field(user::Any, default::Any) -> Any

Return `default` if `user` is `nothing`, and `user` otherwise. This function implements the
sparse override of the fields of [`TableFormat`](@ref) over a back end default format.
"""
_table_format_field(user::Any, default::Any) = isnothing(user) ? default : user

"""
    _table_format_border(line_style::Union{Nothing, LineStyle}, converter::Function, default::Any) -> Any

Convert `line_style` to the back end native line design using `converter`, returning
`default` if `line_style` is `nothing` or has every field set to `nothing`.
"""
function _table_format_border(
    line_style::Union{Nothing, LineStyle},
    converter::Function,
    default::Any
)
    (isnothing(line_style) || _line_style_is_empty(line_style)) && return default
    return converter(line_style)
end

# Line presence fields shared by every back end table format.
const _TABLE_FORMAT_PRESENCE_FIELDS = (
    :horizontal_line_at_beginning,
    :horizontal_line_after_column_labels,
    :horizontal_line_at_merged_column_labels,
    :horizontal_lines_at_data_rows,
    :horizontal_line_before_row_group_label,
    :horizontal_line_after_row_group_label,
    :horizontal_line_after_data_rows,
    :horizontal_line_before_summary_rows,
    :horizontal_line_after_summary_rows,
    :vertical_line_at_beginning,
    :vertical_line_after_row_number_column,
    :vertical_line_after_row_label_column,
    :vertical_lines_at_data_columns,
    :vertical_line_after_data_columns,
    :vertical_line_after_continuation_column,
)

"""
    _table_format_presence_fields(tf::TableFormat, def::Any) -> NamedTuple

Merge the line presence fields of `tf` over the ones of the back end default table format
`def`, returning a named tuple that can be splatted into the keyword constructor of the
back end table format. `def` must have every line presence field shared by all back ends
(see `_TABLE_FORMAT_PRESENCE_FIELDS`), which is the case for the table formats of the text,
HTML, LaTeX, Typst, and Excel back ends. The HTML-only presence fields are not part of the
returned tuple and must be merged by the HTML converter.
"""
function _table_format_presence_fields(tf::TableFormat, def::Any)
    return NamedTuple{_TABLE_FORMAT_PRESENCE_FIELDS}(
        map(_TABLE_FORMAT_PRESENCE_FIELDS) do f
            _table_format_field(getfield(tf, f), getfield(def, f))
        end
    )
end

"""
    _table_format_borders(tf::TableFormat, def::B, converter::Function; skip::Tuple = ()) where B -> B

Convert the line designs of `tf` to the native borders of a back end using `converter`,
returning an object with the same type as the default borders `def`. Every field of `def`
must have the same name as a line design field of [`TableFormat`](@ref). A line design left
as `nothing` in `tf`, or whose field name is in `skip`, keeps the default border of `def`
(see `_table_format_border`).
"""
function _table_format_borders(
    tf::TableFormat,
    def::B,
    converter::Function;
    skip::Tuple = ()
) where B
    return B(
        map(fieldnames(B)) do f
            (f ∈ skip) && return getfield(def, f)
            return _table_format_border(getfield(tf, f), converter, getfield(def, f))
        end...
    )
end
