********************************************************************************
*					PART 1: Set up Empowerment datasets
*******************************************************************************/
	
* 	set up dataset for Gender Empowerment Scale
	use "${dta}/Iraq_F2F_Household_Analysis.dta", clear
	sum  $out_empower
	drop $out_mdd $out_rcsi
	
*	gender variables
	tab RESPSex  GEN_SexR	// should be of the same respondents
/*	Sex of the | Sex of the respondent
	respondent |    Female       Male |     Total
	-----------+----------------------+----------
		Female |       165         21 |       186 
		  Male |        75        170 |       245 
	-----------+----------------------+----------
		 Total |       240        191 |       431 	/!\ 96 diff
*/	

	tab GEN_SexR GENRESPSex_oth	// respondents of diff gender for sections
/*	Sex of the | Sex of the respondent
	respondent |    Female       Male |     Total
	-----------+----------------------+----------
		Female |        80        146 |       226 
		  Male |       163         22 |       185 	/!\ 102 same
	-----------+----------------------+----------
		 Total |       243        168 |       411 
*/	
	tab RESPSex	 GENRESPSex_oth
/*	Sex of the | Sex of the respondent
	respondent |    Female       Male |     Total
	-----------+----------------------+----------
		Female |        11        162 |       173 
		  Male |       232          6 |       238 
	-----------+----------------------+----------
		 Total |       243        168 |       411 
*/
	
	** follow the same method as the MDD sections
	drop if RESPSex  != GEN_SexR 		// 255 observations deleted
	drop if GEN_SexR == GENRESPSex_oth	// 14 observations deleted 

	// now we have n = 306 who answered both of the empowerment sections
	// of different gender while keep the same gender as the main respondent in the first section
	
	save "${temp}/Iraq_GES_F2F_Raw.dta", replace
		
	ren Income_No_PermissionR 		 	GES_1
	ren Own_Decisions_MoneyR 		 	GES_2
	ren Own_Decisions_MedicalR 		 	GES_3
	ren Own_Decisions_RelativesR 	 	GES_4
	ren Own_Decisions_FriendsR 			GES_5
	ren Own_Bank_AccountR 			 	GES_6
	ren Have_Money_SavedR 				GES_7
	ren Own_PropertyR 				 	GES_8
	ren Own_MobileR 					GES_9
	ren You_Decide_WorkR 			 	GES_10
	ren Took_Money_No_PermissionR 	 	GES_11
	ren Permission_Local_EventR 	 	GES_12
	ren Permission_MarketR 			 	GES_13
	ren Most_Time_HouseworkR 		 	GES_14
	ren Housework_Prevented_WorkR 	 	GES_15
	ren Housework_Prevent_EducationR 	GES_16
	ren HarmR 						 	GES_17
	ren Decide_Prevent_PregnancyR 	 	GES_18
	
	ren Income_No_Permission_oth 		GES_1_oth
	ren Own_Decisions_Money_oth 		GES_2_oth
	ren Own_Decisions_Medical_oth 		GES_3_oth
	ren Own_Decisions_Relatives_oth 	GES_4_oth
	ren Own_Decisions_Friends_oth 		GES_5_oth
	ren Own_Bank_Account_oth 			GES_6_oth
	ren Have_Money_Saved_oth 			GES_7_oth
	ren Own_Property_oth 				GES_8_oth
	ren Own_Mobile_oth 				 	GES_9_oth
	ren You_Decide_Work_oth 			GES_10_oth
	ren Took_Money_No_Permission_oth 	GES_11_oth
	ren Permission_Local_Event_oth 	 	GES_12_oth
	ren Permission_Market_oth 			GES_13_oth
	ren Most_Time_Housework_oth 		GES_14_oth
	ren Housework_Prevented_Work_oth 	GES_15_oth
	ren Housework_Prevent_Education_oth GES_16_oth
	ren Harm_oth 						GES_17_oth
	ren Decide_Prevent_Pregnancy_oth 	GES_18_oth
	
tokenize `" "PermInc" "DMMoney" "DMMed" "DMRel" "DMFri" "OwnBank" "OwnSave" "OwnProp" "OwnMob" "DMWork" "TakeMoney" "PermEvent" "PermMarket" "MostHW" "HW" "HWEdu" "Harm" "DMPreg" "'
		
	local i = 0
	while `"`*'"' ~= `""' {	
		ren   	 GES_`++i' 		GES_`1'
		ren		 GES_`i'_oth 	GES_`1'_oth
		mvdecode GES_`1' GES_`1'_oth, mv(888 = .d \ 999 = .r \ 9999 = .n)
		
		macro shift
	}

	** change direction of variables (1 = Positive and 0 = Negative)
	
	
	
	