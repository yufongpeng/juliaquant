using Dates
global help = false
global inter = false
# global sysimage = ""
global command = ""
global args = String[]
# autosofiles = filter!(x -> endswith(x, ".so"), readdir(joinpath(@__DIR__(), "precompile-so")))
# if !isempty(autosofiles)
#     _, i = findmax(autosofiles) do f
#         DateTime(replace(split(f, "_")[end], ".so" => ""), dateformat"yyyy-mm-dd\THH-MM-SS.s")
#     end
#     global sysimage = joinpath(@__DIR__(), "precompile-so", autosofiles[i])
# end

let i = 0
    while i < length(ARGS)
        i += 1
        if ARGS[i] == "-h" || ARGS[i] == "--help"
            global help = true
            break
        elseif ARGS[i] == "-i" || ARGS[i] == "--interactive"
            global inter = true
            break
        # elseif ARGS[i] == "-J" || ARGS[i] == "--sysimage"
        #     i += 1
        #     if i > length(ARGS) || startswith(ARGS[i], "-")
        #         i -= 1
        #         global sysimage = ""
        #     else
        #         global sysimage = ARGS[i]
        #     end
        else
            if ==(ARGS[i], "--")
                i += 1
            end
            if  i > length(ARGS)
                break 
            end
            global command = ARGS[i]
            if i < length(ARGS)
                global args = ARGS[(i + 1):end]
            end
            break
        end
    end
end

if help || "-h" in args || "--help" in args || inter || isempty(command)
    include("help_string.jl")
end

# @info "Use $sysimage as sysimage"
println(stdout)

const command_name_map = Dict{String, String}(
    # "jl" => "jl",
    # "julia" => "jl",
    "jq" => "juliaquant",
    "juliaquant" => "juliaquant",
    "it" => "instantiate",
    "instantiate" => "instantiate",
    "up" => "update",
    "update" => "update",
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

function helpmessagecommand(s)
    if s == "calibrate"
        HelpMessage(join([str_julia, replace(str_juliaquant_jl, "[command]" => s), str_si], " "), str_description[s], [Block(switchtitle, str_switch[s])])
    elseif s == "juliaquant"
        HelpMessage(join([str_julia, replace(str_juliaquant_jl, "[command]" => s), str_juliaquant], " "), str_description[s], [Block(switchtitle, str_switch[s]), Block("For other switches, please run `julia -h`", Option[])])
    elseif s == "julia"
        HelpMessage(join([str_julia, replace(str_juliaquant_jl, "[command]" => s), "[switches]", "--", "[programfile]", "[args...]"], " "), str_description[s], Block[])
    else
        HelpMessage(join([str_julia, replace(str_juliaquant_jl, "[command]" => s), str_sis], " "), str_description[s], [Block(switchtitle, str_switch[s])])
    end
end

function helpmessagecommandshort(s)
    if s == "calibrate"
        HelpMessage(join([s, str_si], " "), str_description[s], [Block(switchtitle, str_switch[s])])
    elseif s == "juliaquant"
        HelpMessage(join([s, str_juliaquant], " "), str_description[s], [Block(switchtitle, str_switch[s]), Block("For other switches, please run `julia -h`", Option[])])
    elseif s == "julia"
        HelpMessage(join([s, "[switches]", "--", "[programfile]", "[args...]"], " "), str_description[s], Block[])
    else
        HelpMessage(join([s, str_sis], " "), str_description[s], [Block(switchtitle, str_switch[s])])
    end
end

function run_juliaquant(command, julia_args, args)
    pushfirst!(julia_args, string("--project=", @__DIR__()))
    cmdfile = command_name_map[command]
    i = findfirst(x -> x == "-NJ" || x == "--no-sysimage", julia_args)
    if isnothing(i)
        autosofiles = filter!(x -> endswith(x, ".so"), readdir(joinpath(@__DIR__(), "precompile-so", cmdfile)))
        if !isempty(autosofiles)
            _, i = findmax(autosofiles) do f
                DateTime(replace(split(f, "_")[end], ".so" => ""), dateformat"yyyy-mm-dd\THH-MM-SS.s")
            end
            pushfirst!(julia_args, joinpath(@__DIR__(), "precompile-so", cmdfile, autosofiles[i]))
            @info "Use $(first(julia_args)) as sysimage"
            pushfirst!(julia_args, "-J")
        end
    else
        deleteat!(julia_args, i)
    end
    run(Cmd(["julia", julia_args..., joinpath(@__DIR__(), string(cmdfile, ".jl")), args...]))
end

function run_juliaquant_with_preprocess(command, args, inter::Bool)
    isempty(args) && throw(ArgumentError("Empty arguments"))
    if first(args) == "-h" || first(args) == "--help"
        print(stdout, helpmessagecommandshort(command_name_map[command]))
        return
    end
    i = findfirst(x -> haskey(command_name_map, x), args)
    if isnothing(i)
        run(Cmd(["julia", string("--project=", @__DIR__()), args...]))
        return
    end
    command = args[i]
    julia_args = inter ? map(x -> replace(x, "\"" => ""), args[firstindex(args):(i - 1)]) : args[firstindex(args):(i - 1)]
    args = deleteat!(args, firstindex(args):i)
    args = inter ? map(x -> replace(x, "\"" => ""), args) : args
    run_juliaquant(command, julia_args, args)
end

function main()
    if help
        try 
            print(stdout, HelpMessage(join([str_julia, str_juliaquant_jl], " "), str_description["juliaquant.jl"], [Block(switchtitle, str_switch["juliaquant.jl"]), Block(commandtitle, str_command)]))
            return
        catch
            throw(ErrorException("Error in printing help message."))
        end
    end
    if inter || isempty(command)
        global inter = true
        while inter
            printstyled(stdout, "juliaquant> "; color = :green, bold = true)
            args = String[]
            i = convert(Vector{String}, split(readline()))
            inquote = false
            qs = String[]
            for c in i
                if inquote && endswith(c, "\"")
                    inquote = false
                    push!(args, string(join(qs, " "), " ", replace(c, "\"" => "")))
                elseif inquote
                    push!(qs, c)
                elseif startswith(c, "\"")
                    if endswith(c, "\"")
                        push!(args, replace(c, "\"" => ""))
                    else
                        inquote = true
                        qs = [replace(c, "\"" => "")]
                    end
                else
                    push!(args, c)
                end
            end
            isempty(args) && (println(stdout); continue)
            command = popfirst!(args)
            try
                if command == "julia" || command == "jl"
                    run(Cmd(["julia", string("--project=", @__DIR__()), args...]))
                elseif command == "juliaquant" || command == "jq"
                    run_juliaquant_with_preprocess(command, args, true)
                elseif command == "help" || command == "h"
                    print(stdout, "\n", Block(commandtitle, [Option(Item(["h", "help"], String[]), printhelp), str_command..., Option(Item(["e", "exit"], String[]), "Exit juliaquant")]), "\n")
                elseif command == "exit" || command == "e"
                    global inter = false
                    println(stdout)
                elseif command == "precompile" || command == "pc"
                    run(Cmd(["julia", string("--project=", @__DIR__()), joinpath(@__DIR__(), string(command_name_map[command], ".jl")), map(x -> replace(x, "\"" => ""), args)...]))
                elseif command == "instantiate" || command == "it" || command == "update" || command == "up"
                    run(Cmd(["julia", string("--project=", @__DIR__()), joinpath(@__DIR__(), string(command_name_map[command], ".jl"))]))
                elseif command in keys(command_name_map)
                    if "-h" in args || "--help" in args
                        print(stdout, helpmessagecommandshort(command_name_map[command]))
                    else
                        run_juliaquant(command, String[], map(x -> replace(x, "\"" => ""), args))       
                    end
                else
                    @error "Unrecognized command: $command"
                    println(stdout)
                end
            catch e
                @error e
                println(stdout)
            end
        end
        return
    end
    if !haskey(command_name_map, command)
        throw(ErrorException("Unrecognized command: $command"))
    elseif "-h" in args || "--help" in args
        try
            print(stdout, helpmessagecommand(command_name_map[command]))
        catch
            throw(ErrorException("Error in printing help message."))
        end    
    elseif command == "juliaquant" || command == "jq"
        run_juliaquant_with_preprocess(command, args, false)
    elseif command == "precompile" || command == "pc"
        run(Cmd(["julia", string("--project=", @__DIR__()), joinpath(@__DIR__(), string(command_name_map[command], ".jl")), args...]))
    elseif command == "instantiate" || command == "it" || command == "update" || command == "up"
        run(Cmd(["julia", string("--project=", @__DIR__()), joinpath(@__DIR__(), string(command_name_map[command], ".jl"))]))
    else
        run_juliaquant(command, String[], args)            
    end
    return
end

(@__MODULE__() == Main) && main()