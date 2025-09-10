*======================================================
* FILE: code/master.do
*======================================================

*******************************************************
* master.do — Orchestrates end-to-end pipeline
* Safe to run from ANY folder:
*   - do "C:\Users\AET816\Downloads\Research_v2\code\master.do"  (absolute)
*   - do "code/master.do"                                        (relative, from ROOT)
*   - do "master.do"                                             (from inside /code)
*******************************************************

version 17
clear all
set more off

* ---------- Resolve ROOT robustly ----------
local __F   "`c(filename)'"                          // how Stata sees this file
local __Fn  : subinstr local __F "\" "/", all        // normalize slashes

* Case A: absolute path ending with /code/master.do -> strip suffix
local __cand `"`=subinstr("`__Fn'","/code/master.do","",.)'"'
if "`__cand'" != "`__Fn'" {
    cd "`__cand'"
}
else {
    * Case B: exactly "code/master.do" (or "./code/master.do")
    if inlist("`__Fn'","code/master.do","./code/master.do",".\code\master.do","code\master.do") {
        * ROOT is current working directory
        * (we're already in ROOT if you called do "code/master.do" from ROOT)
    }
    else if inlist("`__Fn'","master.do","./master.do",".\master.do") {
        * Case C: invoked from inside /code
        capture noisily cd ".."
    }
    else {
        * Fallback: if we somehow started inside /code, go up; else stay put
        capture confirm file "master.do"
        if !_rc {
            capture noisily cd ".."
        }
    }
}

* Sanity check: require a /code folder here
capture confirm dir "code"
if _rc {
    di as error "Could not locate the project root (folder containing /code)."
    di as error "From your shell or Stata, cd to the project folder and re-run:"
    di as error "    do code/master.do"
    exit 601
}

* ---------- Standard globals ----------
global ROOT     "`c(pwd)'"
global CODE     "$ROOT/code"
global OUTDIR   "$ROOT/output"
global OUTTAB   "$ROOT/output/tables"
global OUTFIG   "$ROOT/output/figures"
global TEMPDIR  "$ROOT/temp"
global DATA     "$ROOT/data"
global IN_RAW   "$ROOT/data/raw"
global IN_CLEAN "$ROOT/data/clean"

* Main workbook (override in 00_config.do if you wish)
global OUT_XLSX "$OUTTAB/results.xlsx"

* ---------- Run setup (ALWAYS reference via $CODE) ----------
capture noisily do "$CODE/01_setup.do"

* ===== Pipeline steps (aligned to your files) =====
capture noisily do "$CODE/00_config.do"
capture noisily do "$CODE/00_utils.do"

* Switch into /code so any relative includes inside modules work
local __back = "`c(pwd)'"
cd "$CODE"

capture noisily do "02_clean_bf.do"
capture noisily do "03_construct_indices.do"
capture noisily do "04_analysis.do"
capture noisily do "05_tables.do"

* Balance
capture noisily do "06_balance.do"

* Additional outputs
capture noisily do "07_composites.do"
capture noisily do "08_indicators.do"

* Optional deeper dives
capture noisily do "09_heterogeneity.do"
capture noisily do "10_quality_checks.do"
capture noisily do "11_enumerator_robustness.do"
capture noisily do "12_module_length.do"
capture noisily do "13_lcs_variants.do"

* (If you have it) regressions
capture noisily do "14_regressions.do"

* Return to project root
cd "`__back'"

display as text "✅ Pipeline finished. Outputs in: $OUTDIR"
