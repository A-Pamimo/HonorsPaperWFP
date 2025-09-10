*******************************************************
* 01_setup.do — Create folders, set paths
*******************************************************

version 17
set more off

* Create both local (/code) and parent project folders quietly
capture quietly mkdir "output"
capture quietly mkdir "output/tables"
capture quietly mkdir "output/figures"
capture quietly mkdir "temp"

capture quietly mkdir "../output"
capture quietly mkdir "../output/tables"
capture quietly mkdir "../output/figures"
capture quietly mkdir "../temp"
capture quietly mkdir "../data"
capture quietly mkdir "../data/clean"

* Ensure globals exist (fallbacks consistent with parent layout)
capture confirm global OUT_XLSX
if _rc global OUT_XLSX "../output/tables/results.xlsx"
capture confirm global OUT_CLEAN
if _rc global OUT_CLEAN "../data/clean/bf_analytic_cleaned.dta"
capture confirm global IN_ANALYTIC
if _rc global IN_ANALYTIC "../data/clean/Complete_BF_Household_Analysis.dta"
capture confirm global IN_FOR_TABLES
if _rc global IN_FOR_TABLES "../data/clean/bf_with_indices.dta"

display as result "01_setup.do complete"
