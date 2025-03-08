using Documenter
using PrettyTables

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
    warnonly = [:missing_docs, :cross_references],
    pages = [
        "Home"                        => "index.md",
        "Quick Start"                 => "man/quick_start.md",
        "Usage"                       => "man/usage.md",
        "Back Ends"                   => Any[
            "Text"                    => Any[
                "Text Backend"        => "man/text/text_backend.md",
                "Pre-defined Formats" => "man/text/predefined_formats.md",
            ],
            "HTML"                    => "man/html/html_backend.md",
            "LaTeX"                   => Any[
                "LaTeX Backend"       => "man/latex/latex_backend.md",
                "Examples"            => "man/latex/latex_examples.md",
            ],
            "Markdown"                => "man/markdown/markdown_backend.md",
        ],
        "Library"                     => "lib/library.md",
    ]
)

deploydocs(
    repo = "github.com/ronisbr/PrettyTables.jl.git",
    target = "build",
)
