*======================================================
* FILE: code/13_lcs_variants.do
*======================================================

*******************************************************
* 13_lcs_variants.do — LCS-FS vs LCS-EN (F2F only)
*******************************************************

version 17
set more off
do "00_utils.do"

* Load analytic dataset and keep F2F households
use "$IN_FOR_TABLES", clear
_mk_label
keep if $MODE==0

* Build LCS variants if not present (guard duplicates)
capture confirm variable LCS_Cat
if _rc {
    capture confirm variable Lcs_stress_DomAsset
    if !_rc {
        egen byte LCS_Stress_Coping    = rowmax(Lcs_stress_DomAsset Lcs_stress_HealthEdu Lcs_stress_Saving Lcs_stress_BorrowCash)
        egen byte LCS_Crisis_Coping    = rowmax(Lcs_crisis_ProdAssets Lcs_crisis_DomMigration Lcs_crisis_ChildWork)
        egen byte LCS_Emergency_Coping = rowmax(Lcs_em_ResAsset Lcs_em_Begged Lcs_em_FemAnimal)
        gen byte LCS_Cat = 0
        replace LCS_Cat = 1 if LCS_Stress_Coping==1
        replace LCS_Cat = 2 if LCS_Crisis_Coping==1
        replace LCS_Cat = 3 if LCS_Emergency_Coping==1
    }
}

capture confirm variable LCS_None
if _rc & c(rc)==111 {
    gen byte LCS_None = (LCS_Cat==0) if !missing(LCS_Cat)
}

* (Add any tabulations/summaries you need here)

_xlsx_export, sheet("LCS_Variants_F2F")
display as result "13_lcs_variants.do complete → LCS_Variants_F2F"
