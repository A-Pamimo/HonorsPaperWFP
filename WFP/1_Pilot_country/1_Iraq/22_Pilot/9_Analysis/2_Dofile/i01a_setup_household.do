/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - Iraq 			   * 
*																 			   *
*  PURPOSE:  			Set up appended dataset for full sample				   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Mar 30, 2023										   *
*  LATEST UPDATE: 		Apr 17, 2023										   *
*		  																	   *
********************************************************************************

                    
    ** REQUIRES:	${raw_f2f}/HH_Data_vA.dta
                    ${raw_f2f}/HH_Data_vB.dta
                    
    ** CREATES:		${docs}/Iraq_F2F_Codebook.xlsx
                    ${dta}/Iraq_F2F_Household_Raw.dta
                        
    ** NOTES:		

********************************************************************************
*					PART 1: Load F2F Data and Set codebook
*******************************************************************************/
    
    cap log close 
    
    // set log
    loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
    loc cdate = subinstr(trim("`cdate'"), " " , "", .)
    log using "${logs}/i01_setup_`cdate'.smcl", replace
    di `cdate'
    
* load dataset
* ---------------	

    tempfile group_a group_b
    use "${raw_f2f}/HH_Data_vB.dta", clear
    compress
    gen Group = 2
    save `group_b'
    
    use "${raw_f2f}/HH_Data_vA.dta", clear
    compress
    gen Group = 1
    
    lab def G_l 1 "Group A" 2 "Group B"
    lab val Group G_l
    
    replace ADMIN5Name = 8 if ADMIN5Name == 1 
	// Correct data entry mistake "Hassan Sham"
    
    append using `group_b'
    
    ** check ID and drop empty vars and obs
     isid HHID	 				// check unique identifier
    missings dropvars, force 	// remove extra vars
    missings dropobs , force 	// remove empty observations

    * basic quality checks and formating
    ds, has(type string) 
    
    ** remove unnecessary blanks in string and adjust the proper cases
    local strvars "`r(varlist)'"
foreach var of local strvars {
    replace `var' = strproper(strtrim(`var'))
    }
    
    * drop PIIs
    * drop RESPName MDDWRESPName_oth name_person 
    // too long for export
    labelrename Housework_Prevent_Education_oth 	Housework_Prevent_Edu_oth	
    labelrename HHExpFAnimMeatFishEgg_GiftAid_7D	HHExpPro_GiftAid_7D
    labelrename HHExpFAnimMeatFishEgg_Purch_7D		HHExpPro_Purch_7D
    
* export current codebook
*	iecodebook export using "${docs}/Iraq_F2F_Codebook.xlsx", replace

    save "${dta}/Iraq_F2F_Household_Raw.dta", replace
    
/*	
*	check gender variables
    keep HHID RESPName RESPSex MDDWRESPNameR MDDR_Sex GENRESPNameR GEN_SexR name_person MDDWRESPName_oth MDDWSexR rCSIRESPName_oth rCSIRESPSex_oth rCSIRESPSex_oth GENRESPName_oth GENRESPSex_oth
    
    export excel using "${docs}/[TO CHECK]Iraq_F2F_Group_A_name_sex.xlsx", firstrow(variables) replace
*/

********************************************************************************
*					PART 2: Load Remote Data and Set codebook
*******************************************************************************/

* load dataset
* ---------------	

    tempfile version_b
    use "${raw_rm}/Remote_version_B_NoDup.dta", clear
    compress
    gen Version = 2
   
    save `version_b' // N = 243
    
    use "${raw_rm}/Remote_version_A_NoDup.dta", clear
    compress
    gen Version = 1
         
    lab def V_l 1 "Version A: Long Expenditure Module"  ///
				2 "Version B: Short Expenditure Module"
    lab val Version V_l
    lab var Version "Version for Expenditure Module in remote survey"
    
    append using `version_b'
    
    ** check ID and drop empty vars and obs
     isid HHID	 				// check unique identifier
    missings dropvars, force 	// remove extra vars
    missings dropobs , force 	// remove empty observations

    * basic quality checks and formating
    ds, has(type string) 
    
    ** remove unnecessary blanks in string and adjust the proper cases
    local strvars "`r(varlist)'"
	
foreach var of local strvars {
    replace `var' = strproper(strtrim(`var'))
    }
    
    ** drop PIIs
    drop HHPhNmb RESPname 
    
    * export current codebook
* 	iecodebook export using "${docs}/Iraq_RM_Codebook.xlsx", replace	
    
    * save dataset
    save "${dta}/Iraq_RM_Household_Raw.dta", replace

********************************************************************************
*				PART 3: Create merged dataset for full sample
*******************************************************************************/

    use "${dta}/Iraq_F2F_Household_Raw.dta", clear
    
    * merge Remote Answers to F2F Answers
    mmerge HHID using "${dta}/Iraq_RM_Household_Raw.dta", type(1:1) uname(r_)
    
/* 				 obs |    676
                vars |    561  (including _merge)
         ------------+---------------------------------------------------------
              _merge |    136  obs only in master data                (code==1)
                     |     86  obs only in using data                 (code==2)
                     |    454  obs both in master and using data      (code==3)
-----------------------------------------------------------------------------*/
    
    * save dataset
    save "${dta}/Iraq_Full_Household_Raw.dta", replace
	
* End of dofile
