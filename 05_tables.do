*******************************************************
* 05_tables.do — Descriptives & export to Excel
*******************************************************

version 17
set more off
do "00_utils.do"

use "$IN_FOR_TABLES", clear
_mk_label

* ---------- Unweighted ----------
preserve
    collapse (count) N = FCS (mean) FCS rCSI HHS, by($MODE)
    tostring $MODE, gen(mode_str)
    replace mode_str = cond($MODE==0, "F2F", "Remote")
    order mode_str N FCS rCSI HHS
    _xlsx_export, sheet("Descriptives_unw")
restore

* ---------- Weighted (if available) ----------
preserve
    capture confirm variable $WGT
    if !_rc & "$WGT"!="" {
        collapse (sum) N_wt = $WGT (mean) FCS rCSI HHS [pweight=$WGT], by($MODE)
        tostring $MODE, gen(mode_str)
        replace mode_str = cond($MODE==0, "F2F", "Remote")
        order mode_str N_wt FCS rCSI HHS
        _xlsx_export, sheet("Descriptives_wt")
    }
restore

display as result "05_tables.do complete → Descriptives_unw / Descriptives_wt"
