global input = String[]
global id = r"Sample_(\d*).*"
global type = :estimated_concentration
global prefix = false
global rows = String[]
global cols = ["A"]
global drop = String[]
global notsort = ["F"]
global source = :mh
global colanalyte = "Analyte"
global lodval = nothing
global loqval = nothing
global lloqval = NaN
global uloqval = NaN
global lodsub = "<LOD"
global loqsub = "<LOQ"
global lloqsub = "<LLOQ"
global uloqsub = ">ULOQ"
global output = "sample"
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
        elseif ARGS[i] == "-t" || ARGS[i] == "--type"
            i += 1
            global type = Symbol(ARGS[i])
        elseif ARGS[i] == "-o" || ARGS[i] == "--output"
            i += 1
            global output = ARGS[i]
        elseif ARGS[i] == "-s" || ARGS[i] == "--source"
            i += 1
            global source = Symbol(ARGS[i])
        elseif ARGS[i] == "-p" || ARGS[i] == "--prefix"
            global prefix = true
        elseif ARGS[i] == "--colanalyte"
            i += 1
            global colanalyte = ARGS[i]
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
        elseif ARGS[i] == "--lod"
            i += 1
            global lodval = [ARGS[i]]
            while i < length(ARGS) && !startswith(ARGS[i + 1], "-")
                i += 1
                push!(lodval, ARGS[i])
            end
            global lodval = try 
                parse.(Float64, lodval)
            catch e
                nothing
            end
        elseif ARGS[i] == "--loq"
            i += 1
            global loqval = [ARGS[i]]
            while i < length(ARGS) && !startswith(ARGS[i + 1], "-")
                i += 1
                push!(loqval, ARGS[i])
            end
            global loqval = try 
                parse.(Float64, loqval)
            catch e
                nothing
            end
        elseif ARGS[i] == "--lloq"
            i += 1
            global lloqval = [ARGS[i]]
            while i < length(ARGS) && !startswith(ARGS[i + 1], "-")
                i += 1
                push!(lloqval, ARGS[i])
            end
            global lloqval = try 
                parse.(Float64, lloqval)
            catch e
                nothing
            end
        elseif ARGS[i] == "--uloq"
            i += 1
            global uloqval = [ARGS[i]]
            while i < length(ARGS) && !startswith(ARGS[i + 1], "-")
                i += 1
                push!(uloqval, ARGS[i])
            end
            global uloqval = try 
                parse.(Float64, uloqval)
            catch e
                nothing
            end
        elseif ARGS[i] == "--lodsub"
            i += 1
            global lodsub = [ARGS[i]]
            while i < length(ARGS) && !startswith(ARGS[i + 1], "-")
                i += 1
                push!(lodsub, ARGS[i])
            end
            global lodsub = map(x -> try
                eval(Meta.parse(x))
            catch e
                x
            end, lodsub)
        elseif ARGS[i] == "--loqsub"
            i += 1
            global loqsub = [ARGS[i]]
            while i < length(ARGS) && !startswith(ARGS[i + 1], "-")
                i += 1
                push!(loqsub, ARGS[i])
            end
            global loqsub = map(x -> try
                eval(Meta.parse(x))
            catch e
                x
            end, loqsub)
        elseif ARGS[i] == "--lloqsub"
            i += 1
            global lloqsub = [ARGS[i]]
            while i < length(ARGS) && !startswith(ARGS[i + 1], "-")
                i += 1
                push!(lloqsub, ARGS[i])
            end
            global lloqsub = map(x -> try
                eval(Meta.parse(x))
            catch e
                x
            end, lloqsub)
        elseif ARGS[i] == "--uloqsub"
            i += 1
            global uloqsub = [ARGS[i]]
            while i < length(ARGS) && !startswith(ARGS[i + 1], "-")
                i += 1
                push!(uloqsub, ARGS[i])
            end
            global uloqsub = map(x -> try
                eval(Meta.parse(x))
            catch e
                x
            end, uloqsub)
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
        print(stdout, HelpMessage(join([str_julia, basename(@__FILE__()), str_sis], " "), str_description["sample"], [Block(switchtitle, str_switch["sample"])]))
        return
    end
    if isempty(input)
        @error "No input files"
        println(stdout)
        return
    end
    replace!(rows, "A" => colanalyte, "F" => "File")
    replace!(cols, "A" => colanalyte, "F" => "File")
    replace!(notsort, "A" => colanalyte, "F" => "File")
    replace!(drop, "A" => colanalyte, "F" => "File")
    data = all(endswith.(input, ".csv")) ? AMV.read(input) : CQA.read(first(input), DataFrame)
    if isnan(lloqval)
        global lloqval = data isa Batch ? map(a -> CQA.lloq(data.calibration[a]), eachanalyte(getproperty(data.data, type))) : nothing
    end
    if isnan(uloqval)
        global uloqval = data isa Batch ? map(a -> CQA.uloq(data.calibration[a]), eachanalyte(getproperty(data.data, type))) : nothing
    end
    data = data isa Batch ? data.data : data
    sample = sample_report(data; id, type, colanalyte)
    td = qualify!(pivot(sample, cols; rows, notsort, drop, prefix); lod = lodval, loq = loqval, lloq = lloqval, uloq = uloqval, lodsub, loqsub, lloqsub, uloqsub)
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
    CSV.write(joinpath(file, "raw.csv"), sample)
    CSV.write(joinpath(file, "report.csv"), td)
    @info "Data saved in $file"
    println(stdout)
end

(@__MODULE__() == Main) && main()
