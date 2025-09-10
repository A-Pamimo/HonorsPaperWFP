*******************************************************
* 11_enumerator_robustness.do — Enumerator checks
*******************************************************

version 17
set more off

do "00_utils.do"

* ---- Weighted runner (uses $WGT only if set) ----
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
* --------------------------------------------------

* Prefer the dataset with indices if it exists (FCS/rCSI/HHS), else cleaned
capture confirm file "$IN_FOR_TABLES"
if !_rc {
    use "$IN_FOR_TABLES", clear
}
else {
    use "$OUT_CLEAN", clear
}

_mk_label

* ==================================================
* 1) Detect enumerator variable (robust auto-detect)
*    - Optional manual override: $ENUMVAR (if set)
*    - Try common names
*    - Pattern search (*enum*, *interview*, *device*, *team*)
* ==================================================
local enumvar ""

* (a) Manual override if you set: global ENUMVAR "my_enum_var" in 00_config.do
if "$ENUMVAR" != "" {
    capture confirm variable $ENUMVAR
    if !_rc local enumvar "$ENUMVAR"
}

* (b) Explicit candidate names
if "`enumvar'"=="" {
    foreach cand in ///
        enum_id Enumerator enumerator enumerator_id enumerateur enumerateur_id ///
        interviewer interviewer_name interviewerid interviewer_id ///
        enum enumID enumeratorid enumeratorname enumerator_name ///
        phoneenumerator deviceid device_id team team_id ///
        enumerator_code enumcode enum_code {
        capture confirm variable `cand'
        if !_rc & "`enumvar'"=="" local enumvar "`cand'"
    }
}

* (c) Pattern-based search as a last resort
if "`enumvar'"=="" {
    quietly ds *enum* *interview* *interviewer* *enumera* *device* *team*
    local candidates `r(varlist)'
    local best ""
    local best_uc 0
    foreach v of local candidates {
        capture confirm variable `v'
        if _rc continue
        quietly count if !missing(`v')
        if r(N)==0 continue
        capture noisily levelsof `v', local(L)   // works for string or numeric
        if _rc continue
        local uc : word count `L'
        * heuristics: at least 2 enumerators and not crazy many
        if `uc'>=2 & `uc'<=200 & `uc'>`best_uc' {
            local best "`v'"
            local best_uc `uc'
        }
    }
    if "`best'"!="" local enumvar "`best'"
}

* If still nothing, write a note and exit gracefully
if "`enumvar'"=="" {
    preserve
        clear
        set obs 1
        gen note = "Enumerator variable not found; looked for common names & patterns."
        _xlsx_export, sheet("Enumerator")
    restore
    di as error "Enumerator variable not found; skipping enumerator robustness."
    exit
}

* Make sure we have a numeric enumerator id; keep a readable name too
tempvar enum_id
capture confirm string variable `enumvar'
if !_rc {
    encode `enumvar', gen(`enum_id')   // numeric with value labels = names
}
else {
    gen double `enum_id' = `enumvar'
}

* ==================================================
* 2) Enumerator summary table: N overall/by mode + means
*    (FCS/rCSI/HHS means are included when present)
* ==================================================
preserve
    tempvar __one __f2f __rem
    gen byte  __one = 1
    gen byte  __f2f = ($MODE==0) if !missing($MODE)
    replace   __f2f = 0 if missing(__f2f)
    gen byte  __rem = ($MODE==1) if !missing($MODE)
    replace   __rem = 0 if missing(__rem)

    capture confirm variable FCS
    local has_fcs = !_rc
    capture confirm variable rCSI
    local has_rcsi = !_rc
    capture confirm variable HHS
    local has_hhs = !_rc

    if `has_fcs' & `has_rcsi' & `has_hhs' {
        collapse (sum) N_all=__one N_F2F=__f2f N_Remote=__rem ///
                 (mean) FCS rCSI HHS, by(`enum_id')
    }
    else if `has_fcs' & `has_rcsi' {
        collapse (sum) N_all=__one N_F2F=__f2f N_Remote=__rem ///
                 (mean) FCS rCSI, by(`enum_id')
    }
    else if `has_fcs' {
        collapse (sum) N_all=__one N_F2F=__f2f N_Remote=__rem ///
                 (mean) FCS, by(`enum_id')
    }
    else {
        collapse (sum) N_all=__one N_F2F=__f2f N_Remote=__rem, by(`enum_id')
    }

    * human-readable name
    capture decode `enum_id', gen(enum_name)
    * If decode failed (no value label), try to carry the original string
    capture confirm string variable `enumvar'
    if !_rc {
        replace enum_name = `enumvar' if missing(enum_name)
    }

    order `enum_id' enum_name N_all N_F2F N_Remote FCS rCSI HHS
    sort N_all
    gen byte smallN = (N_all<30)

    label var `enum_id' "Enumerator ID"
    label var enum_name "Enumerator"
    label var N_all     "N (all)"
    label var N_F2F     "N F2F"
    label var N_Remote  "N Remote"
    label var smallN    "Flag: N<30"

    _xlsx_export, sheet("Enumerator")
restore

* ==================================================
* 3) FE vs No-FE comparison for key outcomes
*    (FCS, rCSI, FES, HHS when available)
* ==================================================

* Candidate outcomes for FE comparison
local outcomes FCS rCSI FES HHS
local any_outcome 0
foreach v of local outcomes {
    capture confirm variable `v'
    if !_rc local any_outcome 1
}

* If none of the outcomes are present, write a note and exit gracefully
if !`any_outcome' {
    preserve
        clear
        set obs 1
        gen note = "No key indicators found; skipping FE comparison."
        _xlsx_export, sheet("Enumerator_FE")
    restore
    display as result "11_enumerator_robustness.do complete → Enumerator sheet"
    exit
}

preserve
    tempfile fe
    capture postutil clear
    tempname H
    postfile `H' str20 outcome str20 model double N coef se pval using "`fe'", replace

    foreach y of local outcomes {
        capture confirm variable `y'
        if _rc continue

        * (a) No enumerator FE
        cap noisily _regw regress `y' i.$MODE
        if _rc {
            post `H' ("`y'") ("No FE") (.) (.) (.) (.)
        }
        else {
            scalar b = _b[1.$MODE]
            scalar s = _se[1.$MODE]
            scalar p = .
            capture confirm scalar s
            if !_rc & s>0 {
                scalar p = 2*ttail(e(df_r), abs(b/s))
            }
            post `H' ("`y'") ("No FE") (e(N)) (b) (s) (p)
        }

        * (b) With enumerator FE
        cap noisily _regw regress `y' i.$MODE i.`enum_id'
        if _rc {
            post `H' ("`y'") ("With FE") (.) (.) (.) (.)
        }
        else {
            scalar b = _b[1.$MODE]
            scalar s = _se[1.$MODE]
            scalar p = .
            capture confirm scalar s
            if !_rc & s>0 {
                scalar p = 2*ttail(e(df_r), abs(b/s))
            }
            post `H' ("`y'") ("With FE") (e(N)) (b) (s) (p)
        }
    }

    postclose `H'
    use "`fe'", clear
    label var outcome "Outcome"
    label var model   "Model"
    label var N       "N"
    label var coef    "Coef on 1.$MODE"
    label var se      "Std. Err."
    label var pval    "p-value"
    _xlsx_export, sheet("Enumerator_FE")
restore

display as result "11_enumerator_robustness.do complete → Enumerator / Enumerator_FE"
