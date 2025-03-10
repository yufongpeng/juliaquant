global input = pwd()
global delim = "\t"
global output = nothing
global help = false

let i = 0
    while i < length(ARGS)
        i += 1
        if ARGS[i] == "-h" || ARGS[i] == "--help"
            global help = true
            break
        elseif ARGS[i] == "-d" || ARGS[i] == "--delim"
            i += 1
            global delim = unescape_string(ARGS[i])
        elseif ARGS[i] == "-i" || ARGS[i] == "--input"
            i += 1
            global input = ARGS[i]
        elseif ARGS[i] == "-o" || ARGS[i] == "--output"
            i += 1
            global output = ARGS[i]
        else
            if ==(ARGS[i], "--")
                i += 1
            else
                any(x -> startswith(x, "-"), ARGS[i:end]) && throw(ArgumentError("Invalid switches position"))
            end
            global input = ARGS[i]
            if isnothing(output)
                global output = ARGS[i]
            end
            break
        end
    end
end

if help
    include("help_string.jl")
elseif endswith(input, ".batch")
    using CSV, ChemistryQuantitativeAnalysisUI
    using DataFrames: DataFrame
end

function main()
    if help
        print(stdout, HelpMessage(join([str_julia, basename(@__FILE__()), str_si], " "), str_description["calibrate"], [Block(switchtitle, str_switch["calibrate"])]))
        return
    end
    if !endswith(input, ".batch")
        @error "The input should be '.batch'"
        println(stdout)
        return
    end
    if isnothing(output)
        global output = input
    end
    cal_ui!(input; tablesink = DataFrame, delim, root = output)
    println(stdout)
end

(@__MODULE__() == Main) && main()