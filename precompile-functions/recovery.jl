using ChemistryQuantitativeAnalysis, AnalyticalMethodValidation, DataFrames, CSV, TypedTables
const CQA = ChemistryQuantitativeAnalysis
const AMV = AnalyticalMethodValidation

# reconvery_main.jl 
data = AMV.read(joinpath(@__DIR__(), "..", "project", "example", "D1.csv"))
recovery = recovery_report(data)
pivot(selectby(recovery, :Stats, ["Recovery(%)", "Standard Deviation(%)"] => mean_plus_minus_std => "Recovery(%)"), ["Analyte"])