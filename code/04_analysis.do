*******************************************************
* 04_analysis.do — Sanity checks and quick tabs (patched)
* - Safe display formatting (no parse errors)
* - Guards when vars are missing or all-missing
*******************************************************
version 17
use "$IN_FOR_TABLES", clear

* ---------- Means (only if variables exist) ----------
capture confirm var FCS
if !_rc {
    quietly summarize FCS, meanonly
    if r(N)>0 & r(mean)<. {
        di as txt "Mean FCS: " as res %8.2f r(mean)
    }
    else {
        di as txt "Mean FCS: " as error "NA (no non-missing observations)"
    }
}

capture confirm var rCSI
if !_rc {
    quietly summarize rCSI, meanonly
    if r(N)>0 & r(mean)<. {
        di as txt "Mean rCSI: " as res %8.2f r(mean)
    }
    else {
        di as txt "Mean rCSI: " as error "NA (no non-missing observations)"
    }
}

capture confirm var HHS
if !_rc {
    quietly summarize HHS, meanonly
    if r(N)>0 & r(mean)<. {
        di as txt "Mean HHS: " as res %8.2f r(mean)
    }
    else {
        di as txt "Mean HHS: " as error "NA (no non-missing observations)"
    }
}

* ---------- Distributions (only if variables exist) ----------
capture confirm var FCS_cat
if !_rc {
    di as txt "FCS categories:"
    tab FCS_cat
}

capture confirm var rCSI_cat
if !_rc {
    di as txt "rCSI categories:"
    tab rCSI_cat
}

capture confirm var HHS_cat
if !_rc {
    di as txt "HHS categories:"
    tab HHS_cat
}

* ---------- Modality & region coverage ----------
capture confirm var Modality_Type
if !_rc {
    di as txt "Survey mode coverage:"
    tab Modality_Type, missing
}

capture confirm var admin1_en
if !_rc {
    di as txt "Admin1 coverage:"
    tab admin1_en, missing
}

di as res "04_analysis.do completed."
