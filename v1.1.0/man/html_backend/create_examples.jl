using PrettyTables

header = [ "Header 1" "Header 2" "Header 3" "Header 4";
              "Sub 1"    "Sub 2"    "Sub 3"    "Sub 4"]
data = [ true  100.0 0x8080 "String";
         false 200.0 0x0808 "String";
         true  300.0 0x1986 "String";
         false 400.0 0x1987 "String"; ]

for (filename, format) in
    (("./html_format_default.html",    html_default),
     ("./html_format_dark.html",       html_dark),
     ("./html_format_minimalist.html", html_minimalist),
     ("./html_format_simple.html",     html_simple))

    open(filename, "w") do f
        pretty_table(f, data, header, backend = Val(:html), tf = format)
    end
end

open("./html_format_matrix.html", "w") do f
    pretty_table(f, data, tf = html_matrix, noheader = true)
end
