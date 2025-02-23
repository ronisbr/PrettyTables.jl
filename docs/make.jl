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
        "Home"               => "index.md",
        "Quick Start"        => "man/quick_start.md",
        "Usage"              => "man/usage.md",
        "Back Ends"          => Any[
            "Text"           => "man/text/text_backend.md",
            "HTML"           => "man/html/html_backend.md",
            "LaTeX"          => "man/latex/latex_backend.md",
            "Markdown"       => "man/markdown/markdown_backend.md",
        ],
        "Examples"           => Any[
            "LaTeX Back End" => "man/latex/latex_examples.md",
        ],
        # "Examples"           => Any[
        #     "Text Back End"  => "man/text_examples.md",
        #     "HTML Back End"  => "man/html_examples.md",
        # ],
        "Library"            => "lib/library.md",
    ]
)

deploydocs(
    repo = "github.com/ronisbr/PrettyTables.jl.git",
    target = "build",
)
