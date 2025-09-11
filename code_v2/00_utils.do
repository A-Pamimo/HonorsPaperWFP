*******************************************************
* 00_utils.do — Shared helper programs
*******************************************************

version 17
set more off

* ----------------------------------------------------
* Force string vars in varlist to numeric (in place)
* ----------------------------------------------------
capture program drop _coerce_num
program define _coerce_num
    syntax varlist
    foreach v of local varlist {
        capture confirm numeric variable `v'
        if _rc {
            quietly destring `v', replace ignore(",")
        }
    }
end

* ----------------------------------------------------
* Pretty labels for mode, etc. (safe if vars missing)
* ----------------------------------------------------
capture program drop _mk_label
program define _mk_label
    capture confirm variable Modality_Type
    if !_rc {
        label define MODELBL 0 "F2F" 1 "Remote", modify
        capture label values Modality_Type MODELBL
    }
    capture confirm variable urban
    if !_rc {
        label define URBAN 0 "Rural" 1 "Urban", modify
        capture label values urban URBAN
    }
    capture confirm variable head_female
    if !_rc {
        label define HDF 0 "Male-headed" 1 "Female-headed", modify
        capture label values head_female HDF
    }
end

* ----------------------------------------------------
* _regw — run command with pweight=$WGT if defined
* ----------------------------------------------------
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

* ----------------------------------------------------
* _xlsx_export — robust Excel exporter
*   - Creates workbook/dir if missing
*   - Checks whether sheet exists and chooses replace vs create
*   - Avoids rc=198 modify collisions; falls back to timestamped workbook
* ----------------------------------------------------
capture program drop _xlsx_export
program define _xlsx_export
    version 17
    syntax , Sheet(string)

    * Choose target workbook
    local file "$OUT_XLSX"
    if "`file'" == "" local file "$OUTTAB/results.xlsx"
    if "`file'" == "" local file "../output/tables/results.xlsx"

    * Ensure output directory exists (best-effort)
    quietly {
        local base "`file'"
        local dir = substr("`base'",1, max(strrpos("`base'","/"), strrpos("`base'","\")))
        if "`dir'" != "" capture mkdir "`dir'"
    }

    * Decide whether sheet already exists
    tempname FOUND
    qui _sheet_exists, sheet("`sheet'") using("`file'")
    scalar `FOUND' = r(found)

    * If workbook doesn't exist at all, create new
    capture confirm file "`file'"
    if _rc {
        capture noisily export excel using "`file'", sheet("`sheet'") firstrow(variables) replace
        if _rc {
            capture noisily export excel using "`file'", replace
        }
        exit
    }

    * Workbook exists — write sheet with correct option
    if scalar(`FOUND')==1 {
        * Sheet exists -> replace it
        capture noisily export excel using "`file'", sheet("`sheet'", replace) firstrow(variables)
        if _rc {
            capture noisily export excel using "`file'", sheet("`sheet'") sheetreplace firstrow(variables)
        }
    }
    else {
        * Sheet missing -> create it (no modify)
        capture noisily export excel using "`file'", sheet("`sheet'") firstrow(variables) replace
    }

    * If still failing, fall back to timestamped workbook to not lose results
    if _rc {
        local base "`file'"
        local dir = substr("`base'",1, max(strrpos("`base'","/"), strrpos("`base'","\")))
        local ts : display %tcCCYYNNDD_HHMMSS clock("$S_DATE $S_TIME","DMY hms")
        local ts : subinstr local ts ":" "", all
        local alt = cond("`dir'"=="", "../output/tables/results_fallback_`ts'.xlsx", "`dir'results_fallback_`ts'.xlsx")
        di as error "⚠️  Export failed (rc=" _rc "). Writing fallback workbook: `alt'"
        capture noisily export excel using "`alt'", sheet("`sheet'") firstrow(variables) replace
    }
end

* ----------------------------------------------------
* _sheet_exists — r(found)=1 if sheet exists in workbook (default $OUT_XLSX)
* ----------------------------------------------------
capture program drop _sheet_exists
program define _sheet_exists, rclass
    syntax , Sheet(string) [USING(string)]
    local file "`using'"
    if "`file'" == "" local file "$OUT_XLSX"
    capture noisily import excel using "`file'", describe
    if _rc {
        return scalar found = 0
        exit
    }
    local sheets = r(worksheetlist)
    local found 0
    foreach s of local sheets {
        if ("`s'" == "`sheet'") local found 1
    }
    return scalar found = `found'
end

* ----------------------------------------------------
* _ensure_numeric <var> → returns r(name) = numeric var
* If <var> is string, makes numeric copy; tolerant to commas.
* ----------------------------------------------------
capture program drop _ensure_numeric
program define _ensure_numeric, rclass
    syntax varname
    tempvar _num
    capture confirm numeric variable `varlist'
    if _rc {
        capture destring `varlist', gen(`_num') ignore(",") force
        if _rc {
            gen double `_num' = real(`varlist')
        }
        return local name "`_num'"
        return local src  "`_num'"
    }
    else {
        return local name "`varlist'"
        return local src  "`varlist'"
    }
end

* ----------------------------------------------------
* End-of-file marker
* ----------------------------------------------------
display as result "00_utils.do loaded"
