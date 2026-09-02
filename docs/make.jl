using Documenter
using PrettyTables

#! format: off

makedocs(
    modules = [PrettyTables],
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        canonical = "https://ronisbr.github.io/PrettyTables.jl/stable/",
        size_threshold_warn = 1024 * 1024 * 1024,
        size_threshold = 10 * 1024 * 1024 * 1024,
    ),
    sitename = "Pretty Tables",
    authors = "Ronan Arraes Jardim Chagas",
    # The library page lists the public API only. Hence, we only check that the exported
    # names are documented.
    checkdocs = :exports,
    warnonly = [:missing_docs, :cross_references],
    pages = [
        "Home"                        => "index.md",
        "Quick Start"                 => "man/quick_start.md",
        "Usage"                       => "man/usage.md",
        "Faces"                       => "man/faces.md",
        "Table Format and Style"      => "man/table_format.md",
        "Back Ends"                   => Any[
            "Text"                    => Any[
                "Text Backend"        => "man/text/text_backend.md",
                "Pre-defined Formats" => "man/text/predefined_formats.md",
                "Examples"            => "man/text/text_examples.md",
            ],
            "HTML"                    => Any[
                "HTML Backend"        => "man/html/html_backend.md",
                "Examples"            => "man/html/html_examples.md",
            ],
            "LaTeX"                   => Any[
                "LaTeX Backend"       => "man/latex/latex_backend.md",
                "Examples"            => "man/latex/latex_examples.md",
            ],
            "Markdown"                => Any[
                "Markdown Backend"    => "man/markdown/markdown_backend.md",
                "Examples"            => "man/markdown/markdown_examples.md",
            ],
            "Typst"                   => Any[
               "Typst Backend"       => "man/typst/typst_backend.md",
            ],
            "Excel"                   => Any[
                "Excel Backend"       => "man/excel/excel_backend.md",
                "Examples"            => "man/excel/excel_examples.md",
            ],
        ],
        "Library"                     => "lib/library.md",
    ],
 )

deploydocs(
    repo = "github.com/ronisbr/PrettyTables.jl.git",
    target = "build",
)

#! format: on
