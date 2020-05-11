using MoodleQuestions
using Documenter

makedocs(;
    modules=[MoodleQuestions],
    authors="Daniel Molina <dmolina@decsai.ugr.es>",
    repo="https://github.com/dmolina/MoodleQuestions.jl/blob/{commit}{path}#L{line}",
    sitename="MoodleQuestions.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://dmolina.github.io/MoodleQuestions.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Instructions" => "formato.md"
    ],
)

deploydocs(;
    repo="github.com/dmolina/MoodleQuestions.jl",
)
