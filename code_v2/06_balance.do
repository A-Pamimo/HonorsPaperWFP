*======================================================
* FILE: code/06_balance.do
*======================================================

*******************************************************
* 06_balance.do — Baseline balance by modality (Tbls)
*******************************************************

version 17
set more off

* Always load helpers
do "00_utils.do"

* Pick dataset (prefer the one with indices and both modes)
capture confirm file "$IN_FOR_TABLES"
if !_rc {
    use "$IN_FOR_TABLES", clear
}
else {
    capture confirm file "$OUT_CLEAN"
    if !_rc use "$OUT_CLEAN", clear
    else    use "$IN_ANALYTIC", clear
}

_mk_label

* Ensure we actually have two groups
quietly levelsof $MODE if !missing($MODE), local(L)
local has0 = strpos("`L'","0")>0
local has1 = strpos("`L'","1")>0
if !(`has0' & `has1') {
    di as error "Balance: only one modality present; skipping."
    preserve
        clear
        set obs 1
        gen note = "Only one modality present; balance table skipped."
        _xlsx_export, sheet("Balance")
    restore
    exit
}

tempfile bal
capture postutil clear
tempname H
postfile `H' str32 varname double mean_f2f mean_remote diff tstat pval N_f2f N_remote using "`bal'", replace

foreach v of global BAL_VARS {
    capture confirm variable `v'
    if _rc {
        post `H' ("`v' (missing)") (.) (.) (.) (.) (.) (.) (.)
        continue
    }
    quietly ttest `v', by($MODE)
    local m0 = r(mu_1)
    local m1 = r(mu_2)
    local n0 = r(N_1)
    local n1 = r(N_2)
    local t  = r(t)
    local p  = r(p)
    local d  = `m1' - `m0'
    post `H' ("`v'") (`m0') (`m1') (`d') (`t') (`p') (`n0') (`n1')
}
postclose `H'

use "`bal'", clear
_xlsx_export, sheet("Balance")
