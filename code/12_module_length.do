*******************************************************
* 12_module_length.do — Interview/module timing
*******************************************************

version 17
set more off
do "00_utils.do"

use "$OUT_CLEAN", clear
_mk_label

* ===== Time conversion guards =====
capture confirm variable starttime
if _rc {
    capture confirm variable starttime_raw
    if !_rc {
        gen double starttime = clock(starttime_raw, "YMDhms")
        format starttime %tc
    }
}
capture confirm variable endtime
if _rc {
    capture confirm variable endtime_raw
    if !_rc {
        gen double endtime = clock(endtime_raw, "YMDhms")
        format endtime %tc
    }
}
capture confirm variable interview_minutes
if _rc {
    capture confirm variable starttime
    capture confirm variable endtime
    if !_rc {
        gen double interview_minutes = (endtime - starttime) / 60000
    }
    else {
        gen double interview_minutes = .
    }
}

preserve
    collapse (count) N = interview_minutes (mean) mean = interview_minutes (sd) sd = interview_minutes, by($MODE)
    tostring $MODE, gen(mode_str)
    replace mode_str = cond($MODE==0, "F2F", "Remote")
    order mode_str mean sd N
    _xlsx_export, sheet("ModuleLength")
restore

display as result "12_module_length.do complete → ModuleLength sheet"
