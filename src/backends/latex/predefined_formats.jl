## Description #############################################################################
#
# LaTeX Back End: Pre-defined table formats.
#
############################################################################################

############################################################################################
#                                      Table Borders                                       #
############################################################################################

export latex_table_borders__booktabs

const latex_table_borders__booktabs = LatexTableBorders(
    top_line    = "\\toprule",
    header_line = "\\midrule",
    middle_line = "\\midrule",
    bottom_line = "\\bottomrule"
)

############################################################################################
#                                      Table Formats                                       #
############################################################################################

export latex_table_format__booktabs

const latex_table_format__booktabs = LatexTableFormat(
    ;
    borders = latex_table_borders__booktabs,
    @latex__all_horizontal_lines,
    @latex__no_vertical_lines,
    horizontal_lines_at_data_rows = :none,
)
