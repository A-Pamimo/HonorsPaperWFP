*******************************************************
* 00_utils.do — Shared helper programs
*******************************************************

version 17
set more off

capture program drop _coerce_num
program define _coerce_num
    // Force string vars in varlist to numeric (in place)
    syntax varlist
    foreach v of local varlist {
        capture confirm numeric variable `v'
        if _rc {
            quietly destring `v', replace force
        }
    }
end

capture program drop _ensure_numeric
program define _ensure_numeric, rclass
    // Create numeric temp copy for a single variable and return its name in r(src)
    syntax varname
    tempvar __src
    capture confirm numeric variable `varlist'
    if _rc {
        quietly destring `varlist', gen(`__src') force
    }
    else {
        gen double `__src' = `varlist'
    }
    return local src "`__src'"
end

capture program drop _assert_exists
program define _assert_exists
    // stop with error if variable not present
    syntax varname
    capture confirm variable `varlist'
    if _rc {
        di as error "Variable `varlist' not found."
        error 498
    }
end

capture program drop _mk_label
program define _mk_label
    // apply standard label to $MODE if not present
    capture label list modlbl
    if _rc {
        label define modlbl 0 "F2F" 1 "Remote"
    }
    capture label values $MODE modlbl
end

* ---- NEW: run command with weights only if $WGT is set ----
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

display as result "00_utils.do loaded"
