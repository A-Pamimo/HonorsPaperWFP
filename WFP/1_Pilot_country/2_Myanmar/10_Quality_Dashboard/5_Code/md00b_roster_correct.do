/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - Myanmar 			   * 
*																 			   *
*  PURPOSE:  			Correct field errors for F2F Roster					   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				May 11, 2023										   *
*  LATEST UPDATE: 		Jun 05, 2023										   *
*		  																	   *
********************************************************************************

					
	** REQUIRES:	${d_raw}/Myanmar_F2F_Roster_Raw_`cdate'.csv
					
	** CREATES:		${d_temp}/Myanmar_F2F_Roster_Correct_`cdate'.dta
	
	** NOTES:		_`cdate' was removed after finishing data collection

********************************************************************************
*					PART 1: Load Roster Data and Correct Errors
*******************************************************************************/

	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${d_log}/md00b_roster_correct_`cdate'.smcl", replace
	di `cdate'
	
	* load dataset
	* ---------------	
	use "${d_raw}/Myanmar_F2F_Roster_Raw.dta", clear
	compress
	
	** check ID and drop empty vars and obs
 	ren ___parent_index	 HH_Index

	* basic quality checks and formating
	ds, has(type string) 
	** remove unnecessary blanks in string and adjust the proper cases
	local strvars "`r(varlist)'"
foreach var of local strvars {
    replace `var' = strtrim(`var')
    }
	
*************************  ADD CORRECTION LINES HERE ***************************
	
	*** 1. 0 or More Than 1 Respondent
	replace RESPYN = 1 if inlist(___index,287,568,715,2420,2065,2598,3094,3468) 
	replace RESPName = "Ma Roi Nu" 				if ___index == 715
	replace RESPName = "Daw Bawm Wang" 			if ___index == 2065
	replace RESPName = "Daw Hpaune Shawng Hoi" 	if ___index == 3094
	replace RESPName = "Daw Hkawn Pri" 			if ___index == 3468 
	replace RESPYN = 1 if ___index == 321
	
	replace RESPYN = 0 if inlist(___index,72,73,75,76,77,78)
	replace RESPYN = 0 if inlist(___index,102,103,104,105,106,107)
	replace RESPYN = 0 if inlist(___index,109,110,111,112,113,114,115,116,117)
	replace RESPYN = 0 if inlist(___index,292,293,294,295,296,297,298,299)
	replace RESPYN = 0 if inlist(___index,301,302)
	replace RESPYN = 0 if inlist(___index,304,305)
	replace RESPYN = 0 if inlist(___index,307,308,309,310,311,312,313)
	replace RESPYN = 0 if inlist(___index,745,746,747,748,749,750)
	replace RESPYN = 0 if inlist(___index,752,753,754,755)
	replace RESPYN = 0 if inlist(___index,757,758,759,760,761)
	replace RESPYN = 0 if inlist(___index,763,764,765,766)
	replace RESPYN = 0 if inlist(___index,768,769,770,771,772,773,774,775,776)
	replace RESPYN = 0 if inlist(___index,912,913,914,915,916,917)
	replace RESPYN = 0 if inlist(___index,1184,1185,1186,1187,1188)
	replace RESPYN = 0 if inlist(___index,1190,1191,1192)
	replace RESPYN = 0 if inlist(___index,1194,1195)
	replace RESPYN = 0 if inlist(___index,1219,1220,1221,1222) 
	replace RESPYN = 0 if inlist(___index,1249,1250,1251,1252)
	replace RESPYN = 0 if inlist(___index,1311,1312)
	replace RESPYN = 0 if inlist(___index,1354,1355,1356)
	replace RESPYN = 0 if ___index == 1233
	replace RESPYN = 0 if ___index == 2097
	replace RESPYN = 0 if ___index == 2597
	
	replace RESPYN = 0 if ___index == 3093
	replace RESPName = "" 	if ___index == 3093
	
	** 2. 0 or More Than 1 Head of Household
	drop if ___index == 2431
	replace PRelationHHH = 100 if inlist(___index,299,3032,983,1768,480,6,1238, ///
										 1340,667,1079,2302,3032) 
	replace PRelationHHH = 200 if inlist(___index,2162,3088,2923,3316,1132)
	replace PRelationHHH = 300 if inlist(___index,2528,3386,3312) 
	replace PRelationHHH = 400 if inlist(___index,408) 
	
	** 3. Households have different respondent gender outside and within 
	**    Roster
	replace PSex = 0 if inlist(___index,1132,956,2639,2947,356,3381,864,351,352, ///
										1746,75,78,2517) 
	replace PSex = 1 if inlist(___index,756,72,73,102,103)

	** 4. Age difference
	replace PAge = 67 if ___index == 880
	replace PAge = 38 if ___index == 887
	replace PAge = 67 if ___index == 1257
	replace PAge = 52 if ___index == 1357
	replace PAge = 42 if ___index == 1533
	replace PAge = 59 if ___index == 2209
	replace PAge = 63 if ___index == 2326
	
	** drop PIIs
	drop RESPName

	compress
	save "${d_temp}/Myanmar_F2F_Roster_Correct.dta", replace
