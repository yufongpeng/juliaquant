using Pkg, TOML

function main()
    # git pull?
    Pkg.remove(["GLM", "Gtk4", "GLMakie", "Blink", "PlotlyJS", "TypedTables"])
    Pkg.update()
    Pkg.instantiate()
    @info "juliaquant updated successfully."
    println(stdout)
end

(@__MODULE__() == Main) && main()