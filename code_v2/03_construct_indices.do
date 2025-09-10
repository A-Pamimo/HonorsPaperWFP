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
                replace ``_`k''' = max(0, min(7, `v_`k''))
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

* ===== LCS =====
capture confirm variable LCS
if _rc {
    local stress "Lcs_stress_DomAsset Lcs_stress_HealthEdu Lcs_stress_Saving Lcs_stress_BorrowCash LcsEN_stress_DomAsset LcsEN_stress_HealthEdu LcsEN_stress_Saving LcsEN_stress_BorrowCash"
    local crisis "Lcs_crisis_ProdAssets Lcs_crisis_DomMigration Lcs_crisis_ChildWork LcsEN_crisis_ProdAssets LcsEN_crisis_DomMigration LcsEN_crisis_ChildWork"
    local emergency "Lcs_em_ResAsset Lcs_em_Begged Lcs_em_FemAnimal LcsEN_em_ResAsset LcsEN_em_Begged LcsEN_em_FemAnimal"
    gen byte LCS = 0
    local found_any 0
    foreach v of local stress {
        capture confirm variable `v'
        if !_rc {
            replace LCS = max(LCS, 1*(`v'==1)) if !missing(`v')
            local found_any 1
        }
    }
    foreach v of local crisis {
        capture confirm variable `v'
        if !_rc {
            replace LCS = max(LCS, 2*(`v'==1)) if !missing(`v')
            local found_any 1
        }
    }
    foreach v of local emergency {
        capture confirm variable `v'
        if !_rc {
            replace LCS = max(LCS, 3*(`v'==1)) if !missing(`v')
            local found_any 1
        }
    }
    if !`found_any' {
        replace LCS = .
    }
}

* ===== FES =====
capture confirm variable FES
if _rc {
    local cand "FES CARI_FES_Raw FES_Raw FoodExpShare food_exp_share"
    local chosen ""
    foreach v of local cand {
        capture confirm variable `v'
        if !_rc & "`chosen'"=="" local chosen "`v'"
    }
    if "`chosen'" != "" {
        gen double FES = `chosen'
    }
    else {
        local food_cand "food_exp foodexpenditure FoodExp"
        local tot_cand "total_exp totalexpenditure exp_total"
        local food_var ""
        local tot_var ""
        foreach v of local food_cand {
            capture confirm variable `v'
            if !_rc & "`food_var'"=="" local food_var "`v'"
        }
        foreach v of local tot_cand {
            capture confirm variable `v'
            if !_rc & "`tot_var'"=="" local tot_var "`v'"
        }
        if "`food_var'"!="" & "`tot_var'"!="" {
            gen double FES = 100*`food_var'/`tot_var'
        }
        else gen double FES = .
    }
}

* ===== income =====
capture confirm variable income
if _rc {
    local cand "Income_Recode_Cat Income_Recode Income_3pt HHIncome_3pt income"
    local chosen ""
    foreach v of local cand {
        capture confirm variable `v'
        if !_rc & "`chosen'"=="" local chosen "`v'"
    }
    if "`chosen'"!="" {
        gen double income = `chosen'
    }
    else gen double income = .
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

* ===== FES =====
capture confirm variable FES
if _rc {
    local food_exp_vars "exp_food food_exp foodexpenditure food_expenses"
    local tot_exp_vars  "exp_total total_exp total_expenditure total_expenses exp_tot"
    local fvar ""
    local tvar ""
    foreach v of local food_exp_vars {
        capture confirm variable `v'
        if !_rc & "`fvar'"=="" local fvar "`v'"
    }
    foreach v of local tot_exp_vars {
        capture confirm variable `v'
        if !_rc & "`tvar'"=="" local tvar "`v'"
    }
    if "`fvar'"!="" & "`tvar'"!="" {
        gen double FES = 100*(`fvar'/`tvar')
    }
    else {
        gen double FES = .
    }
}

* ===== LCS =====
capture confirm variable LCS
if _rc {
    local stress   "lcs_stress1 lcs_stress2 lcs_stress3 stress1 stress2 stress3"
    local crisis   "lcs_crisis1 lcs_crisis2 lcs_crisis3 crisis1 crisis2 crisis3"
    local emergency "lcs_emerg1 lcs_emergency1 lcs_emergency2 lcs_emergency3 emerg1 emerg2 emerg3"
    local stress_vars   ""
    local crisis_vars   ""
    local emergency_vars ""
    foreach v of local stress {
        capture confirm variable `v'
        if !_rc local stress_vars "`stress_vars' `v'"
    }
    foreach v of local crisis {
        capture confirm variable `v'
        if !_rc local crisis_vars "`crisis_vars' `v'"
    }
    foreach v of local emergency {
        capture confirm variable `v'
        if !_rc local emergency_vars "`emergency_vars' `v'"
    }
    egen byte _stress_any = rowmax(`stress_vars')
    egen byte _crisis_any = rowmax(`crisis_vars')
    egen byte _emerg_any  = rowmax(`emergency_vars')
    replace _stress_any = 0 if missing(_stress_any)
    replace _crisis_any = 0 if missing(_crisis_any)
    replace _emerg_any  = 0 if missing(_emerg_any)
    gen byte LCS = 0
    replace LCS = max(LCS,1) if _stress_any
    replace LCS = max(LCS,2) if _crisis_any
    replace LCS = max(LCS,3) if _emerg_any
    drop _stress_any _crisis_any _emerg_any
}

* ===== Income source & change =====
capture confirm variable income_source
if _rc {
    local src_cands "income_source inc_source main_income_source incomesrc"
    local chosen ""
    foreach v of local src_cands {
        capture confirm variable `v'
        if !_rc & "`chosen'"=="" local chosen "`v'"
    }
    if "`chosen'"!="" {
        quietly _ensure_numeric `chosen'
        local tmp `r(src)'
        rename `tmp' income_source
    }
    else gen double income_source = .
}

capture confirm variable income_change
if _rc {
    local chg_cands "income_change inc_change main_income_change incomechg"
    local chosen ""
    foreach v of local chg_cands {
        capture confirm variable `v'
        if !_rc & "`chosen'"=="" local chosen "`v'"
    }
    if "`chosen'"!="" {
        quietly _ensure_numeric `chosen'
        local tmp `r(src)'
        rename `tmp' income_change
    }
    else gen double income_change = .
}

* ===== CARI and rCARI =====
* rCSI categories
gen byte rCSI_cat = .
replace rCSI_cat = 1 if rCSI <=3
replace rCSI_cat = 2 if rCSI>3  & rCSI<=9
replace rCSI_cat = 3 if rCSI>9  & rCSI<=18
replace rCSI_cat = 4 if rCSI>18

* Food consumption phase from FCS and rCSI
gen byte FC_phase = .
replace FC_phase = 4 if FCS<=21 | rCSI_cat==4
replace FC_phase = 3 if FC_phase==. & (FCS<=35 | rCSI_cat==3)
replace FC_phase = 2 if FC_phase==. & rCSI_cat==2
replace FC_phase = 1 if FC_phase==. & rCSI_cat==1

* FES categories
gen byte FES_cat = .
replace FES_cat = 1 if FES<=50
replace FES_cat = 2 if FES>50 & FES<=65
replace FES_cat = 3 if FES>65

* LCS phase (1..4)
gen byte LCS_phase = .
replace LCS_phase = LCS + 1 if !missing(LCS)

* HHS phase for CARI
gen byte HHS_phase = .
replace HHS_phase = 1 if HHS<=1
replace HHS_phase = 3 if HHS>1 & HHS<=3
replace HHS_phase = 4 if HHS>3

* Income source/change phases (1..4)
gen byte IncSrc_phase = income_source
gen byte IncChg_phase = income_change

* Economic vulnerability components
egen byte eco_f2f = rowmax(FES_cat LCS_phase)
egen byte eco_remote = rowmax(FES_cat LCS_phase IncSrc_phase IncChg_phase)

* Final CARI/rCARI
egen byte CARI = rowmax(FC_phase eco_f2f HHS_phase)
egen byte rCARI = rowmax(FC_phase eco_remote)

* Save for tables/analysis
save "$IN_FOR_TABLES", replace
display as result "03_construct_indices.do complete → $IN_FOR_TABLES"
