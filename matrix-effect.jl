global input = String[]
global matrix = r"Pre.*_(.*)_.*"
global stds = r"Post.*_(.*)_.*"
global type = :area
global prefix = false
global pct = true
global merge = true
global rows = ["L"]
global cols = ["A"]
global drop = ["S"]
global notsort = ["S"]
global source = :mh
global colanalyte = "Analyte"
global colstats = "Stats"
global collevel = "Level"
global output = "matrix-effect"
global help = false

let i = 0
    while i < length(ARGS)
        i += 1
        if ARGS[i] == "-h" || ARGS[i] == "--help"
            global help = true
            break
        elseif  ARGS[i] == "--matrix"
            i += 1
            global matrix = Regex(ARGS[i])
        elseif ARGS[i] == "--stds"
            i += 1
            global stds = Regex(ARGS[i])
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
        print(stdout, HelpMessage(join([str_julia, basename(@__FILE__()), str_sis], " "), str_description["matrix-effect"], [Block(switchtitle, str_switch["matrix-effect"])]))
        return
    end
    if isempty(input)
        @error "No input files"
        println(stdout)
        return
    end
    replace!(rows, "A" => colanalyte, "L" => collevel, "S" => colstats)
    replace!(cols, "A" => colanalyte, "L" => collevel, "S" => colstats)
    replace!(notsort, "A" => colanalyte, "L" => collevel, "S" => colstats)
    replace!(drop, "A" => colanalyte, "L" => collevel, "S" => colstats)
    data = all(endswith.(input, ".csv")) ? AMV.read(input) : CQA.read(first(input), DataFrame)
    data = data isa Batch ? data.data : data
    me = me_report(data; matrix, stds, type, pct, colanalyte, colstats, collevel)
    td = merge ? pivot(selectby(me, colstats, pct ? ["Matrix Effect(%)", "Standard Deviation(%)"] => mean_plus_minus_std => "Matrix Effect(%)" : 
                                                ["Matrix Effect", "Standard Deviation"] => mean_plus_minus_std => "Matrix Effect"),
                        cols; rows, notsort, drop, prefix) : pivot(me, cols; rows, notsort, drop, prefix)
    println(stdout)
    display(td)
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
        filename = join([name, "($i)"], "")
    end
    println(stdout)
    file = joinpath(dir, filename)
    mkpath(file)
    CSV.write(joinpath(file, "raw.csv"), me)
    CSV.write(joinpath(file, "report.csv"), td)
    @info "Data saved in $file"
    println(stdout)
end

(@__MODULE__() == Main) && main()