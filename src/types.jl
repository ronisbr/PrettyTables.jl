# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Types and structures.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
    struct ColumnTable{T}

This structure helps to access elements that comply with the column access
specification of Tables.jl.

"""
struct ColumnTable{Td,Tt,V<:AbstractVector{Symbol}}
    data::Td             # ...................................... Original table
    table::Tt            # ............... Table converted using `Tables.column`
    column_names::V      # ........................................ Column names
    size::Tuple{Int,Int} # ................................... Size of the table
end

"""
    struct RowTable{T}

This structure helps to access elements that comply with the row access
specification of Tables.jl.

"""
struct RowTable{Td,Tt,V<:AbstractVector{Symbol}}
    data::Td             # ...................................... Original table
    table::Tt            # ................. Table converted using `Tables.rows`
    column_names::V      # ........................................ Column names
    size::Tuple{Int,Int} # ................................... Size of the table
end

"""
    PrintInfo{Td,Th,Trn}

This structure stores the information required so that the backends can print
the tables.

"""
@with_kw struct PrintInfo{Td,Th,Trn,Tc <: Tuple, Tf <: Tuple}
    data::Td
    header::Th
    id_cols::Vector{Int}
    id_rows::Vector{Int}
    num_rows::Int
    num_cols::Int
    num_printed_cols::Int
    num_printed_rows::Int
    header_num_rows::Int
    header_num_cols::Int
    show_row_names::Bool
    row_names::Trn
    row_name_alignment::Symbol
    row_name_column_title::String
    alignment::Vector{Symbol}
    cell_alignment::Tc
    formatters::Tf
    compact_printing::Bool
end
