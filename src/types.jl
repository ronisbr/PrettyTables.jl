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
struct ColumnTable{T,V<:AbstractVector{Symbol}}
    table::T
    column_names::V
    size::Tuple{Int,Int}
end

"""
    struct RowTable{T}

This structure helps to access elements that comply with the row access
specification of Tables.jl.

"""
struct RowTable{T,V<:AbstractVector{Symbol}}
    table::T
    column_names::V
    size::Tuple{Int,Int}
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
end
