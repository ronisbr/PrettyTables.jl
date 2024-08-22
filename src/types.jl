## Description #############################################################################
#
# Define types for PrettyTables.jl
#
############################################################################################

@kwdef struct TableData
    data::Any

    # ==  Table Header =====================================================================

    title::String = ""
    subtitle::String = ""

    # == Labels ============================================================================

    # -- Columns ---------------------------------------------------------------------------

    column_labels::Vector{Vector{Any}}
    stubhead_label::String = ""
    show_row_number_column::Bool = false
    row_number_column_label::String = ""

    # -- Rows ------------------------------------------------------------------------------

    row_labels::Union{Nothing, Vector{String}} = nothing
    row_group_labels::Union{Nothing, Dict{Int, String}} = nothing
    summary_row_label::String = ""
    summary_cell::Union{Nothing, Function} = nothing

    # == Table Footer ======================================================================

    footnotes::Union{Nothing, Vector{Pair{NTuple{2, Int}, String}}} = nothing
    source_notes::String = ""

    # == Alignments ========================================================================

    cell_alignment::Vector{Function} = []
    column_label_alignment::Union{Symbol, Vector{Symbol}} = :r
    continuation_row_alignment::Union{Nothing, Symbol} = nothing
    data_alignment::Union{Symbol, Vector{Symbol}} = :r
    row_number_column_alignment::Symbol = :r
    row_label_alignment::Symbol = :r

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
const _ROW_NUMBER_COLUMN   = 4
const _ROW_LABEL_COLUMN    = 5
const _DATA                = 6
const _CONTINUATION_COLUMN = 7
const _END_ROW             = 8
const _FOOTNOTES           = 9
const _SOURCENOTES         = 10
const _END_PRINTING        = 11

const _VERTICAL_CONTINUATION_CELL_ACTIONS = (
    :vertical_continuation_cell,
    :row_number_vertical_continuation_cell,
    :row_label_vertical_continuation_cell
)

"""
"""
@kwdef struct PrintingTableState
    state::Int = _INITIALIZE
    i::Int = 0
    j::Int = 0
    row_section::Symbol = :column_labels
end

# == Printing Specification ================================================================

@kwdef struct PrintingSpec
    context::IOContext
    table_data::TableData
    renderer::Symbol
    show_omitted_cell_summary::Bool
end
