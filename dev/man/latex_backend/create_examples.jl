using PrettyTables

#                                   Formats
# ==============================================================================

data = [true  100.0 0x8080 "String"
        false 200.0 0x0808 "String"
        true  300.0 0x1986 "String"
        false 400.0 0x1987 "String"]

# Default
# =======

run(`cp example.tex format_default.tex`)
include_pt_in_file("format_default.tex", "Table 1", data, backend = :latex,
                   backup_file = false, tf = latex_default)
run(`pdflatex format_default.tex`)
run(`pdflatex format_default.tex`)
run(`convert -density 150 -trim -strip format_default.pdf format_default.png`)
run(`rm format_default.tex`)
run(`rm format_default.pdf`)

# Simple
# ======

run(`cp example.tex format_simple.tex`)
include_pt_in_file("format_simple.tex", "Table 1", data, backend = :latex,
                   backup_file = false, tf = latex_simple)
run(`pdflatex format_simple.tex`)
run(`pdflatex format_simple.tex`)
run(`convert -density 150 -trim -strip format_simple.pdf format_simple.png`)
run(`rm format_simple.tex`)
run(`rm format_simple.pdf`)

#                                 Highlighters
# ==============================================================================

t = 0:1:20;

data = hcat(t, ones(length(t))*1, 1*t, 0.5.*t.^2);

header = ["Time" "Acceleration" "Velocity" "Distance";
           "[s]"  "[m/s\$^2\$]"    "[m/s]"      "[m]"];

hl_v = LatexHighlighter( (data,i,j)->(j == 3) && data[i,3] > 9, ["color{blue}","textbf"]);

hl_p = LatexHighlighter( (data,i,j)->(j == 4) && data[i,4] > 10, ["color{red}", "textbf"])

hl_e = LatexHighlighter( (data,i,j)->(i == 10), ["cellcolor{black}", "color{white}", "textbf"])

run(`cp example.tex latex_highlighter.tex`)
include_pt_in_file("latex_highlighter.tex", "Table 1", data, header,
                   backend = :latex, backup_file = false,
                   highlighters = (hl_e, hl_p, hl_v))
run(`pdflatex latex_highlighter.tex`)
run(`pdflatex latex_highlighter.tex`)
run(`convert -density 150 -trim -strip latex_highlighter.pdf latex_highlighter.png`)
run(`rm latex_highlighter.tex`)
run(`rm latex_highlighter.pdf`)

run(`sh cleanall.sh`)

