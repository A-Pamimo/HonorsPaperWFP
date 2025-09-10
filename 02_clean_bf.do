*******************************************************
* 02_clean_bf.do — Clean Burkina Faso listing/survey
*******************************************************

version 17
set more off

do "00_utils.do"

* ---- NEW: run command with weights only if $WGT is set (helper, safe to keep) ----
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
* -----------------------------------------------------------

* (These are harmless if duplicated across files.)
capture program drop _xlsx_export
program define _xlsx_export
    // Export current dataset to Excel sheet, preserving other sheets
    // Usage: _xlsx_export , sheet("SheetName")
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

capture program drop _sheet_exists
program define _sheet_exists, rclass
    // Return r(found)=1 if sheet exists in $OUT_XLSX, else 0
    syntax , Sheet(string)
    tempfile __s
    capture noisily import excel using "$OUT_XLSX", describe clear
    if _rc {
        return scalar found = 0
        exit
    }
    local sheets = r(worksheetlist)
    local found 0
    foreach s of local sheets {
        if "`s'" == "`sheet'" local found 1
    }
    return scalar found = `found'
end

* ----------------------------------------------------
* 1) Load the best available input
* ----------------------------------------------------
local _loaded 0
local __src ""

capture confirm file "$IN_ANALYTIC"
if (!_rc) & (`_loaded'==0) {
    use "$IN_ANALYTIC", clear
    local _loaded = 1
    local __src "IN_ANALYTIC"
}

if (`_loaded'==0) {
    capture confirm file "../data/clean/Complete_BF_Household_Analysis.dta"
    if !_rc {
        use "../data/clean/Complete_BF_Household_Analysis.dta", clear
        local _loaded = 1
        local __src "canonical ../data/clean/Complete_BF_Household_Analysis.dta"
    }
}

if (`_loaded'==0) {
    capture confirm file "$OUT_CLEAN"
    if !_rc {
        use "$OUT_CLEAN", clear
        local _loaded = 1
        local __src "OUT_CLEAN"
    }
}

if (`_loaded'==0) {
    di as error "No input data found:"
    di as error "  - Set $IN_ANALYTIC to your analytic .dta, OR"
    di as error "  - Place ../data/clean/Complete_BF_Household_Analysis.dta"
    di as error "  - Or provide an existing $OUT_CLEAN"
    error 498
}

display as result "Loaded source: `__src'"

* ----------------------------------------------------
* 2) Ensure Modality_Type exists and is labeled
* ----------------------------------------------------
capture confirm variable Modality_Type
if _rc {
    capture confirm variable Modality
    if !_rc gen byte Modality_Type = Modality
}
capture confirm variable Modality_Type
if !_rc {
    label define modlbl 0 "F2F" 1 "Remote", replace
    label values Modality_Type modlbl
}

* ----------------------------------------------------
* 3) Harmonise essential variables if present (no-ops if missing)
* ----------------------------------------------------
capture confirm variable hh_size
if !_rc & _N {
    capture drop hhsize
    gen hhsize = hh_size
}

capture confirm variable headsex
if !_rc & _N {
    capture drop head_female
    gen byte head_female = (headsex==2) if !missing(headsex)
}

capture confirm variable headage
if !_rc & _N {
    capture drop head_age
    gen head_age = headage
}

capture confirm variable headeduc
if !_rc & _N {
    capture drop educ_head
    gen educ_head = headeduc
}

* ----------------------------------------------------
* 3b) NEW — Ensure household id (hh_id) exists
*      - Pick first available candidate, coerce to trimmed string
*      - If none exist, create a pseudo-id from row number (QC will still check)
* ----------------------------------------------------
local hh_candidates ///
    "hh_id hhid household_id householdid hhcode hh_code id_hh idhh HHID household HHkey HHKey key KEY uuid UID uid respondent_id resp_id"

local hh_src ""
foreach c of local hh_candidates {
    capture confirm variable `c'
    if !_rc & "`hh_src'"=="" local hh_src "`c'"
}

capture drop hh_id
if "`hh_src'" != "" {
    capture confirm numeric variable `hh_src'
    if _rc {
        gen str64 hh_id = trim(`hh_src')
    }
    else {
        tostring `hh_src', gen(hh_id) usedisplayformat replace
        replace hh_id = trim(hh_id)
    }
}
else {
    gen str20 hh_id = string(_n)
}
label var hh_id "Household ID (derived/coerced)"

* ----------------------------------------------------
* 4) Placeholders if absent (keep pipeline robust)
* ----------------------------------------------------
capture confirm variable urban
if _rc gen byte urban = .

capture confirm variable poor_pre
if _rc gen byte poor_pre = .

capture confirm variable shock_any
if _rc gen byte shock_any = .

* ----------------------------------------------------
* 5) Save cleaned
* ----------------------------------------------------
save "$OUT_CLEAN", replace
display as result "02_clean_bf.do complete → $OUT_CLEAN"
