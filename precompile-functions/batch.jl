using ChemistryQuantitativeAnalysis, DataFrames, CSV, TypedTables
const CQA = ChemistryQuantitativeAnalysis

# batch_main.jl 
df = CSV.read(joinpath(@__DIR__(), "..", "project", "example", "sample.txt"), DataFrame; delim = '\t')
level = df[!, :Level]
ratio = unique!(filter(!ismissing, df[!, :Ratio]))
select!(df, Not([:Level, :Ratio]))
dt1 = SampleDataTable(df, Symbol("File"))
dt2 = AnalyteDataTable(CSV.read(joinpath(@__DIR__(), "..", "project", "example", "analyte.txt"), DataFrame; delim = '\t'), :Analyte)
batch1 = Batch(dt1; calid = level, ratio, f2c = [0.1, 1, 10], parse_decimal = x -> replace(x, "-" => "."))
batch2 = Batch(dt2; calid = r"Cal2_(\d)_(\d*-*\d*)", f2c = [0.1, 1, 10], parse_decimal = x -> replace(x, "-" => "."))
CQA.write(joinpath(@__DIR__(), "..", "project", "example", "precompile", "batch1.batch"), batch1; delim = '\t')
CQA.write(joinpath(@__DIR__(), "..", "project", "example", "precompile", "batch2.batch"), batch2; delim = '\t')