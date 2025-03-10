using ChemistryQuantitativeAnalysis, DataFrames, CSV, TypedTables, ChemistryQuantitativeAnalysisUI
const CQA = ChemistryQuantitativeAnalysis

# cal_main.jl 
batch1 = CQA.read(joinpath(@__DIR__(), "..", "project", "example", "initial_mc_c.batch"), DataFrame)
batch2 = CQA.read(joinpath(@__DIR__(), "..", "project", "example", "initial_mc_r.batch"), DataFrame)
cal_ui!(batch1)
cal_ui!(batch2; async = true, timeout = 1)