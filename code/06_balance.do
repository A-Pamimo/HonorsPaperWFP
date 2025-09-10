*******************************************************
* 06_balance.do — Baseline balance by modality (Tbls)
*******************************************************

version 17
set more off
do "00_utils.do"

* Pick dataset (analytic preferred if exists)
capture confirm file "$IN_ANALYTIC"
if _rc {
    use "$OUT_CLEAN", clear
}
else {
    use "$IN_ANALYTIC", clear
}
_mk_label

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
label var varname     "Variable"
label var mean_f2f    "Mean (F2F)"
label var mean_remote "Mean (Remote)"
label var diff        "Diff (R - F2F)"
label var tstat       "t-stat"
label var pval        "p-value"
label var N_f2f       "N F2F"
label var N_remote    "N Remote"

_xlsx_export, sheet("Balance")

display as result "06_balance.do complete → Balance sheet"
