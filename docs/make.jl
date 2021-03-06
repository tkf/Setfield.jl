using Setfield, Documenter

makedocs(
         format = :html,
         modules = [Setfield],
         sitename = "Setfield.jl",
         pages = [
            "Home" => "index.md",
            ],
        )

deploydocs(
    repo = "github.com/jw3126/Setfield.jl.git",
    julia = "0.6",
    target = "build",
    deps   = nothing,
    make   = nothing
)
