    
	use "${dta}/Iraq_Full_Household_Raw.dta", clear
	
	/* check modality first */
	
	** F2F Date Time Check 
	gen date_start_str = substr(start, 1, 10)
	gen date_start = clock(date_start_str, "YMD") 
	gen date_end_str = substr(end, 1, 10)
	gen date_end = clock(date_end_str, "YMD") 
	
	format date_start date_end %tc
	gen date_diff = date_start - date_end // 579 no diff and all negative ok 
	// use today as start date - all the same
	
	** Remote Date Time Check 
	gen r_date_start_str = substr(r_start, 1, 10)
	gen r_date_start = clock(r_date_start_str, "YMD") 
	gen r_date_end_str = substr(r_end, 1, 10)
	gen r_date_end = clock(r_date_end_str, "YMD") 
	
	format r_date_start r_date_end %tC
	gen r_date_diff = r_date_start - r_date_start // perfect 540 no diff
	// use submission time

	gen time_diff_start 	 = date_start - r_date_start
	gen time_diff_end		 = date_end   - r_date_end
	
	gen time_diff_submission = ___submission_time - r____submission_time
	gen time_diff_today		 = today - r_today
	gen time_inconsistent 	 = time_diff_today - time_diff_submission
	
	** use both date 
	gen 	f2f_first_1 = (time_diff_submission < 0 & time_diff_today < 0) if !mi(time_diff_today)
	gen 	f2f_first_2 = (time_diff_end < 0 & time_diff_start < 0) if !mi(time_diff_start)
	gen 	f2f_first = (f2f_first_1 == 1 & f2f_first_2 == 1) 
	replace f2f_first = 1 if _merge == 1 // 136 f2f only
	
	** use both date 
	gen 	rm_first_1  = (time_diff_submission > 0 & time_diff_today > 0) if !mi(time_diff_today)
	gen 	rm_first_2  = (time_diff_end > 0 & time_diff_start > 0) if !mi(time_diff_start)
	gen 	rm_first  = (rm_first_1 == 1 & rm_first_2 == 1) 
	replace rm_first  = 1 if _merge == 2 // 86 rm only
	
*	keep if f2f_first == 0 & rm_first == 0
/*	keep HHID time_diff_submission ___submission_time r____submission_time ///
		 f2f_first rm_first time_diff_today today r_today time_inconsistent ///
		 start end r_start r_end time_diff_start time_diff_end*/

	order HHID start r_start end r_end today r_today ___submission_time r____submission_time, first

	replace rm_first  = 1 if inlist(HHID, 110101121, 110101124, 110101125, 110101127, 3300201164)
	replace f2f_first = 1 if inlist(HHID, 210201045, 320101080, 2100101154, 2100101200, 2100101218, 2100201055, 2100201058, 4200101041, 4200101047, 4200101048)
	
	order f2f_first rm_first, first
	
	count if f2f_first == 1	// 369
	count if rm_first  == 1 // 307
	
	count if f2f_first == 1 & !mi(r_start) // assigned to f2f first and finished remote 233
	count if rm_first == 1  & !mi(start)   // assigned to remote first and finished f2f 221
	
	************ True Crossover **************
	
	gen   age_diff = RESPAge - r_RESPAge
	count if (age_diff > 2 | age_diff < -2) & _merge == 3 // 187 age diff more than 2
	count if RESPAge == r_RESPAge & _merge == 3			  // 169 exact same age

	count if RESPRelationHHH == r_RESPRelationHHH & _merge == 3 // 251 exact same hhh relations
	
	count if RESPSex != r_RESPSex & _merge == 3			  // 176 different sex
	
	count if RESPAge == r_RESPAge & RESPSex == r_RESPSex & ///
			 RESPRelationHHH == r_RESPRelationHHH & _merge == 3	// 134 exact the same
	// previously used HHH yesno question, this is more accurate
	gen HH_True_Crossover = (RESPAge == r_RESPAge & RESPSex == r_RESPSex & ///
			 RESPRelationHHH == r_RESPRelationHHH & _merge == 3)
	
	gen 	Modality_First = 1 if f2f_first == 1 
	replace Modality_First = 2 if rm_first == 1
	
	label   def modality 1 "F2F First" 2 "Remote First"
	label   val Modality_First modality
	
	keep HHID time_diff_submission ___submission_time r____submission_time ///
		 f2f_first rm_first time_diff_today today r_today time_inconsistent ///
		 start end r_start r_end time_diff_start time_diff_end age_diff RESPAge ///
		 r_RESPAge RESPRelationHHH r_RESPRelationHHH RESPSex r_RESPSex _merge /// 
		 HH_True_Crossover Modality_First
		 
	compress	 
	save "${sample}/Iraq_Full_Household_Sample_Check.dta", replace
	
	compress
	keep HHID Modality_First HH_True_Crossover
	save "${sample}/Iraq_Full_Household_Modality.dta", replace
