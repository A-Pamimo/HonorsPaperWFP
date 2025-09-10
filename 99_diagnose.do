*======================================================
* FILE: code/99_diagnose.do
* Purpose: Identify which modules/files have issues
* Run from anywhere:
*   do "C:\Users\AET816\Downloads\Research_v2\code\99_diagnose.do"
*======================================================

version 17
clear all
set more off

* ---------- Resolve project root ----------
local __this      "`c(filename)'"
local __root_a    : subinstr local __this "\code\99_diagnose.do" "", all
local __root_b    : subinstr local __root_a "/code/99_diagnose.do" "", all
cd "`__root_b'"

* ---------- Paths ----------
global ROOT    "`c(pwd)'"
global CODE    "$ROOT/code"
global OUTDIR  "$ROOT/output"
global OUTTAB  "$ROOT/output/tables"
global OUTFIG  "$ROOT/output/figures"
global TEMPDIR "$ROOT/temp"

* ---------- Setup folders / config / utils ----------
capture noisily do "$CODE/01_setup.do"
capture noisily do "$CODE/00_config.do"
capture noisily do "$CODE/00_utils.do"

* ---------- Helper: human meaning for common error codes ----------
tempname map
postfile `map' int rc str40 meaning using "$TEMPDIR/rc_map", replace
post `map' (603) ("File locked or cannot be opened")
post `map' (111) ("Variable not found / rename issue")
post `map' (109) ("Type mismatch")
post `map' (498) ("Variable missing (assert failed)")
post `map' (420) ("Group issue in ttest/regression")
post `map' (908) ("Excel file in use by another program")
postclose `map'

use "$TEMPDIR/rc_map.dta", clear
tempfile rcmap
save `rcmap'

* ---------- Modules to check ----------
local modules 03_construct_indices 04_analysis 05_tables 06_balance ///
              07_composites 08_indicators 09_heterogeneity 10_quality_checks ///
              11_enumerator_robustness 12_module_length 13_lcs_variants

tempfile diag
tempname H
postfile `H' str20 module int rc str60 meaning using "`diag'", replace

foreach m of local modules {
    capture noisily do "$CODE/`m'.do"
    local rc = _rc
    if (`rc'==0) {
        post `H' ("`m'") (0) ("OK")
    }
    else {
        preserve
        use `rcmap', clear
        quietly keep if rc==`rc'
        local meaning = cond(_N>0, meaning[1], "Unknown error")
        restore
        post `H' ("`m'") (`rc') ("`meaning'")
    }
}
postclose `H'

use "`diag'", clear
list, noobs abbreviate(20)

* Export diagnostic summary
capture noisily export excel using "$OUTTAB/diagnostics.xlsx", firstrow(variables) replace
di as result "99_diagnose.do complete → $OUTTAB/diagnostics.xlsx"
