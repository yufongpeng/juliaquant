using Pkg

function main()
    # cqa = pathof(ChemistryQuantitativeAnalysis)
    cdt = @__DIR__()
    # mkpath(joinpath(cdt, "result"))
    mkpath(joinpath(cdt, "project"))
    mkpath(joinpath(cdt, "precompile-so"))
    mkpath(joinpath(cdt, "precompile-so", "accuracy-precision"))
    mkpath(joinpath(cdt, "precompile-so", "batch"))
    mkpath(joinpath(cdt, "precompile-so", "calibrate"))
    mkpath(joinpath(cdt, "precompile-so", "matrix-effect"))
    mkpath(joinpath(cdt, "precompile-so", "quality-control"))
    mkpath(joinpath(cdt, "precompile-so", "recovery"))
    mkpath(joinpath(cdt, "precompile-so", "sample"))
    mkpath(joinpath(cdt, "precompile-so", "stability"))
    # cp(joinpath(cqa, "..", "..", "ui"), joinpath(cdt, "ui"); force = true)
    # tomlui = TOML.parsefile(joinpath(cdt, "ui", "Project.toml"))
    # tomljq = TOML.parsefile(joinpath(cdt, "Project.toml"))
    # uik = ["GLM", "Gtk4", "GLMakie", "Blink", "PlotlyJS", "TypedTables"]
    # for k in uik
    #     tomljq["deps"][k] = tomlui["deps"][k]
    #     tomljq["compat"][k] = tomlui["compat"][k]
    # end
    # open(joinpath(cdt, "Project.toml"), "w") do io
    #     TOML.print(io, tomljq)
    # end
    Pkg.instantiate()
    # Pkg.update()
    # Pkg.resolve()
    # mkpath(joinpath(cdt, "precompile-so"))
    @info "juliaquant instantiated successfully."
    println(stdout)
end

(@__MODULE__() == Main) && main()