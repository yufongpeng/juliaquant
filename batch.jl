global input = String[]
global calid = r"Cal_(\d)_(\d*-*\d*)*"
global keylevel = nothing
global keyratio = nothing
global keydf = nothing
global order = "LR"
global type = :area
global datatable = :SampleDataTable
global delim = "\t"
global colkey = :Sample
global dot = "-"
global f2c = 1
global output = "new.batch"
global help = false

let i = 0
    while i < length(ARGS)
        i += 1
        if ARGS[i] == "-h" || ARGS[i] == "--help"
            global help = true
            break
        elseif ARGS[i] == "--id"
            i += 1
            global calid = Regex(ARGS[i])
        elseif ARGS[i] == "--keylevel"
            i += 1
            global keylevel = ARGS[i]
        elseif ARGS[i] == "--keyratio"
            i += 1
            global keyratio = ARGS[i]
        elseif ARGS[i] == "--keydf"
            i += 1
            global keydf = ARGS[i]
        elseif ARGS[i] == "-t" || ARGS[i] == "--type"
            i += 1
            global type = Symbol(ARGS[i])
        elseif ARGS[i] == "--sdt"
            global datatable = :SampleDataTable
        elseif ARGS[i] == "--adt"
            global datatable = :AnalyteDataTable
        elseif ARGS[i] == "-d" || ARGS[i] == "--delim"
            i += 1
            global delim = unescape_string(ARGS[i])
        elseif ARGS[i] == "--colkey"
            i += 1
            global colkey = Symbol(ARGS[i])
        elseif ARGS[i] == "-c" || ARGS[i] == "--capture"
            i += 1
            global order = ARGS[i]
        elseif ARGS[i] == "--dot"
            i += 1
            global dot = ARGS[i]
        elseif ARGS[i] == "--f2c"
            i += 1
            global f2c = [ARGS[i]]
            while i < length(ARGS) && !startswith(ARGS[i + 1], "-")
                i += 1
                push!(f2c, ARGS[i])
            end
            global f2c = map(x -> try
                eval(Meta.parse(x))
            catch e
                x
            end, f2c)
        elseif ARGS[i] == "-i" || ARGS[i] == "--input"
            while i < length(ARGS) && !startswith(ARGS[i + 1], "-")
                i += 1
                push!(input, ARGS[i])
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
            global input = vcat(input, ARGS[i:end])
            break
        end
    end
end

if help
    include("help_string.jl")
elseif !isempty(input)
    using CSV, ChemistryQuantitativeAnalysis
    using DataFrames: DataFrame, select!, Not
    const CQA = ChemistryQuantitativeAnalysis
    datatable = eval(datatable)
end

function main()
    if help
        print(stdout, HelpMessage(join([str_julia, basename(@__FILE__()), str_sis], " "), str_description["batch"], [Block(switchtitle, str_switch["batch"])]))
        return
    end
    if isempty(input)
        @error "No input files"
        println(stdout)
        return
    end
    vdt = mapreduce(append!, input) do i
        CSV.read(i, DataFrame; delim)
    end
    if datatable == SampleDataTable
        if !isnothing(keylevel)
            calid = vdt[!, keylevel]
        end
        ratio = isnothing(keyratio) ? nothing : unique!(filter(!ismissing, vdt[!, keyratio]))
        df = isnothing(keydf) ? nothing : unique!(filter(!ismissing, vdt[!, keydf]))
        select!(vdt, Not(filter!(!isnothing, [keylevel, keydf, keyratio])))
    else
        del = Int[]
        if !isnothing(keylevel)
            push!(del, findfirst(==(keylevel), vdt[!, colkey]))
            calid = vdt[last(del), :]
        end
        if isnothing(keyratio) 
            ratio = nothing
        else
            push!(del, findfirst(==(keyratio), vdt[!, colkey]))
            ratio = unique!(filter(!ismissing, vdt[last(del), :]))
        end
        if isnothing(keydf) 
            ratio = nothing
        else
            push!(del, findfirst(==(keydf), vdt[!, keykey]))
            df = unique!(filter(!ismissing, vdt[last(del), :]))
        end
        vdt = vdt[setdiff(eachindex(vdt[!, keykey]), del), :]
    end
    for v in eachcol(vdt)
        for (i, x) in enumerate(v)
            if x == 0
                v[i] = eps(typeof(x)) * (1 + rand())
            end
        end
    end
    dt = datatable(vdt, colkey)
    batch = Batch(dt; calid, order, ratio, df, f2c, parse_decimal = x -> replace(x, dot => "."))
    println(stdout)
    display(batch)
    println(stdout)
    i = 0
    file = output
    name = replace(basename(output), r"\.batch" => "")
    dir = dirname(file)
    dir = isempty(dir) ? pwd() : dir
    mkpath(dir)
    filename = basename(file)
    filename = endswith(filename, r"\.batch") ? filename : string(filename, ".batch")
    while filename in readdir(dir)
        i += 1
        filename = join([name, "($i).batch"], "")
    end
    println(stdout)
    file = joinpath(dir, filename)
    CQA.write(file, batch; delim)
    @info "Batch saved as $file"
    @info "Modify analyte settings in $(joinpath(file, "method.am", "analytetable.txt"))"
    println(stdout)
end

(@__MODULE__() == Main) && main()