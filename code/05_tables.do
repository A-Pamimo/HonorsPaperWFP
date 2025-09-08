*******************************************************
* 05_tables.do — Export tables to Excel (multi-sheet safe)
* - Read-only on $IN_FOR_TABLES
* - Means by modality via by: running sums (no egen/collapse)
* - Category shares via contract/fillin + by: sum (no egen)
* - Writes all sheets to one workbook: only FIRST uses replace
*******************************************************
version 17
use "$IN_FOR_TABLES", clear

* Ensure Modality_Type exists
capture confirm var Modality_Type
if _rc {
    di as error "Modality_Type not found; cannot produce by-mode tables."
    exit 459
}

* Workbook path (one file, many sheets)
local xlsx "$OUT_XLSX"

* Clean any leftovers (in memory only)
capture drop _calc_*
capture drop N mean_FCS mean_rCSI mean_HHS

* =====================================================
* 1) Means by modality WITHOUT collapse/egen
*    - N = total rows per mode
*    - Means = sum(non-missing)/count(non-missing)
* =====================================================
preserve
sort Modality_Type
bys Modality_Type: gen long _calc_N = _N

local keepvars "Modality_Type _calc_N"

foreach v in FCS rCSI HHS {
    capture confirm var `v'
    if !_rc {
        * ensure numeric source; create a numeric copy if needed
        local src `v'
        capture confirm numeric variable `v'
        if _rc {
            capture drop _calc_`v'_num
            destring `v', gen(_calc_`v'_num) force
            local src _calc_`v'_num
        }

        * running counts/sums by mode
        capture drop _calc_`v'_nonmiss _calc_`v'_val _calc_`v'_N _calc_`v'_sum
        gen byte   _calc_`v'_nonmiss = !missing(`src')
        gen double _calc_`v'_val     = cond(missing(`src'), 0, `src')

        by Modality_Type: gen long   _calc_`v'_N   = sum(_calc_`v'_nonmiss)
        by Modality_Type: gen double _calc_`v'_sum = sum(_calc_`v'_val)
        by Modality_Type: replace _calc_`v'_N   = _calc_`v'_N[_N]
        by Modality_Type: replace _calc_`v'_sum = _calc_`v'_sum[_N]

        capture drop mean_`v'
        gen double mean_`v' = _calc_`v'_sum / _calc_`v'_N if _calc_`v'_N > 0

        local keepvars `keepvars' mean_`v'
    }
}

* one row per modality; guaranteed columns
bys Modality_Type: keep if _n==_N
rename _calc_N N
local keepvars : subinstr local keepvars "_calc_N" "N", all
keep `keepvars'
foreach c in mean_FCS mean_rCSI mean_HHS {
    capture confirm var `c'
    if _rc gen double `c' = .
}
order Modality_Type N mean_FCS mean_rCSI mean_HHS

* FIRST sheet: create/overwrite workbook
export excel using "`xlsx'", sheet("by_mode_means") firstrow(variables) replace
restore

* =====================================================
* 2) Category shares by modality (FCS) — drop extras before reshape
* =====================================================
capture confirm var FCS_cat
if !_rc {
    preserve
    capture drop _calc_*
    keep Modality_Type FCS_cat
    keep if !missing(Modality_Type, FCS_cat)
    contract Modality_Type FCS_cat
    fillin Modality_Type FCS_cat
    recode _freq .=0

    sort Modality_Type FCS_cat
    by Modality_Type: gen double _calc_tot = sum(_freq)
    by Modality_Type: replace _calc_tot = _calc_tot[_N]

    gen double share = cond(_calc_tot>0, 100 * _freq / _calc_tot, .)
    keep Modality_Type FCS_cat share
    reshape wide share, i(Modality_Type) j(FCS_cat)

    capture confirm var share1
    if !_rc rename share1 FCS_Poor
    capture confirm var share2
    if !_rc rename share2 FCS_Borderline
    capture confirm var share3
    if !_rc rename share3 FCS_Acceptable

    * Subsequent sheet: replace only the sheet, not the file
    export excel using "`xlsx'", sheet("FCS_shares") firstrow(variables) sheetreplace
    restore
}

* =====================================================
* 3) Category shares by modality (rCSI)
* =====================================================
capture confirm var rCSI_cat
if !_rc {
    preserve
    capture drop _calc_*
    keep Modality_Type rCSI_cat
    keep if !missing(Modality_Type, rCSI_cat)
    contract Modality_Type rCSI_cat
    fillin Modality_Type rCSI_cat
    recode _freq .=0

    sort Modality_Type rCSI_cat
    by Modality_Type: gen double _calc_tot = sum(_freq)
    by Modality_Type: replace _calc_tot = _calc_tot[_N]

    gen double share = cond(_calc_tot>0, 100 * _freq / _calc_tot, .)
    keep Modality_Type rCSI_cat share
    reshape wide share, i(Modality_Type) j(rCSI_cat)

    capture confirm var share1
    if !_rc rename share1 rCSI_Low
    capture confirm var share2
    if !_rc rename share2 rCSI_Medium
    capture confirm var share3
    if !_rc rename share3 rCSI_High

    export excel using "`xlsx'", sheet("rCSI_shares") firstrow(variables) sheetreplace
    restore
}

* =====================================================
* 4) Category shares by modality (HHS)
* =====================================================
capture confirm var HHS_cat
if !_rc {
    preserve
    capture drop _calc_*
    keep Modality_Type HHS_cat
    keep if !missing(Modality_Type, HHS_cat)
    contract Modality_Type HHS_cat
    fillin Modality_Type HHS_cat
    recode _freq .=0

    sort Modality_Type HHS_cat
    by Modality_Type: gen double _calc_tot = sum(_freq)
    by Modality_Type: replace _calc_tot = _calc_tot[_N]

    gen double share = cond(_calc_tot>0, 100 * _freq / _calc_tot, .)
    keep Modality_Type HHS_cat share
    reshape wide share, i(Modality_Type) j(HHS_cat)

    capture confirm var share1
    if !_rc rename share1 HHS_LittleNo
    capture confirm var share2
    if !_rc rename share2 HHS_Moderate
    capture confirm var share3
    if !_rc rename share3 HHS_Severe

    export excel using "`xlsx'", sheet("HHS_shares") firstrow(variables) sheetreplace
    restore
}

di as res "Tables exported (where indicators available) to: `xlsx'"
