#== # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Pre-defined formats.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ==#

export unicode, ascii_dots, ascii_rounded, borderless, compact, markdown, mysql,
       simple, unicode_rounded

const unicode = PrettyTableFormat()

const ascii_dots = PrettyTableFormat(
    up_right_corner     = '.',
    up_left_corner      = '.',
    bottom_left_corner  = ':',
    bottom_right_corner = ':',
    up_intersection     = '.',
    left_intersection   = ':',
    right_intersection  = ':',
    middle_intersection = ':',
    bottom_intersection  = ':',
    column              = ':',
    row                 = '.'
)

const ascii_rounded = PrettyTableFormat(
    up_right_corner     = '.',
    up_left_corner      = '.',
    bottom_left_corner  = '\'',
    bottom_right_corner = ''',
    up_intersection     = '.',
    left_intersection   = ':',
    right_intersection  = ':',
    middle_intersection = '+',
    bottom_intersection = ''',
    column              = '|',
    row                 = '-'
)

const borderless = PrettyTableFormat(
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
    top_line            = false,
    bottom_line         = false
)

const compact = PrettyTableFormat(
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

const markdown = PrettyTableFormat(
    left_intersection   = '|',
    right_intersection  = '|',
    middle_intersection = '|',
    column              = '|',
    row                 = '-',
    top_line            = false,
    bottom_line         = false,
)

const mysql = PrettyTableFormat(
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

const simple = PrettyTableFormat(
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

const unicode_rounded = PrettyTableFormat(
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
    row                 = '─',
)
