var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "#PrettyTables.jl-1",
    "page": "Home",
    "title": "PrettyTables.jl",
    "category": "section",
    "text": "CurrentModule = PrettyTables\nDocTestSetup = quote\n    using PrettyTables\nendThis package has the purpose to print data in matrices in a human-readable format. It was inspired in the functionality provided by ASCII Table Generator.(Image: )"
},

{
    "location": "#Requirements-1",
    "page": "Home",
    "title": "Requirements",
    "category": "section",
    "text": "Julia >= 1.0\nCrayons >= 4.0\nFormatting >= 0.4\nReexport >= 0.2\nTables >= 0.2"
},

{
    "location": "#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "julia> using Pkg\njulia> Pkg.add(\"PrettyTables\")"
},

{
    "location": "#Manual-outline-1",
    "page": "Home",
    "title": "Manual outline",
    "category": "section",
    "text": "Pages = [\n    \"man/usage.md\"\n    \"man/text_backend.md\"\n    \"man/html_backend.md\"\n    \"man/latex_backend.md\"\n    \"man/alignment.md\"\n    \"man/filters.md\"\n    \"man/formatters.md\"\n    \"man/text_examples.md\"\n    \"man/html_examples.md\"\n    \"lib/library.md\"\n]\nDepth = 2"
},

{
    "location": "man/usage/#",
    "page": "Usage",
    "title": "Usage",
    "category": "page",
    "text": ""
},

{
    "location": "man/usage/#Usage-1",
    "page": "Usage",
    "title": "Usage",
    "category": "section",
    "text": "CurrentModule = PrettyTables\nDocTestSetup = quote\n    using PrettyTables\nendThe following function can be used to print data.function pretty_table([io::IO | String,] table[, header::AbstractVecOrMat];  kwargs...)Print to io the table table with header header. If conf is omitted, then the default configuration will be used. If io is omitted, then it defaults to stdout. If String is passed in the place of io, then a String with the printed table will be returned by the function.The header can be a Vector or a Matrix. If it is a Matrix, then each row will be a header line. The first line is called header and the others are called sub-headers . If header is empty or missing, then it will be automatically filled with \"Col.  i\" for the i-th column.When printing, it will be verified if table complies with Tables.jl API.  If it is is compliant, then this interface will be used to print the table. If it is not compliant, then only the following types are supported:AbstractVector: any vector can be printed. In this case, the header must be a vector, where the first element is considered the header and the others are the sub-headers.\nAbstractMatrix: any matrix can be printed.\nDict: any Dict can be printed. In this case, the special keyword sortkeys can be used to select whether or not the user wants to print the dictionary with the keys sorted. If it is false, then the elements will be printed on the same order returned by the functions keys and values. Notice that this assumes that the keys are sortable, if they are not, then an error will be thrown.The user can select which back-end will be used to print the tables using the keyword argument backend. Currently, the following back-ends are supported:Text (backend = :text): prints the table in text mode. This is the default selection if the keyword backend is absent.\nHTML (backend = :html): prints the table in HTML.\nLaTeX (backend = :latex): prints the table in LaTeX format.Each back-end defines its own configuration keywords that can be passed using kwargs. However, the following keywords are valid for all back-ends:alignment: Select the alignment of the columns (see the section              Alignment.\nbackend: Select which back-end will be used to print the table. Notice that            the additional configuration in kwargs... depends on the selected            back-end.\ncell_alignment: A tuple of functions with the signature f(data,i,j) that                   overrides the alignment of the cell (i,j) to the value                   returned by f. It can also be a single function, when it                   is assumed that only one alignment function is required, or                   nothing, when no cell alignment modification will be                   performed. If the function f does not return a valid                   alignment symbol as shown in section Alignment, then                   it will be discarded. For convenience, it can also be a                   dictionary of type (i,j) => a that overrides the                   alignment of the cell (i,j) to a. a must be a symbol                   like specified in the section Alignment.\nnote: Note\nIf more than one alignment function is passed to cell_alignment, then the functions will be evaluated in the same order of the tuple. The first one that returns a valid alignment symbol for each cell is applied, and the rest is discarded.\n(Default = nothing)\ncell_first_line_only: If true, then only the first line of each cell will be printed. (Default = false)\ncompact_printing: Select if the option :compact will be used when printing                     the data. (Default = true)\nfilters_row: Filters for the rows (see the section Filters).\nfilters_col: Filters for the columns (see the section Filters).\nformatters: See the section Formatters.\nheader_alignment: Select the alignment of the header columns (see the                     section Alignment. If the symbol that specifies                     the alignment is :s for a specific column, then the same                     alignment in the keyword alignment for that column will                     be used. (Default = :s)\nheader_cell_alignment: This keyword has the same structure of                          cell_alignment but in this case it operates in the                          header. Thus, (i,j) will be a cell in the header                          matrix that contains the header and sub-headers. This                          means that the data field in the functions will be                          the same value passed in the keyword header.\nnote: Note\nIf more than one alignment function is passed to header_cell_alignment, then the functions will be evaluated in the same order of the tuple. The first one that returns a valid alignment symbol for each cell is applied, and the rest is discarded.\n(Default = nothing)\nrenderer: A symbol that indicates which function should be used to convert             an object to a string. It can be :print to use the function             print or :show to use the function show. Notice that this             selection is not applicable to the headers and sub-headers. They             will always be converted using print. (Default = :print)\nrow_names: A vector containing the row names that will be appended to the              left of the table. If it is nothing, then the column with the              row names will not be shown. Notice that the size of this vector              must match the number of rows in the table.              (Default = nothing)\nrow_name_alignment: Alignment of the column with the rows name (see the                       section Alignment).\nrow_name_column_title: Title of the column with the row names.                          (Default = \"\")\nrow_number_column_title: The title of the column that shows the row numbers.                            (Default = \"Row\")\nshow_row_number: If true, then a new column will be printed showing the                    row number. (Default = false)\ntitle: The title of the table. If it is empty, then no title will be          printed. (Default = \"\")\ntitle_alignment: Alignment of the title, which must be a symbol as explained                    in the section Alignment. This argument is                    ignored in the LaTeX backend. (Default = :l)note: Note\nNotice that all back-ends have the keyword tf to specify the table printing format. Thus, if the keyword backend is not present or if it is nothing, then the back-end will be automatically inferred from the type of the keyword tf. In this case, if tf is also not present, then it just fall-back to the text back-end."
},

{
    "location": "man/usage/#Examples-1",
    "page": "Usage",
    "title": "Examples",
    "category": "section",
    "text": "In the following, it is possible to see some examples for a quick start using the text back-end.julia> data = [1 2 3; 4 5 6];\n\njulia> pretty_table(data, [\"Column 1\", \"Column 2\", \"Column 3\"])\n┌──────────┬──────────┬──────────┐\n│ Column 1 │ Column 2 │ Column 3 │\n├──────────┼──────────┼──────────┤\n│        1 │        2 │        3 │\n│        4 │        5 │        6 │\n└──────────┴──────────┴──────────┘\n\njulia> pretty_table(data, [\"Column 1\" \"Column 2\" \"Column 3\"; \"A\" \"B\" \"C\"])\n┌──────────┬──────────┬──────────┐\n│ Column 1 │ Column 2 │ Column 3 │\n│        A │        B │        C │\n├──────────┼──────────┼──────────┤\n│        1 │        2 │        3 │\n│        4 │        5 │        6 │\n└──────────┴──────────┴──────────┘\n\njulia> str = pretty_table(String, data, [\"Column 1\", \"Column 2\", \"Column 3\"]);\n\njulia> print(str)\n┌──────────┬──────────┬──────────┐\n│ Column 1 │ Column 2 │ Column 3 │\n├──────────┼──────────┼──────────┤\n│        1 │        2 │        3 │\n│        4 │        5 │        6 │\n└──────────┴──────────┴──────────┘julia> dict = Dict(1 => \"Jan\", 2 => \"Feb\", 3 => \"Mar\", 4 => \"Apr\", 5 => \"May\", 6 => \"Jun\");\n\njulia> pretty_table(dict)\n┌───────┬────────┐\n│  Keys │ Values │\n│ Int64 │ String │\n├───────┼────────┤\n│     4 │    Apr │\n│     2 │    Feb │\n│     3 │    Mar │\n│     5 │    May │\n│     6 │    Jun │\n│     1 │    Jan │\n└───────┴────────┘\n\njulia> pretty_table(dict, sortkeys = true)\n┌───────┬────────┐\n│  Keys │ Values │\n│ Int64 │ String │\n├───────┼────────┤\n│     1 │    Jan │\n│     2 │    Feb │\n│     3 │    Mar │\n│     4 │    Apr │\n│     5 │    May │\n│     6 │    Jun │\n└───────┴────────┘\n"
},

{
    "location": "man/usage/#Configuration-1",
    "page": "Usage",
    "title": "Configuration",
    "category": "section",
    "text": "The following function can be used to print a table changing the default configurations of PrettyTables.jl:pretty_table_with_conf(conf::PrettyTablesConf, args...; kwargs...)It calls pretty_table using the default configuration in conf. The args... and kwargs... can be the same as those passed to pretty_tables. Notice that all the configurations in kwargs... will overwrite the ones in conf.The object conf can be created by the function set_pt_conf in which the keyword parameters can be any one supported by the function pretty_table as shown in the following.julia> conf = set_pt_conf(tf = tf_markdown, alignment = :c);\n\njulia> data = [1 2 3; 4 5 6];\n\njulia> header = [\"Column 1\" \"Column 2\" \"Column 3\"];\n\njulia> pretty_table_with_conf(conf, data, header)\n| Column 1 | Column 2 | Column 3 |\n|----------|----------|----------|\n|    1     |    2     |    3     |\n|    4     |    5     |    6     |A configuration object can be modified by the function set_pt_conf! and cleared by the function clear_pt_conf!."
},

{
    "location": "man/usage/#Helpers-1",
    "page": "Usage",
    "title": "Helpers",
    "category": "section",
    "text": "The macro @pt was created to make it easier to pretty print tables to stdout. Its signature is:macro pt(expr...)where the expression list expr contains the tables that should be printed like:@pt table1 table2 table3The user can select the table header by passing the expression::header = [<Vector with the header>]Notice that the header is valid only for the next printed table. Hence:    @pt :header = header1 table1 :header = header2 table2 table3will print table1 using header1, table2 using header2, and table3 using the default header.The global configurations used to print tables with the macro @pt can be selected by:macro ptconf(expr...)where expr format must be:keyword1 = value1 keyword2 = value2 ...The keywords can be any possible keyword that can be used in the function pretty_table.All the configurations can be reseted by calling @ptconfclean.warning: Warning\nIf a keyword is not supported by the function pretty_table, then no error message is printed when calling @ptconf. However, an error will be thrown when @pt is called.info: Info\nWhen more than one table is passed to the macro @pt, then multiple calls to pretty_table will occur. Hence, the cropping algorithm will behave exactly the same as printing the tables separately.julia> data = [1 2 3; 4 5 6];\n\njulia> @pt data\n┌────────┬────────┬────────┐\n│ Col. 1 │ Col. 2 │ Col. 3 │\n├────────┼────────┼────────┤\n│      1 │      2 │      3 │\n│      4 │      5 │      6 │\n└────────┴────────┴────────┘\n\njulia> @pt :header = [\"Column 1\", \"Column 2\", \"Column 3\"] data :header = [\"Column 1\" \"Column 2\" \"Column 3\"; \"A\" \"B\" \"C\"] data\n┌──────────┬──────────┬──────────┐\n│ Column 1 │ Column 2 │ Column 3 │\n├──────────┼──────────┼──────────┤\n│        1 │        2 │        3 │\n│        4 │        5 │        6 │\n└──────────┴──────────┴──────────┘\n┌──────────┬──────────┬──────────┐\n│ Column 1 │ Column 2 │ Column 3 │\n│        A │        B │        C │\n├──────────┼──────────┼──────────┤\n│        1 │        2 │        3 │\n│        4 │        5 │        6 │\n└──────────┴──────────┴──────────┘\n\njulia> @ptconf tf = tf_ascii_dots alignment = :c\n\njulia> @pt data\n............................\n: Col. 1 : Col. 2 : Col. 3 :\n:........:........:........:\n:   1    :   2    :   3    :\n:   4    :   5    :   6    :\n:........:........:........:\n\njulia> @ptconfclean\n\njulia> @pt data\n┌────────┬────────┬────────┐\n│ Col. 1 │ Col. 2 │ Col. 3 │\n├────────┼────────┼────────┤\n│      1 │      2 │      3 │\n│      4 │      5 │      6 │\n└────────┴────────┴────────┘"
},

{
    "location": "man/text_backend/#",
    "page": "Text",
    "title": "Text",
    "category": "page",
    "text": ""
},

{
    "location": "man/text_backend/#Text-back-end-1",
    "page": "Text",
    "title": "Text back-end",
    "category": "section",
    "text": "CurrentModule = PrettyTables\nDocTestSetup = quote\n    using PrettyTables\nendThe following options are available when the text backend is used. Those can be passed as keywords when calling the function pretty_table:border_crayon: Crayon to print the border.\nheader_crayon: Crayon to print the header.\nsubheaders_crayon: Crayon to print sub-headers.\nrownum_header_crayon: Crayon for the header of the column with the row                         numbers.\ntext_crayon: Crayon to print default text.\nalignment: Select the alignment of the columns (see the section              Alignment).\nautowrap: If true, then the text will be wrapped on spaces to fit the             column. Notice that this function requires linebreaks = true and             the column must have a fixed size (see columns_width).\nbody_hlines: A vector of Int indicating row numbers in which an additional                horizontal line should be drawn after the row. Notice that                numbers lower than 1 and equal or higher than the number of                printed rows will be neglected. This vector will be appended to                the one in hlines, but the indices here are related to the                printed rows of the body. Thus, if 1 is added to                body_hlines, then a horizontal line will be drawn after the                first data row. (Default = Int[])\nbody_hlines_format: A tuple of 4 characters specifying the format of the                       horizontal lines that will be drawn by body_hlines.                       The characters must be the left intersection, the middle                       intersection, the right intersection, and the row. If it                       is nothing, then it will use the same format specified                       in tf. (Default = nothing)\ncell_alignment: A dictionary of type (i,j) => a that overrides that                   alignment of the cell (i,j) to a regardless of the                   columns alignment selected. a must be a symbol like                   specified in the section Alignment.\ncolumns_width: A set of integers specifying the width of each column. If the                  width is equal or lower than 0, then it will be automatically                  computed to fit the large cell in the column. If it is                  a single integer, then this number will be used as the size                  of all columns. (Default = 0)\ncontinuation_row_alignment: A symbol that defines the alignment of the cells                               in the continuation row. This row is printed if                               the table is vertically cropped.                               (Default = :c)\ncrop: Select the printing behavior when the data is bigger than the         available screen size (see screen_size). It can be :both to crop         on vertical and horizontal direction, :horizontal to crop only on         horizontal direction, :vertical to crop only on vertical direction,         or :none to do not crop the data at all.\ncrop_num_lines_at_beginning: Number of lines to be left at the beginning of                                the printing when vertically cropping the                                output. Notice that the lines required to show                                the title are automatically computed.                                (Default = 0)\ncrop_subheader: If true, then the sub-header size will not be taken into                   account when computing the column size. Hence, the print                   algorithm can crop it to save space. This has no effect if                   the user selects a fixed column width.                   (Default = false)\nellipsis_line_skip: An integer defining how many lines will be skipped from                       showing the ellipsis that indicates the text was                       cropped. (Default = 0)\nequal_columns_width: If true, then all the columns will have the same                        width. (Default = false)\nfilters_row: Filters for the rows (see the section Filters).\nfilters_col: Filters for the columns (see the section Filters).\nhighlighters: An instance of Highlighter or a tuple with a list of                 highlighters (see the section Text highlighters).\nhlines: This variable controls where the horizontal lines will be drawn. It           can be nothing, :all, :none or a vector of integers.\nIf it is nothing, which is the default, then the configuration will be obtained from the table format in the variable tf (see TextFormat).\nIf it is :all, then all horizontal lines will be drawn.\nIf it is :none, then no horizontal line will be drawn.\nIf it is a vector of integers, then the horizontal lines will be drawn only after the rows in the vector. Notice that the top line will be drawn if 0 is in hlines, and the header and subheaders are considered as only 1 row. Furthermore, it is important to mention that the row number in this variable is related to the printed rows. Thus, it is affected by filters, and by the option to suppress the header noheader. Finally, for convenience, the top and bottom lines can be drawn by adding the symbols :begin and :end to this vector, respectively, and the line after the header can be drawn by adding the symbol :header.\ninfo: Info\nThe values of body_hlines will be appended to this vector. Thus, horizontal lines can be drawn even if hlines is :none.\n(Default = nothing)\nlinebreaks: If true, then \\n will break the line inside the cells.               (Default = false)\nmaximum_columns_width: A set of integers specifying the maximum width of                          each column. If the width is equal or lower than 0,                          then it will be ignored. If it is a single integer,                          then this number will be used as the maximum width                          of all columns. Notice that the parameter                          columns_width has precedence over this one.                          (Default = 0)\nminimum_columns_width: A set of integers specifying the minimum width of                          each column. If the width is equal or lower than 0,                          then it will be ignored. If it is a single integer,                          then this number will be used as the minimum width                          of all columns. Notice that the parameter                          columns_width has precedence over this one.                          (Default = 0)\nnewline_at_end: If false, then the table will not end with a newline                   character. (Default = true)\nnoheader: If true, then the header will not be printed. Notice that all             keywords and parameters related to the header and sub-headers will             be ignored. (Default = false)\nnosubheader: If true, then the sub-header will not be printed, i.e. the                header will contain only one line. Notice that this option has                no effect if noheader = true. (Default = false)\nomitted_cell_summary_crayon: Crayon used to print the omitted cell summary.\noverwrite: If true, then the same number of lines in the printed table              will be deleted from the output io. This can be used to update              the table in the screen continuously. (Default = false)\nrow_number_alignment: Select the alignment of the row number column (see the                         section Alignment). (Default = :r)\nscreen_size: A tuple of two integers that defines the screen size (num. of                rows, num. of columns) that is available to print the table. It                is used to crop the data depending on the value of the keyword                crop. If it is nothing, then the size will be obtained                automatically. Notice that if a dimension is not positive, then                it will be treated as unlimited. (Default = nothing)\nshow_omitted_cell_summary: If true, then a summary will be printed after                              the table with the number of columns and rows                              that were omitted. (Default = true)\ntitle_autowrap: If true, then the title text will be wrapped considering                   the title size. Otherwise, lines larger than the title size                   will be cropped. (Default = false)\ntitle_crayon: Crayon to print the title.\ntitle_same_width_as_table: If true, then the title width will match that                              of the table. Otherwise, the title size will be                              equal to the screen width.                              (Default = false)\ntf: Table format used to print the table (see the section       Text table formats). (Default = tf_unicode)\nvcrop_mode: This variable defines the vertical crop behavior. If it is               :bottom, then the data, if required, will be cropped in the               bottom. On the other hand, if it is :middle, then the data               will be cropped in the middle if necessary.               (Default = :bottom)\nvlines: This variable controls where the vertical lines will be drawn. It           can be nothing, :all, :none or a vector of integers.\nIf it is nothing, which is the default, then the configuration will be obtained from the table format in the variable tf (see TextFormat).\nIf it is :all, then all vertical lines will be drawn.\nIf it is :none, then no vertical line will be drawn.\nIf it is a vector of integers, then the vertical lines will be drawn only after the columns in the vector. Notice that the top line will be drawn if 0 is in vlines. Furthermore, it is important to mention that the column number in this variable is related to the printed column. Thus, it is affected by filters, and by the options row_names and show_row_number. Finally, for convenience, the left and right vertical lines can be drawn by adding the symbols :begin and :end to this vector, respectively, and the line after the header can be drawn by adding the symbol :header.\n(Default = nothing)The keywords header_crayon and subheaders_crayon can be a Crayon or a Vector{Crayon}. In the first case, the Crayon will be applied to all the elements. In the second, each element can have its own crayon, but the length of the vector must be equal to the number of columns in the data.note: Note\nIf the renderer show is used, then all strings will be printed with surrounding quotes. However, if a formatter modifies a value and return a string, then those surrounding quotes will be removed if the original value is not a string."
},

{
    "location": "man/text_backend/#Crayons-1",
    "page": "Text",
    "title": "Crayons",
    "category": "section",
    "text": "A Crayon is an object that handles a style for text printed on terminals. It is defined in the package Crayons.jl. There are many options available to customize the style, such as foreground color, background color, bold text, etc.A Crayon can be created in two different ways:julia> Crayon(foreground = :blue, background = :black, bold = :true)\n\njulia> crayon\"blue bg:black bold\"For more information, see the Crayon.jl documentation.info: Info\nThe Crayon.jl package is re-exported by PrettyTables.jl. Hence, you do not need using Crayons to create a Crayon."
},

{
    "location": "man/text_backend/#Cropping-1",
    "page": "Text",
    "title": "Cropping",
    "category": "section",
    "text": "By default, the data will be cropped to fit the screen. This behavior can be changed by using the keyword crop.julia> data = Any[1    false      1.0     0x01 ;\n                  2     true      2.0     0x02 ;\n                  3    false      3.0     0x03 ;\n                  4     true      4.0     0x04 ;\n                  5    false      5.0     0x05 ;\n                  6     true      6.0     0x06 ;];\n\njulia> pretty_table(data, screen_size = (11,30))\n┌────────┬────────┬────────┬──\n│ Col. 1 │ Col. 2 │ Col. 3 │ ⋯\n├────────┼────────┼────────┼──\n│      1 │  false │    1.0 │ ⋯\n│      2 │   true │    2.0 │ ⋯\n│      3 │  false │    3.0 │ ⋯\n│   ⋮    │   ⋮    │   ⋮    │ ⋱\n└────────┴────────┴────────┴──\n   1 column and 3 rows omitted\n\njulia> pretty_table(data, screen_size = (11,30), crop = :none)\n┌────────┬────────┬────────┬────────┐\n│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │\n├────────┼────────┼────────┼────────┤\n│      1 │  false │    1.0 │      1 │\n│      2 │   true │    2.0 │      2 │\n│      3 │  false │    3.0 │      3 │\n│      4 │   true │    4.0 │      4 │\n│      5 │  false │    5.0 │      5 │\n│      6 │   true │    6.0 │      6 │\n└────────┴────────┴────────┴────────┘If the keyword screen_size is not specified (or is nothing), then the screen size will be obtained automatically. For files, screen_size = (-1,-1), meaning that no limit exits in both vertical and horizontal direction.note: Note\nIn vertical cropping, the header and the first table row is always printed.note: Note\nThe highlighters will work even in partially printed data.If the user selects a fixed size for the columns (using the keyword columns_width), enables line breaks (using the keyword linebreaks), and sets autowrap = true, then the algorithm wraps the text on spaces to automatically fit the space.julia> data = [\"One very very very big long long line\"; \"Another very very very big big long long line\"];\n\njulia> pretty_table(data, columns_width = 10, autowrap = true, linebreaks = true, show_row_number = true)\n┌─────┬────────────┐\n│ Row │     Col. 1 │\n├─────┼────────────┤\n│   1 │   One very │\n│     │  very very │\n│     │   big long │\n│     │  long line │\n│   2 │    Another │\n│     │  very very │\n│     │   very big │\n│     │   big long │\n│     │  long line │\n└─────┴────────────┘It is also possible to change the vertical cropping behavior to crop the table in the middle instead of the bottom. This can be accomplished by passing the option vcrop_mode = :middle to pretty_table:julia> data = Any[1    false      1.0     0x01 ;\n                  2     true      2.0     0x02 ;\n                  3    false      3.0     0x03 ;\n                  4     true      4.0     0x04 ;\n                  5    false      5.0     0x05 ;\n                  6     true      6.0     0x06 ;];\n\njulia> pretty_table(data, screen_size = (11,30), vcrop_mode = :middle)\n┌────────┬────────┬────────┬──\n│ Col. 1 │ Col. 2 │ Col. 3 │ ⋯\n├────────┼────────┼────────┼──\n│      1 │  false │    1.0 │ ⋯\n│      2 │   true │    2.0 │ ⋯\n│   ⋮    │   ⋮    │   ⋮    │ ⋱\n│      6 │   true │    6.0 │ ⋯\n└────────┴────────┴────────┴──\n   1 column and 3 rows omitted"
},

{
    "location": "man/text_backend/#Text-highlighters-1",
    "page": "Text",
    "title": "Text highlighters",
    "category": "section",
    "text": "A set of highlighters can be passed as a Tuple to the highlighters keyword. Each highlighter is an instance of the structure Highlighter that contains three fields:f: Function with the signature f(data,i,j) in which should return true      if the element (i,j) in data must be highlighter, or false      otherwise.\nfd: Function with the signature f(h,data,i,j) in which h is the       highlighter. This function must return the Crayon to be applied to the       cell that must be highlighted.\ncrayon: The Crayon to be applied to the highlighted cell if the default           fd is used.The function f has the following signature:f(data, i, j)in which data is a reference to the data that is being printed, and i and j are the element coordinates that are being tested. If this function returns true, then the cell (i,j) will be highlighted.If the function f returns true, then the function fd(h,data,i,j) will be called and must return a Crayon that will be applied to the cell.A highlighter can be constructed using three helpers:Highlighter(f::Function; kwargs...)where it will construct a Crayon using the keywords in kwargs and apply it to the highlighted cell,Highlighter(f::Function, crayon::Crayon)where it will apply the crayon to the highlighted cell, andHighlighter(f::Function, fd::Function)where it will apply the Crayon returned by the function fd to the highlighted cell.info: Info\nIf only a single highlighter is wanted, then it can be passed directly to the keyword highlighter without being inside a Tuple.note: Note\nIf multiple highlighters are valid for the element (i,j), then the applied style will be equal to the first match considering the order in the tuple highlighters.note: Note\nIf the highlighters are used together with Formatters, then the change in the format will not affect the parameter data passed to the highlighter function f. It will always receive the original, unformatted value.julia> data = Any[ f(a) for a = 0:15:90, f in (sind,cosd,tand) ]\n\njulia> h1 = Highlighter( f      = (data,i,j) -> (data[i,j] < 0.5),\n                         crayon = crayon\"red bold\" )\n\njulia> h2 = Highlighter( (data,i,j) -> (data[i,j] > 0.5),\n                         bold       = true,\n                         foreground = :blue )\n\njulia> h3 = Highlighter( f      = (data,i,j) -> (data[i,j] == 0.5),\n                         crayon = Crayon(bold = true, foreground = :yellow) )\n\njulia> pretty_table(data, highlighters = (h1, h2, h3), compact_printing = false)(Image: )julia> data = Any[ f(a) for a = 0:15:90, f in (sind,cosd,tand) ]\n\njulia> hl_odd = Highlighter( f      = (data,i,j) -> i % 2 == 0,\n                             crayon = Crayon(background = :light_blue))\n\njulia> pretty_table(data, highlighters = hl_odd, formatters = ft_printf(\"%10.5f\"))(Image: )There are a set of pre-defined highlighters (with names hl_*) to make the usage simpler. They are defined in the file ./src/backends/text/predefined_highlighters.jl."
},

{
    "location": "man/text_backend/#Text-table-formats-1",
    "page": "Text",
    "title": "Text table formats",
    "category": "section",
    "text": "The following table formats are available when using the text back-end:tf_unicode (Default)┌────────┬────────┬────────┬────────┐\n│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │\n├────────┼────────┼────────┼────────┤\n│      1 │  false │    1.0 │      1 │\n│      2 │   true │    2.0 │      2 │\n│      3 │  false │    3.0 │      3 │\n└────────┴────────┴────────┴────────┘tf_ascii_dots.....................................\n: Col. 1 : Col. 2 : Col. 3 : Col. 4 :\n:........:........:........:........:\n:      1 :  false :    1.0 :      1 :\n:      2 :   true :    2.0 :      2 :\n:      3 :  false :    3.0 :      3 :\n:........:........:........:........:tf_ascii_rounded.--------.--------.--------.--------.\n| Col. 1 | Col. 2 | Col. 3 | Col. 4 |\n:--------+--------+--------+--------:\n|      1 |  false |    1.0 |      1 |\n|      2 |   true |    2.0 |      2 |\n|      3 |  false |    3.0 |      3 |\n\'--------\'--------\'--------\'--------\'tf_borderless  Col. 1   Col. 2   Col. 3   Col. 4\n\n       1    false      1.0        1\n       2     true      2.0        2\n       3    false      3.0        3tf_compact -------- -------- -------- --------\n  Col. 1   Col. 2   Col. 3   Col. 4\n -------- -------- -------- --------\n       1    false      1.0        1\n       2     true      2.0        2\n       3    false      3.0        3\n -------- -------- -------- --------tf_dataframe│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │\n├────────┼────────┼────────┼────────┤\n│      1 │  false │    1.0 │      1 │\n│      2 │   true │    2.0 │      2 │\n│      3 │  false │    3.0 │      3 │tf_markdown| Col. 1 | Col. 2 | Col. 3 | Col. 4 |\n|--------|--------|--------|--------|\n|      1 |  false |    1.0 |      1 |\n|      2 |   true |    2.0 |      2 |\n|      3 |  false |    3.0 |      3 |tf_matrix┌                     ┐\n│ 1   false   1.0   1 │\n│ 2    true   2.0   2 │\n│ 3   false   3.0   3 │\n└                     ┘info: Info\nIn this case, the table format matrix was printed with the option noheader = true.tf_mysql+--------+--------+--------+--------+\n| Col. 1 | Col. 2 | Col. 3 | Col. 4 |\n+--------+--------+--------+--------+\n|      1 |  false |    1.0 |      1 |\n|      2 |   true |    2.0 |      2 |\n|      3 |  false |    3.0 |      3 |\n+--------+--------+--------+--------+tf_simple========= ======== ======== =========\n  Col. 1   Col. 2   Col. 3   Col. 4\n========= ======== ======== =========\n       1    false      1.0        1\n       2     true      2.0        2\n       3    false      3.0        3\n========= ======== ======== =========tf_unicode_rounded╭────────┬────────┬────────┬────────╮\n│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │\n├────────┼────────┼────────┼────────┤\n│      1 │  false │    1.0 │      1 │\n│      2 │   true │    2.0 │      2 │\n│      3 │  false │    3.0 │      3 │\n╰────────┴────────┴────────┴────────╯note: Note\nThe format unicode_rounded should look awful on your browser, but it should be printed fine on your terminal.julia> data = Any[ f(a) for a = 0:15:90, f in (sind,cosd,tand)];\n\njulia> pretty_table(data, tf = tf_ascii_dots)\n..................................\n:   Col. 1 :   Col. 2 :   Col. 3 :\n:..........:..........:..........:\n:      0.0 :      1.0 :      0.0 :\n: 0.258819 : 0.965926 : 0.267949 :\n:      0.5 : 0.866025 :  0.57735 :\n: 0.707107 : 0.707107 :      1.0 :\n: 0.866025 :      0.5 :  1.73205 :\n: 0.965926 : 0.258819 :  3.73205 :\n:      1.0 :      0.0 :      Inf :\n:..........:..........:..........:\n\njulia> pretty_table(data, tf = tf_compact)\n ---------- ---------- ----------\n    Col. 1     Col. 2     Col. 3\n ---------- ---------- ----------\n       0.0        1.0        0.0\n  0.258819   0.965926   0.267949\n       0.5   0.866025    0.57735\n  0.707107   0.707107        1.0\n  0.866025        0.5    1.73205\n  0.965926   0.258819    3.73205\n       1.0        0.0        Inf\n ---------- ---------- ----------It is also possible to define you own custom table by creating a new instance of the structure TextFormat. For example, let\'s say that you want a table like simple that does not print the bottom line:julia> data = Any[ f(a) for a = 0:15:90, f in (sind,cosd,tand)];\n\njulia> tf = TextFormat(up_right_corner     = \'=\',\n                       up_left_corner      = \'=\',\n                       bottom_left_corner  = \'=\',\n                       bottom_right_corner = \'=\',\n                       up_intersection     = \' \',\n                       left_intersection   = \'=\',\n                       right_intersection  = \'=\',\n                       middle_intersection = \' \',\n                       bottom_intersection  = \' \',\n                       column              = \' \',\n                       row                 = \'=\',\n                       hlines              = [:begin,:header]);\n\njulia> pretty_table(data, tf = tf)\n=========== ========== ===========\n    Col. 1     Col. 2     Col. 3\n=========== ========== ===========\n       0.0        1.0        0.0\n  0.258819   0.965926   0.267949\n       0.5   0.866025    0.57735\n  0.707107   0.707107        1.0\n  0.866025        0.5    1.73205\n  0.965926   0.258819    3.73205\n       1.0        0.0        Inf\nor that does not print the header line:julia> data = Any[ f(a) for a = 0:15:90, f in (sind,cosd,tand)];\n\njulia> tf = TextFormat(up_right_corner     = \'=\',\n                       up_left_corner      = \'=\',\n                       bottom_left_corner  = \'=\',\n                       bottom_right_corner = \'=\',\n                       up_intersection     = \' \',\n                       left_intersection   = \'=\',\n                       right_intersection  = \'=\',\n                       middle_intersection = \' \',\n                       bottom_intersection  = \' \',\n                       column              = \' \',\n                       row                 = \'=\',\n                       hlines              = [:begin,:end]);\n\njulia> pretty_table(data, tf = tf)\n=========== ========== ===========\n    Col. 1     Col. 2     Col. 3\n       0.0        1.0        0.0\n  0.258819   0.965926   0.267949\n       0.5   0.866025    0.57735\n  0.707107   0.707107        1.0\n  0.866025        0.5    1.73205\n  0.965926   0.258819    3.73205\n       1.0        0.0        Inf\n=========== ========== ===========For more information, see the documentation of the structure TextFormat."
},

{
    "location": "man/html_backend/#",
    "page": "HTML",
    "title": "HTML",
    "category": "page",
    "text": ""
},

{
    "location": "man/html_backend/#HTML-back-end-1",
    "page": "HTML",
    "title": "HTML back-end",
    "category": "section",
    "text": "CurrentModule = PrettyTables\nDocTestSetup = quote\n    using PrettyTables\nend<script language=\"javascript\" type=\"text/javascript\">\n function resizeIframe(obj)\n {\n   obj.style.height = obj.contentWindow.document.body.scrollHeight + 10 + \'px\';\n   obj.style.width = obj.contentWindow.document.body.scrollWidth + 100 + \'px\';\n }\n</script>The following options are available when the HTML backend is used. Those can be passed as keywords when calling the function pretty_table:highlighters: An instance of HTMLHighlighter or a tuple with a                 list of HTML highlighters (see the section HTML                 highlighters).\nlinebreaks: If true, then \\\\n will be replaced by <br>.               (Default = false)\nnoheader: If true, then the header will not be printed. Notice that all             keywords and parameters related to the header and sub-headers will             be ignored. (Default = false)\nnosubheader: If true, then the sub-header will not be printed, i.e. the                header will contain only one line. Notice that this option has                no effect if noheader = true. (Default = false)\nstandalone: If true, then a complete HTML page will be generated.               Otherwise, only the content between the tags <table> and               </table> will be printed (with the tags included).               (Default = true)\ntf: An instance of the structure HTMLTableFormat that defines the       general format of the HTML table."
},

{
    "location": "man/html_backend/#HTML-highlighters-1",
    "page": "HTML",
    "title": "HTML highlighters",
    "category": "section",
    "text": "A set of highlighters can be passed as a Tuple to the highlighters keyword. Each highlighter is an instance of a structure that is a subtype of AbstractHTMLHighlighter. It also must also contain at least the following two fields to comply with the API:f: Function with the signature f(data,i,j) in which should return true      if the element (i,j) in data must be highlighted, or false      otherwise.\nfd: Function with the signature f(h,data,i,j) in which h is the       highlighter. This function must return the HTMLDecoration to       be applied to the cell that must be highlighted.The function f has the following signature:f(data, i, j)in which data is a reference to the data that is being printed, and i and j are the element coordinates that are being tested. If this function returns true, then the highlight style will be applied to the (i,j) element. Otherwise, the default style will be used.If the function f returns true, then the function fd(h,data,i,j) will be called and must return an element of type HTMLDecoration that contains the decoration to be applied to the cell.A HTML highlighter can be constructed using two helpers:HTMLHighlighter(f::Function, decoration::HTMLDecoration)\nHTMLHighlighter(f::Function, fd::Function)The first will apply a fixed decoration to the highlighted cell specified in decoration whereas the second let the user select the desired decoration by specifying the function fd.info: Info\nIf only a single highlighter is wanted, then it can be passed directly to the keyword highlighter without being inside a Tuple.note: Note\nIf multiple highlighters are valid for the element (i,j), then the applied style will be equal to the first match considering the order in the tuple highlighters.note: Note\nIf the highlighters are used together with Formatters, then the change in the format will not affect the parameter data passed to the highlighter function f. It will always receive the original, unformatted value.There are a set of pre-defined highlighters (with names hl_*) to make the usage simpler. They are defined in the file ./src/backends/html/predefined_highlighters.jl.julia> t = 0:1:20;\n\njulia> data = hcat(t, ones(length(t))*1, 1*t, 0.5.*t.^2);\n\njulia> header = [\"Time\" \"Acceleration\" \"Velocity\" \"Distance\";\n                  \"[s]\"       \"[m/s²]\"    \"[m/s]\"      \"[m]\"];\n\njulia> hl_v = HTMLHighlighter( (data,i,j)->(j == 3) && data[i,3] > 9, HTMLDecoration(color = \"blue\", font_weight = \"bold\"));\n\njulia> hl_p = HTMLHighlighter( (data,i,j)->(j == 4) && data[i,4] > 10, HTMLDecoration(color = \"red\"));\n\njulia> hl_e = HTMLHighlighter( (data,i,j)->data[i,1] == 10, HTMLDecoration(background = \"black\", color = \"white\"))\n\njulia> pretty_table(data, header, backend = :html, highlighters = (hl_e, hl_p, hl_v))<iframe src=\"html_highlighters_example.html\" frameborder=\"0\" scrolling=\"no\" onload=\"javascript:resizeIframe(this)\">\n  <p>Your browser does not support iframes. Click <a href=\"html_highlighters_example.html>here</a> to see the table.</p>\n</iframe>"
},

{
    "location": "man/html_backend/#HTML-table-formats-1",
    "page": "HTML",
    "title": "HTML table formats",
    "category": "section",
    "text": "The following table formats are available when using the html back-end:tf_html_default (Default)<iframe src=\"html_format_default.html\" frameborder=\"0\" scrolling=\"no\" onload=\"javascript:resizeIframe(this)\">\n  <p>Your browser does not support iframes. Click <a href=\"html_format_default.html>here</a> to see the table.</p>\n</iframe>tf_html_dark<iframe src=\"html_format_dark.html\" frameborder=\"0\" scrolling=\"no\" onload=\"javascript:resizeIframe(this)\">\n  <p>Your browser does not support iframes. Click <a href=\"html_format_dark.html>here</a> to see the table.</p>\n</iframe>tf_html_minimalist<iframe src=\"html_format_minimalist.html\" frameborder=\"0\" scrolling=\"no\" onload=\"javascript:resizeIframe(this)\">\n  <p>Your browser does not support iframes. Click <a href=\"html_format_minimalist.html>here</a> to see the table.</p>\n</iframe>tf_html_matrix<iframe src=\"html_format_matrix.html\" frameborder=\"0\" scrolling=\"no\" onload=\"javascript:resizeIframe(this)\">\n  <p>Your browser does not support iframes. Click <a href=\"html_format_matrix.html>here</a> to see the table.</p>\n</iframe>info: Info\nIn this case, the table format html_matrix was printed with the option noheader = true.tf_html_simple<iframe src=\"html_format_simple.html\" frameborder=\"0\" scrolling=\"no\" onload=\"javascript:resizeIframe(this)\">\n  <p>Your browser does not support iframes. Click <a href=\"html_format_simple.html>here</a> to see the table.</p>\n</iframe>"
},

{
    "location": "man/latex_backend/#",
    "page": "LaTeX",
    "title": "LaTeX",
    "category": "page",
    "text": ""
},

{
    "location": "man/latex_backend/#LaTeX-back-end-1",
    "page": "LaTeX",
    "title": "LaTeX back-end",
    "category": "section",
    "text": "CurrentModule = PrettyTables\nDocTestSetup = quote\n    using PrettyTables\nendThe following options are available when the LaTeX backend is used. Those can be passed as keywords when calling the function pretty_table:body_hlines: A vector of Int indicating row numbers in which an additional                horizontal line should be drawn after the row. Notice that                numbers lower than 1 and equal or higher than the number of                printed rows will be neglected. This vector will be appended to                the one in hlines, but the indices here are related to the                printed rows of the body. Thus, if 1 is added to                body_hlines, then a horizontal line will be drawn after the                first data row. (Default = Int[])\nhighlighters: An instance of LatexHighlighter or a tuple with a list of                 LaTeX highlighters (see the section                 LaTeX highlighters).\nhlines: This variable controls where the horizontal lines will be drawn. It           can be nothing, :all, :none or a vector of integers.\nIf it is nothing, which is the default, then the configuration will be obtained from the table format in the variable tf (see LatexTableFormat).\nIf it is :all, then all horizontal lines will be drawn.\nIf it is :none, then no horizontal line will be drawn.\nIf it is a vector of integers, then the horizontal lines will be drawn only after the rows in the vector. Notice that the top line will be drawn if 0 is in hlines, and the header and subheaders are considered as only 1 row. Furthermore, it is important to mention that the row number in this variable is related to the printed rows. Thus, it is affected by filters, and by the option to suppress the header noheader. Finally, for convenience, the top and bottom lines can be drawn by adding the symbols :begin and :end to this vector, respectively, and the line after the header can be drawn by adding the symbol :header.\ninfo: Info\nThe values of body_hlines will be appended to this vector. Thus, horizontal lines can be drawn even if hlines is :none.\n(Default = nothing)\nlongtable_footer: The string that will be drawn in the footer of the tables                     before a page break. This only works if table_type is                     :longtable. If it is nothing, then no footer will be                     used. (Default = nothing)\nnoheader: If true, then the header will not be printed. Notice that all             keywords and parameters related to the header and sub-headers will             be ignored. (Default = false)\nnosubheader: If true, then the sub-header will not be printed, i.e. the                header will contain only one line. Notice that this option has                no effect if noheader = true. (Default = false)\nrow_number_alignment: Select the alignment of the row number column (see the                         section Alignment). (Default = :r)\ntable_type: Select which LaTeX environment will be used to print the table.               Currently supported options are :tabular for tabular or               :longtable for longtable. (Default = :tabular)\ntf: An instance of the structure LatexTableFormat that defines the       general format of the LaTeX table.\nvlines: This variable controls where the vertical lines will be drawn. It           can be :all, :none or a vector of integers. In the first case           (the default behavior), all vertical lines will be drawn. In the           second case, no vertical line will be drawn. In the third case,           the vertical lines will be drawn only after the columns in the           vector. Notice that the left border will be drawn if 0 is in           vlines. Furthermore, it is important to mention that the column           number in this variable is related to the printed columns. Thus,           it is affected by filters, and by the columns added using the           variable show_row_number. Finally, for convenience, the left and           right border can be drawn by adding the symbols :begin and :end           to this vector, respectively. (Default = :none)"
},

{
    "location": "man/latex_backend/#LaTeX-highlighters-1",
    "page": "LaTeX",
    "title": "LaTeX highlighters",
    "category": "section",
    "text": "A set of highlighters can be passed as a Tuple to the highlighters keyword. Each highlighter is an instance of the structure LatexHighlighter. It contains the following two fields:f: Function with the signature f(data,i,j) in which should return true      if the element (i,j) in data must be highlighted, or false      otherwise.\nfd: A function with the signature f(data,i,j,str)::String in which       data is the matrix, (i,j) is the element position in the table, and       str is the data converted to string. This function must return a       string that will be placed in the cell.The function f has the following signature:f(data, i, j)in which data is a reference to the data that is being printed, i and j are the element coordinates that are being tested. If this function returns true, then the highlight style will be applied to the (i,j) element. Otherwise, the default style will be used.Notice that if multiple highlighters are valid for the element (i,j), then the applied style will be equal to the first match considering the order in the Tuple highlighters.If the function f returns true, then the function fd(data,i,j,str) will be called and must return the LaTeX string that will be placed in the cell.If only a single highlighter is wanted, then it can be passed directly to the keyword highlighter without being inside a Tuple.There are two helpers that can be used to create LaTeX highlighters:LatexHighlighter(f::Function, envs::Union{String,Vector{String}})\nLatexHighlighter(f::Function, fd::Function)The first will apply recursively all the LaTeX environments in envs to the highlighted text whereas the second let the user select the desired decoration by specifying the function fd.Thus, for example:LatexHighlighter((data,i,j)->true, [\"textbf\", \"small\"])will wrap all the cells in the table in the following environment:\\textbf{\\small{<Cell text>}}info: Info\nIf only a single highlighter is wanted, then it can be passed directly to the keyword highlighter without being inside a Tuple.note: Note\nIf multiple highlighters are valid for the element (i,j), then the applied style will be equal to the first match considering the order in the tuple highlighters.note: Note\nIf the highlighters are used together with Formatters, then the change in the format will not affect the parameter data passed to the highlighter function f. It will always receive the original, unformatted value.julia> t = 0:1:20;\n\njulia> data = hcat(t, ones(length(t))*1, 1*t, 0.5.*t.^2);\n\njulia> header = [\"Time\" \"Acceleration\" \"Velocity\" \"Distance\";\n                  \"[s]\"  \"[m/s\\$^2\\$]\"    \"[m/s]\"      \"[m]\"];\n\njulia> hl_v = LatexHighlighter( (data,i,j)->(j == 3) && data[i,3] > 9, [\"color{blue}\",\"textbf\"]);\n\njulia> hl_p = LatexHighlighter( (data,i,j)->(j == 4) && data[i,4] > 10, [\"color{red}\", \"textbf\"])\n\njulia> hl_e = LatexHighlighter( (data,i,j)->(i == 10), [\"cellcolor{black}\", \"color{white}\", \"textbf\"])\n\njulia> pretty_table(data, header, backend = :latex, highlighters = (hl_e, hl_p, hl_v))(Image: )note: Note\nThe following LaTeX packages are required to render this example: colortbl and xcolor."
},

{
    "location": "man/latex_backend/#LaTeX-table-formats-1",
    "page": "LaTeX",
    "title": "LaTeX table formats",
    "category": "section",
    "text": "The following table formats are available when using the LaTeX back-end:tf_latex_default (Default)(Image: )tf_latex_simple(Image: )"
},

{
    "location": "man/alignment/#",
    "page": "Alignment",
    "title": "Alignment",
    "category": "page",
    "text": ""
},

{
    "location": "man/alignment/#Alignment-1",
    "page": "Alignment",
    "title": "Alignment",
    "category": "section",
    "text": "CurrentModule = PrettyTables\nDocTestSetup = quote\n    using PrettyTables\nendThe keyword alignment can be a Symbol or a vector of Symbol.If it is a symbol, we have the following behavior::l or :L: the text of all columns will be left-aligned;\n:c or :C: the text of all columns will be center-aligned;\n:r or :R: the text of all columns will be right-aligned;\nOtherwise it defaults to :r.If it is a vector, then it must have the same number of symbols as the number of columns in data. The i-th symbol in the vector specify the alignment of the i-th column using the same symbols as described previously.julia> data = Any[ f(a) for a = 0:30:90, f in (sind,cosd,tand)];\n\njulia> pretty_table(data; alignment=:l)\n┌──────────┬──────────┬─────────┐\n│ Col. 1   │ Col. 2   │ Col. 3  │\n├──────────┼──────────┼─────────┤\n│ 0.0      │ 1.0      │ 0.0     │\n│ 0.5      │ 0.866025 │ 0.57735 │\n│ 0.866025 │ 0.5      │ 1.73205 │\n│ 1.0      │ 0.0      │ Inf     │\n└──────────┴──────────┴─────────┘\n\njulia> pretty_table(data; alignment=[:l,:c,:r])\n┌──────────┬──────────┬─────────┐\n│ Col. 1   │  Col. 2  │  Col. 3 │\n├──────────┼──────────┼─────────┤\n│ 0.0      │   1.0    │     0.0 │\n│ 0.5      │ 0.866025 │ 0.57735 │\n│ 0.866025 │   0.5    │ 1.73205 │\n│ 1.0      │   0.0    │     Inf │\n└──────────┴──────────┴─────────┘note: Note\nThe alignment keyword is supported in all back-ends."
},

{
    "location": "man/filters/#",
    "page": "Filters",
    "title": "Filters",
    "category": "page",
    "text": ""
},

{
    "location": "man/filters/#Filters-1",
    "page": "Filters",
    "title": "Filters",
    "category": "section",
    "text": "CurrentModule = PrettyTables\nDocTestSetup = quote\n    using PrettyTables\nendIt is possible to specify filters to filter the data that will be printed. There are two types of filters: the row filters, which are specified by the keyword filters_row, and the column filters, which are specified by the keyword filters_col.The filters are a tuple of functions that must have the following signature:f(data,i)::Boolin which data is a pointer to the matrix that is being printed and i is the i-th row in the case of the row filters or the i-th column in the case of column filters. If this function returns true for i, then the i-th row (in case of filters_row) or the i-th column (in case of filters_col) will be printed. Otherwise, it will be omitted.A set of filters can be passed inside of a tuple. Notice that, in this case, all filters for a specific row or column must be return true so that it can be printed, i.e the set of filters has an AND logic.If the keyword is set to nothing, which is the default, then no filtering will be applied to the row and/or column.note: Note\nThe filters do not change the row and column numbering for the others modifiers such as column width specification, formatters, and highlighters. Thus, for example, if only the 4-th row is printed, then it will also be referenced inside the formatters and highlighters as 4 instead of 1."
},

{
    "location": "man/filters/#Example-1",
    "page": "Filters",
    "title": "Example",
    "category": "section",
    "text": "Given a matrix data, let\'s suppose that is desired to print:only the 5-th and 6-th column; and\nonly the rows in which the 5-th and 6-th columns are positive.Then we can use one of the following approaches:f_c(data,i)  = i in (5,6)\nf_r1(data,i) = data[i,5] >= 0\nf_r2(data,i) = data[i,6] >= 0and set filters_col = (f_c,) and filters_row = (f_r1,f_r2), orf_c(data,i) = i in (5,6)\nf_r(data,i) = (data[i,5] >= 0) && (data[i,6] >= 0)and set filters_col = (f_c,) and filters_row = (f_r,).note: Note\nThe keywords related to the filters are supported in all back-ends."
},

{
    "location": "man/formatters/#",
    "page": "Formatters",
    "title": "Formatters",
    "category": "page",
    "text": ""
},

{
    "location": "man/formatters/#Formatters-1",
    "page": "Formatters",
    "title": "Formatters",
    "category": "section",
    "text": "CurrentModule = PrettyTables\nDocTestSetup = quote\n    using PrettyTables\nendThe keyword formatters can be used to pass functions to format the values in the columns. It must be a tuple of functions in which each function has the following signature:f(v, i, j)where v is the value in the cell, i is the row number, and j is the column number. Thus, it must return the formatted value of the cell (i,j) that has the value v. Notice that the returned value will be converted to string after using the function sprint.This keyword can also be a single function, meaning that only one formatter is available, or nothing, meaning that no formatter will be used.For example, if we want to multiply all values in odd rows of the column 2 by π, then the formatter should look like:formatters = (v,i,j) -> (j == 2 && isodd(i)) ? v*π : vIf multiple formatters are available, then they will be applied in the same order as they are located in the tuple. Thus, for the following formatters:formatters = (f1, f2, f3)each element v in the table (i-th row and j-th column) will be formatted by:v = f1(v,i,j)\nv = f2(v,i,j)\nv = f3(v,i,j)Thus, the user must be ensure that the type of v between the calls are compatible.julia> data = Any[ f(a) for a = 0:30:90, f in (sind,cosd,tand)];\n\njulia> formatter = (v,i,j) -> round(v, digits=3);\n\njulia> pretty_table(data; formatters = formatter)\n┌────────┬────────┬────────┐\n│ Col. 1 │ Col. 2 │ Col. 3 │\n├────────┼────────┼────────┤\n│    0.0 │    1.0 │    0.0 │\n│    0.5 │  0.866 │  0.577 │\n│  0.866 │    0.5 │  1.732 │\n│    1.0 │    0.0 │    Inf │\n└────────┴────────┴────────┘note: Note\nThe user can check if a value is undefined (#undef) inside a formatter by using the comparison v == undef."
},

{
    "location": "man/formatters/#Predefined-formatters-1",
    "page": "Formatters",
    "title": "Predefined formatters",
    "category": "section",
    "text": "There are a set of predefined formatters (with names ft_*) to make the usage simpler. They are defined in the file ./src/predefined_formatter.jl.function ft_printf(ftv_str, [columns])Apply the formats ftv_str (see @sprintf) to the elements in the columns columns.If ftv_str is a Vector, then columns must be also be a Vector with the same number of elements. If ftv_str is a String, and columns is not specified (or is empty), then the format will be applied to the entire table. Otherwise, if ftv_str is a String and columns is a Vector, then the format will be applied only to the columns in columns.note: Note\nThis formatter will be applied only to the cells that are of type Number. The other types of cells will be left untouched.julia> data = Any[ f(a) for a = 0:30:90, f in (sind,cosd,tand)];\n\njulia> pretty_table(data; formatters = ft_printf(\"%5.3f\"))\n┌────────┬────────┬────────┐\n│ Col. 1 │ Col. 2 │ Col. 3 │\n├────────┼────────┼────────┤\n│  0.000 │  1.000 │  0.000 │\n│  0.500 │  0.866 │  0.577 │\n│  0.866 │  0.500 │  1.732 │\n│  1.000 │  0.000 │    Inf │\n└────────┴────────┴────────┘\n\njulia> pretty_table(data; formatters = ft_printf(\"%5.3f\", [1,3]))\n┌────────┬──────────┬────────┐\n│ Col. 1 │   Col. 2 │ Col. 3 │\n├────────┼──────────┼────────┤\n│  0.000 │      1.0 │  0.000 │\n│  0.500 │ 0.866025 │  0.577 │\n│  0.866 │      0.5 │  1.732 │\n│  1.000 │      0.0 │    Inf │\n└────────┴──────────┴────────┘note: Note\nNow, this formatter uses the function sprintf1 from the package Formatting.jl that drastically improved the performance compared to the case with the macro @sprintf. Thanks to @RalphAS for the information!function ft_round(digits, [columns])Round the elements in the columns columns to the number of digits in digits.If digits is a Vector, then columns must be also be a Vector with the same number of elements. If digits is a Number, and columns is not specified (or is empty), then the rounding will be applied to the entire table. Otherwise, if digits is a Number and columns is a Vector, then the elements in the columns columns will be rounded to the number of digits digits.julia> data = Any[ f(a) for a = 0:30:90, f in (sind,cosd,tand)];\n\njulia> pretty_table(data; formatters = ft_round(1))\n┌────────┬────────┬────────┐\n│ Col. 1 │ Col. 2 │ Col. 3 │\n├────────┼────────┼────────┤\n│    0.0 │    1.0 │    0.0 │\n│    0.5 │    0.9 │    0.6 │\n│    0.9 │    0.5 │    1.7 │\n│    1.0 │    0.0 │    Inf │\n└────────┴────────┴────────┘\n\njulia> pretty_table(data; formatters = ft_round(1,[1,3]))\n┌────────┬──────────┬────────┐\n│ Col. 1 │   Col. 2 │ Col. 3 │\n├────────┼──────────┼────────┤\n│    0.0 │      1.0 │    0.0 │\n│    0.5 │ 0.866025 │    0.6 │\n│    0.9 │      0.5 │    1.7 │\n│    1.0 │      0.0 │    Inf │\n└────────┴──────────┴────────┘note: Note\nThe formatters keyword is supported in all back-ends."
},

{
    "location": "man/text_examples/#",
    "page": "Text back-end",
    "title": "Text back-end",
    "category": "page",
    "text": ""
},

{
    "location": "man/text_examples/#Text-back-end-examples-1",
    "page": "Text back-end",
    "title": "Text back-end examples",
    "category": "section",
    "text": "CurrentModule = PrettyTables\nDocTestSetup = quote\n    using PrettyTables\nendIn the following, it is presented how the following matrix can be printed using the text back-end.julia> data = Any[ 1    false      1.0     0x01 ;\n                   2     true      2.0     0x02 ;\n                   3    false      3.0     0x03 ;\n                   4     true      4.0     0x04 ;\n                   5    false      5.0     0x05 ;\n                   6     true      6.0     0x06 ;]julia> pretty_table(data)(Image: )julia> pretty_table(data, border_crayon = crayon\"yellow\")(Image: )julia> pretty_table(data, tf = tf_simple, border_crayon = crayon\"bold yellow\", header_crayon = crayon\"bold green\")(Image: )julia> pretty_table(data, tf = tf_markdown, show_row_number = true)(Image: )The following example shows how formatters can be used to change how elements are printed.julia> formatter = (v,i,j) -> begin\n           if j != 2\n               return isodd(i) ? i : 0\n           else\n               return v\n           end\n       end\n\njulia> pretty_table(data, tf = tf_ascii_rounded, formatters = formatter)(Image: )The following example indicates how highlighters can be used to highlight the lowest and highest element in the data considering the columns 1, 3, and 5:julia> h1 = Highlighter( (data,i,j)->j in (1,3,4) && data[i,j] == maximum(data[2:end,[1,3,4]]),\n                         bold       = true,\n                         foreground = :blue )\n\njulia> h2 = Highlighter( (data,i,j)->j in (1,3,4) && data[i,j] == minimum(data[2:end,[1,3,4]]),\n                         bold       = true,\n                         foreground = :red )\n\njulia> pretty_table(data, highlighters = (h1,h2))(Image: )Since this package has support to the API defined by Tables.jl, then many formats, e.g DataFrames.jl, can be pretty printed:julia> using DataFrames\n\njulia> df = DataFrame(A = 1:2:20, B = rand(10), C = rand(10))\n\njulia> pretty_table(df, formatters = ft_printf(\"%.3f\", [2,3]), highlighters = (hl_lt(0.2), hl_gt(0.8)))(Image: )You can use body_hlines keyword to divide the table into interesting parts:julia> pretty_table(data, body_hlines = [2,4])(Image: )If you want to break lines inside the cells, then you can set the keyword linebreaks to true. Hence, the characters \\n will cause a line break inside the cell.julia> text = [\"This line contains\\nthe velocity [m/s]\" 10.0;\n               \"This line contains\\nthe acceleration [m/s^2]\" 1.0;\n               \"This line contains\\nthe time from the\\nbeginning of the simulation\" 10;]\n\njulia> pretty_table(text, linebreaks = true, body_hlines = [1,2,3])(Image: )The keyword noheader can be used to suppres the header, which leads to a very simplistic, compact format.julia> pretty_table(data, tf = tf_borderless, noheader = true)(Image: )In the following, it is shown how the filters can be used to print only the even rows and columns:julia> A = [ (0:1:10)\'\n             (1:1:11)\'\n             (2:1:12)\'\n             (3:1:13)\'\n             (4:1:14)\' ]\n\njulia> f_c(data,i) = i % 2 == 0\n\njulia> f_r(data,i) = i % 2 == 0\n\njulia> pretty_table(A, filters_row = (f_r,), filters_col = (f_c,), show_row_number = true)(Image: )By default, if the data is larger than the screen, then it will be cropped to fit it. This can be changed by using the keywords crop and screen_size.julia> data = rand(100,10); pretty_table(data, highlighters = (hl_gt(0.5),))(Image: )You can use the keyword columns_width to select the width of each column, so that the data is cropped to fit the available space.julia> mat = rand(100,4)\n\njulia> pretty_table(mat,\n                    highlighters = hl_gt(0.5),\n                    columns_width = [7,-1,7,8],\n                    compact_printing = false)(Image: )If you want to save the printed table to a file, you can do:julia> open(\"output.txt\", \"w\") do f\n            pretty_table(f,data)\n       endThis package can also be used to create data reports in text format:julia> data = [\"Torques\" \"\" \"\" \"\";\n               \"Atmospheric drag\" \".\"^10 10 \"10⁻⁵ Nm\";\n               \"Gravity gradient\" \".\"^10 3 \"10⁻⁵ Nm\";\n               \"Solar radiation pressure\" \".\"^10 0.1 \"10⁻⁵ Nm\";\n               \"Total\" \".\"^10 13.1 \"10⁻⁵ Nm\";\n               \"\" \"\" \"\" \"\"\n               \"Angular momentum\" \"\" \"\" \"\";\n               \"Atmospheric drag\" \".\"^10 6.5 \"Nms\";\n               \"Gravity gradient\" \".\"^10 3.0 \"Nms\";\n               \"Solar radiation pressure\" \".\"^10 1.0 \"Nms\";\n               \"Total\" \".\"^10 10.5 \"Nms\"]\n\njulia> pretty_table(data, tf = tf_borderless,\n                    noheader = true,\n                    cell_alignment = Dict( (1,1) => :l, (7,1) => :l ),\n                    formatters = ft_printf(\"%10.1f\", 2),\n                    highlighters = (hl_cell( [(1,1);(7,1)], crayon\"bold\"),\n                                    hl_col(2, crayon\"dark_gray\"),\n                                    hl_row([5,11], crayon\"bold yellow\")),\n                    body_hlines = [1,7],\n                    body_hlines_format = Tuple(\'─\' for _ = 1:4) )(Image: )The highlighters API can be used to dynamically highlight cells. In the next example, it is shown how the package ColorSchemes.jl can be integrated to build a table with a color map (the following example will be displayed better in a terminal that supports 24-bit color):julia> using ColorSchemes\n\njulia> data = [ sind(x)*cosd(y) for x in 0:10:180, y in 0:10:180 ]\n\njulia> hl = Highlighter((data,i,j)->true,\n                        (h,data,i,j)->begin\n                             color = get(colorschemes[:coolwarm], data[i,j], (-1,1))\n                             return Crayon(foreground = (round(Int,color.r*255),\n                                                         round(Int,color.g*255),\n                                                         round(Int,color.b*255)))\n                         end)\n\njulia> pretty_table(data, [\"x = $(x)°\" for x = 0:10:180],\n                    row_names = [\"y = $(y)°\" for y = 0:10:180],\n                    highlighters = hl,\n                    formatters = ft_printf(\"%.2f\"))(Image: )"
},

{
    "location": "man/html_examples/#",
    "page": "HTML back-end",
    "title": "HTML back-end",
    "category": "page",
    "text": ""
},

{
    "location": "man/html_examples/#HTML-back-end-examples-1",
    "page": "HTML back-end",
    "title": "HTML back-end examples",
    "category": "section",
    "text": "CurrentModule = PrettyTables\nDocTestSetup = quote\n    using PrettyTables\nendComing soon..."
},

{
    "location": "lib/library/#",
    "page": "Library",
    "title": "Library",
    "category": "page",
    "text": ""
},

{
    "location": "lib/library/#PrettyTables.HTMLDecoration",
    "page": "Library",
    "title": "PrettyTables.HTMLDecoration",
    "category": "type",
    "text": "HTMLDecoration\n\nStructure that defines parameters to decorate a table cell.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.HTMLHighlighter",
    "page": "Library",
    "title": "PrettyTables.HTMLHighlighter",
    "category": "type",
    "text": "HTMLHighlighter\n\nDefines the default highlighter of a table when using the html backend.\n\nFields\n\nf: Function with the signature f(data,i,j) in which should return true      if the element (i,j) in data must be highlighter, or false      otherwise.\nfd: Function with the signature f(h,data,i,j) in which h is the       highlighter. This function must return the HTMLDecoration to be       applied to the cell that must be highlighted.\ndecoration: The HTMLDecoration to be applied to the highlighted cell if               the default fd is used.\n\nRemarks\n\nThis structure can be constructed using two helpers:\n\nHTMLHighlighter(f::Function, decoration::HTMLDecoration)\n\nHTMLHighlighter(f::Function, fd::Function)\n\nThe first will apply a fixed decoration to the highlighted cell specified in decoration whereas the second let the user select the desired decoration by specifying the function fd.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.HTMLTableFormat",
    "page": "Library",
    "title": "PrettyTables.HTMLTableFormat",
    "category": "type",
    "text": "HTMLTableFormat\n\nFormat that will be used to print the HTML table. All parameters are strings compatible with the corresponding HTML property.\n\nFields\n\ncss: CSS to be injected at the end of the <style> section.\ntable_width: Table width.\n\nRemarks\n\nBesides the usual HTML tags related to the tables (table, td,th,tr, etc.), there are three important classes that can be used to format tables using the variablecss`.\n\nheader: This is the class of the header (first line).\nsubheader: This is the class of the sub-headers (all the rest of the lines              in the header section).\nheaderLastRow: The last row of the header section has additionally this                  class.\nrowNumber: All the cells related to the row number have this class. Thus,              the row number header can be styled using th.rowNumber and the              row numbers cells can be styled using td.rowNumber.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.Highlighter",
    "page": "Library",
    "title": "PrettyTables.Highlighter",
    "category": "type",
    "text": "Highlighter\n\nDefines the default highlighter of a table when using the text backend.\n\nFields\n\nf: Function with the signature f(data,i,j) in which should return true      if the element (i,j) in data must be highlighter, or false      otherwise.\nfd: Function with the signature f(h,data,i,j) in which h is the       highlighter. This function must return the Crayon to be applied to the       cell that must be highlighted.\ncrayon: The Crayon to be applied to the highlighted cell if the default           fd is used.\n\nRemarks\n\nThis structure can be constructed using three helpers:\n\nHighlighter(f::Function; kwargs...)\n\nwhere it will construct a Crayon using the keywords in kwargs and apply it to the highlighted cell,\n\nHighlighter(f::Function, crayon::Crayon)\n\nwhere it will apply the crayon to the highlighted cell, and\n\nHighlighter(f::Function, fd::Function)\n\nwhere it will apply the Crayon returned by the function fd to the highlighted cell.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.LatexHighlighter",
    "page": "Library",
    "title": "PrettyTables.LatexHighlighter",
    "category": "type",
    "text": "LatexHighlighter\n\nDefines the default highlighter of a table when using the LaTeX backend.\n\nFields\n\nf: Function with the signature f(data,i,j) in which should return true      if the element (i,j) in data must be highlighted, or false      otherwise.\nfd: A function with the signature f(data,i,j,str)::String in which       data is the matrix, (i,j) is the element position in the table, and       str is the data converted to string. This function must return a       string that will be placed in the cell.\n\nRemarks\n\nThis structure can be constructed using two helpers:\n\nLatexHighlighter(f::Function, envs::Union{String,Vector{String}})\n\nLatexHighlighter(f::Function, fd::Function)\n\nThe first will apply recursively all the LaTeX environments in envs to the highlighted text whereas the second let the user select the desired decoration by specifying the function fd.\n\nThus, for example:\n\nLatexHighlighter((data,i,j)->true, [\"textbf\", \"small\"])\n\nwill wrap all the cells in the table in the following environment:\n\n\\textbf{\\small{<Cell text>}}\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.LatexTableFormat",
    "page": "Library",
    "title": "PrettyTables.LatexTableFormat",
    "category": "type",
    "text": "LatexTableFormat\n\nThis structure defines the format of the LaTeX table.\n\nFields\n\ntop_line: Top line of the table.\nheader_line: Line that separate the header from the table body.\nmid_line: Line printed in the middle of the table.\nbottom_line: Bottom line of the table.\nleft_vline: Left vertical line of the table.\nmid_vline: Vertical line in the middle of the table.\nright_vline: Right vertical line of the table.\nheader_envs: LaTeX environments that will be used in each header cell.\nsubheader_envs: LaTeX environments that will be used in each sub-header                   cell.\nhlines: Horizontal lines that must be drawn by default.\nvlines: Vertical lines that must be drawn by default.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.PrettyTablesConf",
    "page": "Library",
    "title": "PrettyTables.PrettyTablesConf",
    "category": "type",
    "text": "PrettyTablesConf\n\nType of the object that holds a pre-defined set of configurations for PrettyTables.jl.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.TextFormat",
    "page": "Library",
    "title": "PrettyTables.TextFormat",
    "category": "type",
    "text": "TextFormat\n\nFields\n\nup_right_corner: Character in the up right corner.\nup_left_corner: Character in the up left corner.\nbottom_left_corner: Character in the bottom left corner.\nbottom_right_corner: Character in the bottom right corner.\nup_intersection: Character in the intersection of lines in the up part.\nleft_intersection: Character in the intersection of lines in the left part.\nright_intersection: Character in the intersection of lines in the right                       part.\nmiddle_intersection: Character in the intersection of lines in the middle of                        the table.\nbottom_intersection: Character in the intersection of the lines in the                        bottom part.\ncolumn: Character in a vertical line inside the table.\nleft_border: Character used as the left border.\nright_border: Character used as the right border.\nrow: Character in a horizontal line inside the table.\nhlines: Horizontal lines that must be drawn by default.\nvlines: Vertical lines that must be drawn by default.\n\nPre-defined formats\n\nThe following pre-defined formats are available: unicode (default), mysql, compact, markdown, simple, ascii_rounded, and ascii_dots.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.clear_pt_conf!-Tuple{PrettyTablesConf}",
    "page": "Library",
    "title": "PrettyTables.clear_pt_conf!",
    "category": "method",
    "text": "clear_pt_conf!(conf::PrettyTablesConf)\n\nClear all configurations in conf.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.compact_type_str-Tuple{Any}",
    "page": "Library",
    "title": "PrettyTables.compact_type_str",
    "category": "method",
    "text": "compact_type_str(T)\n\nReturn a string with a compact representation of type T.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.ft_latex_sn-Tuple{Int64}",
    "page": "Library",
    "title": "PrettyTables.ft_latex_sn",
    "category": "method",
    "text": "ft_latex_sn(m_digits, [columns])\n\nFormat the numbers of the elements in the columns columns to a scientific notation using LaTeX. The number is first printed using sprintf1 functions with the g modifier and then converted to the LaTeX format. The number of digits in the mantissa can be selected by the argument m_digits.\n\nIf m_digits is a Vector, then columns must be also be a Vector with the same number of elements. If m_digits is a Integer, and columns is not specified (or is empty), then the format will be applied to the entire table. Otherwise, if m_digits is a String and columns is a Vector, then the format will be applied only to the columns in columns.\n\nRemarks\n\nThis formatter will be applied only to the cells that are of type Number.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.ft_printf-Tuple{String}",
    "page": "Library",
    "title": "PrettyTables.ft_printf",
    "category": "method",
    "text": "ft_printf(ftv_str, [columns])\n\nApply the formats ftv_str (see the function sprintf1 of the package Formatting.jl) to the elements in the columns columns.\n\nIf ftv_str is a Vector, then columns must be also be a Vector with the same number of elements. If ftv_str is a String, and columns is not specified (or is empty), then the format will be applied to the entire table. Otherwise, if ftv_str is a String and columns is a Vector, then the format will be applied only to the columns in columns.\n\nRemarks\n\nThis formatter will be applied only to the cells that are of type Number.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.ft_round-Tuple{Int64}",
    "page": "Library",
    "title": "PrettyTables.ft_round",
    "category": "method",
    "text": "ft_round(digits, [columns])\n\nRound the elements in the columns columns to the number of digits in digits.\n\nIf digits is a Vector, then columns must be also be a Vector with the same number of elements. If digits is a Number, and columns is not specified (or is empty), then the rounding will be applied to the entire table. Otherwise, if digits is a Number and columns is a Vector, then the elements in the columns columns will be rounded to the number of digits digits.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.hl_cell-Tuple{Number,Number,Crayon}",
    "page": "Library",
    "title": "PrettyTables.hl_cell",
    "category": "method",
    "text": "hl_cell(i::Number, j::Number, crayon::Crayon)\n\nHighlight the cell (i,j) with the crayon crayon.\n\nhl_cell(cells::AbstractVector{NTuple(2,Int)}, crayon::Crayon)\n\nHighlights all the cells in cells with the crayon crayon.\n\nRemarks\n\nThose functions return a Highlighter to be used with the text backend.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.hl_cell-Tuple{Number,Number,HTMLDecoration}",
    "page": "Library",
    "title": "PrettyTables.hl_cell",
    "category": "method",
    "text": "hl_cell(i::Number, j::Number, decoration::HTMLDecoration)\n\nHighlight the cell (i,j) with the decoration decoration (see HTMLDecoration).\n\nhl_cell(cells::AbstractVector{NTuple(2,Int)}, decoration::HTMLDecoration)\n\nHighlights all the cells in cells with the decoration decoration (see HTMLDecoration).\n\nRemarks\n\nThose functions return a HTMLHighlighter to be used with the HTML backend.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.hl_col-Tuple{Number,Crayon}",
    "page": "Library",
    "title": "PrettyTables.hl_col",
    "category": "method",
    "text": "hl_col(i::Number, crayon::Crayon)\n\nHighlight the entire column i with the crayon crayon.\n\nhl_col(cols::AbstractVector{Int}, crayon::Crayon)\n\nHighlights all the columns in cols with the crayon crayon.\n\nRemarks\n\nThose functions return a Highlighter to be used with the text backend.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.hl_col-Tuple{Number,HTMLDecoration}",
    "page": "Library",
    "title": "PrettyTables.hl_col",
    "category": "method",
    "text": "hl_col(i::Number, decoration::HTMLDecoration)\n\nHighlight the entire column i with the decoration decoration.\n\nhl_col(cols::AbstractVector{Int}, decoration::HTMLDecoration)\n\nHighlights all the columns in cols with the decoration decoration.\n\nRemarks\n\nThose functions return a HTMLHighlighter to be used with the HTML backend.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.hl_geq-Tuple{Number,HTMLDecoration}",
    "page": "Library",
    "title": "PrettyTables.hl_geq",
    "category": "method",
    "text": "hl_geq(n::Number, decoration::HTMLDecoration)\n\nHighlight all elements that ≥ n using the decoration decoration.\n\nRemarks\n\nThose functions return a HTMLHighlighter to be used with the text backend.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.hl_geq-Tuple{Number}",
    "page": "Library",
    "title": "PrettyTables.hl_geq",
    "category": "method",
    "text": "hl_geq(n::Number)\n\nHighlight all elements that ≥ n.\n\nRemarks\n\nThose functions return a Highlighter to be used with the text backend.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.hl_gt-Tuple{Number,HTMLDecoration}",
    "page": "Library",
    "title": "PrettyTables.hl_gt",
    "category": "method",
    "text": "hl_gt(n::Number, decoration::HTMLDecoration)\n\nHighlight all elements that > n using the decoration decoration.\n\nRemarks\n\nThose functions return a HTMLHighlighter to be used with the text backend.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.hl_gt-Tuple{Number}",
    "page": "Library",
    "title": "PrettyTables.hl_gt",
    "category": "method",
    "text": "hl_gt(n::Number)\n\nHighlight all elements that > n.\n\nRemarks\n\nThose functions return a Highlighter to be used with the text backend.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.hl_leq-Tuple{Number,HTMLDecoration}",
    "page": "Library",
    "title": "PrettyTables.hl_leq",
    "category": "method",
    "text": "hl_leq(n::Number, decoration::HTMLDecoration)\n\nHighlight all elements that ≤ n using the decoration decoration.\n\nRemarks\n\nThose functions return a HTMLHighlighter to be used with the text backend.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.hl_leq-Tuple{Number}",
    "page": "Library",
    "title": "PrettyTables.hl_leq",
    "category": "method",
    "text": "hl_leq(n::Number)\n\nHighlight all elements that ≤ n.\n\nRemarks\n\nThose functions return a Highlighter to be used with the text backend.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.hl_lt-Tuple{Number,HTMLDecoration}",
    "page": "Library",
    "title": "PrettyTables.hl_lt",
    "category": "method",
    "text": "hl_lt(n::Number, decoration::HTMLDecoration)\n\nHighlight all elements that < n using the decoration decoration.\n\nRemarks\n\nThose functions return a HTMLHighlighter to be used with the text backend.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.hl_lt-Tuple{Number}",
    "page": "Library",
    "title": "PrettyTables.hl_lt",
    "category": "method",
    "text": "hl_lt(n::Number)\n\nHighlight all elements that < n.\n\nRemarks\n\nThose functions return a Highlighter to be used with the text backend.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.hl_row-Tuple{Number,Crayon}",
    "page": "Library",
    "title": "PrettyTables.hl_row",
    "category": "method",
    "text": "hl_row(i::Number, crayon::Crayon)\n\nHighlight the entire row i with the crayon crayon.\n\nhl_row(rows::AbstractVector{Int}, crayon::Crayon)\n\nHighlights all the rows in rows with the crayon crayon.\n\nRemarks\n\nThose functions return a Highlighter to be used with the text backend.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.hl_row-Tuple{Number,HTMLDecoration}",
    "page": "Library",
    "title": "PrettyTables.hl_row",
    "category": "method",
    "text": "hl_row(i::Number, decoration::HTMLDecoration)\n\nHighlight the entire row i with the decoration decoration.\n\nhl_row(rows::AbstractVector{Int}, decoration::HTMLDecoration)\n\nHighlights all the rows in rows with the decoration decoration.\n\nRemarks\n\nThose functions return a HTMLHighlighter to be used with the HTML backend.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.hl_value-Tuple{Any,HTMLDecoration}",
    "page": "Library",
    "title": "PrettyTables.hl_value",
    "category": "method",
    "text": "hl_value(v::Any, decoration::HTMLDecoration)\n\nHighlight all the values that matches data[i,j] == v using the decoration decoration.\n\nRemarks\n\nThose functions return a HTMLHighlighter to be used with the text backend.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.hl_value-Tuple{Any}",
    "page": "Library",
    "title": "PrettyTables.hl_value",
    "category": "method",
    "text": "hl_value(v::Any)\n\nHighlight all the values that matches data[i,j] == v.\n\nRemarks\n\nThose functions return a Highlighter to be used with the text backend.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.include_pt_in_file-Tuple{AbstractString,AbstractString,Vararg{Any,N} where N}",
    "page": "Library",
    "title": "PrettyTables.include_pt_in_file",
    "category": "method",
    "text": "include_pt_in_file(filename::AbstractString, mark::AbstractString, args...; kwargs...)\n\nInclude a table in the file filename using the mark mark.\n\nThis function will print a table using the arguments args and keywords kwargs in the function pretty_table (the IO must not be passed to args here). Then, it will search inside the file filename for the following section:\n\n<PrettyTables mark>\n...\n</PrettyTables>\n\nand will replace everything between the marks with the printed table. If the closing tag is in a separate line, then all characters before it will be kept. This is important to add comment tags.\n\nIf the user wants to also remove the opening and ending tags, then pass the keyword remove_tags = true.\n\nThe keyword tag_append can be used to pass a string that can be used to add a text after the opening tag. This is important for HTML where the comments have openning and closing tags. Thus, if tag_append = \" -->\", then the following can be used to add a table into HTML files:\n\n<!-- <PrettyTables mark> -->\n...\n<!-- </PrettyTables> -->\n\nBy default, this function will copy the original file to filename_backup. If this is not desired, then pass the keyword backup_file = false to the function.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.pretty_table-Tuple{Any}",
    "page": "Library",
    "title": "PrettyTables.pretty_table",
    "category": "method",
    "text": "pretty_table([io::IO | String,] table[, header::AbstractVecOrMat];  kwargs...)\n\nPrint to io the table table with header header. If conf is omitted, then the default configuration will be used. If io is omitted, then it defaults to stdout. If String is passed in the place of io, then a String with the printed table will be returned by the function.\n\nThe header can be a Vector or a Matrix. If it is a Matrix, then each row will be a header line. The first line is called header and the others are called sub-headers . If header is empty or missing, then it will be automatically filled with \"Col.  i\" for the i-th column.\n\nWhen printing, it will be verified if table complies with Tables.jl API. If it is compliant, then this interface will be used to print the table. If it is not compliant, then only the following types are supported:\n\nAbstractVector: any vector can be printed. In this case, the header must be a vector, where the first element is considered the header and the others are the sub-headers.\nAbstractMatrix: any matrix can be printed.\nDict: any Dict can be printed. In this case, the special keyword sortkeys can be used to select whether or not the user wants to print the dictionary with the keys sorted. If it is false, then the elements will be printed on the same order returned by the functions keys and values. Notice that this assumes that the keys are sortable, if they are not, then an error will be thrown.\n\nKeywords\n\nalignment: Select the alignment of the columns (see the section Alignment).\nbackend: Select which back-end will be used to print the table (see the            section Backend). Notice that the additional configuration in            kwargs... depends on the selected backend. (see the section            Backend).\ncell_alignment: A tuple of functions with the signature f(data,i,j) that                   overrides the alignment of the cell (i,j) to the value                   returned by f. It can also be a single function, when it                   is assumed that only one alignment function is required, or                   nothing, when no cell alignment modification will be                   performed. If the function f does not return a valid                   alignment symbol as shown in section Alignment, then it                   will be discarded. For convenience, it can also be a                   dictionary of type (i,j) => a that overrides the                   alignment of the cell (i,j) to a. a must be a symbol                   like specified in the section Alignment.\nnote: Note\nIf more than one alignment function is passed to cell_alignment, then the functions will be evaluated in the same order of the tuple. The first one that returns a valid alignment symbol for each cell is applied, and the rest is discarded.\n(Default = nothing)\ncell_first_line_only: If true, then only the first line of each cell will be printed. (Default = false)\ncompact_printing: Select if the option :compact will be used when printing                     the data. (Default = true)\nfilters_row: Filters for the rows (see the section Filters).\nfilters_col: Filters for the columns (see the section Filters).\nformatters: See the section Formatters.\nheader_alignment: Select the alignment of the header columns (see the                     section Alignment). If the symbol that specifies the                     alignment is :s for a specific column, then the same                     alignment in the keyword alignment for that column will                     be used. (Default = :s)\nheader_cell_alignment: This keyword has the same structure of                          cell_alignment but in this case it operates in the                          header. Thus, (i,j) will be a cell in the header                          matrix that contains the header and sub-headers. This                          means that the data field in the functions will be                          the same value passed in the keyword header.\nnote: Note\nIf more than one alignment function is passed to header_cell_alignment, then the functions will be evaluated in the same order of the tuple. The first one that returns a valid alignment symbol for each cell is applied, and the rest is discarded.\n(Default = nothing)\nrenderer: A symbol that indicates which function should be used to convert             an object to a string. It can be :print to use the function             print or :show to use the function show. Notice that this             selection is applicable only to the table data. Headers,             sub-headers, and row name column are always rendered with print.             (Default = :print)\nrow_names: A vector containing the row names that will be appended to the              left of the table. If it is nothing, then the column with the              row names will not be shown. Notice that the size of this vector              must match the number of rows in the table.              (Default = nothing)\nrow_name_alignment: Alignment of the column with the rows name (see the                       section Alignment).\nrow_name_column_title: Title of the column with the row names.                          (Default = \"\")\ntitle: The title of the table. If it is empty, then no title will be          printed. (Default = \"\")\ntitle_alignment: Alignment of the title, which must be a symbol as explained                    in the section Alignment. This argument is ignored in the                    LaTeX backend. (Default = :l)\n\nnote: Note\nNotice that all back-ends have the keyword tf to specify the table printing format. Thus, if the keyword backend is not present or if it is nothing, then the back-end will be automatically inferred from the type of the keyword tf. In this case, if tf is also not present, then it just fall-back to the text back-end.\n\nAlignment\n\nThe keyword alignment can be a Symbol or a vector of Symbol.\n\nIf it is a symbol, we have the following behavior:\n\n:l or :L: the text of all columns will be left-aligned;\n:c or :C: the text of all columns will be center-aligned;\n:r or :R: the text of all columns will be right-aligned;\nOtherwise it defaults to :r.\n\nIf it is a vector, then it must have the same number of symbols as the number of columns in data. The i-th symbol in the vector specify the alignment of the i-th column using the same symbols as described previously.\n\nFilters\n\nIt is possible to specify filters to filter the data that will be printed. There are two types of filters: the row filters, which are specified by the keyword filters_row, and the column filters, which are specified by the keyword filters_col.\n\nThe filters are a tuple of functions that must have the following signature:\n\nf(data,i)::Bool\n\nin which data is a pointer to the matrix that is being printed and i is the i-th row in the case of the row filters or the i-th column in the case of column filters. If this function returns true for i, then the i-th row (in case of filters_row) or the i-th column (in case of filters_col) will be printed. Otherwise, it will be omitted.\n\nA set of filters can be passed inside of a tuple. Notice that, in this case, all filters for a specific row or column must be return true so that it can be printed, i.e the set of filters has an AND logic.\n\nIf the keyword is set to nothing, which is the default, then no filtering will be applied to the data.\n\nnote: Note\nThe filters do not change the row and column numbering for the others modifiers such as column width specification, formatters, and highlighters. Thus, for example, if only the 4-th row is printed, then it will also be referenced inside the formatters and highlighters as 4 instead of 1.\n\n\n\nPretty table text back-end\n\nThis back-end produces text tables. This back-end can be used by selecting back-end = :text.\n\nKeywords\n\nborder_crayon: Crayon to print the border.\nheader_crayon: Crayon to print the header.\nsubheaders_crayon: Crayon to print sub-headers.\nrownum_header_crayon: Crayon for the header of the column with the row                         numbers.\ntext_crayon: Crayon to print default text.\nautowrap: If true, then the text will be wrapped on spaces to fit the             column. Notice that this function requires linebreaks = true and             the column must have a fixed size (see columns_width).\nbody_hlines: A vector of Int indicating row numbers in which an additional                horizontal line should be drawn after the row. Notice that                numbers lower than 1 and equal or higher than the number of                printed rows will be neglected. This vector will be appended to                the one in hlines, but the indices here are related to the                printed rows of the body. Thus, if 1 is added to                body_hlines, then a horizontal line will be drawn after the                first data row. (Default = Int[])\nbody_hlines_format: A tuple of 4 characters specifying the format of the                       horizontal lines that will be drawn by body_hlines.                       The characters must be the left intersection, the middle                       intersection, the right intersection, and the row. If it                       is nothing, then it will use the same format specified                       in tf. (Default = nothing)\ncolumns_width: A set of integers specifying the width of each column. If the                  width is equal or lower than 0, then it will be automatically                  computed to fit the large cell in the column. If it is                  a single integer, then this number will be used as the size                  of all columns. (Default = 0)\ncrop: Select the printing behavior when the data is bigger than the         available screen size (see screen_size). It can be :both to crop         on vertical and horizontal direction, :horizontal to crop only on         horizontal direction, :vertical to crop only on vertical direction,         or :none to do not crop the data at all.\ncrop_num_lines_at_beginning: Number of lines to be left at the beginning of                                the printing when vertically cropping the                                output. Notice that the lines required to show                                the title are automatically computed.                                (Default = 0)\ncrop_subheader: If true, then the sub-header size will not be taken into                   account when computing the column size. Hence, the print                   algorithm can crop it to save space. This has no effect if                   the user selects a fixed column width.                   (Default = false)\ncontinuation_row_alignment: A symbol that defines the alignment of the cells                               in the continuation row. This row is printed if                               the table is vertically cropped.                               (Default = :c)\nellipsis_line_skip: An integer defining how many lines will be skipped from                       showing the ellipsis that indicates the text was                       cropped. (Default = 0)\nequal_columns_width: If true, then all the columns will have the same                        width. (Default = false)\nhighlighters: An instance of Highlighter or a tuple with a list of                 text highlighters (see the section Text highlighters).\nhlines: This variable controls where the horizontal lines will be drawn. It           can be nothing, :all, :none or a vector of integers.\nIf it is nothing, which is the default, then the configuration will be obtained from the table format in the variable tf (see TextFormat).\nIf it is :all, then all horizontal lines will be drawn.\nIf it is :none, then no horizontal line will be drawn.\nIf it is a vector of integers, then the horizontal lines will be drawn only after the rows in the vector. Notice that the top line will be drawn if 0 is in hlines, and the header and subheaders are considered as only 1 row. Furthermore, it is important to mention that the row number in this variable is related to the printed rows. Thus, it is affected by filters, and by the option to suppress the header noheader. Finally, for convenience, the top and bottom lines can be drawn by adding the symbols :begin and :end to this vector, respectively, and the line after the header can be drawn by adding the symbol :header.\ninfo: Info\nThe values of body_hlines will be appended to this vector. Thus, horizontal lines can be drawn even if hlines is :none.\n(Default = nothing)\nlinebreaks: If true, then \\n will break the line inside the cells.               (Default = false)\nmaximum_columns_width: A set of integers specifying the maximum width of                          each column. If the width is equal or lower than 0,                          then it will be ignored. If it is a single integer,                          then this number will be used as the maximum width                          of all columns. Notice that the parameter                          columns_width has precedence over this one.                          (Default = 0)\nminimum_columns_width: A set of integers specifying the minimum width of                          each column. If the width is equal or lower than 0,                          then it will be ignored. If it is a single integer,                          then this number will be used as the minimum width                          of all columns. Notice that the parameter                          columns_width has precedence over this one.                          (Default = 0)\nnewline_at_end: If false, then the table will not end with a newline                   character. (Default = true)\nnoheader: If true, then the header will not be printed. Notice that all             keywords and parameters related to the header and sub-headers will             be ignored. (Default = false)\nnosubheader: If true, then the sub-header will not be printed, i.e. the                header will contain only one line. Notice that this option has                no effect if noheader = true. (Default = false)\nomitted_cell_summary_crayon: Crayon used to print the omitted cell summary.\noverwrite: If true, then the same number of lines in the printed table              will be deleted from the output io. This can be used to update              the table in the screen continuously. (Default = false)\nrow_number_alignment: Select the alignment of the row number column (see the                         section Alignment). (Default = :r)\nscreen_size: A tuple of two integers that defines the screen size (num. of                rows, num. of columns) that is available to print the table. It                is used to crop the data depending on the value of the keyword                crop. If it is nothing, then the size will be obtained                automatically. Notice that if a dimension is not positive, then                it will be treated as unlimited. (Default = nothing)\nrow_number_column_title: The title of the column that shows the row numbers.                            (Default = \"Row\")\nshow_omitted_cell_summary: If true, then a summary will be printed after                              the table with the number of columns and rows                              that were omitted. (Default = true)\nshow_row_number: If true, then a new column will be printed showing the                    row number. (Default = false)\ntf: Table format used to print the table (see TextFormat).       (Default = tf_unicode)\ntitle_autowrap: If true, then the title text will be wrapped considering                   the title size. Otherwise, lines larger than the title size                   will be cropped. (Default = false)\ntitle_crayon: Crayon to print the title.\ntitle_same_width_as_table: If true, then the title width will match that                              of the table. Otherwise, the title size will be                              equal to the screen width.                              (Default = false)\nvcrop_mode: This variable defines the vertical crop behavior. If it is               :bottom, then the data, if required, will be cropped in the               bottom. On the other hand, if it is :middle, then the data               will be cropped in the middle if necessary.               (Default = :bottom)\nvlines: This variable controls where the vertical lines will be drawn. It           can be nothing, :all, :none or a vector of integers.\nIf it is nothing, which is the default, then the configuration will be obtained from the table format in the variable tf (see TextFormat).\nIf it is :all, then all vertical lines will be drawn.\nIf it is :none, then no vertical line will be drawn.\nIf it is a vector of integers, then the vertical lines will be drawn only after the columns in the vector. Notice that the top line will be drawn if 0 is in vlines. Furthermore, it is important to mention that the column number in this variable is related to the printed column. Thus, it is affected by filters, and by the options row_names and show_row_number. Finally, for convenience, the left and right vertical lines can be drawn by adding the symbols :begin and :end to this vector, respectively, and the line after the header can be drawn by adding the symbol :header.\n(Default = nothing)\n\nThe keywords header_crayon and subheaders_crayon can be a Crayon or a Vector{Crayon}. In the first case, the Crayon will be applied to all the elements. In the second, each element can have its own crayon, but the length of the vector must be equal to the number of columns in the data.\n\nCrayons\n\nA Crayon is an object that handles a style for text printed on terminals. It is defined in the package Crayons.jl. There are many options available to customize the style, such as foreground color, background color, bold text, etc.\n\nA Crayon can be created in two different ways:\n\njulia> Crayon(foreground = :blue, background = :black, bold = :true)\n\njulia> crayon\"blue bg:black bold\"\n\nFor more information, see the package documentation.\n\nText highlighters\n\nA set of highlighters can be passed as a Tuple to the highlighters keyword. Each highlighter is an instance of the structure Highlighter that contains three fields:\n\nf: Function with the signature f(data,i,j) in which should return true      if the element (i,j) in data must be highlighter, or false      otherwise.\nfd: Function with the signature f(h,data,i,j) in which h is the       highlighter. This function must return the Crayon to be applied to the       cell that must be highlighted.\ncrayon: The Crayon to be applied to the highlighted cell if the default           fd is used.\n\nThe function f has the following signature:\n\nf(data, i, j)\n\nin which data is a reference to the data that is being printed, and i and j are the element coordinates that are being tested. If this function returns true, then the cell (i,j) will be highlighted.\n\nIf the function f returns true, then the function fd(h,data,i,j) will be called and must return a Crayon that will be applied to the cell.\n\nA highlighter can be constructed using three helpers:\n\nHighlighter(f::Function; kwargs...)\n\nwhere it will construct a Crayon using the keywords in kwargs and apply it to the highlighted cell,\n\nHighlighter(f::Function, crayon::Crayon)\n\nwhere it will apply the crayon to the highlighted cell, and\n\nHighlighter(f::Function, fd::Function)\n\nwhere it will apply the Crayon returned by the function fd to the highlighted cell.\n\ninfo: Info\nIf only a single highlighter is wanted, then it can be passed directly to the keyword highlighter without being inside a Tuple.\n\nnote: Note\nIf multiple highlighters are valid for the element (i,j), then the applied style will be equal to the first match considering the order in the tuple highlighters.\n\nnote: Note\nIf the highlighters are used together with Formatters, then the change in the format will not affect the parameter data passed to the highlighter function f. It will always receive the original, unformatted value.\n\n\n\nPretty table HTML backend\n\nThis backend produces HTML tables. This backend can be used by selecting backend = :html.\n\nKeywords\n\nhighlighters: An instance of HTMLHighlighter or a tuple with a list of                 HTML highlighters (see the section HTML highlighters).\nlinebreaks: If true, then \\n will be replaced by <br>.               (Default = false)\nnoheader: If true, then the header will not be printed. Notice that all             keywords and parameters related to the header and sub-headers will             be ignored. (Default = false)\nnosubheader: If true, then the sub-header will not be printed, i.e. the                header will contain only one line. Notice that this option has                no effect if noheader = true. (Default = false)\nstandalone: If true, then a complete HTML page will be generated.               Otherwise, only the content between the tags <table> and               </table> will be printed (with the tags included).               (Default = true)\ntf: An instance of the structure HTMLTableFormat that defines the general       format of the HTML table.\n\nHTML highlighters\n\nA set of highlighters can be passed as a Tuple to the highlighters keyword. Each highlighter is an instance of a structure that is a subtype of AbstractHTMLHighlighter. It also must also contain at least the following two fields to comply with the API:\n\nf: Function with the signature f(data,i,j) in which should return true      if the element (i,j) in data must be highlighted, or false      otherwise.\nfd: Function with the signature f(h,data,i,j) in which h is the       highlighter. This function must return the HTMLDecoration to be       applied to the cell that must be highlighted.\n\nThe function f has the following signature:\n\nf(data, i, j)\n\nin which data is a reference to the data that is being printed, and i and j are the element coordinates that are being tested. If this function returns true, then the highlight style will be applied to the (i,j) element. Otherwise, the default style will be used.\n\nIf the function f returns true, then the function fd(h,data,i,j) will be called and must return an element of type HTMLDecoration that contains the decoration to be applied to the cell.\n\nA HTML highlighter can be constructed using two helpers:\n\nHTMLHighlighter(f::Function, decoration::HTMLDecoration)\n\nHTMLHighlighter(f::Function, fd::Function)\n\nThe first will apply a fixed decoration to the highlighted cell specified in decoration whereas the second let the user select the desired decoration by specifying the function fd.\n\ninfo: Info\nIf only a single highlighter is wanted, then it can be passed directly to the keyword highlighter without being inside a Tuple.\n\nnote: Note\nIf multiple highlighters are valid for the element (i,j), then the applied style will be equal to the first match considering the order in the tuple highlighters.\n\nnote: Note\nIf the highlighters are used together with Formatters, then the change in the format will not affect the parameter data passed to the highlighter function f. It will always receive the original, unformatted value.\n\n\n\nPretty table LaTeX backend\n\nThis backend produces LaTeX tables. This backend can be used by selecting backend = :latex.\n\nKeywords\n\nbody_hlines: A vector of Int indicating row numbers in which an additional                horizontal line should be drawn after the row. Notice that                numbers lower than 1 and equal or higher than the number of                printed rows will be neglected. This vector will be appended to                the one in hlines, but the indices here are related to the                printed rows of the body. Thus, if 1 is added to                body_hlines, then a horizontal line will be drawn after the                first data row. (Default = Int[])\nhighlighters: An instance of LatexHighlighter or a tuple with a list of                 LaTeX highlighters (see the section LaTeX highlighters).\nhlines: This variable controls where the horizontal lines will be drawn. It           can be nothing, :all, :none or a vector of integers.\nIf it is nothing, which is the default, then the configuration will be obtained from the table format in the variable tf (see LatexTableFormat).\nIf it is :all, then all horizontal lines will be drawn.\nIf it is :none, then no horizontal line will be drawn.\nIf it is a vector of integers, then the horizontal lines will be drawn only after the rows in the vector. Notice that the top line will be drawn if 0 is in hlines, and the header and subheaders are considered as only 1 row. Furthermore, it is important to mention that the row number in this variable is related to the printed rows. Thus, it is affected by filters, and by the option to suppress the header noheader. Finally, for convenience, the top and bottom lines can be drawn by adding the symbols :begin and :end to this vector, respectively, and the line after the header can be drawn by adding the symbol :header.\ninfo: Info\nThe values of body_hlines will be appended to this vector. Thus, horizontal lines can be drawn even if hlines is :none.\n(Default = nothing)\nlongtable_footer: The string that will be drawn in the footer of the tables                     before a page break. This only works if table_type is                     :longtable. If it is nothing, then no footer will be                     used. (Default = nothing)\nnoheader: If true, then the header will not be printed. Notice that all             keywords and parameters related to the header and sub-headers will             be ignored. (Default = false)\nnosubheader: If true, then the sub-header will not be printed, i.e. the                header will contain only one line. Notice that this option has                no effect if noheader = true. (Default = false)\nrow_number_alignment: Select the alignment of the row number column (see the                         section Alignment). (Default = :r)\ntable_type: Select which LaTeX environment will be used to print the table.               Currently supported options are :tabular for tabular or               :longtable for longtable. (Default = :tabular)\ntf: An instance of the structure LatexTableFormat that defines the general       format of the LaTeX table.\nvlines: This variable controls where the vertical lines will be drawn. It           can be :all, :none or a vector of integers. In the first case           (the default behavior), all vertical lines will be drawn. In the           second case, no vertical line will be drawn. In the third case,           the vertical lines will be drawn only after the columns in the           vector. Notice that the left border will be drawn if 0 is in           vlines. Furthermore, it is important to mention that the column           number in this variable is related to the printed columns. Thus,           it is affected by filters, and by the columns added using the           variable show_row_number. Finally, for convenience, the left and           right border can be drawn by adding the symbols :begin and :end           to this vector, respectively. (Default = :none)\n\nLaTeX highlighters\n\nA set of highlighters can be passed as a Tuple to the highlighters keyword. Each highlighter is an instance of the structure LatexHighlighter. It contains the following two fields:\n\nf: Function with the signature f(data,i,j) in which should return true      if the element (i,j) in data must be highlighted, or false      otherwise.\nfd: A function with the signature f(data,i,j,str)::String in which       data is the matrix, (i,j) is the element position in the table, and       str is the data converted to string. This function must return a       string that will be placed in the cell.\n\nThe function f has the following signature:\n\nf(data, i, j)\n\nin which data is a reference to the data that is being printed, i and j are the element coordinates that are being tested. If this function returns true, then the highlight style will be applied to the (i,j) element. Otherwise, the default style will be used.\n\nIf the function f returns true, then the function fd(data,i,j,str) will be called and must return the LaTeX string that will be placed in the cell.\n\nThere are two helpers that can be used to create LaTeX highlighters:\n\nLatexHighlighter(f::Function, envs::Union{String,Vector{String}})\n\nLatexHighlighter(f::Function, fd::Function)\n\nThe first will apply recursively all the LaTeX environments in envs to the highlighted text whereas the second let the user select the desired decoration by specifying the function fd.\n\nThus, for example:\n\nLatexHighlighter((data,i,j)->true, [\"textbf\", \"small\"])\n\nwill wrap all the cells in the table in the following environment:\n\n\\textbf{\\small{<Cell text>}}\n\ninfo: Info\nIf only a single highlighter is wanted, then it can be passed directly to the keyword highlighter without being inside a Tuple.\n\nnote: Note\nIf multiple highlighters are valid for the element (i,j), then the applied style will be equal to the first match considering the order in the tuple highlighters.\n\nnote: Note\nIf the highlighters are used together with Formatters, then the change in the format will not affect the parameter data passed to the highlighter function f. It will always receive the original, unformatted value.\n\n\n\nFormatters\n\nThe keyword formatters can be used to pass functions to format the values in the columns. It must be a tuple of functions in which each function has the following signature:\n\nf(v, i, j)\n\nwhere v is the value in the cell, i is the row number, and j is the column number. Thus, it must return the formatted value of the cell (i,j) that has the value v. Notice that the returned value will be converted to string after using the function sprint.\n\nThis keyword can also be a single function, meaning that only one formatter is available, or nothing, meaning that no formatter will be used.\n\nFor example, if we want to multiply all values in odd rows of the column 2 by π, then the formatter should look like:\n\nformatters = (v,i,j) -> (j == 2 && isodd(i)) ? v*π : v\n\nIf multiple formatters are available, then they will be applied in the same order as they are located in the tuple. Thus, for the following formatters:\n\nformatters = (f1, f2, f3)\n\neach element v in the table (i-th row and j-th column) will be formatted by:\n\nv = f1(v,i,j)\nv = f2(v,i,j)\nv = f3(v,i,j)\n\nThus, the user must be ensure that the type of v between the calls are compatible.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.pretty_table_with_conf-Tuple{PrettyTablesConf,Vararg{Any,N} where N}",
    "page": "Library",
    "title": "PrettyTables.pretty_table_with_conf",
    "category": "method",
    "text": "pretty_table_with_conf(conf::PrettyTablesConf, args...; kwargs...)\n\nCall pretty_table using the default configuration in conf. The args... and kwargs... can be the same as those passed to pretty_tables. Notice that all the configurations in kwargs... will overwrite the ones in conf.\n\nThe object conf can be created by the function set_pt_conf in which the keyword parameters can be any one supported by the function pretty_table as shown in the following.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.set_pt_conf!-Tuple{PrettyTablesConf}",
    "page": "Library",
    "title": "PrettyTables.set_pt_conf!",
    "category": "method",
    "text": "set_pt_conf!(conf; kwargs...)\n\nApply the configurations in kwargs to the object conf.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.set_pt_conf-Tuple{}",
    "page": "Library",
    "title": "PrettyTables.set_pt_conf",
    "category": "method",
    "text": "set_pt_conf(;kwargs...)\n\nCreate a new configuration object based on the arguments in kwargs.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.@pt-Tuple",
    "page": "Library",
    "title": "PrettyTables.@pt",
    "category": "macro",
    "text": "@pt(expr...)\n\nPretty print tables in expr to stdout using the global configurations selected with the macro @ptconf.\n\nMultiple tables can be printed by passing multiple expressions like:\n\n@pt table1 table2 table3\n\nThe user can select the table header by passing the expression:\n\n:header = [<Vector with the header>]\n\nNotice that the header is valid only for the next printed table. Hence:\n\n@pt :header = header1 table1 :header = header2 table2 table3\n\nwill print table1 using header1, table2 using header2, and table3 using the default header.\n\nExamples\n\njulia> @ptconf tf = simple\n\njulia> @pt :header = [\"Time\",\"Velocity\"] [1:1:10 ones(10)] :header = [\"Time\",\"Position\"] [1:1:10 1:1:10]\n======= ===========\n  Time   Velocity\n======= ===========\n   1.0        1.0\n   2.0        1.0\n   3.0        1.0\n   4.0        1.0\n   5.0        1.0\n   6.0        1.0\n   7.0        1.0\n   8.0        1.0\n   9.0        1.0\n  10.0        1.0\n======= ===========\n======= ===========\n  Time   Position\n======= ===========\n     1          1\n     2          2\n     3          3\n     4          4\n     5          5\n     6          6\n     7          7\n     8          8\n     9          9\n    10         10\n======= ===========\n\njulia> @pt ones(3,3) + I + [1 2 3; 4 5 6; 7 8 9]\n========= ======== =========\n  Col. 1   Col. 2   Col. 3\n========= ======== =========\n     3.0      3.0      4.0\n     5.0      7.0      7.0\n     8.0      9.0     11.0\n========= ======== =========\n\nRemarks\n\nWhen more than one table is passed to this macro, then multiple calls to pretty_table will occur. Hence, the cropping algorithm will behave exactly the same as printing the tables separately.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.@ptconf-Tuple",
    "page": "Library",
    "title": "PrettyTables.@ptconf",
    "category": "macro",
    "text": "@ptconf(expr...)\n\nAdd configurations in expr to be used with the macro @pt.\n\nThe expression format must be:\n\nkeyword1 = value1 keyword2 = value2 ...\n\nin which the keywords can be any other possible keyword that can be used in the function pretty_table.\n\nwarning: Warning\nIf a keyword is not supported by the function pretty_table, then no error message is printed when calling @ptconf. However, an error will be thrown when @pt is called.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.@ptconfclean-Tuple{}",
    "page": "Library",
    "title": "PrettyTables.@ptconfclean",
    "category": "macro",
    "text": "@ptconfclean()\n\nClean all global configurations to pretty print tables using the macro @pt.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.ColumnTable",
    "page": "Library",
    "title": "PrettyTables.ColumnTable",
    "category": "type",
    "text": "struct ColumnTable\n\nThis structure helps to access elements that comply with the column access specification of Tables.jl.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.PrintInfo",
    "page": "Library",
    "title": "PrettyTables.PrintInfo",
    "category": "type",
    "text": "PrintInfo{Td,Th,Trn}\n\nThis structure stores the information required so that the backends can print the tables.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.RowTable",
    "page": "Library",
    "title": "PrettyTables.RowTable",
    "category": "type",
    "text": "struct RowTable\n\nThis structure helps to access elements that comply with the row access specification of Tables.jl.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables.Screen",
    "page": "Library",
    "title": "PrettyTables.Screen",
    "category": "type",
    "text": "Screen\n\nStore the information of the screen and the current cursor position. Notice that this is not the real cursor position with respect to the screen, but with respect to the point in which the table is printed.\n\nFields\n\nsize: Screen size.\nrow: Current row.\ncol: Current column.\nhas_color: Indicates if the screen has color support.\ncont_char: The character that indicates the line is cropped.\ncont_space_char: Space character to be printed before cont_char.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables._aprint",
    "page": "Library",
    "title": "PrettyTables._aprint",
    "category": "function",
    "text": "_aprint(buf, [v,] indentation = 0, nspace = 2)\n\nPrint the variable v to the buffer buf at the indentation level indentation. Each level has nspaces spaces.\n\nIf v is not present, then only the indentation spaces will be printed.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables._aprintln",
    "page": "Library",
    "title": "PrettyTables._aprintln",
    "category": "function",
    "text": "_aprintln(buf, [v,] indentation = 0, nspaces = 2)\n\nSame as _aprint, but a new line will be added at the end.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables._conf_to_nt-Tuple{PrettyTablesConf}",
    "page": "Library",
    "title": "PrettyTables._conf_to_nt",
    "category": "method",
    "text": "_conf_to_nt(conf::PrettyTablesConf)\n\nConvert the configuration object conf to a named tuple so that it can be passed to pretty_table.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables._crop_str",
    "page": "Library",
    "title": "PrettyTables._crop_str",
    "category": "function",
    "text": "_crop_str(str, crop_size, lstr = -1)\n\nReturn a cropped string of str with size crop_size. Notice that if the last character before the crop does not fit due to its width, then blank spaces are added.\n\nThe size of the string can be passed to lstr to save computational burden. If lstr = -1, then the string length will be computed inside the function.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables._draw_continuation_row-Tuple{PrettyTables.Screen,IO,TextFormat,Crayon,Crayon,Array{Int64,1},Array{Int64,1},Symbol}",
    "page": "Library",
    "title": "PrettyTables._draw_continuation_row",
    "category": "method",
    "text": "_draw_continuation_row(screen::Screen, io::IO, tf::TextFormat, text_crayon::Crayon, border_crayon::Crayon, cols_width::Vector{Int}, vlines::Vector{Int}, alignment::Symbol)\n\nDraw the continuation row when the table has filled the vertical space available. This function prints in each column the character ⋮ with the alignment in alignment.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables._draw_line!-Tuple{PrettyTables.Screen,IO,Char,Char,Char,Char,Crayon,Array{Int64,1},Array{Int64,1}}",
    "page": "Library",
    "title": "PrettyTables._draw_line!",
    "category": "method",
    "text": "_draw_line!(screen::Screen, io::IO, left::Char, intersection::Char, right::Char, row::Char, border_crayon::Crayon, cols_width::Vector{Int}, vlines::Vector{Int})\n\nDraw a vertical line in internal line buffer of screen and then flush to the io io.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables._eol-Tuple{PrettyTables.Screen}",
    "page": "Library",
    "title": "PrettyTables._eol",
    "category": "method",
    "text": "_eol(screen::Screen)\n\nReturn true if the cursor is at the end of line or false otherwise.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables._get_composed_ansi_format-Union{Tuple{Array{T,1}}, Tuple{T}} where T<:AbstractString",
    "page": "Library",
    "title": "PrettyTables._get_composed_ansi_format",
    "category": "method",
    "text": "_get_composed_ansi_format(ansi::Vector{T}) where T<:AbstractString\n\nGiven a vector with a set of ANSI escape sequences, return a composed escape sequence that leads to the same formatting.\n\nwarning: Warning\nThis function only works with the minimal set used by Markdown in stdlib.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables._nl!-Tuple{PrettyTables.Screen,IO}",
    "page": "Library",
    "title": "PrettyTables._nl!",
    "category": "method",
    "text": "_nl!(screen::Screen, io::IO)\n\nFlush the internal line buffer of screen into io.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables._p!",
    "page": "Library",
    "title": "PrettyTables._p!",
    "category": "function",
    "text": "_p!(screen::Screen, crayon::Crayon, str::Char, final_line_print::Bool = false, lstr::Int = -1)\n_p!(screen::Screen, crayon::Crayon, str::String, final_line_print::Bool = false, lstr::Int = -1)\n\nPrint str into the internal line buffer of screen using the Crayon crayon with the screen information in screen. The parameter final_line_print must be set to true if this is the last string that will be printed in the line. This is necessary for the algorithm to select whether or not to include the continuation character.\n\nThe size of the string can be passed to lstr to save computational burden. If lstr = -1, then the string length will be computed inside the function.\n\nThe line buffer can be flushed to an io using the function _nl!.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables._parse_cell_html-Tuple{Any}",
    "page": "Library",
    "title": "PrettyTables._parse_cell_html",
    "category": "method",
    "text": "_parse_cell_html(cell::T; kwargs...)\n\nParse the table cell cell of type T. This function must return a string that will be printed to the IO.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables._parse_cell_latex-Tuple{Any}",
    "page": "Library",
    "title": "PrettyTables._parse_cell_latex",
    "category": "method",
    "text": "_parse_cell_latex(cell::T; kwargs...)\n\nParse the table cell cell of type T. This function must return a string that will be printed to the IO.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables._parse_cell_text-Tuple{Any}",
    "page": "Library",
    "title": "PrettyTables._parse_cell_text",
    "category": "method",
    "text": "_parse_cell_text(cell::T; kwargs...)\n\nParse the table cell cell of type T. This function must return:\n\nA vector of String with the parsed cell text, one component per line.\nA vector with the length of each parsed line.\nThe necessary width for the cell.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables._pc!",
    "page": "Library",
    "title": "PrettyTables._pc!",
    "category": "function",
    "text": "_pc!(cond::Bool, screen::Screen, io::IO, crayon::Crayon, str_true::Union{Char,String}, str_false::Union{Char,String}, final_line_print::Bool = false, lstr_true::Int = -1, lstr_false::Int = -1)\n\nIf cond == true then print str_true. Otherwise, print str_false. Those strings will be printed into the internal line buffer of screen using the Crayon crayon with the screen information in screen. The parameter final_line_print must be set to true if this is the last string that will be printed in the line. This is necessary for the algorithm to select whether or not to include the continuation character.\n\nThe size of the strings can be passed to lstr_true and lstr_false to save computational burden. If they are -1, then the string lengths will be computed inside the function.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables._process_cell_text-Tuple{Any,Int64,Int64,Bool,String,Int64,Int64,Crayon,Symbol,Tuple,Tuple}",
    "page": "Library",
    "title": "PrettyTables._process_cell_text",
    "category": "method",
    "text": "_process_cell_text(data::Any, i::Int, j::Int, data_cell::Bool, data_str::String, data_len::Int, col_width::Int, crayon::Crayon, alignment::Symbol, cell_alignment::Tuple, highlighters::Tuple)\n\nProcess the cell by applying the right alignment and also verifying the highlighters.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables._process_hlines-Tuple{Symbol,AbstractArray{T,1} where T,Int64,Bool}",
    "page": "Library",
    "title": "PrettyTables._process_hlines",
    "category": "method",
    "text": "_process_hlines(hlines::Union{Symbol,AbstractVector}, body_hlines::AbstractVector, num_printed_rows::Int, noheader::Bool)\n\nProcess the horizontal lines in hlines and body_hlines considering the number of printed rows num_printed_rows and if the header is present (noheader).\n\nIt returns a vector of Int stating where the horizontal lines must be drawn.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables._process_vlines-Tuple{Symbol,Int64}",
    "page": "Library",
    "title": "PrettyTables._process_vlines",
    "category": "method",
    "text": "_process_vlines(vlines::AbstractVector, num_printed_cols::Int)\n\nProcess the vertical lines vlines considerering the number of printed columns num_printed_cols.\n\nIt returns a vector of Int stating where the vertical lines must be drawn.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables._reapply_ansi_format!-Union{Tuple{Array{T,1}}, Tuple{T}} where T<:AbstractString",
    "page": "Library",
    "title": "PrettyTables._reapply_ansi_format!",
    "category": "method",
    "text": "_reapply_ansi_format!(lines::Vector{T}) where T<:AbstractString\n\nFor each line in lines, reapply the ANSI format left by the previous line.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables._render_text-Tuple{Val{:print},Any}",
    "page": "Library",
    "title": "PrettyTables._render_text",
    "category": "method",
    "text": "_render_text(T, v; compact_printing::Bool = true, isstring::Bool = false, linebreaks::Bool = false)\n\nRender the value v to strings using the rendered T to be displayed in the text back-end.\n\nT can be:\n\nVal(:print): the function print will be used.\nVal(:show): the function show will be used.\n\nThis function must return a vector of strings in which each element is a line inside the rendered cell.\n\nIf linebreaks is true, then the rendered should split the created string into multiple tokens.\n\nIn case show is used, if isstring is false, then it means that the original data is not a string even if v is a string. Hence, the surrounding quotes added by show will be removed. This is required to correctly handle formatters.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables._str_aligned",
    "page": "Library",
    "title": "PrettyTables._str_aligned",
    "category": "function",
    "text": "_str_aligned(data::String, alignment::Symbol, field_size::Integer, lstr::Integer = -1)\n\nThis function returns the string data with alignment alignment in a field with size field_size. alignment can be :l or :L for left alignment, :c or :C for center alignment, or :r or :R for right alignment. It defaults to :r if alignment is any other symbol.\n\nThis function also returns the new size of the aligned string.\n\nIf the string is larger than field_size, then it will be cropped and ⋯ will be added as the last character.\n\nThe size of the string can be passed to lstr to save computational burden. If lstr = -1, then the string length will be computed inside the function.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables._str_autowrap",
    "page": "Library",
    "title": "PrettyTables._str_autowrap",
    "category": "function",
    "text": "_str_autowrap(tokens_raw::Vector{String}, width::Int = 0)\n\nAutowrap the tokens in tokens_raw considering a field width of width. It returns a new vector with the new wrapped tokens.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#PrettyTables._str_escaped-Tuple{AbstractString}",
    "page": "Library",
    "title": "PrettyTables._str_escaped",
    "category": "method",
    "text": "_str_escaped(str::AbstractString)\n\nReturn the escaped string representation of str.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#Library-1",
    "page": "Library",
    "title": "Library",
    "category": "section",
    "text": "Documentation for PrettyTables.jl.Modules = [PrettyTables]"
},

]}
