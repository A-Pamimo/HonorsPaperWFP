*******************************************************
* 09_heterogeneity.do — Heterogeneity by subgroups
*******************************************************

version 17
set more off
do "00_utils.do"

use "$IN_FOR_TABLES", clear
_mk_label

* Guard: need outcome & mode
capture confirm variable FCS
if _rc {
    preserve
        clear
        set obs 1
        gen note = "FCS not found in $IN_FOR_TABLES; skipping heterogeneity."
        _xlsx_export, sheet("Heterogeneity")
    restore
    exit
}
capture confirm variable $MODE
if _rc {
    preserve
        clear
        set obs 1
        gen note = "Mode variable $MODE not found; skipping heterogeneity."
        _xlsx_export, sheet("Heterogeneity")
    restore
    exit
}

tempfile het
capture postutil clear
tempname H
postfile `H' str32 subgroup str8 level double N coef se pval using "`het'", replace

foreach sg of global SUBGROUPS {
    capture confirm variable `sg'
    if _rc {
        post `H' ("`sg' (missing)") ("") (.) (.) (.) (.)
        continue
    }

    * Count observations by binary levels (0/1)
    quietly count if `sg'==1
    local n1 = r(N)
    quietly count if `sg'==0
    local n0 = r(N)

    * If both levels have zero obs (all missing or non-binary), record and skip
    if (`n1'==0 & `n0'==0) {
        post `H' ("`sg' (no 0/1 values)") ("") (.) (.) (.) (.)
        continue
    }

    * ---------- Level 1 ----------
    preserve
        keep if `sg'==1
        local N_here = _N
        if (`N_here'==0) {
            post `H' ("`sg'") ("1") (0) (.) (.) (.)
        }
        else {
            capture noisily _regw regress FCS i.$MODE
            if (_rc) {
                post `H' ("`sg'") ("1") (`N_here') (.) (.) (.)
            }
            else {
                capture scalar b = _b[1.$MODE]
                capture scalar s = _se[1.$MODE]
                capture scalar p = .
                capture confirm scalar s
                if !_rc & s>0 {
                    scalar p = 2*ttail(e(df_r), abs(b/s))
                }
                post `H' ("`sg'") ("1") (e(N)) (b) (s) (p)
            }
        }
    restore

    * ---------- Level 0 ----------
    preserve
        keep if `sg'==0
        local N_here = _N
        if (`N_here'==0) {
            post `H' ("`sg'") ("0") (0) (.) (.) (.)
        }
        else {
            capture noisily _regw regress FCS i.$MODE
            if (_rc) {
                post `H' ("`sg'") ("0") (`N_here') (.) (.) (.)
            }
            else {
                capture scalar b = _b[1.$MODE]
                capture scalar s = _se[1.$MODE]
                capture scalar p = .
                capture confirm scalar s
                if !_rc & s>0 {
                    scalar p = 2*ttail(e(df_r), abs(b/s))
                }
                post `H' ("`sg'") ("0") (e(N)) (b) (s) (p)
            }
        }
    restore
}

postclose `H'
use "`het'", clear
label var subgroup "Subgroup"
label var level    "Level"
label var N        "N"
label var coef     "Coef on 1.$MODE"
label var se       "Std. Err."
label var pval     "p-value"

_xlsx_export, sheet("Heterogeneity")

display as result "09_heterogeneity.do complete → Heterogeneity sheet"
