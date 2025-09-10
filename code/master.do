*======================================================
* FILE: code/master.do
*======================================================

*******************************************************
* master.do — Orchestrates end-to-end pipeline
* Safe to run from ANY folder:
*   do "C:\Users\AET816\Downloads\Research_v2\code\master.do"
*******************************************************

clear all
set more off

* --- Derive ROOT from this file's full path (handles \ or /) ---
local __this      "`c(filename)'"                        // full path to this do-file
local __root_a    : subinstr local __this "\code\master.do" "", all
local __root_b    : subinstr local __root_a "/code/master.do" "", all
cd "`__root_b'"

* --- Standard globals for paths ---
global ROOT    "`c(pwd)'"
global CODE    "$ROOT/code"
global OUTDIR  "$ROOT/output"
global OUTTAB  "$ROOT/output/tables"
global OUTFIG  "$ROOT/output/figures"
global TEMPDIR "$ROOT/temp"

* --- Run setup (ALWAYS reference code/ with $CODE) ---
do "$CODE/01_setup.do"

* ===== Pipeline steps (aligned to your actual files) =====
capture noisily do "$CODE/00_config.do"
capture noisily do "$CODE/00_utils.do"

* Switch into /code so relative `do "00_utils.do"` inside modules works
local __back = "`c(pwd)'"
cd "$CODE"

* Core: clean → indices → analysis → tables/balance → composites/indicators → extras
capture noisily do "02_clean_bf.do"
capture noisily do "03_construct_indices.do"
capture noisily do "04_analysis.do"
capture noisily do "05_tables.do"

* Balance
capture noisily do "06_balance.do"

* Additional outputs
capture noisily do "07_composites.do"
capture noisily do "08_indicators.do"

* Optional deeper dives (present in your repo)
capture noisily do "09_heterogeneity.do"
capture noisily do "10_quality_checks.do"
capture noisily do "11_enumerator_robustness.do"
capture noisily do "12_module_length.do"
capture noisily do "13_lcs_variants.do"

* Return to project root
cd "`__back'"

display as text "✅ Pipeline finished. Outputs in: $OUTDIR"
