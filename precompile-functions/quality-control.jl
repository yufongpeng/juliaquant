using ChemistryQuantitativeAnalysis, AnalyticalMethodValidation, DataFrames, CSV, TypedTables
const CQA = ChemistryQuantitativeAnalysis
const AMV = AnalyticalMethodValidation

# qc_main.jl 
data = AMV.read(joinpath(@__DIR__(), "..", "project", "example", "D1.csv"))
qc = qc_report(data)