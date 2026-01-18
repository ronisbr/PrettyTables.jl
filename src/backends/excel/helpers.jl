## Description #############################################################################
#
# Helpers for designing tables in the Excel backend.
#
############################################################################################

"""
    _excel_width_for_text(text)

Estimate the width of a cell in Excel needed to accommodate the provided `text`.
"""
_excel_width_for_text(text) = length(text) * 1.1 + 1