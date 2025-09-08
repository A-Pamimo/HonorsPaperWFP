*******************************************************
* master.do — Orchestrate the BF pipeline (read-only input)
*******************************************************
version 17
clear all
set more off

* --- Make this file location-aware so paths like code/… always work ---
local this `"`c(filename)'"'
local slash "/"
if strpos("`this'","\")==0 local slash "/"
else local slash "\"
local codedir = substr("`this'", 1, strrpos("`this'","`slash'"))     // .../project/code/
local projdir = subinstr("`codedir'", "code`slash'", "", .)           // .../project/
cd "`projdir'"

* 1) Config + setup (creates folders)
do "code/00_config.do"
do "code/01_setup.do"

* Close any logs that might already be open
capture log close _all

* 2) Open a named log after setup (folder now exists)
local ts : display %tdCCYY-NN-DD date(c(current_date), "DMY")
log using "$LOGDIR/master_`ts'.log", name(master) replace text

* 3) Utilities
do "code/00_utils.do"

* 4) Cleaning (read-only on input; writes a new cleaned file)
capture noisily do "code/02_clean_bf.do"
local rc = _rc
if `rc' != 0 {
    di as error "ERROR in 02_clean_bf.do (code = " %9.0g `rc' ")"
    log close master
    exit `rc'
}

* 5) Construct indices (on cleaned copy; writes another new file)
capture noisily do "code/03_construct_indices.do"
local rc = _rc
if `rc' != 0 {
    di as error "ERROR in 03_construct_indices.do (code = " %9.0g `rc' ")"
    log close master
    exit `rc'
}

* 6) Analysis checks (read-only on derived file)
capture noisily do "code/04_analysis.do"
local rc = _rc
if `rc' != 0 {
    di as error "ERROR in 04_analysis.do (code = " %9.0g `rc' ")"
    log close master
    exit `rc'
}

* 7) Tables/exports (from derived file)
capture noisily do "code/05_tables.do"
local rc = _rc
if `rc' != 0 {
    di as error "ERROR in 05_tables.do (code = " %9.0g `rc' ")"
    log close master
    exit `rc'
}

di as result "Pipeline completed successfully (input .dta untouched)."
log close master
