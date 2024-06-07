using ChemistryQuantitativeAnalysis
# GLM, Gtk4, GLMakie, Blink, Plotly
using TOML, Pkg

function main()
    cqa = pathof(ChemistryQuantitativeAnalysis)
    cdt = @__DIR__()
    cp(joinpath(cqa, "..", "..", "ui"), joinpath(cdt, "ui"); force = true)
    tomlui = TOML.parsefile(joinpath(cdt, "ui", "Project.toml"))
    tomljq = TOML.parsefile(joinpath(cdt, "Project.toml"))
    uik = ["GLM", "Gtk4", "GLMakie", "Blink", "Plotly", "TypedTables"]
    for k in uik
        tomljq["deps"][k] = tomlui["deps"][k]
        tomljq["compat"][k] = tomlui["compat"][k]
    end
    open(joinpath(cdt, "Project.toml"), "w") do io
        TOML.print(io, tomljq)
    end
    Pkg.update()
    Pkg.resolve()
    mkpath(joinpath(cdt, "precompile-so"))
    @info "juliaquant build successfully."
    println(stdout)
end

(@__MODULE__() == Main) && main()