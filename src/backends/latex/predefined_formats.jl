## Description #############################################################################
#
# Pre-defined formats for LaTeX tables.
#
############################################################################################

export tf_latex_default, tf_latex_double, tf_latex_modern, tf_latex_booktabs

const tf_latex_default = LatexTableFormat()

const tf_latex_double = LatexTableFormat(
    top_line       = "\\hline\\hline",
    header_line    = "\\hline",
    mid_line       = "\\hline",
    bottom_line    = "\\hline\\hline",
    left_vline     = "|",
    mid_vline      = "|",
    right_vline    = "|",
    header_envs    = ["textbf"],
    subheader_envs = ["texttt"]
   )

const tf_latex_modern = LatexTableFormat(
    top_line       = "\\noalign{\\hrule height 2pt}",
    header_line    = "\\noalign{\\hrule height 2pt}",
    mid_line       = "\\noalign{\\hrule height 1pt}",
    bottom_line    = "\\noalign{\\hrule height 2pt}",
    left_vline     = "!{\\vrule width 2pt}",
    mid_vline      = "!{\\vrule width 1pt}",
    right_vline    = "!{\\vrule width 2pt}",
    header_envs    = ["textbf"],
    subheader_envs = ["texttt"]
   )

const tf_latex_booktabs = LatexTableFormat(
    top_line       = "\\toprule",
    header_line    = "\\midrule",
    mid_line       = "\\midrule",
    bottom_line    = "\\bottomrule",
    left_vline     = "",
    mid_vline      = "",
    right_vline    = "",
    header_envs    = ["textbf"],
    subheader_envs = ["texttt"],
   )
