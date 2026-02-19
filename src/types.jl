## Description #############################################################################
#
# Define types for PrettyTables.jl
#
############################################################################################

export EmptyCells, MultiColumn, MergeCells, PrettyTable

# Tuple that defined a footnote.
const FootnoteTuple = Tuple{Symbol, Int, Int}

"""
    struct EmptyCells

Specification for adding a set of empty cells at the column label rows.

# Fields

- `number_of_cells::Int`: Number of cells to add (must be greater than 0).
"""
struct EmptyCells
    number_of_cells::Int

    function EmptyCells(number_of_cells::Int)
        number_of_cells < 1 && throw(ArgumentError(
            "The `number_of_cells` of `EmptyCells` must be greater than 0."
        ))

        return new(number_of_cells)
    end
end

"""
    struct MultiColumn

Specification for merging columns at the column label rows.

# Fields

- `column_span::Int`: Number of columns to merge (must be greater than 1).
- `data::Any`: Merged cell data.
- `alignment::Symbol`: Merge cell alignment.
"""
struct MultiColumn
    column_span::Int
    data::Any
    alignment::Symbol

    function MultiColumn(column_span::Int, data::Any)
        column_span < 2 && throw(ArgumentError(
            "The `column_span` of `MultiColumn` must be greater than 1."
        ))
        return new(column_span, data, :c)
    end

    function MultiColumn(column_span::Int, data::Any, alignment::Symbol)
        column_span < 2 && throw(ArgumentError(
            "The `column_span` of `MultiColumn` must be greater than 1."
        ))
        return new(column_span, data, alignment)
    end
end

@kwdef struct MergeCells
    i::Int
    j::Int
    column_span::Int
    data::Any
    alignment::Symbol = :c

    function MergeCells(i::Int, j::Int, column_span::Int, data::Any)
        return new(i, j, column_span, data, :c)
    end

    function MergeCells(i::Int, j::Int, column_span::Int, data::Any, alignment::Symbol)
        return new(i, j, column_span, data, alignment)
    end
end

struct __IGNORE_CELL__ end
const _IGNORE_CELL = __IGNORE_CELL__()

struct UndefinedCell end
const _UNDEFINED_CELL = UndefinedCell()

@kwdef mutable struct TableData
    data::Any

    # ==  Table Header =====================================================================

    title::String = ""
    subtitle::String = ""

    # == Labels ============================================================================

    # -- Columns ---------------------------------------------------------------------------

    stubhead_label::String = ""
    show_row_number_column::Bool = false
    row_number_column_label::String = ""
    column_labels::Vector{Vector{Any}}
    show_column_labels::Bool = true

    # -- Rows ------------------------------------------------------------------------------

    row_labels::Union{Nothing, AbstractVector} = nothing
    row_group_labels::Union{Nothing, Vector{Pair{Int, String}}} = nothing
    summary_rows::Union{Nothing, Vector{Any}} = nothing
    summary_row_labels::Union{Nothing, Vector{String}} = nothing

    # -- Cell Merging ----------------------------------------------------------------------

    merge_column_label_cells::Union{Nothing, Vector{MergeCells}} = nothing

    # == Table Footer ======================================================================

    footnotes::Union{Nothing, Vector{Pair{FootnoteTuple, String}}} = nothing
    source_notes::String = ""

    # == Alignments ========================================================================

    title_alignment::Symbol = :c
    subtitle_alignment::Symbol = :c
    cell_alignment::Union{Nothing, Vector{Any}} = nothing
    column_label_alignment::Union{Symbol, Vector{Symbol}} = :r
    continuation_row_alignment::Union{Nothing, Symbol} = nothing
    data_alignment::Union{Symbol, Vector{Symbol}} = :r
    row_number_column_alignment::Symbol = :r
    row_label_column_alignment::Symbol = :r
    row_group_label_alignment::Symbol = :l
    footnote_alignment::Symbol = :l
    source_note_alignment::Symbol = :l

    # == Formatters ========================================================================

    formatters::Union{Nothing, Vector{Any}} = nothing

    # == Auxiliary Variables ===============================================================

    # Since `data` can be any object, `size` is type unstable. Hence, we store this
    # information here to improve the performance.
    num_rows::Int
    num_columns::Int

    # We need to store the first index in both direction to reduce the number of
    # allocations. Notice that `data` is stored using `Any`, meaning that using functions
    # like `axes`, `firstindex`, and `begin` inside `getindex` will allocate.
    first_row_index::Int
    first_column_index::Int

    # Maxium number of rows and columns we must print.
    maximum_number_of_columns::Int = -1
    maximum_number_of_rows::Int = -1

    # How we should vertically crop the table.
    vertical_crop_mode::Symbol = :bottom
end

# == Tables.jl API =========================================================================

"""
    struct ColumnTable

This structure helps to access elements that comply with the column access specification of
Tables.jl.
"""
struct ColumnTable
    data::Any                    # .......................................... Original table
    table::Any                   # ................... Table converted using `Tables.column`
    column_names::Vector{Symbol} # ............................................ Column names
    size::Tuple{Int, Int}        # ....................................... Size of the table
end

"""
    struct RowTable

This structure helps to access elements that comply with the row access specification of
Tables.jl.
"""
struct RowTable
    data::Any                    # .......................................... Original table
    table::Any                   # ..................... Table converted using `Tables.rows`
    column_names::Vector{Symbol} # ............................................ Column names
    size::Tuple{Int, Int}        # ....................................... Size of the table
end

# == Print Table State =====================================================================

const _INITIALIZE          = 0
const _TITLE               = 1
const _SUBTITLE            = 2
const _NEW_ROW             = 3
const _ROW_GROUP           = 4
const _ROW_NUMBER_COLUMN   = 5
const _ROW_LABEL_COLUMN    = 6
const _DATA                = 7
const _CONTINUATION_COLUMN = 8
const _END_ROW             = 9
const _FOOTNOTES           = 10
const _SOURCENOTES         = 11
const _END_PRINTING        = 12
const _END_ROW_AFTER_GROUP = 13
const _NEW_ROW_AFTER_GROUP = 14

const _VERTICAL_CONTINUATION_CELL_ACTIONS = (
    :vertical_continuation_cell,
    :row_number_vertical_continuation_cell,
    :row_label_vertical_continuation_cell
)

"""
    struct PrintingTableState

This structure stores the current state of the printing process.

# Fields

- `state::Int`: The current state of the printing process.
- `i::Int`: The current row index.
- `j::Int`: The current column index.
- `row_section::Symbol`: The current or the next row section.

!!! warning

    The field `row_section` is used to determine the next state of the printing process. It
    must not be used to verify the current or the next row section as the meaning can change
    depending on the current state. Instead, always used the function `_next` to obtain the
    next row section.
"""
struct PrintingTableState
    state::Int
    i::Int
    j::Int
    row_section::Symbol

    function PrintingTableState(
        state::Int,
        i::Int,
        j::Int,
        row_section::Symbol
    )
        return new(state, i, j, row_section)
    end

    function PrintingTableState()
        return new(_INITIALIZE, 0, 0, :table_header)
    end
end

# == Printing Specification ================================================================

@kwdef struct PrintingSpec
    context::IOContext
    table_data::TableData
    renderer::Symbol
    show_omitted_cell_summary::Bool
    new_line_at_end::Bool
end

# == Auxiliary =============================================================================

# Type to lazily construct the summary row / column label if the user does not pass this
# information.
struct SummaryLabelIterator <: AbstractVector{String}
    summary_rows::Vector{Any}
end

Base.size(s::SummaryLabelIterator) = (length(s.summary_rows),)
function Base.getindex(s::SummaryLabelIterator, i::Int)
    f_str = string(s.summary_rows[i])
    first(f_str) == '#' && return "Summary $i"
    return f_str
end

# == PrettyTable ===========================================================================

"""
    mutable struct PrettyTable

This structure stores the data and configuration options required to print a table. The
table to be displayed is specified by the `data` field, while any additional configuration
options, corresponding to the keyword arguments accepted by the `pretty_table` function, can
be set as fields with matching names.

Users can overload the `show` function to customize how the table is printed for different
MIME types. PrettyTables.jl provides a default `show` method for printing tables to
`stdout`.

## Fields

- `data::Any`: The table to be displayed.
- `configurations::Dict{Symbol, Any}`: A dictionary containing configuration options for
    the table. The keys are symbols corresponding to the keyword arguments accepted by the
    `pretty_table` function, and the values are the corresponding settings. It is not
    recommended to add configurations here directly. Use the native Julia syntax to set
    fields in the `PrettyTable` object instead.

# Extended Help

## Examples

```julia-repl
julia> pt = PrettyTable(ones(3, 3))
┌────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │
├────────┼────────┼────────┤
│    1.0 │    1.0 │    1.0 │
│    1.0 │    1.0 │    1.0 │
│    1.0 │    1.0 │    1.0 │
└────────┴────────┴────────┘

julia> pt.table_format = TextTableFormat(; @text__no_vertical_lines)
TextTableFormat(TextTableBorders('┐', '┌', '└', '┘', '┬', '├', '┤', '┼', '┴', '│', '─'), true, :none, true, :none, true, true, true, true, true, false, false, false, :none, false, false, true, 0)

julia> pt
────────────────────────
 Col. 1  Col. 2  Col. 3
────────────────────────
    1.0     1.0     1.0
    1.0     1.0     1.0
    1.0     1.0     1.0
────────────────────────

julia> pt.data = 2 .* ones(3, 3)
3×3 Matrix{Float64}:
 2.0  2.0  2.0
 2.0  2.0  2.0
 2.0  2.0  2.0

julia> pt
────────────────────────
 Col. 1  Col. 2  Col. 3
────────────────────────
    2.0     2.0     2.0
    2.0     2.0     2.0
    2.0     2.0     2.0
────────────────────────
```
"""
mutable struct PrettyTable
    data::Any
    configurations::Dict{Symbol, Any}

    function PrettyTable(data::Any; kwargs...)
        return new(data, Dict{Symbol, Any}(kwargs...))
    end
end

function Base.getproperty(pt::PrettyTable, field::Symbol)
    field in fieldnames(PrettyTable) && return getfield(pt, field)
    return get(getfield(pt, :configurations), field, nothing)
end

function Base.setproperty!(pt::PrettyTable, field::Symbol, value::Any)
    field in fieldnames(PrettyTable) && return setfield!(pt, field, value)
    return getfield(pt, :configurations)[field] = value
end

