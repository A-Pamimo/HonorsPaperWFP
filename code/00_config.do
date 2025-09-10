*******************************************************
* 00_config.do — Project configuration (paths, cutoffs)
*******************************************************

version 17
set more off

* Root project folder (defaults to parent of /code when run from /code)
capture noisily cd "`c(pwd)'"
global PROJ "`c(pwd)'"

* ===================== PATHS =========================
* Use parent-relative paths so master.do can run from /code
global IN_RAW            "../raw"
global IN_ANALYTIC       "../data/clean/Complete_BF_Household_Analysis.dta"
global OUT_CLEAN         "../data/clean/bf_analytic_cleaned.dta"
global IN_FOR_TABLES     "../data/clean/bf_with_indices.dta"
global OUT_XLSX          "../output/tables/results.xlsx"

* Country toggle (if you run multiple countries)
capture macro drop COUNTRY
global COUNTRY "BF"

* ===== Core Analysis Controls =====
* Mode variable used across scripts (0 = F2F, 1 = Remote)
capture macro drop MODE
global MODE Modality_Type

* Baseline balance variables (edit to your actual columns)
capture macro drop BAL_VARS
global BAL_VARS "hhsize head_female head_age educ_head urban poor_pre shock_any"

* Optional survey design (leave blank if not applicable)
capture macro drop PSU
capture macro drop STRATA
capture macro drop CLUSTVAR
capture macro drop SURVEY_DESIGN
global PSU           ""
global STRATA        ""
global CLUSTVAR      ""
global SURVEY_DESIGN "0"

* Weight(s) (optional; leave blank if none)
capture macro drop WGT
global WGT ""

* Heterogeneity subgroups for 09_heterogeneity.do
capture macro drop SUBGROUPS
global SUBGROUPS "head_female urban poor_pre"

* Feature flags
capture macro drop FLAG_EXPORT
global FLAG_EXPORT 1

* Thresholds / cutoffs used downstream
capture macro drop FCS_CUTOFF
global FCS_CUTOFF 21

display as result "00_config.do loaded"
