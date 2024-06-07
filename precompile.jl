using Dates
global help = false
global pkg = ["DataFrames", "CSV", "ChemistryQuantitativeAnalysis", "AnalyticalMethodValidation", "GLM", "Gtk4", "GLMakie", "Blink", "Plotly"]
global input = "precompile-functions.jl"
global output = joinpath(@__DIR__(), "precompile-so", string(replace(string(Dates.now()), ":" => "-"), ".so"))

let i = 0
    while i < length(ARGS)
        i += 1
        if ARGS[i] == "-h" || ARGS[i] == "--help"
            global help = true
            break
        elseif ARGS[i] == "-p" || ARGS[i] == "--package"
            i += 1
            global pkg = [ARGS[i]]
            while i < length(ARGS) && !startswith(ARGS[i + 1], "-")
                i += 1
                push!(pkg, ARGS[i])
            end
        elseif ARGS[i] == "-i" || ARGS[i] == "--input"
            i += 1
            if startswith(ARGS[i], "-")
                i -= 1
            else
                global input = ARGS[i]
            end
        elseif ARGS[i] == "-o" || ARGS[i] == "--output"
            i += 1
            if startswith(ARGS[i], "-")
                i -= 1
            else
                global output = ARGS[i]
            end
        else
            if ==(ARGS[i], "--")
                i += 1
            else
                any(x -> startswith(x, "-"), ARGS[i:end]) && throw(ArgumentError("Invalid switches position"))
            end
            global input = input, ARGS[i]
            break
        end
    end
end

if help
    include("help_string.jl")
else
    using PackageCompiler
end

function main()
    if help
        print(stdout, HelpMessage(join([str_julia, basename(@__FILE__()), str_sis], " "), str_description["precompile"], [Block(switchtitle, str_switch["precompile"])]))
        println(stdout)
        return
    end
    PackageCompiler.create_sysimage(nothing; sysimage_path = output, precompile_execution_file = input)
    @info "juliaquant successfully precompiled in $output"
    println(stdout)
end

(@__MODULE__() == Main) && main()