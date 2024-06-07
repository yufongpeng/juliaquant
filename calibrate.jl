global input = pwd()
global dev_acc = 0.15
global lloq_multiplier = 0.2 / 0.15
global signal = nothing
global rel_sig = :relative_signal
global est_conc = :estimated_concentration
global delim = "\t"
global output = nothing
global help = false

let i = 0
    while i < length(ARGS)
        i += 1
        if ARGS[i] == "-h" || ARGS[i] == "--help"
            global help = true
            break
        elseif ARGS[i] == "-a" || ARGS[i] == "--dev-acc"
            i += 1
            global dev_acc = parse(Float64, ARGS[i])
        elseif ARGS[i] == "-l" || ARGS[i] == "--lloq-multiplier"
            i += 1
            global lloq_multiplier = parse(Float64, ARGS[i])
        elseif ARGS[i] == "-s" || ARGS[i] == "--signal"
            i += 1
            global signal = Symbol(ARGS[i])
            signal = signal == :nothing ? nothing : signal
        elseif ARGS[i] == "-r" || ARGS[i] == "--rel-sig"
            i += 1
            global rel_sig = Symbol(ARGS[i])
        elseif ARGS[i] == "-e" || ARGS[i] == "--est-conc-"
            i += 1
            global est_conc = Symbol(ARGS[i])
        elseif ARGS[i] == "-d" || ARGS[i] == "--delim"
            i += 1
            global delim = unescape_string(ARGS[i])
        elseif ARGS[i] == "-i" || ARGS[i] == "--input"
            i += 1
            global input = ARGS[i]
            if isnothing(output)
                global output = ARGS[i]
            end
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
    using AnalyticalMethodValidation, CSV, ChemistryQuantitativeAnalysis
    using DataFrames: DataFrame
    const CQA = ChemistryQuantitativeAnalysis
    include(joinpath(@__DIR__(), "ui", "src", "ui.jl"))
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
    batch = CQA.read(input, DataFrame; delim)
    interactive_calibrate!(batch; root = output, signal = isnothing(signal) ? batch.method.signal : signal, rel_sig, est_conc, dev_acc, lloq_multiplier)
end

(@__MODULE__() == Main) && main()