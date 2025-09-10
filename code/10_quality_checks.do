*******************************************************
* 10_quality_checks.do — Data QC (dups, ranges, ids)
*******************************************************

version 17
set more off
do "00_utils.do"

* Helpers (safe if duplicated)
capture program drop _regw
program define _regw
    version 17
    syntax anything
    if "$WGT" != "" {
        `anything' [pweight=$WGT]
    }
    else {
        `anything'
    }
end

capture program drop _xlsx_export
program define _xlsx_export
    syntax , Sheet(string)
    local file "$OUT_XLSX"
    capture confirm file "`file'"
    if _rc {
        export excel using "`file'", sheet("`sheet'") firstrow(variables) replace
    }
    else {
        export excel using "`file'", sheet("`sheet'", replace) firstrow(variables)
    }
end

use "$OUT_CLEAN", clear
_mk_label

tempfile qc
capture postutil clear
tempname H
postfile `H' str40 check str8 status str200 detail using "`qc'", replace

local fail 0

* ----------------------------------------------------
* ID checks — derive hh_id if missing; fail only if no candidate or duplicates
* ----------------------------------------------------
local hh_candidates ///
    "hh_id hhid household_id householdid hhcode hh_code id_hh idhh HHID household HHkey HHKey key KEY uuid UID uid respondent_id resp_id"

* Try to ensure hh_id exists
capture confirm variable hh_id
if _rc {
    local hh_src ""
    foreach c of local hh_candidates {
        capture confirm variable `c'
        if !_rc & "`hh_src'"=="" local hh_src "`c'"
    }
    if "`hh_src'" != "" {
        capture confirm numeric variable `hh_src'
        if _rc {
            gen str64 hh_id = trim(`hh_src')
        }
        else {
            tostring `hh_src', gen(hh_id) usedisplayformat replace
            replace hh_id = trim(hh_id)
        }
        post `H' ("hh_id derived") ("OK") ("Created from `hh_src'")
    }
    else {
        post `H' ("hh_id exists") ("FAIL") ("No candidate among: `hh_candidates'")
        local fail = `fail' + 1
    }
}
else {
    post `H' ("hh_id exists") ("OK") ("Found variable")
}

* If hh_id exists now, check duplicates
capture confirm variable hh_id
if !_rc {
    quietly duplicates report hh_id
    if r(N)>r(unique) {
        post `H' ("hh_id duplicates") ("FAIL") ("Duplicates detected")
        local fail = `fail' + 1
    }
    else {
        post `H' ("hh_id duplicates") ("OK") ("No duplicates")
    }
}

* ----------------------------------------------------
* Mode variable exists & is binary 0/1
* ----------------------------------------------------
capture confirm variable $MODE
if _rc {
    post `H' ("Mode variable") ("FAIL") ("$MODE missing")
    local fail = `fail' + 1
}
else {
    quietly levelsof $MODE, local(modes)
    if strpos("`modes'","0") & strpos("`modes'","1") {
        post `H' ("Mode values") ("OK") ("Found 0 and 1: `modes'")
    }
    else {
        post `H' ("Mode values") ("FAIL") ("Expected 0/1, got: `modes'")
        local fail = `fail' + 1
    }
}

* ----------------------------------------------------
* Item nonresponse rates by modality; flag high-missing variables
* ----------------------------------------------------
capture confirm variable $MODE
if !_rc {
    local miss_thresh 0.2
    ds hh_id $MODE, not
    foreach v of varlist `r(varlist)' {
        foreach m in 0 1 {
            quietly count if $MODE==`m'
            local N`m' = r(N)
            quietly count if missing(`v') & $MODE==`m'
            local miss`m' = cond(`N`m''>0, r(N)/`N`m'', .)
        }
        local maxmiss = max(`miss0',`miss1')
        if (`maxmiss' >= `miss_thresh') {
            local detail "F2F=`=round(`miss0'*100,0.1)'% Remote=`=round(`miss1'*100,0.1)'%"
            post `H' ("`v' missing") ("WARN") ("`detail'")
        }
    }
}

* ----------------------------------------------------
* Numeric heaping tests (proportion multiples of 5)
* ----------------------------------------------------
local heap_vars head_age hhsize
foreach v of local heap_vars {
    capture confirm numeric variable `v'
    if _rc {
        post `H' ("`v' exists") ("WARN") ("Variable not found")
    }
    else {
        quietly count if !missing(`v')
        local N = r(N)
        quietly count if mod(`v',5)==0 & !missing(`v')
        local prop = cond(`N'>0, r(N)/`N', .)
        local detail "`=round(`prop'*100,0.1)'% multiples of 5"
        local status = cond(`prop'>=0.2,"WARN","OK")
        post `H' ("`v' heaping") ("`status'") ("`detail'")
    }
}

* ----------------------------------------------------
* Interview duration distribution (mean & percentiles)
* ----------------------------------------------------
capture confirm numeric variable interview_minutes
if _rc {
    post `H' ("interview_minutes exists") ("WARN") ("Variable not found")
}
else {
    quietly summarize interview_minutes, detail
    local detail "mean=`=round(r(mean),0.1)' p25=`=round(r(p25),0.1)' p50=`=round(r(p50),0.1)' p75=`=round(r(p75),0.1)'"
    post `H' ("interview_minutes dist") ("OK") ("`detail'")
}

* ----------------------------------------------------
* Indices existence & crude range checks (WARNs)
* ----------------------------------------------------
foreach v in FCS rCSI HHS {
    capture confirm variable `v'
    if _rc {
        post `H' ("`v' exists") ("WARN") ("Not found; will be missing if used")
    }
    else {
        post `H' ("`v' exists") ("OK") ("Found")
        quietly summarize `v'
        if ("`v'"=="FCS") & (r(min)<0 | r(max)>112) {
            post `H' ("FCS range") ("WARN") ("Observed ["+string(r(min))+", "+string(r(max))+"] expected ~[0,112]")
        }
        if ("`v'"=="rCSI") & (r(min)<0) {
            post `H' ("rCSI range") ("WARN") ("Observed min "+string(r(min))+", expected >=0")
        }
        if ("`v'"=="HHS") & (r(min)<0 | r(max)>6) {
            post `H' ("HHS range") ("WARN") ("Observed ["+string(r(min))+", "+string(r(max))+"] expected ~[0,6]")
        }
    }
}

postclose `H'
use "`qc'", clear
_xlsx_export, sheet("QualityChecks")

if `fail' > 0 {
    di as error "Critical quality checks failed (`fail'). See QualityChecks sheet."
    error 498
}
