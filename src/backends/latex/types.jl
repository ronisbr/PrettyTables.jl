# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Types and structures for the LaTeX backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export LatexTableFormat, LatexHighlighter

"""
    struct LatexTableFormat

This structure defines the format of the LaTeX table.

# Fields

* `top_line`: Top line of the table.
* `header_line`: Line that separate the header from the table body.
* `mid_line`: Line printed in the middle of the table.
* `bottom_line`: Bottom line of the table.
* `left_vline`: Left vertical line of the table.
* `mid_vline`: Vertical line in the middle of the table.
* `right_vline`: Right vertical line of the table.
* `header_envs`: LaTeX environments that will be used in each header cell.
* `subheader_envs`: LaTeX environments that will be used in each sub-header
                    cell.

"""
@with_kw struct LatexTableFormat
    top_line::String               = "\\noalign{\\hrule height 2pt}"
    header_line::String            = "\\noalign{\\hrule height 2pt}"
    mid_line::String               = "\\noalign{\\hrule height 1pt}"
    bottom_line::String            = "\\noalign{\\hrule height 2pt}"
    left_vline::String             = "@{\\vrule width 2pt\\hspace{2pt}}"
    mid_vline::String              = "@{\\hspace{2pt}\\vrule width 2pt\\hspace{2pt}}"
    right_vline::String            = "@{\\hspace{2pt}\\vrule width 2pt}"
    header_envs::Vector{String}    = ["textbf"]
    subheader_envs::Vector{String} = ["texttt"]
end

"""
    struct LatexHighlighter

Defines the default highlighter of a table when using the LaTeX backend.

# Fields

* `f`: Function with the signature `f(data,i,j)` in which should return `true`
       if the element `(i,j)` in `data` must be highlighter, or `false`
       otherwise.
* `fd`: A function with the signature `f(data,i,j,str)::String` in which
        `data` is the matrix, `(i,j)` is the element position in the table, and
        `str` is the data converted to string. This function must return a
        string that will be placed in the cell.

# Remarks

This structure can be constructed using two helpers:

    LatexHighlighter(f::Function, envs::Union{String,Vector{String}})

    LatexHighlighter(f::Function, fd::Function)

The first will apply recursively all the LaTeX environments in `envs` to the
highlighted text whereas the second let the user select the desired decoration
by specifying the function `fd`.

Thus, for example:

    LatexHighlighter((data,i,j)->true, ["textbf", "small"])

will wrap all the cells in the table in the following environment:

    \\textbf{\\small{<Cell text>}}

"""
@with_kw struct LatexHighlighter
    f::Function
    fd::Function
end

LatexHighlighter(f::Function, env::String) = LatexHighlighter(f, [env])
LatexHighlighter(f::Function, envs::Vector{String}) =
    LatexHighlighter(f, (data,i,j,str)->_latex_envs(str, envs))
