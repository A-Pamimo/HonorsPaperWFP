*******************************************************
* 09_heterogeneity.do — Heterogeneity by subgroups
*******************************************************

version 17
set more off
do "00_utils.do"

use "$IN_FOR_TABLES", clear
_mk_label

* Guard: need mode variable
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

local outcomes "FCS rCSI FES"

tempfile het
capture postutil clear
tempname H
postfile `H' str32 outcome str32 subgroup str8 level double N coef se pval using "`het'", replace

foreach y of local outcomes {
    capture confirm variable `y'
    if _rc {
        post `H' ("`y' (missing)") ("") ("") (.) (.) (.) (.)
        continue
    }

    foreach sg of global SUBGROUPS {
        capture confirm variable `sg'
        if _rc {
            post `H' ("`y'") ("`sg' (missing)") ("") (.) (.) (.) (.)
            continue
        }

        quietly count if `sg'==0 & !missing(`y',`sg')
        local N0 = r(N)
        quietly count if `sg'==1 & !missing(`y',`sg')
        local N1 = r(N)
        if (`N0'==0 & `N1'==0) {
            post `H' ("`y'") ("`sg' (no 0/1 values)") ("") (.) (.) (.) (.)
            continue
        }

        capture noisily _regw regress `y' i.$MODE##i.`sg'
        if (_rc) {
            post `H' ("`y'") ("`sg'") ("0") (`N0') (.) (.) (.)
            post `H' ("`y'") ("`sg'") ("1") (`N1') (.) (.) (.)
        }
        else {
            * Effect for subgroup level 0
            lincom 1.$MODE
            scalar b = r(estimate)
            scalar s = r(se)
            scalar p = .
            capture confirm scalar s
            if !_rc & s>0 {
                scalar p = 2*ttail(r(df), abs(b/s))
            }
            post `H' ("`y'") ("`sg'") ("0") (`N0') (b) (s) (p)

            * Effect for subgroup level 1
            lincom 1.$MODE + 1.$MODE#1.`sg'
            scalar b = r(estimate)
            scalar s = r(se)
            scalar p = .
            capture confirm scalar s
            if !_rc & s>0 {
                scalar p = 2*ttail(r(df), abs(b/s))
            }
            post `H' ("`y'") ("`sg'") ("1") (`N1') (b) (s) (p)
        }
    }
}

postclose `H'
use "`het'", clear
label var outcome  "Outcome"
label var subgroup "Subgroup"
label var level    "Level"
label var N        "N"
label var coef     "Coef on 1.$MODE"
label var se       "Std. Err."
label var pval     "p-value"

_xlsx_export, sheet("Heterogeneity")

display as result "09_heterogeneity.do complete → Heterogeneity sheet"

