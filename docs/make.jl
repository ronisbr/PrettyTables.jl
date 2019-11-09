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
        "Back-ends"          => "man/backends.md",
        "Alignment"          => "man/alignment.md",
        "Filters"            => "man/filters.md",
        "Formatters"         => "man/formatter.md",
        "Highlighters"       => "man/highlighters.md",
        "Examples"           => "man/examples.md",
        "Text table formats" => "man/formats.md",
    ],
)

deploydocs(
    repo = "github.com/ronisbr/PrettyTables.jl.git",
    target = "build",
)
