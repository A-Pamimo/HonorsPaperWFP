*****************************************************************
* Goal: Create survey weights	
* Country: Bangladesh
* Data source: HIES, 2016
* Worked on Stata 15.0
*****************************************************************

clear all
set more off

global raw "..\Data\HIES"
global clean "..\Data"

* Load data
use "$clean/HIES_vars.dta", clear

local weight_vars "division_st urban_rural_st sex_st age_st"

		gen phone_hh=(access_phone!=0)
		label var phone_hh "Proportion of households with a mobile phone available"
                
		preserve
			collapse (mean) phone_hh (sum) ind_weight [weight=ind_weight], by(`weight_vars')
			label var sex_st "Gender"
			label var phone_hh "Has access to a mobile phone available"
                        ren ind_weight pop_weight
                        egen tot=sum(pop_weight)
                        replace pop_weight=pop_weight/tot
                        drop tot
			label var pop_weight "Weighted proportion in sample"
		save "$clean/group_frequencies_HIES.dta", replace
		restore
