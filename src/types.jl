## Description #############################################################################
#
# Define types for PrettyTables.jl
#
############################################################################################

export MergeCells

# Tuple that defined a footnote.
const FootnoteTuple = Tuple{Symbol, Int, Int}

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

@kwdef struct TableData
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
    summary_columns::Union{Nothing, Vector{Any}} = nothing
    summary_column_labels::Union{Nothing, Vector{String}} = nothing

    # -- Rows ------------------------------------------------------------------------------

    row_labels::Union{Nothing, AbstractVector} = nothing
    row_group_labels::Union{Nothing, Vector{Pair{Int, String}}} = nothing
    summary_rows::Union{Nothing, Vector{Any}} = nothing
    summary_row_labels::Union{Nothing, Vector{String}} = nothing

    # -- Cell Merging ----------------------------------------------------------------------

    merge_cells::Union{Nothing, Vector{MergeCells}} = nothing

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
    row_label_alignment::Symbol = :r
    row_group_label_alignment::Symbol = :l
    summary_column_alignment::Union{Symbol, Vector{Symbol}} = :r
    summary_column_label_alignment::Union{Symbol, Vector{Symbol}} = :r
    footnote_alignment::Symbol = :l
    source_note_alignment::Symbol = :l

    # == Formatters ========================================================================

    formatters::Union{Nothing, Vector{Any}} = nothing

    # == Auxiliary Variables ===============================================================

    # Since `data` can be any object, `size` is type unstable. Hence, we store this
    # information here to improve the performance.
    num_rows::Int
    num_columns::Int

    # Maxium number of rows and columns we must print.
    maximum_number_of_columns::Int = 0
    maximum_number_of_rows::Int = 0

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
const _SUMMARY_COLUMNS     = 9
const _END_ROW             = 10
const _FOOTNOTES           = 11
const _SOURCENOTES         = 12
const _END_PRINTING        = 13
const _END_ROW_AFTER_GROUP = 14
const _NEW_ROW_AFTER_GROUP = 15

const _VERTICAL_CONTINUATION_CELL_ACTIONS = (
    :vertical_continuation_cell,
    :row_number_vertical_continuation_cell,
    :row_label_vertical_continuation_cell
)

"""
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
end

# == Auxiliary =============================================================================

# Type to lazily construct the summary row / column label if the user does not pass this
# information.
struct SummaryLabelIterator <: AbstractVector{String}
    length::Int
end

Base.size(s::SummaryLabelIterator) = (s.length,)
Base.getindex(::SummaryLabelIterator, i::Int) = "Summary $i"
