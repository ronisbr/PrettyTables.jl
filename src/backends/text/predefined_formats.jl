#== # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Pre-defined formats.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ==#

export unicode, ascii_dots, ascii_rounded, borderless, compact, markdown, mysql, simple, unicode_rounded, matrix

const unicode = TextFormat()

const ascii_dots = TextFormat(
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
    left_border         = ':',
    right_border        = ':',
    row                 = '.'
)

const ascii_rounded = TextFormat(
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
    left_border         = '|',
    right_border        = '|',
    row                 = '-'
)

const borderless = TextFormat(
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
    left_border         = ' ',
    right_border        = ' ',
    row                 = ' ',
    hlines              = [:header]
)

const compact = TextFormat(
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
    left_border         = ' ',
    right_border        = ' ',
    row                 = '-'
   )

const markdown = TextFormat(
    left_intersection   = '|',
    right_intersection  = '|',
    middle_intersection = '|',
    column              = '|',
    left_border         = '|',
    right_border        = '|',
    row                 = '-',
    hlines              = [:header]
)

const mysql = TextFormat(
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
    left_border         = '|',
    right_border        = '|',
    row                 = '-'
   )

const simple = TextFormat(
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
    left_border         = ' ',
    right_border        = ' ',
    row                 = '='
)

const unicode_rounded = TextFormat(
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
    left_border         = '│',
    right_border        = '│',
    row                 = '─'
)

const matrix = TextFormat(
    up_intersection     = ' ',
    left_intersection   = '│',
    right_intersection  = '│',
    middle_intersection = ' ',
    bottom_intersection = ' ',
    left_border         = '│',
    right_border        = '│',
    column              = ' ',
    row                 = ' '
)
