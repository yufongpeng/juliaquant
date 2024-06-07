global input = String[]
global day0 = r"S.*_(.*)_.*"  #r"Pre.*_(.*)_.*"
global stored = r"S.*_(.*)_(.*)_(.*)_.*"
global order = "CDL"
global type = :accuracy
global prefix = false
global isaccuracy = true
global pct = true
global merge = true
global rows = ["C", "D"]
global cols = ["A", "L"]
global drop = ["S"]
global notsort = ["S"]
global source = :mh
global colanalyte = "Analyte"
global colstats = "Stats"
global colcondition = "Condition"
global colday = "Day"
global collevel = "Level"
global output = "stability"
global help = false

let i = 0
    while i < length(ARGS)
        i += 1
        if ARGS[i] == "-h" || ARGS[i] == "--help"
            global help = true
            break
        elseif  ARGS[i] == "--day0"
            i += 1
            global day0 = Regex(ARGS[i])
        elseif ARGS[i] == "--stored"
            i += 1
            global stored = Regex(ARGS[i])
        elseif ARGS[i] == "-c" || ARGS[i] == "--capture"
            i += 1
            global order = ARGS[i]
        elseif ARGS[i] == "-t" || ARGS[i] == "--type"
            i += 1
            global type = Symbol(ARGS[i])
        elseif ARGS[i] == "-p" || ARGS[i] == "--prefix"
            global prefix = true
        elseif ARGS[i] == "--not-accuracy"
            global isaccuracy = false
        elseif ARGS[i] == "--not-pct"
            global pct = false
        elseif ARGS[i] == "--not-merge"
            global merge = false
        elseif ARGS[i] == "-o" || ARGS[i] == "--output"
            i += 1
            global output = ARGS[i]
        elseif ARGS[i] == "-s" || ARGS[i] == "--source"
            i += 1
            global source = Symbol(ARGS[i])
        elseif ARGS[i] == "--colanalyte"
            i += 1
            global colanalyte = ARGS[i]
        elseif ARGS[i] == "--colstats"
            i += 1
            global colstats = ARGS[i]
        elseif ARGS[i] == "--colcondition"
            i += 1
            global colcondition = ARGS[i]
        elseif ARGS[i] == "--colday"
            i += 1
            global colday = ARGS[i]
        elseif ARGS[i] == "--collevel"
            i += 1
            global collevel = ARGS[i]
        elseif ARGS[i] == "--rows"
            i += 1
            global rows = [ARGS[i]]
            while i < length(ARGS) && !startswith(ARGS[i + 1], "-")
                i += 1
                push!(rows, ARGS[i])
            end
        elseif ARGS[i] == "--cols"
            i += 1
            global cols = [ARGS[i]]
            while i < length(ARGS) && !startswith(ARGS[i + 1], "-")
                i += 1
                push!(cols, ARGS[i])
            end
        elseif ARGS[i] == "--not-sort"
            i += 1
            global notsort = [ARGS[i]]
            while i < length(ARGS) && !startswith(ARGS[i + 1], "-")
                i += 1
                push!(notsort, ARGS[i])
            end
        elseif ARGS[i] == "--drop"
            i += 1
            global drop = [ARGS[i]]
            while i < length(ARGS) && !startswith(ARGS[i + 1], "-")
                i += 1
                push!(drop, ARGS[i])
            end
        elseif ARGS[i] == "-i" || ARGS[i] == "--input"
            while i < length(ARGS) && !startswith(ARGS[i + 1], "-")
                i += 1
                push!(input, ARGS[i])
            end
        else
            if ==(ARGS[i], "--")
                i += 1
            else
                any(x -> startswith(x, "-"), ARGS[i:end]) && throw(ArgumentError("Invalid switches position"))
            end
            global input = vcat(input, ARGS[i:end])
            break
        end
    end
end

if help
    include("help_string.jl")
elseif !isempty(input)
    using AnalyticalMethodValidation, CSV, ChemistryQuantitativeAnalysis
    using DataFrames: DataFrame
    const AMV = AnalyticalMethodValidation
    const CQA = ChemistryQuantitativeAnalysis
end

function main()
    if help
        print(stdout, HelpMessage(join([str_julia, basename(@__FILE__()), str_sis], " "), str_description["stability"], [Block(switchtitle, str_switch["stability"])]))
        return
    end
    if isempty(input)
        @error "No input files"
        println(stdout)
        return
    end
    replace!(rows, "A" => colanalyte, "C" => colcondition, "D" => colday, "L" => collevel, "S" => colstats)
    replace!(cols, "A" => colanalyte, "C" => colcondition, "D" => colday, "L" => collevel, "S" => colstats)
    replace!(notsort, "A" => colanalyte, "C" => colcondition, "D" => colday, "L" => collevel, "S" => colstats)
    replace!(drop, "A" => colanalyte, "C" => colcondition, "D" => colday, "L" => collevel, "S" => colstats)
    data = all(endswith.(input, ".csv")) ? AMV.read(input) : CQA.read(first(input), DataFrame)
    data = data isa Batch ? data.data : data
    stability = stability_report(data; day0, stored, order, type, isaccuracy, pct, colanalyte, colstats, colcondition, colday, collevel)
    colp = !isaccuracy ? (["Mean", "Standard Deviation"] => mean_plus_minus_std => "Mean") :
            pct ? (["Accuracy(%)", "Standard Deviation(%)"] => mean_plus_minus_std => "Accuracy(%)") :
            (["Accuracy", "Standard Deviation"] => mean_plus_minus_std => "Accuracy")
    println(stdout)
    printstyled("Day0: ", color = :blue)
    println(stdout)
    if !isnothing(stability.day0)
        td1 = merge ? pivot(selectby(stability.day0, colstats, colp), cols; rows, notsort, drop, prefix) : 
                        pivot(stability.day0, cols; rows, notsort, drop, prefix)
        display(td1)
    end
    println(stdout)
    printstyled("Stored: ", color = :blue)
    println(stdout)
    td2 = merge ? pivot(selectby(stability.stored, colstats, colp), cols; rows, notsort, drop, prefix) : 
                    pivot(stability.stored, cols; rows, notsort, drop, prefix)
    display(td2)
    println(stdout)
    printstyled("Stored/Day0: ", color = :blue)
    println(stdout)
    if !isnothing(stability.stored_over_day0)
        td3 = merge ? pivot(selectby(stability.stored_over_day0, colstats, pct ? ["Stability(%)", "Standard Deviation(%)"] => mean_plus_minus_std => "Stability(%)" : 
                                                                ["Stability", "Standard Deviation"] => mean_plus_minus_std => "Stability"), 
                            cols; rows, notsort, drop, prefix) : pivot(stability.stored_over_day0, cols; rows, notsort, drop, prefix)
        display(td3)
    end
    println(stdout)
    i = 0
    file = output
    name = basename(output)
    dir = dirname(file)
    dir = isempty(dir) ? pwd() : dir
    mkpath(dir)
    filename = basename(file)
    while filename in readdir(dir)
        i += 1
        filename = name * "($i)"
    end
    file = joinpath(dir, filename)
    mkpath(file)
    if !isnothing(stability.day0)
        CSV.write(joinpath(file, "day0.csv"), stability.day0)
        CSV.write(joinpath(file, "day0_report.csv"), td1)
    end
    CSV.write(joinpath(file, "stored.csv"), stability.stored)
    CSV.write(joinpath(file, "stored_report.csv"), td2)
    if !isnothing(stability.stored_over_day0)
        CSV.write(joinpath(file, "stored_over_day0.csv"), stability.stored_over_day0)
        CSV.write(joinpath(file, "stored_over_day0_report.csv"), td3)
    end
    @info "Data saved in $file"
    println(stdout)
end

(@__MODULE__() == Main) && main()
