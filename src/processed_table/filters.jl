# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Algorithm to process the filters in a `ProcessedTable`.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
    _process_filters!(table::ProcessedTable; kwargs...)

Process the filters in the table `ptable`.

# Keywords

- `max_num_filtered_rows::Int`: Maximum number of rows that should be filtered.
    If it is ≤ 0, then all the filtered rows will be considered.
    (**Default** = 0)
- `max_num_filtered_columns::Int`: Maximum number of columns that should be
    filtered. If it is ≤ 0, then all the filtered columns will be considered.
    (**Default** = 0)
"""
function _process_filters!(
    ptable::ProcessedTable;
    max_num_filtered_rows::Int = 0,
    max_num_filtered_columns::Int = 0
)
    num_rows, num_columns = size(ptable.data)::Tuple{Int, Int}

    # If the user wants to filter the data, then check which columns and rows
    # must be printed. Notice that if a data is filtered, then it means that it
    # passed the filter and must be printed.
    column_filters = ptable._column_filters
    row_filters    = ptable._row_filters

    # Process the column filters.
    if max_num_filtered_columns ≤ 0
        max_num_filtered_columns = num_columns
    else
        max_num_filtered_columns = min(max_num_filtered_columns, num_columns)
    end

    if column_filters !== nothing
        num_filtered_columns = 0

        filtered_columns = Vector{Int}(undef, max_num_filtered_columns)
        id_filt = 1

        # Loop throught the columns and apply the column filters. If a column
        # is filtered, then add its number to the vector `filtered_columns`. At
        # the end, this vector will contain the ids of the filtered columns.
        @inbounds for i in 1:num_columns
            filtered_i = true

            for filter in column_filters
                if !filter(_getdata(ptable.data), i)
                    filtered_i = false
                    break
                end
            end

            if filtered_i
                if id_filt ≤ max_num_filtered_columns
                    filtered_columns[id_filt] = i
                    id_filt += 1
                end

                num_filtered_columns += 1
            end
        end

        ptable._id_columns = filtered_columns[1:(id_filt - 1)]
        ptable._num_filtered_columns = num_filtered_columns
    else
        ptable._num_filtered_columns = max_num_filtered_columns
    end

    # Process the row filters.
    if max_num_filtered_rows ≤ 0
        max_num_filtered_rows = num_rows
    else
        max_num_filtered_rows = min(max_num_filtered_rows, num_rows)
    end

    if row_filters !== nothing
        num_filtered_rows = 0

        filtered_rows = Vector{Int}(undef, max_num_filtered_rows)
        id_filt = 1

        # Loop throught the rows and apply the row filters. If a row is
        # filtered, then add its number to the vector `filtered_rows`. At the
        # end, this vector will contain the ids of the filtered rows.
        @inbounds for i = 1:num_rows
            filtered_i = true

            for filter in row_filters
                if !filter(_getdata(ptable.data), i)
                    filtered_i = false
                    break
                end
            end

            if filtered_i
                if id_filt ≤ max_num_filtered_rows
                    filtered_rows[id_filt] = i
                    id_filt += 1
                end

                num_filtered_rows +=1
            end
        end

        ptable._id_rows = filtered_rows[1:(id_filt - 1)]
        ptable._num_filtered_rows = num_filtered_rows
    else
        ptable._num_filtered_rows = max_num_filtered_rows
    end

    # Indicate that the filters were processed.
    ptable._filters_processed = true

    return nothing
end
