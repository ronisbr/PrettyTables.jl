using Documenter
using PrettyTables

makedocs(
    modules = [PrettyTables],
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        canonical = "https://ronisbr.github.io/PrettyTables.jl/stable/",
    ),
    sitename = "Pretty Tables",
    authors = "Ronan Arraes Jardim Chagas",
    pages = [
        "Home"               => "index.md",
        "Usage"              => "man/usage.md",
        "Back Ends"          => Any[
            "Text"           => "man/text_backend.md",
            "HTML"           => "man/html_backend.md",
            "LaTeX"          => "man/latex_backend.md",
            "Markdown"       => "man/markdown_backend.md",
        ],
        "Alignment"          => "man/alignment.md",
        "Formatters"         => "man/formatters.md",
        "Examples"           => Any[
            "Text Back End"  => "man/text_examples.md",
            "HTML Back End"  => "man/html_examples.md",
        ],
        "Library"            => "lib/library.md",
    ]
)

deploydocs(
    repo = "github.com/ronisbr/PrettyTables.jl.git",
    target = "build",
)
