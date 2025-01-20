using Dates
global help = false
global pkg = ["DataFrames", "CSV", "ChemistryQuantitativeAnalysis", "AnalyticalMethodValidation", "GLM", "Gtk4", "GLMakie", "Blink", "Plotly"]
global input = nothing
global output = nothing
global all_command = false
global precompile_command = [
    "batch", 
    "calibrate",
    "accuracy-precision",
    "stability",
    "matrix-effect",
    "recovery",
    "quality-control",
    "sample"
]

const command_name_map = Dict{String, String}(
    # "jl" => "jl",
    # "julia" => "jl",
    "jq" => "juliaquant",
    "juliaquant" => "juliaquant",
    "bd" => "build",
    "build" => "build",
    "pc" => "precompile",
    "precompile" => "precompile",
    "bt" => "batch",
    "batch" => "batch",
    "cl" => "calibrate",
    "cal" => "calibrate",
    "calibrate" => "calibrate",
    "ap" => "accuracy-precision",
    "accuracy-precision" => "accuracy-precision",
    "st" => "stability",
    "stability" => "stability",
    "me" => "matrix-effect",
    "matrix-effect" => "matrix-effect",
    "rc" => "recovery",
    "recovery" => "recovery",
    "qc" => "quality-control",
    "quality-control" => "quality-control",
    "sp" => "sample",
    "sample" => "sample"
)

let i = 0
    while i < length(ARGS)
        i += 1
        if ARGS[i] == "-h" || ARGS[i] == "--help"
            global help = true
            break
        elseif ARGS[i] == "-a" || ARGS[i] == "--all"
            global all_commmad = true
            global precompile_command = [
                "batch", 
                "calibrate",
                "accuracy-precision",
                "stability",
                "matrix-effect",
                "recovery",
                "quality-control",
                "sample"
            ]
            break
        elseif ARGS[i] == "-c" || ARGS[i] == "--command"
            i += 1
            if startswith(ARGS[i], "-")
                i -= 1
            else
                global precompile_command = [command_name_map[ARGS[i]]]
            end
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
            global input = ARGS[i]
            break
        end
    end
end

if help
    include("help_string.jl")
else
    using PackageCompiler
    if all_command
        global input = [joinpath(@__DIR__(), "precompile-functions", "$c.jl") for c in precompile_command]
        global output = [joinpath(@__DIR__(), "precompile-so", c, string(replace(string(Dates.now()), ":" => "-"), ".so")) for c in precompile_command]
    else
        if isnothing(input)
            global input = [joinpath(@__DIR__(), "precompile-functions", "$c.jl") for c in precompile_command]
        end
        if isnothing(output)
            global output = [joinpath(@__DIR__(), "precompile-so", c, string(replace(string(Dates.now()), ":" => "-"), ".so")) for c in precompile_command]
        end
    end
end

function main()
    if help
        print(stdout, HelpMessage(join([str_julia, basename(@__FILE__()), str_sis], " "), str_description["precompile"], [Block(switchtitle, str_switch["precompile"])]))
        println(stdout)
        return
    end
    for (i, o, c) in zip(input, output, precompile_command)
        PackageCompiler.create_sysimage(nothing; sysimage_path = o, precompile_execution_file = i)
        @info "juliaquant $c successfully precompiled in $o"
    end
    println(stdout)
end

(@__MODULE__() == Main) && main()