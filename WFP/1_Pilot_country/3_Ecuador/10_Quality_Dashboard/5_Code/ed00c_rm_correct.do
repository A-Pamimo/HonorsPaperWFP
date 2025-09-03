/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - Ecuador 			   * 
*																 			   *
*  PURPOSE:  			Correct field errors for Remote sample				   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Jun 18, 2023										   *
*  LATEST UPDATE: 		Jun 19, 2023										   *
*		  																	   *
********************************************************************************

					
	** REQUIRES:	${d_raw}/Ecuador_RM_Household_Raw_`cdate'.csv
					
	** CREATES:		${d_temp}/Ecuador_RM_Household_Correct_`cdate'.dta
			
	** NOTES:		_`cdate' on Jul 20 when data collection finished
					
					Attempt level dataset -> Household level
					1. Best survey outcome per household
					2. Keep only the best obs for each household
					3. Drop duplicates when answered the last survey question
					4. Attrition analysis (adding listing information? or do it 
					   later)

********************************************************************************
*					PART 1: Load Household Data and Correct Errors
*******************************************************************************/
	
	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${d_log}/ed00c_rm_correct_`cdate'.smcl", replace
	di `cdate'
	
* load dataset
* ---------------	
	use "${d_raw}/Ecuador_RM_Household_Raw.dta", clear
	compress
	
	* basic quality checks and formating
	ds, has(type string) 
	** remove unnecessary blanks in string and adjust the proper cases
	local strvars "`r(varlist)'"
foreach var of local strvars {
    replace `var' = strtrim(`var')
    }

	** temp
	replace HHID = HHID_manual if mi(HHID)		// this is temporary
	drop if mi(HHID)
	
	** check duplicates
	duplicates tag HHID, generate(Dup)
	
	** Recode for best outcome - combining the consent and availability
	recode RESPpart (0=4) (1=1) (2=5) (999=6), gen(Outcome_Order)
	replace Outcome_Order = 2 if Outcome_Order == 1 & RESPAvailable == 2
	replace Outcome_Order = 3 if Outcome_Order == 1 & RESPAvailable == 0
	
	label def Outcome_L 1 "Agreed & Available" 2 "Agreed & Later" ///
						3 "Agreed & Not Available" 4 "Not answer" ///
						5 "Refused" 6 "Other"
	label val Outcome_Order Outcome_L
	
	bysort HHID: egen Survey_Outcome = min(Outcome_Order) if Dup >= 1
	replace Survey_Outcome = Outcome_Order if Dup == 0
	
	gen HH_Final = (Outcome_Order == Survey_Outcome)
	
	egen HH_TAG = tag(HHID) if HH_Final == 1
	
	replace Survey_Outcome = . if HH_TAG == 0 
	label val Survey_Outcome Outcome_L
		
	** create one consent variable 
	gen  Temp_Complete = !mi(HHIncChg)

	bysort HHID: gen Consent = inlist(Survey_Outcome,1,2,3)
	label val Consent sampleYN
	
	keep if Temp_Complete == 1
	
	** Dup 12
	drop if ___uuid == "9a887a11-4a44-413b-ac49-31a59b4125a8"
	** Dup 13 
	drop if ___uuid == "de5b4569-41c8-4cc1-99e7-79e39fc89c49"
	** Dup 14
	drop if ___uuid == "584143cf-e450-4e50-a97f-e1fb6657d6f5"
	** Dup 15
	replace HHID = "ECA0134" if ___uuid == "562086e3-aeaa-4d31-a87b-2853eab773b6"
	** Dup 16
	replace HHID = "ECA0137" if ___uuid == "74302195-85fe-43cd-a405-8a0252c108dd"
	** Dup 17
	replace HHID = "ECA0138" if ___uuid == "214d31bf-2a7c-4171-8f16-4406f3c91fcc"
	** Dup 18
	replace HHID = "ECA0139" if ___uuid == "e1a7c8e8-6073-408c-83e0-9eb6e48d03da"
	** Dup 19
	replace HHID = "ECA0140" if ___uuid == "2ac0cd14-b1f5-482e-9c91-cdcea3c90055"
	** Dup 20
	replace HHID = "ECA0141" if ___uuid == "1f08711e-4361-45f4-bd21-616e557a7097"
	** Dup 21
	replace HHID = "ECA0142" if ___uuid == "3a22ac4a-1a27-46e7-b18a-3ba3e39fbfea"
	** Dup 22
	replace HHID = "ECA0143" if ___uuid == "f9dcdbda-a8d7-4307-ba0c-20392053e52b"
	** Dup 23
	replace HHID = "ECA0146" if ___uuid == "0866a623-2a1a-4a63-af29-e292ac47f858"
	** Dup 24
	replace HHID = "ECA0147" if ___uuid == "1ad689dd-4bbc-406e-83bc-4d1786ab6ef1"
	** Dup 25
	drop if ___uuid == "126188eb-13c6-40b1-833e-9838dbe07bde"
	** Dup 26
	replace HHID = "ECA0148" if ___uuid == "7674a793-fd88-4c20-8a20-d6ae83b9ac0f"
	** Dup 27
	drop if ___uuid == "fcf8430b-cc54-4a47-937b-9327e58af103"
	** Dup 28
	replace HHID = "ECA0169" if ___uuid == "34fd760b-2568-424c-be83-90632877cbb3"
	** Dup 29
	replace HHID = "ECA0174" if ___uuid == "00bc2775-ad29-421b-88c0-cb76c882164a"
	** Dup 30
	replace HHID = "ECA0176" if ___uuid == "608ecac4-2924-4caf-8b92-e1774bb33fd3"
	** Dup 31
	replace HHID = "ECA0179" if ___uuid == "404aaf88-fbc9-4957-8924-a5e598334220"
	** Dup 32
	replace HHID = "ECA0180" if ___uuid == "9e90df8e-3b12-4d40-a805-b2250e884b40"
	drop if ___uuid == "ae383d48-5269-4d5d-8612-86d8a642b13b"
	** Dup 33
	replace HHID = "ECA0185" if ___uuid == "0b781af0-43bd-4a1b-8b62-1fc37548176e"
	** Dup 34
	replace HHID = "ECA0187" if ___uuid == "8e67a952-9e23-4f23-8e0a-8d6dc4ef4f93"
	** Dup 35
	replace HHID = "ECA0195" if ___uuid == "ef53156b-0121-4ea4-9668-5ce0771d8767"
	** Dup 36
	replace HHID = "ECA0196" if ___uuid == "6b0fc600-70d7-40aa-a5a7-611a2926d2b6"
	** Dup 37
	drop if ___uuid == "d99c3b1a-52da-40e7-8d24-5f336ff607ec"
	drop if ___uuid == "5af5e02a-e479-4e58-a88f-d7f52ce1eb39"
	** Dup 38
	replace HHID = "ECA0203" if ___uuid == "60b404cf-aceb-452a-ab25-536c4e6599b8"
	drop if ___uuid == "77fd449d-61d4-45b7-87ce-31305479f1da"
	** Dup 39
	replace HHID = "ECA0204" if ___uuid == "a1db9794-c8f5-4d62-906f-8979aa55a5c2"
	drop if ___uuid == "49fe3dfb-030f-4106-a16d-12cb6370add0"
	drop if ___uuid == "40058476-dbd1-4784-b765-bfcb0dbe9887"
	** Dup 40
	replace HHID = "ECA0206" if ___uuid == "30775b37-bc21-471d-9fbf-59860df7d185"
	** Dup 41
	drop if ___uuid == "8aae6694-dc33-4b83-9d1d-a091d4828d22"
	** Dup 42
	replace HHID = "ECA0260" if ___uuid == "c28ee94d-9059-43e5-bdbb-c01f60c9d1a3"
	** Dup 43
	replace HHID = "ECA0273" if ___uuid == "1275da75-e5d6-41fd-84a9-ae572d48f7cc"
	** Dup 44
	replace HHID = "ECA0277" if ___uuid == "19336eeb-5ec9-47cc-bd3b-ca61076a2f9c"
	** Dup 45
	replace HHID = "ECA0280" if ___uuid == "b5593bb9-a799-4dca-98b5-ee320288046a"
	** Dup 46
	replace HHID = "ECA0281" if ___uuid == "d9df7653-4f50-43a0-9c16-464c03235dee"
	** Dup 47
	replace HHID = "ECA0285" if ___uuid == "0261bd5a-9764-4a4f-a4b7-8c148b1c0e0a"
	** Dup 48
	replace HHID = "ECA0292" if ___uuid == "75c3f243-7f28-40fa-b833-384c523ceddb"
	** Dup 49
	replace HHID = "ECA0297" if ___uuid == "e35911a3-3027-4195-8a01-d6bad41c6e50"
	** Dup 50
	replace HHID = "ECA0299" if ___uuid == "a3e7c6cf-f147-4df1-9da6-43b7a44c3899"
	** Dup 51 
	drop if ___uuid == "541beaf8-8822-4649-93cc-ffb5770c9f5b"
	** Dup 52
	drop if ___uuid == "f8473b6b-a3d5-48b2-acbb-19f96afd1745"
	** Dup 53
	drop if ___uuid == "ef412da3-15b9-4b11-b9a2-61235e11fac0"
	drop if ___uuid == "85195c11-14e7-43c3-8565-42a778d58802"
	** Dup 54
	replace HHID = "ECA0310" if ___uuid == "405adea7-472c-41be-86b0-f6d071877640"
	** Dup 55
	replace HHID = "ECA0312" if ___uuid == "ff043db2-8f16-48ea-9353-20d1daf0835f"
	drop if ___uuid == "704720c9-d3f2-4a5d-b9c0-556cfe5b0b02"
	** Dup 56
	replace HHID = "ECA0314" if ___uuid == "048b0426-2fd3-4cea-818b-5857a161ce35"
	** Dup 57 
	drop if ___uuid == "3cabe55e-d0ff-4d83-83bf-a14b16c5571f"
	** Dup 58
	replace HHID = "ECA0320" if ___uuid == "84deafbb-1ab4-4778-8252-800adbf3e69e"
	** Dup 59
	replace HHID = "ECA0322" if ___uuid == "b154ffe5-d134-4f21-ba9b-3971a0cd546b"
	** Dup 60
	replace HHID = "ECA0323" if ___uuid == "f75e68a2-0e82-4cdd-80ae-6b9b9f84974f"
	** Dup 61
	replace HHID = "ECA0324" if ___uuid == "1d253cb4-a16a-4ae8-96c9-c1129e0ddbe5"
	** Dup 62
	replace HHID = "ECA0325" if ___uuid == "979f3057-98ad-4e3e-8a0e-4de2af139e20"
	** Dup 63
	replace HHID = "ECA0327" if ___uuid == "bc6a1e35-02df-47e1-a931-a20faba626bd"
	** Dup 64
	drop if ___uuid == "45263464-f11b-48e0-ba51-1973be133912"
	drop if ___uuid == "90fada10-23b4-4bc0-b7d8-3d7665ac0084"
	** Dup 65
	drop if ___uuid == "64780aaf-0e33-44de-a414-868454a802d8"
	** Dup 66
	drop if ___uuid == "a07be561-1651-473c-88ae-01384f2ce3a1"
	** Dup 67
	drop if ___uuid == "ce25bb65-a55f-4682-a3e7-3f185de3b7a4"
	** Dup 68
	drop if ___uuid == "c6d844a7-abbc-47c7-8661-928306e408d3"
	** Dup 69
	drop if ___uuid == "975dac47-1fce-4a47-956a-6ab3502d9c73"
	** Dup 70
	drop if ___uuid == "30851617-e130-44ca-8461-4a7ae4cac238"
	** Dup 71
	drop if ___uuid == "da89a425-00c5-4ddf-8307-2c4f3b55cfe1"

/*	ieduplicates HHID using "${note}/Ecuador_RM_DuplicateID_`cdate'.xlsx", 		///
					  keepvar(EnuName_Display RESPpart RESPAvailable RESPAge RESPSex HHSize) 			///
					  uniquevars(___uuid) nodaily force 
*/
	isid   HHID	// Yes
	
	mmerge HHID using "${sample}/Ecuador_Sample_Merge.dta", type(1:1) uname(S_)
	
	tab S_Assign_Modality Temp_Complete
	tab S_Phase if Temp_Complete == 1
	
	** keep only Remote sample for attrition analysis
	drop if S_Assign_Modality == 1
	gen Attrition = (_merge == 2)
	label val Attrition sampleYN
	
/* table i.S_Assign_Length i.S_Geo_Admin1 i.S_Geo_Admin3 i.S_Geo_Admin5 ///
		   i.S_Gender S_Age i.S_Marital_Status S_HHSize S_Num_Under15 	  ///
		   S_Num_Over60 i.S_Education i.S_HHDisable, 					  ///
		   by(Attrition, tests) 			///
		   title(Ecuador rCARI Validation Remote Attrition Analysis)  		///
		   export(${d_tex_tab}/Ecuador_rCARI_RM_Attrition.docx, replace) 
*/	
	drop if Attrition == 1
	
	** check ID and drop empty vars and obs
 	isid HHID	 				// check unique identifier
	// check again with the real survey data
	ren ___index HH_Index
	
*************************  ADD CORRECTION LINES HERE ***************************
	
	save "${d_temp}/Ecuador_RM_Household_Correct.dta", replace
