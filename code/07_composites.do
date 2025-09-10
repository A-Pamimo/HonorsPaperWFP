*******************************************************
* 07_composites.do — Composite indicators by mode
*******************************************************

version 17
set more off
do "00_utils.do"

use "$IN_FOR_TABLES", clear
_mk_label

* Composite (example)
capture drop FS_composite
gen double FS_composite = (FCS>0) + (rCSI>0) + (HHS>0)

preserve
    collapse (count) N = FS_composite (mean) FS_composite, by($MODE)
    tostring $MODE, gen(mode_str)
    replace mode_str = cond($MODE==0, "F2F", "Remote")
    order mode_str FS_composite N
    _xlsx_export, sheet("Composites")
restore

display as result "07_composites.do complete → Composites sheet"
