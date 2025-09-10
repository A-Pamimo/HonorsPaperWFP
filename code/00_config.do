*======================================================
* FILE: code/00_config.do
*======================================================

*******************************************************
* 00_config.do — Project configuration (paths, cutoffs)
*******************************************************

version 17
set more off

capture noisily cd "`c(pwd)'"
global PROJ "`c(pwd)'"

* ===================== PATHS =========================
global IN_RAW            "../raw"
global IN_ANALYTIC       "../data/clean/Complete_BF_Household_Analysis.dta"
global OUT_CLEAN         "../data/clean/bf_analytic_cleaned.dta"
global IN_FOR_TABLES     "../data/clean/bf_with_indices.dta"
global OUT_XLSX          "../output/tables/results.xlsx"

* Provide a safe default for OUTTAB if not set elsewhere
capture confirm global OUTTAB
if _rc global OUTTAB "../output/tables"

* Country toggle
capture macro drop COUNTRY
global COUNTRY "BF"

* ===== Core Analysis Controls =====
capture macro drop MODE
global MODE Modality_Type

capture macro drop BAL_VARS
global BAL_VARS "HHSize S_HHHFemale HHH_Age HHH_Education urban poor_pre shock_any"

* Survey design (optional)
capture macro drop PSU STRATA CLUSTVAR SURVEY_DESIGN
global PSU ""
global STRATA ""
global CLUSTVAR ""
global SURVEY_DESIGN "0"

* Weight (optional)
capture macro drop WGT
global WGT ""

* Heterogeneity subgroups
capture macro drop SUBGROUPS
global SUBGROUPS "head_female urban poor_pre"

* ---------- SAFE SUBGROUP CHECK ----------
capture confirm file "$IN_FOR_TABLES"
if !_rc {
    capture noisily {
        use "$IN_FOR_TABLES", clear
        local __sg_list "$SUBGROUPS"
        local __keep ""
        foreach sg of local __sg_list {
            capture confirm numeric variable `sg'
            if _rc {
                di as error "⚠️ Subgroup var '`sg'' not found or not numeric — dropping from SUBGROUPS"
            }
            else {
                quietly count if !missing(`sg')
                if r(N)==0 di as error "⚠️ Subgroup var '`sg'' has no non-missing values — dropping"
                else local __keep "`__keep' `sg'"
            }
        }
        global SUBGROUPS "`__keep'"
        clear
    }
}
* ----------------------------------------

* Feature flags / cutoffs
capture macro drop FLAG_EXPORT FCS_CUTOFF
global FLAG_EXPORT 1
global FCS_CUTOFF 21

display as result "00_config.do loaded"
