## Description #############################################################################
#
# Functions to retrieve table information.
#
############################################################################################

"""
    _number_of_printed_columns(table_data::TableData) -> Int

Return the number of printed columns in `table_data`, which includes the continuation row.
"""
function _number_of_printed_columns(table_data::TableData)
    data_columns = table_data.maximum_number_of_columns > 0 ?
        # If we are cropping the table, we have one additional column for the continuation
        # characters.
        min(table_data.maximum_number_of_columns + 1, table_data.num_columns) :
        table_data.num_columns

    total_columns =
        data_columns +
        table_data.show_row_number_column +
        (!isnothing(table_data.row_labels) || !isnothing(table_data.summary_row_labels)) +
        (!isnothing(table_data.summary_columns) ? length(table_data.summary_columns) : 0)

    return total_columns
end

"""
    _number_of_printed_data_columns(table_data::TableData) -> Int

Return the number of printed data columns.
"""
function _number_of_printed_data_columns(table_data::TableData)
    data_columns = table_data.maximum_number_of_columns > 0 ?
        # If we are cropping the table, we have one additional column for the continuation
        # characters.
        min(table_data.maximum_number_of_columns, table_data.num_columns) :
        table_data.num_columns

    return data_columns
end
