*******************************************************
* 00_config.do — Project configuration (paths, cutoffs)
*******************************************************
version 17

* Project root — default to current working directory
global PROJ "`c(pwd)'"

* Inputs/Outputs (edit as needed)
global IN_ANALYTIC   "data/clean/Complete_BF_Household_Analysis.dta"
global OUT_CLEAN     "data/clean/bf_analytic_cleaned.dta"
global IN_FOR_TABLES "data/clean/bf_with_indices.dta"
global OUT_XLSX      "output/tables/BF_tables.xlsx"
global LOGDIR        "logs"

* Thresholds (switch to 28/42 if your context uses those)
global FCS_CUT_POOR   21
global FCS_CUT_BORDER 35

* rCSI bands (0–3 Low, 4–9 Medium, >=10 High as default)
global RCSI_CUT1 3
global RCSI_CUT2 9

* Labels for modality (0=F2F, 1=Remote)
label define modlbl 0 "F2F" 1 "Remote", replace
