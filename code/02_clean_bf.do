*******************************************************
* 02_clean_bf.do — Prepare cleaned analytic copy (read-only input)
*******************************************************
version 17

* Load input into memory (we will NOT overwrite it on disk)
use "$IN_ANALYTIC", clear

* --- Create a separate work frame and copy dataset into it ---
cap frame drop work
frame copy default work          // copies current data into NEW frame "work"
frame change work

* Include utilities inside work frame
do "code/00_utils.do"

* ---- Modality (0=F2F, 1=Remote); derive only inside work frame ----
cap confirm var Modality_Type
if _rc {
    cap confirm var Modality
    if !_rc {
        _coerce_num Modality
        gen byte Modality_Type = Modality
    }
}
label define modlbl 0 "F2F" 1 "Remote", replace
cap label values Modality_Type modlbl

* ---------- Admin1 English label (robust) — work frame only ----------
capture confirm var admin1_en
if _rc {
    * Try plausible admin1 variables; else create empty placeholder
    local admin_candidates admin1 admin1_name admin1_en_s ADMIN1_EN ADMIN1 region_en region Region
    local found ""
    foreach v of local admin_candidates {
        capture confirm var `v'
        if !_rc {
            local found "`v'"
            continue, break
        }
    }
    if "`found'" != "" {
        clonevar admin1_en = `found'
    }
    else {
        gen str40 admin1_en = ""
    }
}
label var admin1_en "Region (Admin1, EN)"

* Save a CLEANED analytic copy to a NEW file (original input untouched)
save "$OUT_CLEAN", replace

* Return to default frame; clean up
frame change default
cap frame drop work
