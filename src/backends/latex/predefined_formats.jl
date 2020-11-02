# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Pre-defined formats for LaTeX tables.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export tf_latex_default, tf_latex_simple

const tf_latex_default = LatexTableFormat()

const tf_latex_simple = LatexTableFormat(
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
