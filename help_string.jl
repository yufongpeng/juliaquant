import Base: show
struct Item{T}
    name::Vector{String}
    value::T
end

struct Option
    item::Item
    description::String
end

struct Block
    title::String
    option::Vector{Option}
end

struct HelpMessage
    title::String
    description::String
    block::Vector{Block}
end

function Base.show(io::IO, item::Item{T}) where {T <: Vector{String}}
    print(io, join(item.name, ", "), " ")
    isempty(item.value) || print(io, "{", join(item.value, "|"), "}")
end

function Base.show(io::IO, item::Item{T}) where {T <: String}
    print(io, join(item.name, ", "), " ")
    isempty(item.value) || print(io, "<", item.value, ">")
end

Item(name::Vector{String}) = Item(name, "")

function Base.show(io::IO, option::Option)
    print(io, option.item)
    print(io, "\t")
    print(io, option.description)
end

function Base.show(io::IO, block::Block)
    print(io, block.title, "\n\n")
    isempty(block.option) && return
    items = map(x -> repr(x.item), block.option)
    des = map(x -> x.description, block.option)
    li = maximum(length, items)
    items = map(x -> rpad(x, li + 4), items)
    for (i, d) in zip(items, des)
        print(io, " ", i, replace(d, "\ni\t" => string("\n", " " ^ (li + 5))), "\n")
    end
end

function Base.show(io::IO, hm::HelpMessage)
    print(io, "\n\t", hm.title, "\n\n")
    print(io, hm.description, "\n\n")
    for b in hm.block
        print(io, b, "\n")
    end
end

const str_julia = "julia [julia switches] --"
const str_juliaquant_jl = "juliaquant.jl [juliaquant.jl switches] -- [command]"
const str_juliaquant = "[switches] [command]"
const str_sis = "[switches] -- [input files]"
const str_si = "[switches] -- [input file]"
const str_ijq = "[command] [switches] -- [input]"
const str_description = Dict{String, String}(
    "juliaquant.jl"         => "Quantitative analysis with julia.",
    "juliaquant"            => "Set switches and run the following command.",
    "julia"                 => "Run julia codes or enter julia REPL. The switch '--project' is set; for other switches, see julia manual.",
    "instantiate"           => "Instantiate juliaquant.",
    "update"                => "Update packages of juliaquant.",
    "precompile"            => "Precompile juliaquant. The input file is an optional julia script file.",
    "batch"                 => "Create a new batch. The input files can be multiple text files.",
    "calibrate"             => "Calibrate the input batch with a GUI.",
    "accuracy-precision"    => "Compute accuracy and precision. The input files can be multiple csv files, '.at', or '.batch' (See `ChemistryQuantitativeAnalysis.jl`)",
    "stability"             => "Compute stability. The input files can be multiple csv files, '.at', or '.batch' (See `ChemistryQuantitativeAnalysis.jl`)",
    "matrix-effect"         => "Compute matrix effect. The input files can be multiple csv files, '.at', or '.batch' (See `ChemistryQuantitativeAnalysis.jl`)",
    "recovery"              => "Compute recovery. The input files can be multiple csv files, '.at', or '.batch' (See `ChemistryQuantitativeAnalysis.jl`)",
    "quality-control"       => "QC analysis. The input files can be multiple csv files, '.at', or '.batch' (See `ChemistryQuantitativeAnalysis.jl`)",
    "sample"                => "Sample analysis. The input files can be multiple csv files, '.at', or '.batch' (See `ChemistryQuantitativeAnalysis.jl`)"
)
const commandtitle = "Commands:"
const switchtitle = "Switches (a '*' marks the default value):"
const printhelp = "Print this message"
const str_command = [
    Option(
        Item(
            ["jq", "juliaquant"],
            "[switches] [command] [args]"
        ),
        "Quantitative analysis with user-defined julia switches."
    ),
    Option(
        Item(
            ["jl", "julia"],
            "args"
        ),
        "Run julia codes or enter julia REPL."
    ),
    Option(
        Item(
            ["it", "instantiate"],
            ""
        ),
        "Instantiate juliaquant."
    ),
    Option(
        Item(
            ["up", "update"],
            ""
        ),
        "Update packages of juliaquant."
    ),
    Option(
        Item(
            ["pc", "precompile"],
            ""
        ),
        "Precompile juliaquant."
    ),
    Option(
        Item(
            ["bt", "batch"],
            "args"
        ),
        "Create a new batch."
    ),
    Option(
        Item(
            ["cl", "cal", "calibrate"],
            "args"
        ),
        "Calibrate the input batch with a GUI."
    ),
    Option(
        Item(
            ["ap", "accuracy-precision"],
            "args"
        ),
        "Compute accuracy and precision."
    ),
    Option(
        Item(
            ["st", "stability"],
            "args"
        ),
        "Compute stability."
    ),
    Option(
        Item(
            ["me", "matrix-effect"],
            "args"
        ),
        "Compute matrix effect."
    ),
    Option(
        Item(
            ["rc", "recovery"],
            "args"
        ),
        "Compute recovery."
    ),
    Option(
        Item(
            ["qc", "quality-control"],
            "args"
        ),
        "QC analysis."
    ),
    Option(
        Item(
            ["sp", "sample"],
            "args"
        ),
        "Sample analysis."
    )
]
const str_switch = Dict{String, Vector{Option}}(
    "juliaquant" => [
        Option(
            Item(
                ["-h", "--help"]
            ),
            printhelp
        ),
        Option(
            Item(
                ["-NJ", "--no-sysimage"]
            ),
            "Do not use default sysimage."
        )
    ],
    "juliaquant.jl" => [
        Option(
            Item(
                ["-h", "--help"]
            ),
            printhelp
        ),
        Option(
            Item(
                ["-i", "--interactive"]
            ),
            "Enter interactive mode"
        ),
    ],
    "precompile" => [
        Option(
            Item(
                ["-h", "--help"]
            ),
            printhelp
        ),
        Option(
            Item(
                ["-a", "--all"]
            ),
            "Precompile all commands."
        ),
        Option(
            Item(
                ["-c", "--command"],
                "command"
            ),
            "Command to be precompiled."
        ),
        Option(
            Item(
                ["-p", "--package"],
                "packages"
            ),
            "Packages to be compiled. The default is all packages in project except 'PackageCompiler'."  
        ),
        Option(
            Item(
                ["-i", "--input"],
                ["precompile-functions.jl*", "…"]
            ),
            "Set the input file ('.jl')"
        ),
        Option(
            Item(
                ["-o", "--output"],
                ["@current-date-time.jl", "…"]
            ),
            "Set the output file ('.so')"
        )
    ],
    "batch" => [
        Option(
            Item(
                ["-h", "--help"]
            ),
            printhelp
        ),
        Option(
            Item(
                ["--id"],
                [""""Cal_(\\d)_(\\d*-*\\d*)*"*""", "…"]
            ),
            "Set the identifier for the Calibration points. This will be wrapped in `Regex`."
        ),
        Option(
            Item(
                ["-t", "--type"],
                ["area*", "…"]
            ),
            "Set the data type for input table"
        ),
        Option(
            Item(
                ["-c", "--capture"],
                ["LR*", "LD", "DL", "DR"]
            ),
            "Set the order of captured values from '--id'. \ni\t'L' is level, 'R' is ratio of concentration, 'D' is dilution factor (df)."
        ),
        Option(
            Item(
                ["-sdt"]
            ),
            "Set `datatable` to be `SampleDataTable` (default, each row represents a sample)"
        ),
        Option(
            Item(
                ["-adt"]
            ),
            "Set `datatable` to be `AnalyteDataTable` (default, each column represents a sample)"
        ),
        Option(
            Item(
                ["-d", "--delim"],
                ["\\t*", "…"]
            ),
            "Set `delim`"
        ),
        Option(
            Item(
                ["--keylevel"],
                ["nothing*", "…"]
            ),
            "Set column name or row key of calibration levels"
        ),
        Option(
            Item(
                ["--keyratio"],
                ["nothing*", "…"]
            ),
            "Set column name or row key of ratios of concentrations"
        ),
        Option(
            Item(
                ["--keydf"],
                ["nothing*", "…"]
            ),
            "Set column name or row key of dilution factors"
        ),
        Option(
            Item(
                ["--colkey"],
                ["Sample*", "…"]
            ),
            "Set column name of row keys which are samples for `SampleDataTable`, and analytes for `AnalyteDataTable`"
        ),
        Option(
            Item(
                ["--dot"],
                ["-*", "…"]
            ),
            """Set replacement of "." in sample names (calbration concentration)"""
        ),
        Option(
            Item(
                ["--f2c"],
                ["1*", "…"]
            ),
            "Set `f2c`; concentration equals to f2c * ratio or f2c / df. \ni\tWhen multiple values are provided, each element represents `f2c` value of each analyte."
        ),
        Option(
            Item(
                ["-i", "--input"],
                "files…"
            ),
            "Set the input files"
        ),
        Option(
            Item(
                ["-o", "--output"],
                ["new.batch*", "…"]
            ),
            "Set the output directory"
        )
    ],
    "calibrate" => [
        Option(
            Item(
                ["-h", "--help"]
            ),
            printhelp
        ),
        Option(
            Item(
                ["-d", "--delim"],
                ["\\t*", "…"]
            ),
            "Set `delim`"
        ),
        Option(
            Item(
                ["-i", "--input"],
                "files…"
            ),
            "Set the input files ('.batch')"
        ),
        Option(
            Item(
                ["-o", "--output"],
                "dir"
            ),
            "Set the output directory"
        )
    ],
    "accuracy-precision" => [
        Option(
            Item(
                ["-h", "--help"]
            ),
            printhelp
        ),
        Option(
            Item(
                ["-s", "--source"],
                ["mh*", "MassHunter"]
            ),
            "Set the source of input file"
        ),
        Option(
            Item(
                ["--id"],
                [""""Pre(.*)_(.*)_.*"*""", "…"]
            ),
            "Set the identifier for the AP experiment samples. This will be wrapped in `Regex`. \ni\tThe concentration level, and validation days are captured; the order can be set by '-c'."
        ),
        Option(
            Item(
                ["-c", "--capture"],
                ["DL*", "LD"]
            ),
            "Set the order of captured values from '--id'. 'D' is validation days; 'L' is concentration level."
        ),
        Option(
            Item(
                ["-t", "--type"],
                ["accuracy*", "area", "height", "…"]
            ),
            "Set the data type for calculation. For data from mh (MassHunter), 'Area' is converted to 'area', \ni\t'Height' is converted to 'height', 'ISTD Resp. Ratio' is converted to 'relative_signal', \ni\t'Final Conc.' is converted to 'estimated_concentration', and 'Accuracy' is converted to 'accuracy'."
        ),
        Option(
            Item(
                ["-p", "--prefix"]
            ),
            "Preserve original column names in new column names in wide format"
        ),
        Option(
            Item(
                ["--not-pct"]
            ),
            "Do not convert ratio data into percentage (*100)"
        ),
        Option(
            Item(
                ["--not-merge"]
            ),
            "Do not merge mean and std with ±"
        ),
        Option(
            Item(
                ["--rows"],
                ["D S*", "A", "D", "L", "S", "…"]
            ),
            "Preserve these column(s) as row keys in wide format. Accept multiple arguments. \ni\t'A' is analytes; 'D' is validation days; 'L' is concentration level; 'S' is Stats."
        ),
        Option(
            Item(
                ["--cols"],
                ["A L*", "A", "D", "L", "S", "…"]
            ),
            "Set column names holding the column names in wide format. Accept multiple arguments. \ni\t'A' is analytes; 'D' is validation days; 'L' is concentration level; 'S' is Stats."
        ),
        Option(
            Item(
                ["--not-sort"],
                ["S*", "A", "D", "L", "…"]
            ),
            "Do not sort by these column(s). Accept multiple arguments. \ni\t'A' is analytes; 'D' is validation days; 'L' is concentration level; 'S' is Stats."
        ),
        Option(
            Item(
                ["--drop"],
                ["S", "A", "D", "L", "…"]
            ),
            "Drop these column(s) in wide format. Accept multiple arguments. \ni\t'A' is analytes; 'D' is validation days; 'L' is concentration level; 'S' is Stats."
        ),
        Option(
            Item(
                ["--colanalyte"],
                ["Analyte*", "…"]
            ),
            "Set column name of analytes"
        ),
        Option(
            Item(
                ["--colstats"],
                ["Stats*", "…"]
            ),
            "Set column name of statistics"
        ),
        Option(
            Item(
                ["--colday"],
                ["Day*", "…"]
            ),
            "Set column name of validation day"
        ),
        Option(
            Item(
                ["--collevel"],
                ["Level*", "…"]
            ),
            "Set column name of level"
        ),
        Option(
            Item(
                ["-i", "--input"],
                "files…"
            ),
            "Set the input files ('.csv', '.at', '.batch')"
        ),
        Option(
            Item(
                ["-o", "--output"],
                ["accuracy-precision*", "…"]
            ),
            "Set the output directory"
        )
    ],
    "stability" => [
        Option(
            Item(
                ["-h", "--help"]
            ),
            printhelp
        ),
        Option(
            Item(
                ["-s", "--source"],
                ["mh*", "MassHunter"]
            ),
            "Set the source of input file"
        ),
        Option(
            Item(
                ["--day0"],
                [""""S.*_(.*)_.*"*""", "nothing", "…"]
            ),
            "Set the identifier for the day0 samples. This will be wrapped in `Regex`. \ni\tThe concentration level is captured. 'nothing' indicates no day0 sample." 
        ),
        Option(
            Item(
                ["--stored"],
                [""""S.*_(.*)_(.*)_(.*)_.*"*""", "…"]
            ),
            "Set the identifier for the stored samples; this will be wrapped in `Regex`. \ni\tThe storage condition, concentration level, and storage days are captured; the order can be set by '-c'."
        ),
        Option(
            Item(
                ["-c", "--capture"],
                ["CDL*", "DCL", "LCD", "…"]
            ),
            "Set the order of captured values from '--id'. \ni\t'C' is storage condition; 'D' is storage days; 'L' is concentration level."
        ),
        Option(
            Item(
                ["-t", "--type"],
                ["accuracy*", "area", "height", "…"]
            ),
            "Set the data type for calculation. For data from mh (MassHunter), 'Area' is converted to 'area', \ni\t'Height' is converted to 'height', 'ISTD Resp. Ratio' is converted to 'relative_signal', \ni\t'Final Conc.' is converted to 'estimated_concentration', and 'Accuracy' is converted to 'accuracy'."
        ),
        Option(
            Item(
                ["-p", "--prefix"]
            ),
            "Preserve original column names in new column names in wide format"
        ),
        Option(
            Item(
                ["--not-accuracy"]
            ),
            "Indicate the input data type is not accuracy, and thus it will not be transformed into percentage \ni\teven if '--not-pct' is not set."
        ),
        Option(
            Item(
                ["--not-pct"]
            ),
            "Do not convert ratio data into percentage (*100)"
        ),
        Option(
            Item(
                ["--not-merge"]
            ),
            "Do not merge mean and std with ±"
        ),
        Option(
            Item(
                ["--rows"],
                ["C D*", "A", "C", "D", "L", "S", "…"]
            ),
            "Preserve these column(s) as row keys in wide format. Accept multiple arguments. \ni\t'A' is analytes; 'C' is storage condition; 'D' is validation days; 'L' is concentration level; 'S' is Stats."
        ),
        Option(
            Item(
                ["--cols"],
                ["A L*", "A", "C", "D", "L", "S", "…"]
            ),
            "Set column names holding the column names in wide format. Accept multiple arguments. \ni\t'A' is analytes; 'C' is storage condition; 'D' is validation days; 'L' is concentration level; 'S' is Stats."
        ),
        Option(
            Item(
                ["--not-sort"],
                ["S*", "C", "A", "D", "L", "…"]
            ),
            "Do not sort by these column(s). Accept multiple arguments. \ni\t'A' is analytes; 'C' is storage condition; 'D' is validation days; 'L' is concentration level; 'S' is Stats."
        ),
        Option(
            Item(
                ["--drop"],
                ["S*", "A", "C", "D", "L", "…"]
            ),
            "Drop these column(s) in wide format. Accept multiple arguments. \ni\t'A' is analytes; 'C' is storage condition; 'D' is validation days; 'L' is concentration level; 'S' is Stats."
        ),
        Option(
            Item(
                ["--colanalyte"],
                ["Analyte*", "…"]
            ),
            "Set column name of analytes"
        ),
        Option(
            Item(
                ["--colstats"],
                ["Stats*", "…"]
            ),
            "Set column name of statistics"
        ),
        Option(
            Item(
                ["--colcondition"],
                ["Condition*", "…"]
            ),
            "Set column name of storage condition"
        ),
        Option(
            Item(
                ["--colday"],
                ["Day*", "…"]
            ),
            "Set column name of validation day"
        ),
        Option(
            Item(
                ["--collevel"],
                ["Level*", "…"]
            ),
            "Set column name of level"
        ),
        Option(
            Item(
                ["-i", "--input"],
                "files…"
            ),
            "Set the input files ('.csv', '.at', '.batch')"
        ),
        Option(
            Item(
                ["-o", "--output"],
                ["stability*", "…"]
            ),
            "Set the output directory"
        )
    ],
    "matrix-effect" => [
        Option(
            Item(
                ["-h", "--help"]
            ),
            printhelp
        ),
        Option(
            Item(
                ["-s", "--source"],
                ["mh*", "MassHunter"]
            ),
            "Set the source of input file"
        ),
        Option(
            Item(
                ["--matrix"],
                [""""Post.*_(.*)_.*"*""", "…"]
            ),
            "Set the identifier for the samples with matrix. This will be wrapped in `Regex`. \ni\tThe concentration level is captured."
        ),
        Option(
            Item(
                ["--stds"],
                [""""STD.*_(.*)_.*"*""", "…"]
            ),
            "Set the identifier for the standard solutions. This will be wrapped in `Regex`. \ni\tThe concentration level is captured."
        ),
        Option(
            Item(
                ["-t", "--type"],
                ["area*", "accuracy", "height", "…"]
            ),
            "Set the data type for calculation. For data from mh (MassHunter), 'Area' is converted to 'area', \ni\t'Height' is converted to 'height', 'ISTD Resp. Ratio' is converted to 'relative_signal', \ni\t'Final Conc.' is converted to 'estimated_concentration', and 'Accuracy' is converted to 'accuracy'."
        ),
        Option(
            Item(
                ["-p", "--prefix"]
            ),
            "Preserve original column names in new column names in wide format"
        ),
        Option(
            Item(
                ["--not-pct"]
            ),
            "Do not convert ratio data into percentage (*100)"
        ),
        Option(
            Item(
                ["--not-merge"]
            ),
            "Do not merge mean and std with ±"
        ),
        Option(
            Item(
                ["--rows"],
                ["L*", "A", "L", "S", "…"]
            ),
            "Preserve these column(s) as row keys in wide format. Accept multiple arguments. \ni\t'A' is analytes; 'L' is concentration level; 'S' is Stats."
        ),
        Option(
            Item(
                ["--cols"],
                ["A*", "L", "S", "…"]
            ),
            "Set column names holding the column names in wide format. Accept multiple arguments. \ni\t'A' is analytes; 'L' is concentration level; 'S' is Stats."
        ),
        Option(
            Item(
                ["--not-sort"],
                ["S*", "A", "L", "…"]
            ),
            "Do not sort by these column(s). Accept multiple arguments. \ni\t'A' is analytes; 'L' is concentration level; 'S' is Stats."
        ),
        Option(
            Item(
                ["--drop"],
                ["S*", "A", "L", "…"]
            ),
            "Drop these column(s) in wide format. Accept multiple arguments. \ni\t'A' is analytes; 'L' is concentration level; 'S' is Stats."
        ),
        Option(
            Item(
                ["--colanalyte"],
                ["Analyte*", "…"]
            ),
            "Set column name of analytes"
        ),
        Option(
            Item(
                ["--colstats"],
                ["Stats*", "…"]
            ),
            "Set column name of statistics"
        ),
        Option(
            Item(
                ["--collevel"],
                ["Level*", "…"]
            ),
            "Set column name of level"
        ),
        Option(
            Item(
                ["-i", "--input"],
                "files…"
            ),
            "Set the input files ('.csv', '.at', '.batch')"
        ),
        Option(
            Item(
                ["-o", "--output"],
                ["me*", "…"]
            ),
            "Set the output directory"
        )
    ],
    "recovery" => [
        Option(
            Item(
                ["-h", "--help"]
            ),
            printhelp
        ),
        Option(
            Item(
                ["-s", "--source"],
                ["mh*", "MassHunter"]
            ),
            "Set the source of input file"
        ),
        Option(
            Item(
                ["--pre"],
                [""""Pre.*_(.*)_.*"*""", "…"]
            ),
            "Set the identifier for the prespiked samples. This will be wrapped in `Regex`. \ni\tThe concentration level is captured."
        ),
        Option(
            Item(
                ["--post"],
                [""""Post.*_(.*)_.*"*""", "…"]
            ),
            "Set the identifier for the postspiked samples. This will be wrapped in `Regex`. \ni\tThe concentration level is captured."
        ),
        Option(
            Item(
                ["-t", "--type"],
                ["area*", "accuracy", "height", "…"]
            ),
            "Set the data type for calculation. For data from mh (MassHunter), 'Area' is converted to 'area', \ni\t'Height' is converted to 'height', 'ISTD Resp. Ratio' is converted to 'relative_signal', \ni\t'Final Conc.' is converted to 'estimated_concentration', and 'Accuracy' is converted to 'accuracy'."
        ),
        Option(
            Item(
                ["-p", "--prefix"]
            ),
            "Preserve original column names in new column names in wide format"
        ),
        Option(
            Item(
                ["--not-pct"]
            ),
            "Do not convert ratio data into percentage (*100)"
        ),
        Option(
            Item(
                ["--not-merge"]
            ),
            "Do not merge mean and std with ±"
        ),
        Option(
            Item(
                ["--rows"],
                ["L*", "A", "L", "S", "…"]
            ),
            "Preserve these column(s) as row keys in wide format. Accept multiple arguments. \ni\t'A' is analytes; 'L' is concentration level; 'S' is Stats."
        ),
        Option(
            Item(
                ["--cols"],
                ["A*", "L", "S", "…"]
            ),
            "Set column names holding the column names in wide format. Accept multiple arguments. \ni\t'A' is analytes; 'L' is concentration level; 'S' is Stats."
        ),
        Option(
            Item(
                ["--not-sort"],
                ["S*", "A", "L", "…"]
            ),
            "Do not sort by these column(s). Accept multiple arguments. \ni\t'A' is analytes; 'L' is concentration level; 'S' is Stats."
        ),
        Option(
            Item(
                ["--drop"],
                ["S*", "A", "L", "…"]
            ),
            "Drop these column(s) in wide format. Accept multiple arguments. \ni\t'A' is analytes; 'L' is concentration level; 'S' is Stats."
        ),
        Option(
            Item(
                ["--colanalyte"],
                ["Analyte*", "…"]
            ),
            "Set column name of analytes"
        ),
        Option(
            Item(
                ["--colstats"],
                ["Stats*", "…"]
            ),
            "Set column name of statistics"
        ),
        Option(
            Item(
                ["--collevel"],
                ["Level*", "…"]
            ),
            "Set column name of level"
        ),
        Option(
            Item(
                ["-i", "--input"],
                "files…"
            ),
            "Set the input files ('.csv', '.at', '.batch')"
        ),
        Option(
            Item(
                ["-o", "--output"],
                ["recovery*", "…"]
            ),
            "Set the output directory"
        )
    ],
    "quality-control" => [
        Option(
            Item(
                ["-h", "--help"]
            ),
            printhelp
        ),
        Option(
            Item(
                ["-s", "--source"],
                ["mh*", "MassHunter"]
            ),
            "Set the source of input file"
        ),
        Option(
            Item(
                ["--id"],
                ["PooledQC*", "…"]
            ),
            "Set the identifier for the QC samples. This will be wrapped in `Regex`. \ni\tThe concentration level, and validation days are captured in the identifier; the order can be set by '-c'."
        ),
        Option(
            Item(
                ["-t", "--type"],
                ["estimated_concentration*", "…"]
            ),
            "Set the data type for calculation. For data from mh (MassHunter), 'Area' is converted to 'area', \ni\t'Height' is converted to 'height', 'ISTD Resp. Ratio' is converted to 'relative_signal', \ni\t'Final Conc.' is converted to 'estimated_concentration', and 'Accuracy' is converted to 'accuracy'."
        ),
        Option(
            Item(
                ["-p", "--prefix"]
            ),
            "Preserve original column names in new column names in wide format"
        ),
        Option(
            Item(
                ["--not-pct"]
            ),
            "Do not convert ratio data into percentage (*100)"
        ),
        Option(
            Item(
                ["--not-merge"]
            ),
            "Do not merge mean and std with ±"
        ),
        Option(
            Item(
                ["--rows"],
                ["S*", "A", "S", "…"]
            ),
            "Preserve these column(s) as row keys in wide format. Accept multiple arguments. \ni\t'A' is analytes; 'S' is Stats."
        ),
        Option(
            Item(
                ["--cols"],
                ["A*", "S", "…"]
            ),
            "Set column names holding the column names in wide format. Accept multiple arguments. \ni\t'A' is analytes; 'S' is Stats."
        ),
        Option(
            Item(
                ["--not-sort"],
                ["S*", "A", "S", "…"]
            ),
            "Do not sort by these column(s). Accept multiple arguments. \ni\t'A' is analytes; 'S' is Stats."
        ),
        Option(
            Item(
                ["--drop"],
                ["S", "A", "…"]
            ),
            "Drop these column(s) in wide format. Accept multiple arguments. \ni\t'A' is analytes; 'S' is Stats."
        ),
        Option(
            Item(
                ["--colanalyte"],
                ["Analyte*", "…"]
            ),
            "Set column name of analytes"
        ),
        Option(
            Item(
                ["--colstats"],
                ["Stats*", "…"]
            ),
            "Set column name of statistics"
        ),
        Option(
            Item(
                ["-i", "--input"],
                "files…"
            ),
            "Set the input files ('.csv', '.at', '.batch')"
        ),
        Option(
            Item(
                ["-o", "--output"],
                ["qc*", "…"]
            ),
            "Set the output directory"
        )
    ],
    "sample" => [
        Option(
            Item(
                ["-h", "--help"]
            ),
            printhelp
        ),
        Option(
            Item(
                ["-s", "--source"],
                ["mh*", "MassHunter"]
            ),
            "Set the source of input file"
        ),
        Option(
            Item(
                ["--id"],
                [""""Sample_(\\d*).*"*""", "…"]
            ),
            "Set the identifier for the samples. This will be wrapped in `Regex`. \ni\tThe sample id is captured."
        ),
        Option(
            Item(
                ["-t", "--type"],
                ["estimated_concentration*", "…"]
            ),
            "Set the data type for calculation. For data from mh (MassHunter), 'Area' is converted to 'area', \ni\t'Height' is converted to 'height', 'ISTD Resp. Ratio' is converted to 'relative_signal', \ni\t'Final Conc.' is converted to 'estimated_concentration', and 'Accuracy' is converted to 'accuracy'."
        ),
        Option(
            Item(
                ["-p", "--prefix"]
            ),
            "Preserve original column names in new column names in wide format"
        ),
        Option(
            Item(
                ["--not-pct"]
            ),
            "Do not convert ratio data into percentage (*100)"
        ),
        Option(
            Item(
                ["--not-merge"]
            ),
            "Do not merge mean and std with ±"
        ),
        Option(
            Item(
                ["--rows"],
                ["F*", "A", "…"]
            ),
            "Preserve these column(s) as row keys in wide format. Accept multiple arguments. \ni\t'A' is analytes; 'F' is files."
        ),
        Option(
            Item(
                ["--cols"],
                ["A*", "F", "…"]
            ),
            "Set column names holding the column names in wide format. Accept multiple arguments. \ni\t'A' is analytes; 'F' is files."
        ),
        Option(
            Item(
                ["--not-sort"],
                ["F A*", "A", "F", "…"]
            ),
            "Do not sort by these column(s). Accept multiple arguments. \ni\t'A' is analytes; 'F' is files."
        ),
        Option(
            Item(
                ["--drop"],
                ["F", "A", "…"]
            ),
            "Drop these column(s) in wide format. Accept multiple arguments. \ni\t'A' is analytes; 'F' is files."
        ),
        Option(
            Item(
                ["--colanalyte"],
                ["Analyte*", "…"]
            ),
            "Set column name of analytes"
        ),
        Option(
            Item(
                ["--coldatafile"],
                ["File*", "…"]
            ),
            "Set column name of data files"
        ),
        Option(
            Item(
                ["--lod"],
                ["nothing*", "…"]
            ),
            "Set limit of detection (LOD). Values are promoted to match columns whose name starts with 'Data'. \ni\t'nothing' indicates no LOD."
        ),
        Option(
            Item(
                ["--loq"],
                ["nothing*", "…"]
            ),
            "Set limit of quantification (LOQ). Values are promoted to match columns whose name starts with 'Data'. \ni\t'nothing' indicates no LOQ."
        ),
        Option(
            Item(
                ["--lloq"],
                ["nan*", "nothing", "…"]
            ),
            "Set lower limit of quantification (LLOQ). Values are promoted to match columns whose name starts with 'Data'.\ni\t'NaN' indicates using LLOQ from calibration curves if the input is '.batch'; otherwise, no LLOQ. \ni\t'nothing' indicates no LLOQ."
        ),
        Option(
            Item(
                ["--uloq"],
                ["nan*", "nothing", "…"]
            ),
            "Set upper limit of quantification (ULOQ). Values are promoted to match columns whose name starts with 'Data'.\ni\t'NaN' indicates using ULOQ from calibration curves if the input is '.batch'; otherwise, no ULOQ. \ni\t'nothing' indicates no ULOQ."
        ),
        Option(
            Item(
                ["--lodsub"],
                ["<LOD*", "missing", "…"]
            ),
            "Substitution for value smaller than LOD. Values are promoted to match columns whose name starts with 'Data'."
        ),
        Option(
            Item(
                ["--loqsub"],
                ["<LOQ*", "missing", "…"]
            ),
            "Substitution for value smaller than LOQ. Values are promoted to match columns whose name starts with 'Data'."
        ),
        Option(
            Item(
                ["--lloqsub"],
                ["<LLOQ*", "missing", "…"]
            ),
            "Substitution for value smaller than LLOQ. Values are promoted to match columns whose name starts with 'Data'."
        ),
        Option(
            Item(
                ["--uloqsub"],
                [">ULOQ*", "missing", "…"]
            ),
            "Substitution for value larger than ULOQ. Values are promoted to match columns whose name starts with 'Data'."
        ),
        Option(
            Item(
                ["-i", "--input"],
                "files…"
            ),
            "Set the input files ('.csv', '.at', '.batch')"
        ),
        Option(
            Item(
                ["-o", "--output"],
                ["sample*", "…"]
            ),
            "Set the output directory"
        )
    ]
)