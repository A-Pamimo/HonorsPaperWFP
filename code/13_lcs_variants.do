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

* Ensure coping variables are numeric
capture ds Lcs* LcsEN*
local allvars `r(varlist)'
if "`allvars'" != "" {
    _coerce_num `allvars'
}

* -------------------- LCS-FS -------------------------
* Existing category variable (LCS_Cat) if present; otherwise build
capture confirm variable LCS_Cat
if _rc {
    egen byte LCS_Stress_Coping = rowmax(Lcs_stress_DomAsset Lcs_stress_HealthEdu Lcs_stress_Saving Lcs_stress_BorrowCash)
    egen byte LCS_Crisis_Coping = rowmax(Lcs_crisis_ProdAssets Lcs_crisis_DomMigration Lcs_crisis_ChildWork)
    egen byte LCS_Emergency_Coping = rowmax(Lcs_em_ResAsset Lcs_em_Begged Lcs_em_FemAnimal)
    gen byte LCS_Cat = 0
    replace LCS_Cat = 1 if LCS_Stress_Coping==1
    replace LCS_Cat = 2 if LCS_Crisis_Coping==1
    replace LCS_Cat = 3 if LCS_Emergency_Coping==1
}

gen byte LCS_None      = (LCS_Cat==0)
gen byte LCS_Stress    = (LCS_Cat==1)
gen byte LCS_Crisis    = (LCS_Cat==2)
gen byte LCS_Emergency = (LCS_Cat==3)

* -------------------- LCS-EN -------------------------
egen byte LCSEN_Stress_Coping    = rowmax(LcsEN_stress_DomAsset LcsEN_stress_HealthEdu LcsEN_stress_Saving LcsEN_stress_BorrowCash)
egen byte LCSEN_Crisis_Coping    = rowmax(LcsEN_crisis_ProdAssets LcsEN_crisis_DomMigration LcsEN_crisis_ChildWork)
egen byte LCSEN_Emergency_Coping = rowmax(LcsEN_em_ResAsset LcsEN_em_Begged LcsEN_em_FemAnimal)

gen byte LCSEN_Cat = 0
replace LCSEN_Cat = 1 if LCSEN_Stress_Coping==1
replace LCSEN_Cat = 2 if LCSEN_Crisis_Coping==1
replace LCSEN_Cat = 3 if LCSEN_Emergency_Coping==1

gen byte LCSEN_None      = (LCSEN_Cat==0)
gen byte LCSEN_Stress    = (LCSEN_Cat==1)
gen byte LCSEN_Crisis    = (LCSEN_Cat==2)
gen byte LCSEN_Emergency = (LCSEN_Cat==3)

* ---------------- Paired comparisons -----------------
tempfile lcsvar
capture postutil clear
tempname H
postfile `H' str12 severity double FS EN diff tstat pval using "`lcsvar'", replace

foreach s in None Stress Crisis Emergency {
    quietly ttest LCS_`s' == LCSEN_`s'
    local m_fs = r(mu_1)
    local m_en = r(mu_2)
    local d    = `m_en' - `m_fs'
    local t    = r(t)
    local p    = r(p)
    post `H' ("`s'") (`m_fs') (`m_en') (`d') (`t') (`p')
}

postclose `H'
use "`lcsvar'", clear
label var severity "Severity"
label var FS       "Prop LCS-FS"
label var EN       "Prop LCS-EN"
label var diff     "Diff (EN - FS)"
label var tstat    "t-stat"
label var pval     "p-value"

_xlsx_export, sheet("LCS_variants")

display as result "13_lcs_variants.do complete → LCS_variants sheet"
