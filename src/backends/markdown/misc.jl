## Description #############################################################################
#
# Miscellaneous functions for the markdown back end.
#
############################################################################################

function _markdown_print_header_line(
    @nospecialize(io::IOContext),
    ptable::ProcessedTable,
    actual_columns_width::Vector{Int},
    hidden_columns_at_end::Bool
)
    num_columns = length(actual_columns_width)

    print(io, "|")

    @inbounds for j in 1:num_columns
        cell_header_line = "-"^(actual_columns_width[j])

        column_alignment = _get_column_alignment(ptable, j)

        if column_alignment == :l
            cell_header_line = ":" * cell_header_line * "-"
        elseif column_alignment == :c
            cell_header_line = ":" * cell_header_line * ":"
        elseif column_alignment == :r
            cell_header_line = "-" * cell_header_line * ":"
        else
            cell_header_line = "-" * cell_header_line * "-"
        end

        print(io, "$(cell_header_line)|")
    end

    if hidden_columns_at_end
        print(io, ":-:|")
    end

    println(io)

    return nothing
end
