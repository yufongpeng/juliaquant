global input = String[]
global calid = r"Cal_(\d)_(\d*-*\d*)*"
global order = "LR"
global type = :area
global datatable = :SampleDataTable
global delim = "\t"
global col = :Sample
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
        elseif ARGS[i] == "--col"
            i += 1
            global col = Symbol(ARGS[i])
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
    using DataFrames: DataFrame
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
    dt = datatable(mapreduce(append!, input) do i
        CSV.read(i, DataFrame; delim)
    end, col)
    batch = Batch(dt; calid, order, f2c, parse_decimal = x -> replace(x, dot => "."))
    println(stdout)
    display(batch)
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
    CQA.write(file, batch; delim)
    @info "Batch saved as $file"
    @info "Modify analyte settings in $(joinpath(file, "method.am", "analytetable.txt"))"
    println(stdout)
end

(@__MODULE__() == Main) && main()