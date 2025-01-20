using ChemistryQuantitativeAnalysis, AnalyticalMethodValidation, DataFrames, CSV, TypedTables
const CQA = ChemistryQuantitativeAnalysis
const AMV = AnalyticalMethodValidation

# sample_main.jl 
data = AMV.read(joinpath(@__DIR__(), "..", "data", "sample.csv"))
sample = sample_report(data)
qualify!(pivot(sample, :Analyte); lod = 1, lloq = 3, uloq = [100, 200, 100], lodsub = missing)