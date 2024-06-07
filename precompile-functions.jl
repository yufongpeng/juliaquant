using ChemistryQuantitativeAnalysis, AnalyticalMethodValidation, DataFrames, CSV, TypedTables
const CQA = ChemistryQuantitativeAnalysis
const AMV = AnalyticalMethodValidation

# batch_main.jl 
dt1 = SampleDataTable(CSV.read(joinpath("data", "sample.txt"), DataFrame; delim = '\t'), Symbol("Data File"))
dt2 = AnalyteDataTable(CSV.read(joinpath("data", "analyte.txt"), DataFrame; delim = '\t'), :Analyte)
batch1 = Batch(dt1; calid = r"Cal2_(\d)_(\d*-*\d*)", f2c = [0.1, 1, 10], parse_decimal = x -> replace(x, "-" => "."))
batch2 = Batch(dt2; calid = r"Cal2_(\d)_(\d*-*\d*)", f2c = [0.1, 1, 10], parse_decimal = x -> replace(x, "-" => "."))
CQA.write(joinpath("data", "precompile", "batch1.batch"), batch1; delim = '\t')
CQA.write(joinpath("data", "precompile", "batch2.batch"), batch2; delim = '\t')

# cal_main.jl 
batch1 = CQA.read(joinpath("data", "initial_mc_c.batch"), DataFrame)
batch2 = CQA.read(joinpath("data", "initial_mc_r.batch"), DataFrame)
include(joinpath(@__DIR__(), "ui", "src", "ui.jl"))
interactive_calibrate!(batch1)
interactive_calibrate!(batch2; async = true, timeout = 1)

# reconvery_main.jl 
data = AMV.read(joinpath("data", "D1.csv"))
recovery = recovery_report(data)
pivot(selectby(recovery, :Stats, ["Recovery(%)", "Standard Deviation(%)"] => mean_plus_minus_std => "Recovery(%)"), ["Analyte"])

# me_main.jl
# data = AMV.read(joinpath("data", "D1.csv"))
me = me_report(data; matrix = r"Pre.*_(.*)_.*", stds = r"Post.*_(.*)_.*")
# td = pivot(selecby(me, :Stats, ["Matrix Effect(%)", "Standard Deviation(%)"] => mean_plus_minus_std => "Matrix Effect(%)"), ["Analyte"])

# qc_main.jl 
qc = qc_report(data)
# ap_main.jl 
data = AMV.read(joinpath.("data", ["D1.csv", "D2S0S7.csv", "D3.csv"]))
ap = ap_report(data)
pivot(selectby(ap.daily, :Stats, ["Accuracy(%)", "Standard Deviation(%)"] => mean_plus_minus_std => "Accuracy(%)"), [:Analyte, :Level]; rows = [:Day, :Stats])

# stability_main.jl 
data = AMV.read(joinpath("data", "D2S0S7.csv"))
st = stability_report(data; day0 = r"Pre.*_(.*)_.*", stored = r"S.*_(.*)_D(.*)_(.*)_.*")

# sample_main.jl 
data = AMV.read(joinpath("data", "sample.csv"))
sample = sample_report(data)
qualify!(pivot(sample, :Analyte); lod = 1, lloq = 3, uloq = [100, 200, 100], lodsub = missing)