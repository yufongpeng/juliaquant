using ChemistryQuantitativeAnalysis, AnalyticalMethodValidation, DataFrames, CSV, TypedTables
const CQA = ChemistryQuantitativeAnalysis
const AMV = AnalyticalMethodValidation

# cal_main.jl 
batch1 = CQA.read(joinpath(@__DIR__(), "..", "project", "example", "initial_mc_c.batch"), DataFrame)
batch2 = CQA.read(joinpath(@__DIR__(), "..", "project", "example", "initial_mc_r.batch"), DataFrame)
# include(joinpath(@__DIR__(), "ui", "src", "ui.jl"))
# interactive_calibrate!(batch1)
# interactive_calibrate!(batch2; async = true, timeout = 1)