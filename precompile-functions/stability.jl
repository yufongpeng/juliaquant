using ChemistryQuantitativeAnalysis, AnalyticalMethodValidation, DataFrames, CSV, TypedTables
const CQA = ChemistryQuantitativeAnalysis
const AMV = AnalyticalMethodValidation

# stability_main.jl 
data = AMV.read(joinpath(@__DIR__(), "..", "data", "D2S0S7.csv"))
st = stability_report(data; day0 = r"Pre.*_(.*)_.*", stored = r"S.*_(.*)_D(.*)_(.*)_.*")
td2 = pivot(selectby(st.stored, "Stats", (["Accuracy(%)", "Standard Deviation(%)"] => mean_plus_minus_std => "Accuracy(%)")), ["Analyte", "Level"]; rows = ["Condition", "Day"], notsort = ["Stats"], drop = ["Stats"], prefix = false)