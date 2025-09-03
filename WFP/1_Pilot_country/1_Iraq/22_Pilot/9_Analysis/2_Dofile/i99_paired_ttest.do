** set program to export paired t-test results
capture program drop post_ttest

program define post_ttest, eclass
    syntax, colnames(string)

    // calculate statistics needed but not saved by ttest
    matrix obs    = r(N_1)
	matrix diff   = r(mu_1) - r(mu_2)
    matrix mu_1   = r(mu_1)
    matrix mu_2   = r(mu_2)
    matrix p      = r(p)
	matrix se_1   = r(sd_1) / (r(N_1)^.5)
	matrix se_2   = r(sd_2) / (r(N_2)^.5)
	
foreach var in obs diff mu_1 mu_2 p se_1 se_2 {
		ereturn matrix `var' = `var'
	}

end

/* 
// Create an empty table to store the results
tempname results
matrix `results' = J(`: word count `variables'', 5, .)

// Loop through the variables
local i = 1
foreach var in `variables' {
    
    // Perform the paired t-test
    quietly ttest `var'_F == `var'_M
    
    // Store the results in the matrix
    matrix `results'[`i', 1] = r(N_1)
    matrix `results'[`i', 2] = r(mu_1)
    matrix `results'[`i', 3] = r(mu_2)
    matrix `results'[`i', 4] = r(mu_1) - r(mu_2) 
    matrix `results'[`i', 5] = r(p)
    
    // Increment the counter
    local ++i
}
*/
	ereturn clear
	eststo  clear

	quietly estpost summarize StapCer_F StapCer_M // otherwise no estimates to store\
	ttest StapCer_F == StapCer_M
	eststo: post_ttest, colnames("Staple")
	esttab using "${tabs_tex}/Iraq_MDD_F2F_Gender_Difference_Paired_ttest.tex", ///
		replace style(tex) cells("obs(fmt(0)) mu_1(fmt(%9.2f)) mu_2(fmt(%9.2f)) diff(fmt(%9.2f)) p(fmt(%9.2f))") ///
		nonumbers noobs nomtitles	///
		starlevels(* 0.1 ** 0.05 *** 0.01)	///
		collabels("Sample" "Female Mean" "Male Mean" "Difference between Female - Male" "P Value") 
