using ChemistryQuantitativeAnalysis, AnalyticalMethodValidation, DataFrames, CSV, TypedTables
const CQA = ChemistryQuantitativeAnalysis
const AMV = AnalyticalMethodValidation

data = AMV.read(joinpath(@__DIR__(), "..", "data", "D1.csv"))
me = me_report(data; matrix = r"Pre.*_(.*)_.*", stds = r"Post.*_(.*)_.*")
td = pivot(selectby(me, :Stats, ["Matrix Effect(%)", "Standard Deviation(%)"] => mean_plus_minus_std => "Matrix Effect(%)"), ["Analyte"])