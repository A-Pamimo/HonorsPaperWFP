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
    collapse (count) N = interview_minutes (mean) mean_long = interview_minutes (sd) sd = interview_minutes, by($MODE)
    tostring $MODE, gen(mode_str)
    replace mode_str = cond($MODE==0, "F2F", "Remote")
    gen mean_short = .
    gen tstat = .
    gen pval = .
    gen str20 stat = "Interview"
    keep stat mode_str mean_long mean_short sd tstat pval N
    tempfile __time
    save `__time'
restore

* ===== Long vs short FCS/FES modules =====
tempfile __tests
postfile __h str20 stat str10 mode_str double mean_long mean_short tstat pval N using `__tests', replace

capture confirm variable FCS
local rcFCS = _rc
capture confirm variable FCS_S
local rcFCSS = _rc
if (`rcFCS'==0 & `rcFCSS'==0) {
    gen byte __hasFCS = !missing(FCS) & !missing(FCS_S)
    quietly count if __hasFCS
    if (r(N)>0) {
        quietly ttest FCS == FCS_S if __hasFCS
        post __h ("FCS") ("All") (r(mu_1)) (r(mu_2)) (r(t)) (r(p)) (r(N_1))
        levelsof $MODE if __hasFCS, local(modes)
        foreach m of local modes {
            quietly ttest FCS == FCS_S if __hasFCS & $MODE==`m'
            local modestring = cond(`m'==0, "F2F", "Remote")
            post __h ("FCS") ("`modestring'") (r(mu_1)) (r(mu_2)) (r(t)) (r(p)) (r(N_1))
        }
    }
    drop __hasFCS
}

capture confirm variable FES
local rcFES = _rc
capture confirm variable FES_S
local rcFESS = _rc
if (`rcFES'==0 & `rcFESS'==0) {
    gen byte __hasFES = !missing(FES) & !missing(FES_S)
    quietly count if __hasFES
    if (r(N)>0) {
        quietly ttest FES == FES_S if __hasFES
        post __h ("FES") ("All") (r(mu_1)) (r(mu_2)) (r(t)) (r(p)) (r(N_1))
        levelsof $MODE if __hasFES, local(modes)
        foreach m of local modes {
            quietly ttest FES == FES_S if __hasFES & $MODE==`m'
            local modestring = cond(`m'==0, "F2F", "Remote")
            post __h ("FES") ("`modestring'") (r(mu_1)) (r(mu_2)) (r(t)) (r(p)) (r(N_1))
        }
    }
    drop __hasFES
}

postclose __h
use `__tests', clear
gen sd = .
save `__tests', replace

use `__time', clear
append using `__tests'
order stat mode_str mean_long mean_short sd tstat pval N
_xlsx_export, sheet("ModuleLength")

display as result "12_module_length.do complete → ModuleLength sheet"
