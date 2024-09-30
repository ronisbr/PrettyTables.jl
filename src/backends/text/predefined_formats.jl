## Description #############################################################################
#
# Text Back End: Pre-defined table formats.
#
############################################################################################

############################################################################################
#                                      Table Borders                                       #
############################################################################################

export text_table_borders__ascii_dots
export text_table_borders__ascii_rounded
export text_table_borders__borderless
export text_table_borders__compact
export text_table_borders__matrix
export text_table_borders__mysql
export text_table_borders__simple
export text_table_borders__unicode_rounded

const text_table_borders__ascii_dots = TextTableBorders(
    up_right_corner     = '.',
    up_left_corner      = '.',
    bottom_left_corner  = ':',
    bottom_right_corner = ':',
    up_intersection     = '.',
    left_intersection   = ':',
    right_intersection  = ':',
    middle_intersection = ':',
    bottom_intersection = ':',
    column              = ':',
    row                 = '.'
)

const text_table_borders__ascii_rounded = TextTableBorders(
    up_right_corner     = '.',
    up_left_corner      = '.',
    bottom_left_corner  = '\'',
    bottom_right_corner = '\'',
    up_intersection     = '.',
    left_intersection   = ':',
    right_intersection  = ':',
    middle_intersection = '+',
    bottom_intersection = '\'',
    column              = '|',
    row                 = '-'
)

const text_table_borders__borderless = TextTableBorders(
    up_right_corner     = ' ',
    up_left_corner      = ' ',
    bottom_left_corner  = ' ',
    bottom_right_corner = ' ',
    up_intersection     = ' ',
    left_intersection   = ' ',
    right_intersection  = ' ',
    middle_intersection = ' ',
    bottom_intersection = ' ',
    column              = ' ',
    row                 = ' ',
)

const text_table_borders__compact = TextTableBorders(
    up_right_corner     = ' ',
    up_left_corner      = ' ',
    bottom_left_corner  = ' ',
    bottom_right_corner = ' ',
    up_intersection     = ' ',
    left_intersection   = ' ',
    right_intersection  = ' ',
    middle_intersection = ' ',
    bottom_intersection  = ' ',
    column              = ' ',
    row                 = '-'
)

const text_table_borders__matrix = TextTableBorders(
    left_intersection   = '│',
    right_intersection  = '│',
    middle_intersection = '│',
    row                 = ' '
)

const text_table_borders__mysql = TextTableBorders(
    up_right_corner     = '+',
    up_left_corner      = '+',
    bottom_left_corner  = '+',
    bottom_right_corner = '+',
    up_intersection     = '+',
    left_intersection   = '+',
    right_intersection  = '+',
    middle_intersection = '+',
    bottom_intersection = '+',
    column              = '|',
    row                 = '-'
)

const text_table_borders__simple = TextTableBorders(
    up_right_corner     = '=',
    up_left_corner      = '=',
    bottom_left_corner  = '=',
    bottom_right_corner = '=',
    up_intersection     = ' ',
    left_intersection   = '=',
    right_intersection  = '=',
    middle_intersection = ' ',
    bottom_intersection  = ' ',
    column              = ' ',
    row                 = '='
)

const text_table_borders__unicode_rounded = TextTableBorders(
    up_right_corner     = '╮',
    up_left_corner      = '╭',
    bottom_left_corner  = '╰',
    bottom_right_corner = '╯',
    up_intersection     = '┬',
    left_intersection   = '├',
    right_intersection  = '┤',
    middle_intersection = '┼',
    bottom_intersection = '┴',
    column              = '│',
    row                 = '─'
)

############################################################################################
#                                      Table Formats                                       #
############################################################################################

export text_table_format__matrix

const text_table_format__matrix = TextTableFormat(
    borders                                  = text_table_borders__matrix,
    horizontal_line_after_column_labels      = true,
    horizontal_line_after_data_rows          = true,
    horizontal_line_after_row_group_label    = false,
    horizontal_line_after_summary_rows       = true,
    horizontal_line_at_beginning             = true,
    horizontal_line_before_row_group_label   = false,
    horizontal_lines_at_data_rows            = :none,
    right_vertical_lines_at_data_columns     = :none,
    suppress_vertical_lines_at_column_labels = true,
    vertical_line_after_continuation_column  = true,
    vertical_line_after_data_columns         = true,
    vertical_line_after_row_label_column     = true,
    vertical_line_after_row_number_column    = true,
    vertical_line_at_beginning               = true,
)
