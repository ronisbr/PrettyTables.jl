# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Types and structures.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
    PrintInfo{Td,Th,Trn}

This structure stores the information required so that the backends can print
the tables.

"""
@with_kw struct PrintInfo{Td,Th,Trn}
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
end
