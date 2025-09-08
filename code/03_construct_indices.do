*******************************************************
* 03_construct_indices.do — Build FCS, rCSI, HHS on derived data
* - Works only on $OUT_CLEAN (a copy), never the original input
* - If FCS/rCSI/HHS already exist, do NOT overwrite them
*   (only fill missings from a recalculation), then rebuild categories
*******************************************************
version 17

* Load the cleaned analytic copy (NOT the original input)
use "$OUT_CLEAN", clear

* Work in a separate frame
cap frame drop work2
frame copy default work2
frame change work2

do "code/00_utils.do"

* ------------------ FCS ------------------
local fcs_all FCSStap FCSPulse FCSDairy FCSPr FCSVeg FCSFruit FCSFat FCSSugar
local fcs_present
foreach v of local fcs_all {
    capture confirm var `v'
    if !_rc local fcs_present `fcs_present' `v'
}
local fcs_n : word count `fcs_present'
if `fcs_n'==8 {
    _coerce_num `fcs_present'
    foreach x of local fcs_present {
        cap replace `x' = . if `x' < 0
        cap replace `x' = 7 if `x' > 7 & `x' != .
    }

    * Recalculate into a temp var; don't collide with existing FCS
    tempvar FCS_calc
    gen double `FCS_calc' = (FCSStap*2) + (FCSPulse*3) + (FCSDairy*4) + (FCSPr*4) ///
                          + (FCSVeg*1) + (FCSFruit*1) + (FCSFat*0.5) + (FCSSugar*0.5)

    * If FCS exists, keep it; only fill missing values from calc
    capture confirm var FCS
    if _rc {
        gen double FCS = `FCS_calc'
    }
    else {
        replace FCS = `FCS_calc' if missing(FCS)
    }
    cap label var FCS "Food Consumption Score"

    * Categories (rebuild safely)
    cap drop FCS_cat
    gen byte FCS_cat = .
    replace FCS_cat = 1 if FCS <= $FCS_CUT_POOR & FCS != .
    replace FCS_cat = 2 if FCS >  $FCS_CUT_POOR & FCS <= $FCS_CUT_BORDER
    replace FCS_cat = 3 if FCS >  $FCS_CUT_BORDER
    label define fcscat 1 "Poor" 2 "Borderline" 3 "Acceptable", replace
    label values FCS_cat fcscat
}
else {
    di as txt "Note: Missing some FCS components; FCS not (re)computed."
}

* ------------------ rCSI ------------------
local rcsi_all rCSILessQlty rCSIBorrow rCSIMealSize rCSIMealAdult rCSIMealNb
local rcsi_present
foreach v of local rcsi_all {
    capture confirm var `v'
    if !_rc local rcsi_present `rcsi_present' `v'
}
local rcsi_n : word count `rcsi_present'
if `rcsi_n'==5 {
    _coerce_num `rcsi_present'
    foreach r of local rcsi_present {
        cap replace `r' = . if `r' < 0
        cap replace `r' = 7 if `r' > 7 & `r' != .
    }

    tempvar rCSI_calc
    gen double `rCSI_calc' = (rCSILessQlty*1) + (rCSIBorrow*2) + (rCSIMealSize*1) + (rCSIMealAdult*3) + (rCSIMealNb*1)

    capture confirm var rCSI
    if _rc {
        gen double rCSI = `rCSI_calc'
    }
    else {
        replace rCSI = `rCSI_calc' if missing(rCSI)
    }
    cap label var rCSI "Reduced Coping Strategy Index"

    cap drop rCSI_cat
    gen byte rCSI_cat = .
    replace rCSI_cat = 1 if rCSI <= $RCSI_CUT1 & rCSI != .
    replace rCSI_cat = 2 if rCSI >  $RCSI_CUT1 & rCSI <= $RCSI_CUT2
    replace rCSI_cat = 3 if rCSI >= $RCSI_CUT2
    label define rcsicat 1 "Low" 2 "Medium" 3 "High", replace
    label values rCSI_cat rcsicat
}
else {
    di as txt "Note: Missing some rCSI items; rCSI not (re)computed."
}

* ------------------ HHS ------------------
* Try fallbacks for *_FR_S if main vars missing
foreach pair in "HHSNoFood HHSNoFood_FR_S" "HHSBedHung HHSBedHung_FR_S" "HHSNotEat HHSNotEat_FR_S" {
    gettoken main alt : pair
    capture confirm var `main'
    if _rc {
        capture confirm var `alt'
        if !_rc clonevar `main' = `alt'
    }
}

local hhs_all HHSNoFood HHSBedHung HHSNotEat
local hhs_present
foreach v of local hhs_all {
    capture confirm var `v'
    if !_rc local hhs_present `hhs_present' `v'
}
local hhs_n : word count `hhs_present'
if `hhs_n'==3 {
    _coerce_num `hhs_present'
    foreach h of local hhs_present {
        cap replace `h' = 0 if `h' < 0
        cap replace `h' = 2 if `h' > 2 & `h' != .
    }

    tempvar HHS_calc
    egen `HHS_calc' = rowtotal(HHSNoFood HHSBedHung HHSNotEat)

    capture confirm var HHS
    if _rc {
        gen double HHS = `HHS_calc'
    }
    else {
        replace HHS = `HHS_calc' if missing(HHS)
    }
    cap label var HHS "Household Hunger Scale"

    cap drop HHS_cat
    gen byte HHS_cat = .
    replace HHS_cat = 1 if inrange(HHS,0,1)
    replace HHS_cat = 2 if inrange(HHS,2,3)
    replace HHS_cat = 3 if inrange(HHS,4,6)
    label define hhslbl 1 "Little/No" 2 "Moderate" 3 "Severe", replace
    label values HHS_cat hhslbl
}
else {
    di as txt "Note: Missing some HHS items; HHS not (re)computed."
}

* Save indices to a NEW dataset (does not touch $OUT_CLEAN)
save "$IN_FOR_TABLES", replace

frame change default
cap frame drop work2
