using ChemistryQuantitativeAnalysis, AnalyticalMethodValidation, DataFrames, CSV, TypedTables
const CQA = ChemistryQuantitativeAnalysis
const AMV = AnalyticalMethodValidation

data = AMV.read(joinpath.(@__DIR__(), "..", "project", "example", ["D1.csv", "D2S0S7.csv", "D3.csv"]))
ap = ap_report(data)
pivot(selectby(ap.daily, :Stats, ["Accuracy(%)", "Standard Deviation(%)"] => mean_plus_minus_std => "Accuracy(%)"), [:Analyte, :Level]; rows = [:Day, :Stats])