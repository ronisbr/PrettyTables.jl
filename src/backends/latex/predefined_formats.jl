# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Pre-defined formats for LaTeX tables.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export latex_default, latex_simple

const latex_default = LatexTableFormat()

const latex_simple = LatexTableFormat(
    top_line       = "\\hline",
    header_line    = "\\hline",
    mid_line       = "\\hline",
    bottom_line    = "\\hline",
    left_vline     = "|",
    mid_vline      = "|",
    right_vline    = "|",
    header_envs    = ["textbf"],
    subheader_envs = ["texttt"]
   )
