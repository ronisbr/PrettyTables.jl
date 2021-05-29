# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Pre-defined formats.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export tf_unicode, tf_ascii_dots, tf_ascii_rounded, tf_borderless, tf_compact
export tf_markdown, tf_mysql, tf_simple, tf_unicode_rounded, tf_matrix

const tf_unicode = TextFormat()

const tf_ascii_dots = TextFormat(
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

const tf_ascii_rounded = TextFormat(
    up_right_corner     = '.',
    up_left_corner      = '.',
    bottom_left_corner  = ''',
    bottom_right_corner = ''',
    up_intersection     = '.',
    left_intersection   = ':',
    right_intersection  = ':',
    middle_intersection = '+',
    bottom_intersection = ''',
    column              = '|',
    row                 = '-'
)

const tf_borderless = TextFormat(
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
    hlines              = [:header]
)

const tf_compact = TextFormat(
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

const tf_markdown = TextFormat(
    left_intersection   = '|',
    right_intersection  = '|',
    middle_intersection = '|',
    column              = '|',
    row                 = '-',
    hlines              = [:header]
)

const tf_mysql = TextFormat(
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

const tf_simple = TextFormat(
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

const tf_unicode_rounded = TextFormat(
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

const tf_matrix = TextFormat(
    left_intersection   = '│',
    right_intersection  = '│',
    row                 = ' ',
    vlines              = [:begin, :end],
    hlines              = [:begin, :end]
)
