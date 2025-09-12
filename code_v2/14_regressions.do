*******************************************************
* 14_regressions.do — Outcome regressions by survey mode
*   - Produces sheets: Comp_Reg, Ind_Reg, Ind_Means_Ttests
*   - Uses globals from 00_config.do:
*       $IN_FOR_TABLES (dataset with indices/indicators)
*       $MODE          (modality var; 0=F2F, 1=Remote)
*       $WGT           (optional pweight var)
*       $CLUSTVAR      (optional cluster var for vce(cluster))
*       $SUBGROUPS     (space-separated list of subgroup vars)
*******************************************************

version 17
set more off
do "00_utils.do"

* Load data
use "$IN_FOR_TABLES", clear
_mk_label

* Ensure mode is numeric/binary
capture confirm numeric variable $MODE
if _rc {
    destring $MODE, replace force
}
label define MODELBL 0 "F2F" 1 "Remote", modify
capture label values $MODE MODELBL

* Outcomes
local outcomes FCS rCSI HHS

* Optional: controls (kept blank unless you add globals)
local controls ""
capture confirm global CONTROL_VARS
if !_rc & "$CONTROL_VARS"!="" {
    local controls "$CONTROL_VARS"
}

* Helper to run regression with optional weights/clustering
capture program drop _runreg
program define _runreg, rclass
    syntax varname, on(string)
    local y `varlist'
    local rhs "`on'"
    if "`controls'" != "" {
        local rhs "`rhs' `controls'"
    }
    if "$WGT" != "" & "$CLUSTVAR" != "" {
        regress `y' `rhs' [pweight=$WGT], vce(cluster $CLUSTVAR)
    }
    else if "$WGT" != "" {
        regress `y' `rhs' [pweight=$WGT]
    }
    else if "$CLUSTVAR" != "" {
        regress `y' `rhs', vce(cluster $CLUSTVAR)
    }
    else {
        regress `y' `rhs'
    }
    * Return key stats
    return scalar b_mode   = _b[`on']
    return scalar se_mode  = _se[`on']
    return scalar N        = e(N)
    return scalar r2       = e(r2)
end

* ----------------------------
* 1) Composite regressions
* ----------------------------
tempfile comp
tempname C
postfile `C' str12 outcome double b se N r2 using "`comp'", replace
foreach y of local outcomes {
    quietly _runreg `y', on("$MODE")
    post `C' ("`y'") (r(b_mode)) (r(se_mode)) (r(N)) (r(r2))
}
postclose `C'
use "`comp'", clear
gen tstat = b/se
gen pval  = 2*ttail(N-1, abs(tstat))
order outcome b se tstat pval N r2
_xlsx_export, sheet("Comp_Reg")

* ----------------------------
* 2) Individual indicator regressions
*     (use indicators constructed in 08_indicators.do if present)
* ----------------------------
* Identify likely indicator vars: starts with ind_ or share_
ds ind_* share_*
local indvars `r(varlist)'
if "`indvars'" == "" {
    * Fallback: look for binary indicators commonly used
    ds *_bin
    local indvars `r(varlist)'
}

tempfile ind
tempname I
postfile `I' str24 var double mean_F2F mean_Remote diff t p N using "`ind'", replace

* Means by mode and t-test
preserve
collapse (mean) mean_F2F = (`indvars') if $MODE==0, cw
tempfile _f2f_
