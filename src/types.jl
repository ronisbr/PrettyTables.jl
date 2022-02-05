# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Types and structures.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export PrettyTablesConf

"""
    T_BACKENDS

Types that define the supported backends.
"""
const T_BACKENDS = Union{Val{:auto}, Val{:text}, Val{:html}, Val{:latex}}

"""
    struct ColumnTable

This structure helps to access elements that comply with the column access
specification of Tables.jl.
"""
struct ColumnTable
    data::Any                    # .............................. Original table
    table::Any                   # ....... Table converted using `Tables.column`
    column_names::Vector{Symbol} # ................................ Column names
    size::Tuple{Int, Int}        # ........................... Size of the table
end

"""
    struct RowTable

This structure helps to access elements that comply with the row access
specification of Tables.jl.
"""
struct RowTable
    data::Any                    # .............................. Original table
    table::Any                   # ......... Table converted using `Tables.rows`
    column_names::Vector{Symbol} # ................................ Column names
    size::Tuple{Int, Int}        # ........................... Size of the table
end

"""
    struct ProcessedTable

This struct contains the processed table, which handles additional columns,
filters, etc. All the backend functions have access to this object.
"""
Base.@kwdef mutable struct ProcessedTable
    data::Any
    header::Any

    # Private fields
    # ==========================================================================

    # Inputs
    # --------------------------------------------------------------------------
    _column_filters::Union{Nothing, Tuple} = nothing
    _row_filters::Union{Nothing, Tuple} = nothing

    # Internal variables
    # --------------------------------------------------------------------------
    _additional_column_id::Vector{Symbol} = Symbol[]
    _additional_data_columns::Vector{Any} = Any[]
    _additional_header_columns::Vector{Vector{String}} = Vector{String}[]
    _filters_processed::Bool = false
    _id_rows::Union{Nothing, Vector{Int}} = nothing
    _id_columns::Union{Nothing, Vector{Int}} = nothing
    _num_header_rows::Int = -1
    _num_header_columns::Int = -1
    _num_filtered_rows::Int = -1
    _num_filtered_columns::Int = -1
end

"""
    struct PrintInfo

This structure stores the information required so that the backends can print
the tables.
"""
struct PrintInfo
    data::ProcessedTable
    row_number_column_title::String
    row_name_alignment::Symbol
    row_name_column_title::String
    alignment::Vector{Symbol}
    cell_alignment::Ref{Any}
    formatters::Ref{Any}
    compact_printing::Bool
    title::String
    title_alignment::Symbol
    header_alignment::Vector{Symbol}
    header_cell_alignment::Ref{Any}
    cell_first_line_only::Bool
    renderer::Union{Val{:print}, Val{:show}}
    limit_printing::Bool
end

"""
    struct PrettyTablesConf

Type of the object that holds a pre-defined set of configurations for
PrettyTables.jl.
"""
struct PrettyTablesConf
    confs::Dict{Symbol, Any}
end

PrettyTablesConf() = PrettyTablesConf(Dict{Symbol, Any}())
