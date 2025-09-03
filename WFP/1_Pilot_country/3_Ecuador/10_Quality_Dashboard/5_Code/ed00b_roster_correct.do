/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - Ecuador 			   * 
*																 			   *
*  PURPOSE:  			Correct field errors for F2F Roster					   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Jun 18, 2023										   *
*  LATEST UPDATE: 		Jun 19, 2023										   *
*		  																	   *
********************************************************************************

					
	** REQUIRES:	${d_raw}/Ecuador_F2F_Roster_Raw_`cdate'.csv
					
	** CREATES:		${d_temp}/Ecuador_F2F_Roster_Correct_`cdate'.dta
	
	** NOTES:		_`cdate' on Jul 20 when data collection finished

********************************************************************************
*					PART 1: Load Roster Data and Correct Errors
*******************************************************************************/

	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${d_log}/ed00b_roster_correct_`cdate'.smcl", replace
	di `cdate'
	
	* load dataset
	* ---------------	
	use "${d_raw}/Ecuador_F2F_Roster_Raw.dta", clear
	compress
	
	** check ID and drop empty vars and obs
 	ren ___parent_index	 HH_Index
	
	** drop PIIs
	drop RESPName

	* basic quality checks and formating
	ds, has(type string) 
	** remove unnecessary blanks in string and adjust the proper cases
	local strvars "`r(varlist)'"
foreach var of local strvars {
    replace `var' = strtrim(`var')
    }
	
*************************  ADD CORRECTION LINES HERE ***************************
	
	** more than one respondent 
	replace RESPYN = 0 if HH_Index == 24  & ___index != 89		| ///
						  HH_Index == 68  & ___index != 295		| ///
						  HH_Index == 92  & ___index != 405		| ///
						  HH_Index == 115 & ___index != 506		| ///
						  HH_Index == 145 & ___index != 633		| ///
						  HH_Index == 160 & ___index != 678		| ///
						  HH_Index == 161 & ___index != 684		| ///
						  HH_Index == 162 & ___index != 696		| ///
						  HH_Index == 166 & ___index != 721		| ///
						  HH_Index == 167 & ___index != 724		| ///
						  HH_Index == 196 & ___index != 834		| ///
						  HH_Index == 205 & ___index != 869		| ///
						  HH_Index == 215 & ___index != 891		| ///
						  HH_Index == 247 & ___index != 1007	| ///
						  HH_Index == 262 & ___index != 1047	| ///
						  HH_Index == 263 & ___index != 1051	| ///
						  HH_Index == 284 & ___index != 1141	| ///
						  HH_Index == 329 & ___index != 1294	| ///
						  HH_Index == 351 & ___index != 1422	| ///
						  HH_Index == 380 & ___index != 1562	| ///
						  HH_Index == 384 & ___index != 1580	| ///
						  HH_Index == 387 & ___index != 1594	| ///
						  HH_Index == 418 & ___index != 1694	| ///
						  HH_Index == 419 & ___index != 1701	| ///
						  HH_Index == 422 & ___index != 1714	| ///
						  HH_Index == 433 & ___index != 1756	| ///
						  HH_Index == 467 & ___index != 1854	| ///
						  HH_Index == 475 & ___index != 1882	| ///
						  HH_Index == 477 & ___index != 1893	| ///
						  HH_Index == 523 & ___index != 2056	| ///
						  HH_Index == 555 & ___index != 2202	| ///
						  HH_Index == 556 & ___index != 2211	| ///
						  HH_Index == 560 & ___index != 2220	| ///	
						  HH_Index == 607 & ___index != 2409	| ///
						  HH_Index == 642 & ___index != 2579	| ///
						  HH_Index == 650 & ___index != 2616	| ///
						  HH_Index == 662 & ___index != 2666	| ///
						  HH_Index == 665 & ___index != 2679	| ///
						  HH_Index == 666 & ___index != 2683	| ///
						  HH_Index == 667 & ___index != 2688	| ///
						  HH_Index == 679 & ___index != 2752	| ///
						  HH_Index == 683 & ___index != 2771	| ///
						  HH_Index == 828 & ___index != 3348	| ///
						  HH_Index == 829 & ___index != 3353	| ///
						  HH_Index == 830 & ___index != 3359

	replace RESPYN = 1 if HH_Index == 24  & ___index == 89		| ///
						  HH_Index == 68  & ___index == 295		| ///
						  HH_Index == 92  & ___index == 405		| ///
						  HH_Index == 115 & ___index == 506		| ///
						  HH_Index == 145 & ___index == 633		| ///
						  HH_Index == 160 & ___index == 678		| ///
						  HH_Index == 161 & ___index == 684		| ///
						  HH_Index == 162 & ___index == 696		| ///
						  HH_Index == 166 & ___index == 721		| ///
						  HH_Index == 167 & ___index == 724		| ///
						  HH_Index == 196 & ___index == 834		| ///
						  HH_Index == 205 & ___index == 869		| ///
						  HH_Index == 215 & ___index == 891		| ///
						  HH_Index == 247 & ___index == 1007	| ///
						  HH_Index == 262 & ___index == 1047	| ///
						  HH_Index == 263 & ___index == 1051	| ///
						  HH_Index == 284 & ___index == 1141	| ///
						  HH_Index == 329 & ___index == 1294	| ///
						  HH_Index == 351 & ___index == 1422	| ///
						  HH_Index == 380 & ___index == 1562	| ///
						  HH_Index == 384 & ___index == 1580	| ///
						  HH_Index == 387 & ___index == 1594	| ///
						  HH_Index == 418 & ___index == 1694	| ///
						  HH_Index == 419 & ___index == 1701	| ///
						  HH_Index == 422 & ___index == 1714	| ///
						  HH_Index == 433 & ___index == 1756	| ///
						  HH_Index == 467 & ___index == 1854	| ///
						  HH_Index == 475 & ___index == 1882	| ///
						  HH_Index == 477 & ___index == 1893	| ///
						  HH_Index == 523 & ___index == 2056	| ///
						  HH_Index == 555 & ___index == 2202	| ///
						  HH_Index == 556 & ___index == 2211	| ///
						  HH_Index == 560 & ___index == 2220	| ///	
						  HH_Index == 607 & ___index == 2409	| ///
						  HH_Index == 642 & ___index == 2579	| ///
						  HH_Index == 650 & ___index == 2616	| ///
						  HH_Index == 662 & ___index == 2666	| ///
						  HH_Index == 665 & ___index == 2679	| ///
						  HH_Index == 666 & ___index == 2683	| ///
						  HH_Index == 667 & ___index == 2688	| ///
						  HH_Index == 679 & ___index == 2752	| ///
						  HH_Index == 683 & ___index == 2771	| ///
						  HH_Index == 828 & ___index == 3348	| ///
						  HH_Index == 829 & ___index == 3353	| ///
						  HH_Index == 830 & ___index == 3359

	** head of household
	replace PRelationHHH = . if   PRelationHHH == 100 & 				  ///
								 (HH_Index == 3   & ___index != 13		| ///
								  HH_Index == 20  & ___index != 77		| ///
								  HH_Index == 30  & ___index != 126		| ///
								  HH_Index == 32  & ___index != 140		| ///
								  HH_Index == 49  & ___index != 217		| ///
								  HH_Index == 61  & ___index != 270		| ///
								  HH_Index == 63  & ___index != 276		| ///
								  HH_Index == 116 & ___index != 509		| ///
								  HH_Index == 121 & ___index != 532		| ///
								  HH_Index == 196 & ___index != 835		| ///
								  HH_Index == 203 & ___index != 863		| ///
								  HH_Index == 205 & ___index != 869		| ///
								  HH_Index == 206 & ___index != 872		| ///
								  HH_Index == 207 & ___index != 874		| ///
								  HH_Index == 248 & ___index != 1012	| ///
								  HH_Index == 249 & ___index != 1017	| ///
								  HH_Index == 296 & ___index != 1179	| ///
								  HH_Index == 304 & ___index != 1212	| ///
								  HH_Index == 308 & ___index != 1227	| ///
								  HH_Index == 311 & ___index != 1237	| ///
								  HH_Index == 319 & ___index != 1260	| ///
								  HH_Index == 322 & ___index != 1270	| ///
								  HH_Index == 325 & ___index != 1279	| ///
								  HH_Index == 344 & ___index != 1394	| ///
								  HH_Index == 351 & ___index != 1422	| ///
								  HH_Index == 353 & ___index != 1434	| ///
								  HH_Index == 366 & ___index != 1495	| ///
								  HH_Index == 422 & ___index != 1715	| ///
								  HH_Index == 433 & ___index != 1756	| ///
								  HH_Index == 445 & ___index != 1793	| ///
								  HH_Index == 459 & ___index != 1833	| ///
								  HH_Index == 479 & ___index != 1905	| ///
								  HH_Index == 507 & ___index != 1990	| ///
								  HH_Index == 525 & ___index != 2065	| ///
								  HH_Index == 550 & ___index != 2186	| ///
								  HH_Index == 601 & ___index != 2387	| ///
								  HH_Index == 613 & ___index != 2431	| ///
								  HH_Index == 624 & ___index != 2492	| ///
								  HH_Index == 657 & ___index != 2641	| ///
								  HH_Index == 678 & ___index != 2748	| ///
								  HH_Index == 705 & ___index != 2850	| ///
								  HH_Index == 708 & ___index != 2867	| ///
								  HH_Index == 711 & ___index != 2878	| ///
								  HH_Index == 713 & ___index != 2888	| ///
								  HH_Index == 763 & ___index != 3069	| ///
								  HH_Index == 768 & ___index != 3084	| ///
								  HH_Index == 795 & ___index != 3188	| ///
								  HH_Index == 797 & ___index != 3204	| ///
								  HH_Index == 798 & ___index != 3212	| ///
								  HH_Index == 801 & ___index != 3219 	| ///
								  HH_Index == 803 & ___index != 3225	| ///
								  HH_Index == 804 & ___index != 3232	| ///
								  HH_Index == 805 & ___index != 3235	| ///
								  HH_Index == 810 & ___index != 3257	| ///
								  HH_Index == 812 & ___index != 3277	| ///
								  HH_Index == 823 & ___index != 3321	| ///
								  HH_Index == 826 & ___index != 3331	| ///
								  HH_Index == 828 & ___index != 3349)

	replace PRelationHHH = 100 if HH_Index == 3   & ___index == 13		| ///
								  HH_Index == 20  & ___index == 77		| ///
								  HH_Index == 30  & ___index == 126		| ///
								  HH_Index == 32  & ___index == 140		| ///
								  HH_Index == 49  & ___index == 217		| ///
								  HH_Index == 61  & ___index == 270		| ///
								  HH_Index == 63  & ___index == 276		| ///
								  HH_Index == 116 & ___index == 509		| ///
								  HH_Index == 121 & ___index == 532		| ///
								  HH_Index == 196 & ___index == 835		| ///
								  HH_Index == 203 & ___index == 863		| ///
								  HH_Index == 205 & ___index == 869		| ///
								  HH_Index == 206 & ___index == 872		| ///
								  HH_Index == 207 & ___index == 874		| ///
								  HH_Index == 248 & ___index == 1012	| ///
								  HH_Index == 249 & ___index == 1017	| ///
								  HH_Index == 296 & ___index == 1179	| ///
								  HH_Index == 304 & ___index == 1212	| ///
								  HH_Index == 308 & ___index == 1227	| ///
								  HH_Index == 311 & ___index == 1237	| ///
								  HH_Index == 319 & ___index == 1260	| ///
								  HH_Index == 322 & ___index == 1270	| ///
								  HH_Index == 325 & ___index == 1279	| ///
								  HH_Index == 344 & ___index == 1394	| ///
								  HH_Index == 351 & ___index == 1422	| ///
								  HH_Index == 353 & ___index == 1434	| ///
								  HH_Index == 366 & ___index == 1495	| ///
								  HH_Index == 422 & ___index == 1715	| ///
								  HH_Index == 433 & ___index == 1756	| ///
								  HH_Index == 445 & ___index == 1793	| ///
								  HH_Index == 459 & ___index == 1833	| ///
								  HH_Index == 479 & ___index == 1905	| ///
								  HH_Index == 507 & ___index == 1990	| ///
								  HH_Index == 525 & ___index == 2065	| ///
								  HH_Index == 550 & ___index == 2186	| ///
								  HH_Index == 601 & ___index == 2387	| ///
								  HH_Index == 613 & ___index == 2431	| ///
								  HH_Index == 624 & ___index == 2492	| ///
								  HH_Index == 657 & ___index == 2641	| ///
								  HH_Index == 678 & ___index == 2748	| ///
								  HH_Index == 705 & ___index == 2850	| ///
								  HH_Index == 708 & ___index == 2867	| ///
								  HH_Index == 711 & ___index == 2878	| ///
								  HH_Index == 713 & ___index == 2888	| ///
								  HH_Index == 763 & ___index == 3069	| ///
								  HH_Index == 768 & ___index == 3084	| ///
								  HH_Index == 795 & ___index == 3188	| ///
								  HH_Index == 797 & ___index == 3204	| ///
								  HH_Index == 798 & ___index == 3212	| ///
								  HH_Index == 801 & ___index == 3219 	| ///
								  HH_Index == 803 & ___index == 3225	| ///
								  HH_Index == 804 & ___index == 3232	| ///
								  HH_Index == 805 & ___index == 3235	| ///
								  HH_Index == 810 & ___index == 3257	| ///
								  HH_Index == 812 & ___index == 3277	| ///
								  HH_Index == 823 & ___index == 3321	| ///
								  HH_Index == 826 & ___index == 3331	| ///
								  HH_Index == 828 & ___index == 3349
	
	
	** Spouse to head of household
	replace PRelationHHH = .  if  PRelationHHH == 200 & 				  ///
								 (HH_Index == 3   & ___index != 14		| ///
								  HH_Index == 20  & ___index != 78		| ///
								  HH_Index == 61  & ___index != 269		| ///
								  HH_Index == 63  & ___index != 275		| ///
								  HH_Index == 196 & ___index != 834		| ///
								  HH_Index == 248 & ___index != 1011	| ///
								  HH_Index == 249 & ___index != 1016	| ///
								  HH_Index == 359 & ___index != 1466	| ///
								  HH_Index == 371 & ___index != 1526	| ///
								  HH_Index == 601 & ___index != 2386	| ///
								  HH_Index == 705 & ___index != 2849	| ///
								  HH_Index == 828 & ___index != 3348)
								  
	replace PRelationHHH = 200 if HH_Index == 3   & ___index == 14		| ///
								  HH_Index == 20  & ___index == 78		| ///
								  HH_Index == 61  & ___index == 269		| ///
								  HH_Index == 63  & ___index == 275		| ///
								  HH_Index == 196 & ___index == 834		| ///
								  HH_Index == 248 & ___index == 1011	| ///
								  HH_Index == 249 & ___index == 1016	| ///
								  HH_Index == 359 & ___index == 1466	| ///
								  HH_Index == 371 & ___index == 1526	| ///
								  HH_Index == 601 & ___index == 2386	| ///
								  HH_Index == 705 & ___index == 2849	| ///
								  HH_Index == 828 & ___index == 3348	| ///
								  HH_Index == 657 & ___index == 2642
	
	* parents with < 9 yo difference
	replace PRelationHHH  = 300 if HH_Index == 294 & ___index == 1155 
	replace PRelationHHH  = 100 if HH_Index == 294 & ___index == 1156
	replace PRelationHHH  = 700 if HH_Index == 294 & ___index == 1157
	replace PRelationHHH  = 601 if HH_Index == 294 & ___index == 1158
	replace PRelationHHH  = 601 if HH_Index == 294 & ___index == 1159
	replace PRelationHHH  = 601 if HH_Index == 294 & ___index == 1160
	replace PRelationHHH  = 300 if HH_Index == 294 & ___index == 1161
	replace PRelationHHH  = 200 if HH_Index == 294 & ___index == 1162
	replace PRelationHHH  = 300 if HH_Index == 294 & ___index == 1163
	replace PRelationHHH  = 300 if HH_Index == 294 & ___index == 1164

	replace PRelationHHH  = 300 if HH_Index == 350 & ___index == 1415
	replace PRelationHHH  = 700 if HH_Index == 350 & ___index == 1416
	replace PRelationHHH  = 100 if HH_Index == 350 & ___index == 1417
	replace PRelationHHH  = 200 if HH_Index == 350 & ___index == 1418
	replace PRelationHHH  = 300 if HH_Index == 350 & ___index == 1419
	replace PRelationHHH  = 300 if HH_Index == 350 & ___index == 1420
	replace PRelationHHH  = 300 if HH_Index == 350 & ___index == 1421
	
	replace PRelationHHH  = 300 if HH_Index == 403 & ___index == 1644
	replace PRelationHHH  = 700 if HH_Index == 403 & ___index == 1645
	replace PRelationHHH  = 100 if HH_Index == 403 & ___index == 1646
	replace PRelationHHH  = 300 if HH_Index == 403 & ___index == 1647
	replace PRelationHHH  = 300 if HH_Index == 403 & ___index == 1648
	
	replace PRelationHHH  = 300 if HH_Index == 470 & ___index == 1863
	replace PRelationHHH  = 200 if HH_Index == 470 & ___index == 1864
	replace PRelationHHH  = 100 if HH_Index == 470 & ___index == 1865
	replace PRelationHHH  = 300 if HH_Index == 470 & ___index == 1866
	replace PRelationHHH  = 300 if HH_Index == 470 & ___index == 1867
		
	replace PRelationHHH  = 300 if HH_Index == 474 & ___index == 1879
	replace PRelationHHH  = 200 if HH_Index == 474 & ___index == 1880
	replace PRelationHHH  = 100 if HH_Index == 474 & ___index == 1881
	
	replace PRelationHHH  = 300 if HH_Index == 548 & ___index == 2177
	replace PRelationHHH  = 601 if HH_Index == 548 & ___index == 2178
	replace PRelationHHH  = 200 if HH_Index == 548 & ___index == 2179
	replace PRelationHHH  = 100 if HH_Index == 548 & ___index == 2180
	
	replace PRelationHHH  = 300 if HH_Index == 651 & ___index == 2622
	replace PRelationHHH  = 100 if HH_Index == 651 & ___index == 2623
	replace PRelationHHH  = 200 if HH_Index == 651 & ___index == 2624
	replace PRelationHHH  = 300 if HH_Index == 651 & ___index == 2625

	tab PRelationHHH
	
	save "${d_temp}/Ecuador_F2F_Roster_Correct.dta", replace
