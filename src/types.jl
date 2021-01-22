# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Types and structures.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export PrettyTablesConf

"""
    struct ColumnTable

This structure helps to access elements that comply with the column access
specification of Tables.jl.

"""
struct ColumnTable
    data         # .............................................. Original table
    table        # ....................... Table converted using `Tables.column`
    column_names # ................................................ Column names
    size         # ........................................... Size of the table
end

"""
    struct RowTable

This structure helps to access elements that comply with the row access
specification of Tables.jl.

"""
struct RowTable
    data         # .............................................. Original table
    table        # ......................... Table converted using `Tables.rows`
    column_names # ................................................ Column names
    size         # ........................................... Size of the table
end

"""
    PrintInfo{Td,Th,Trn}

This structure stores the information required so that the backends can print
the tables.

"""
struct PrintInfo
    data
    header
    id_cols::Vector{Int}
    id_rows::Vector{Int}
    num_rows::Int
    num_cols::Int
    num_printed_cols::Int
    num_printed_rows::Int
    header_num_rows::Int
    header_num_cols::Int
    show_row_number::Bool
    row_number_column_title::String
    show_row_names::Bool
    row_names
    row_name_alignment::Symbol
    row_name_column_title::String
    alignment::Vector{Symbol}
    cell_alignment
    formatters
    compact_printing::Bool
    title::String
    title_alignment::Symbol
    header_alignment::Vector{Symbol}
    header_cell_alignment
    cell_first_line_only::Bool
    renderer::Union{Val{:print}, Val{:show}}
    limit_printing::Bool
end

"""
    PrettyTablesConf

Type of the object that holds a pre-defined set of configurations for
PrettyTables.jl.

"""
struct PrettyTablesConf
    confs::Dict{Symbol, Any}
end

PrettyTablesConf() = PrettyTablesConf(Dict{Symbol, Any}())
