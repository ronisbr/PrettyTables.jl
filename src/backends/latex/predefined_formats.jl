# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Pre-defined formats for LaTeX tables.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export latex_default, latex_thick

const latex_default = LatexTableFormat()

const latex_thick = LatexTableFormat(
    top_line       = "\\noalign{\\hrule height 2pt}",
    header_line    = "\\noalign{\\hrule height 2pt}",
    mid_line       = "\\noalign{\\hrule height 1pt}",
    bottom_line    = "\\noalign{\\hrule height 2pt}",
    left_vline     = "@{\\vrule width 2pt\\hspace{2pt}}",
    mid_vline      = "@{\\hspace{2pt}\\vrule width 2pt\\hspace{2pt}}",
    right_vline    = "@{\\hspace{2pt}\\vrule width 2pt}",
    header_envs    = ["textbf"],
    subheader_envs = ["texttt"]
   )
