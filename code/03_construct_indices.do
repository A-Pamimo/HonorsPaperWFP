*******************************************************
* 03_construct_indices.do — Build indices/derivations
*******************************************************

version 17
set more off
do "00_utils.do"

use "$OUT_CLEAN", clear

* ===== FCS =====
capture confirm variable FCS
if _rc {
    * Try to build FCS if standard components are present (capped 0..7 days)
    local comps "cereals pulses veg fruit meat fish dairy sugar oil"
    local map_cer "fcs_cereals cereal cereals"
    local map_pul "fcs_pulses pulses pulse legumes"
    local map_veg "fcs_veg veg vegetables"
    local map_fru "fcs_fruit fruit fruits"
    local map_mea "fcs_meat meat animal_protein"
    local map_fis "fcs_fish fish"
    local map_dai "fcs_dairy milk dairy"
    local map_sug "fcs_sugar sugar"
    local map_oil "fcs_oil oil fats"

    * helper: find first existing var among candidates
    tempname v_cer v_pul v_veg v_fru v_mea v_fis v_dai v_sug v_oil
    local found_any 0
    foreach k in cer pul veg fru mea fis dai sug oil {
        local chosen ""
        foreach cand of local map_`k' {
            capture confirm variable `cand'
            if !_rc & "`chosen'"=="" local chosen "`cand'"
        }
        if "`chosen'"!="" {
            local v_`k' "`chosen'"
            local found_any 1
        }
    }

    if `found_any' {
        * cap to 0..7 and compute FCS with standard WFP weights
        tempvar _cer _pul _veg _fru _mea _fis _dai _sug _oil
        foreach k in cer pul veg fru mea fis dai sug oil {
            gen double ``_`k''' = .
            capture confirm variable `v_`k''
            if !_rc {
                gen double ``_`k''' = max(0, min(7, `v_`k''))
            }
            else replace ``_`k''' = 0
        }
        gen double FCS = 2*``_cer'' + 3*``_pul'' + 1*``_veg'' + 1*``_fru'' ///
                       + 4*(``_mea'' + ``_fis'') + 4*``_dai'' + 0.5*``_sug'' + 0.5*``_oil''
    }
    else {
        gen double FCS = .
    }
}

* ===== rCSI =====
capture confirm variable rCSI
if _rc {
    local r1 "rcsi_lesspreferred lesspreferred"
    local r2 "rcsi_borrowfood borrowfood"
    local r3 "rcsi_limitportion limitportion"
    local r4 "rcsi_restrict_adults restrict_adults restrictadults"
    local r5 "rcsi_daywithout daywithout nofood dayswithout"
    local found_any 0
    foreach grp in r1 r2 r3 r4 r5 {
        local chosen ""
        foreach cand of local `grp' {
            capture confirm variable `cand'
            if !_rc & "`chosen'"=="" local chosen "`cand'"
        }
        if "`chosen'"!="" local found_any 1
        local `grp'_sel "`chosen'"
    }

    if `found_any' {
        tempvar _1 _2 _3 _4 _5
        foreach j in 1 2 3 4 5 {
            gen double ``_`j''' = 0
            if "``r`j'_sel''" != "" gen double ``_`j''' = max(0, ``r`j'_sel'')
        }
        * Standard weights: 1,2,1,3,1
        gen double rCSI = ``_1''*1 + ``_2''*2 + ``_3''*1 + ``_4''*3 + ``_5''*1
    }
    else {
        gen double rCSI = .
    }
}

* ===== HHS =====
capture confirm variable HHS
if _rc {
    * Try compute from 7 HHS items (hhs_q1..hhs_q7 or similar)
    local hhs ""
    forvalues i=1/7 {
        foreach cand in hhs_q`i' HHS`i' hhs`i' {
            capture confirm variable `cand'
            if !_rc {
                local hhs "`hhs' `cand'"
                continue, break
            }
        }
    }
    if "`hhs'" != "" {
        egen double HHS = rowtotal(`hhs')
    }
    else {
        gen double HHS = .
    }
}

* Save for tables/analysis
save "$IN_FOR_TABLES", replace
display as result "03_construct_indices.do complete → $IN_FOR_TABLES"
