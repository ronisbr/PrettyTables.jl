## Description #############################################################################
#
# Excel Back End: Helpers for designing table formats.
#
############################################################################################

export @excel__all_horizontal_lines, @excel__all_vertical_lines
export @excel__no_horizontal_lines,  @excel__no_vertical_lines

"""
    @excel__all_horizontal_lines

Return the keyword arguments to be splatted into [`ExcelTableFormat`](@ref) to enable all
horizontal lines.

# Examples

```julia
# Enable all horizontal lines.
table_format = ExcelTableFormat(; @excel__all_horizontal_lines)

# Enable all horizontal lines but suppress data-row underlines.
table_format = ExcelTableFormat(; @excel__all_horizontal_lines, horizontal_lines_at_data_rows = :none)
```
"""
macro excel__all_horizontal_lines()
    return :((
        horizontal_line_at_beginning            = true,
        horizontal_line_after_column_labels     = true,
        horizontal_line_between_column_labels   = true,
        horizontal_line_at_merged_column_labels = true,
        horizontal_lines_at_data_rows           = :all,
        horizontal_line_after_data_rows         = true,
        horizontal_line_before_row_group_label  = true,
        horizontal_line_after_row_group_label   = true,
        horizontal_line_before_summary_rows     = true,
        horizontal_line_after_summary_rows      = true,
    )...)
end

"""
    @excel__all_vertical_lines

Return the keyword arguments to be splatted into [`ExcelTableFormat`](@ref) to enable all
vertical lines.

# Examples

```julia
# Enable all vertical lines.
table_format = ExcelTableFormat(; @excel__all_vertical_lines)

# Enable all vertical lines but suppress the row-number column divider.
table_format = ExcelTableFormat(; @excel__all_vertical_lines, vertical_line_after_row_number_column = false)
```
"""
macro excel__all_vertical_lines()
    return :((
        vertical_line_at_beginning             = true,
        vertical_line_after_row_number_column  = true,
        vertical_line_after_row_label_column   = true,
        vertical_lines_at_data_columns         = :all,
        vertical_line_after_data_columns       = true,
    )...)
end

"""
    @excel__no_horizontal_lines

Return the keyword arguments to be splatted into [`ExcelTableFormat`](@ref) to suppress all
horizontal lines.

# Examples

```julia
# Suppress all horizontal lines.
table_format = ExcelTableFormat(; @excel__no_horizontal_lines)

# Suppress all horizontal lines except the one after the column labels.
table_format = ExcelTableFormat(; @excel__no_horizontal_lines, horizontal_line_after_column_labels = true)
```
"""
macro excel__no_horizontal_lines()
    return :((
        horizontal_line_at_beginning            = false,
        horizontal_line_after_column_labels     = false,
        horizontal_line_between_column_labels   = false,
        horizontal_line_at_merged_column_labels = false,
        horizontal_lines_at_data_rows           = :none,
        horizontal_line_after_data_rows         = false,
        horizontal_line_before_row_group_label  = false,
        horizontal_line_after_row_group_label   = false,
        horizontal_line_before_summary_rows     = false,
        horizontal_line_after_summary_rows      = false,
    )...)
end

"""
    @excel__no_vertical_lines

Return the keyword arguments to be splatted into [`ExcelTableFormat`](@ref) to suppress all
vertical lines.

# Examples

```julia
# Suppress all vertical lines.
table_format = ExcelTableFormat(; @excel__no_vertical_lines)

# Suppress all vertical lines except the one at the beginning.
table_format = ExcelTableFormat(; @excel__no_vertical_lines, vertical_line_at_beginning = true)
```
"""
macro excel__no_vertical_lines()
    return :((
        vertical_line_at_beginning             = false,
        vertical_line_after_row_number_column  = false,
        vertical_line_after_row_label_column   = false,
        vertical_lines_at_data_columns         = :none,
        vertical_line_after_data_columns       = false,
    )...)
end
