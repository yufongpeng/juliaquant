using Dates
global help = false
global inter = false
global sysimage = ""
global command = ""
global args = String[]
autosofiles = filter!(x -> endswith(x, ".so"), readdir(joinpath(@__DIR__(), "precompile-so")))
if !isempty(autosofiles)
    _, i = findmax(autosofiles) do f
        DateTime(replace(split(f, "_")[end], ".so" => ""), dateformat"yyyy-mm-dd\THH-MM-SS.s")
    end
    global sysimage = joinpath(@__DIR__(), "precompile-so", autosofiles[i])
    @info "Use $sysimage as sysimage"
end

let i = 0
    while i < length(ARGS)
        i += 1
        if ARGS[i] == "-h" || ARGS[i] == "--help"
            global help = true
            break
        elseif ARGS[i] == "-i" || ARGS[i] == "--interactive"
            global inter = true
            break
        elseif ARGS[i] == "-J" || ARGS[i] == "--sysimage"
            i += 1
            if startswith(ARGS[i], "-")
                i -= 1
                global sysimage = ""
            else
                global sysimage = ARGS[i]
            end
        else
            if ==(ARGS[i], "--")
                i += 1
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

const command_name_map = Dict{String, String}(
    "jl" => "jl",
    "julia" => "jl",
    "juliaquant" => "jl",
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

function helpmessagecommand(s)
    if s == "calibrate"
        HelpMessage(join([str_julia, replace(str_juliaquant, "[command]" => s), str_si], " "), str_description[s], [Block(switchtitle, str_switch[s])])
    elseif s == "julia"
        HelpMessage(join([str_julia, replace(str_juliaquant, "[command]" => s), "[switches]", "--", "[programfile]", "[args...]"], " "), str_description[s], Block[])
    else
        HelpMessage(join([str_julia, replace(str_juliaquant, "[command]" => s), str_sis], " "), str_description[s], [Block(switchtitle, str_switch[s])])
    end
end

function helpmessagecommandshort(s)
    if s == "calibrate"
        HelpMessage(join([s, str_si], " "), str_description[s], [Block(switchtitle, str_switch[s])])
    elseif s == "julia"
        HelpMessage(join([s, "[switches]", "--", "[programfile]", "[args...]"], " "), str_description[s], Block[])
    else
        HelpMessage(join([s, str_sis], " "), str_description[s], [Block(switchtitle, str_switch[s])])
    end
end

function main()
    if help
        print(stdout, HelpMessage(join([str_julia, str_juliaquant], " "), str_description["juliaquant"], [Block(switchtitle, str_switch["juliaquant"]), Block(commandtitle, str_command)]))
        return
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
            command = popfirst!(args)
            if command == "juliaquant" || command == "julia" || command == "jl"
                run(Cmd(["julia", "--project", args...]))
            elseif command == "help" || command == "h"
                print(stdout, "\n", Block(commandtitle, [Option(Item(["h", "help"], String[]), printhelp), str_command..., Option(Item(["e", "exit"], String[]), "Exit juliaquant")]), "\n")
            elseif command == "exit" || command == "e"
                global inter = false
                println(stdout)
            elseif command == "precompile" || command == "pc"
                run(Cmd(["julia", "--project", string(command_name_map[command], ".jl"), map(x -> replace(x, "\"" => ""), args)...]))
            elseif command == "build" || command == "bd"
                run(Cmd(["julia", "--project", string(command_name_map[command], ".jl")]))
            elseif command in keys(command_name_map)
                if "-h" in args || "--help" in args
                    print(stdout, helpmessagecommandshort(command_name_map[command]))
                elseif isempty(sysimage)                
                    run(Cmd(["julia", "--project", string(command_name_map[command], ".jl"), map(x -> replace(x, "\"" => ""), args)...]))
                else
                    run(Cmd(["julia", "--project", "-J", sysimage, string(command_name_map[command], ".jl"), map(x -> replace(x, "\"" => ""), args)...]))
                end
            else
                @error "Unrecognized command: $command"
                println(stdout)
            end
        end
        return
    end
    if !in(command, command_name_map)
        @error "Unrecognized command: $command"
        println(stdout)
    elseif "-h" in args || "--help" in args
        print(stdout, helpmessagecommand(command_name_map[command]))
    elseif isempty(sysimage) 
        run(Cmd(["julia", "--project", string(command_name_map[command], ".jl"), args...]))
    else
        run(Cmd(["julia", "--project", "-J", sysimage, string(command_name_map[command], ".jl"), args...]))
    end
    return
end

(@__MODULE__() == Main) && main()