# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Types and structures.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
    struct PrintInfo{Td,Th}

This structure stores the information required so that the backends can print
the tables.

"""
@with_kw struct PrintInfo{Td,Th}
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
    alignment::Vector{Symbol}
end
