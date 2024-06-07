global input = String[]
global id = r"Pre(.*)_(.*)_.*"
global order = "DL"
global type = :accuracy
global prefix = false
global pct = true
global merge = true
global rows = ["D", "S"]
global cols = ["A", "L"]
global drop = []
global notsort = ["S"]
global source = :mh
global colanalyte = "Analyte"
global colstats = "Stats"
global colday = "Day"
global collevel = "Level"
global output = "accuracy-precision"
global help = false

let i = 0
    while i < length(ARGS)
        i += 1
        if ARGS[i] == "-h" || ARGS[i] == "--help"
            global help = true
            break
        elseif ARGS[i] == "--id"
            i += 1
            global id = Regex(ARGS[i])
        elseif ARGS[i] == "-c" || ARGS[i] == "--capture"
            i += 1
            global order = ARGS[i]
        elseif ARGS[i] == "-t" || ARGS[i] == "--type"
            i += 1
            global type = Symbol(ARGS[i])
        elseif ARGS[i] == "-p" || ARGS[i] == "--prefix"
            global prefix = true
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
        print(stdout, HelpMessage(join([str_julia, basename(@__FILE__()), str_sis], " "), str_description["accuracy-precision"], [Block(switchtitle, str_switch["accuracy-precision"])]))
        return
    end
    if isempty(input)
        @error "No input files"
        println(stdout)
        return
    end
    replace!(rows, "A" => colanalyte, "D" => colday, "L" => collevel, "S" => colstats)
    replace!(cols, "A" => colanalyte, "D" => colday, "L" => collevel, "S" => colstats)
    replace!(notsort, "A" => colanalyte, "D" => colday, "L" => collevel, "S" => colstats)
    replace!(drop, "A" => colanalyte, "D" => colday, "L" => collevel, "S" => colstats)
    data = all(endswith.(input, ".csv")) ? AMV.read(input) : CQA.read(first(input), DataFrame)
    data = data isa Batch ? data.data : data
    ap = ap_report(data; id, type, pct, colanalyte, colstats, colday, collevel)
    println(stdout)
    printstyled("Daily: ", color = :blue)
    println(stdout)
    td1 = merge ? pivot(selecby(ap.daily, colstats, pct ? ["Accuracy(%)", "Standard Deviation(%)"] => mean_plus_minus_std => "Accuracy(%)" : 
                                                    ["Accuracy", "Standard Deviation"] => mean_plus_minus_std => "Accuracy"), 
                        cols; rows, notsort, drop, prefix) : pivot(ap.daily, cols; rows, notsort, drop, prefix)
    display(td1)
    println(stdout)
    printstyled("Summary: ", color = :blue)
    println(stdout)
    td2 = pivot(ap.summary, filter(!=(colday), cols); rows = filter(!=(colday), rows), notsort, drop, prefix)
    display(td2)
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
    CSV.write(joinpath(file, "daily.csv"), ap.daily)
    CSV.write(joinpath(file, "summary.csv"), ap.summary)
    CSV.write(joinpath(file, "daily_report.csv"), td1)
    CSV.write(joinpath(file, "summary_report.csv"), td2)
    @info "Data saved in $file"
    println(stdout)
end

(@__MODULE__() == Main) && main()
