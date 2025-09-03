*****************************************************************
* Goal: Create Sample Weights for RDD Baseline					*
* Country: Bangladesh											*
* Data source:  group_frequencies_HIES.dta						*
* Data source:  Bangladesh_Round1_Demographics.dta				*
* Worked on Stata 15.0											*
*****************************************************************

version 15
clear all
set more off

if "`inloop'"=="" {
    loc version 5    
}


global DATA "../../Bangladesh/Data"

* variable labels

loc population_vars population pop_phone

if `version'==1 {
    loc weight_vars division urban // age education gender 
    }
else if  `version'==2 {
    loc weight_vars division urban age // gender 
}
else if  `version'==3 {
    loc weight_vars division urban gender // age education 
}
else if  `version'==4 {
    loc weight_vars urban gender age // zone 
}
else if  `version'==5 {
    loc weight_vars division gender age // zone 
}

* loc weight_missing county_code 
loc raking 0


* Load census values
use $DATA/group_frequencies_HIES.dta, clear

    * Population (%)
    gen population=pop_weight
    * Population with a phone in the HH
    gen pop_phone = population*phone_hh
    *~ Set pop_phone to be percentages
    qui sum pop_phone, d
    assert 1-`r(mean)'*`r(N)'<1e-4 | `r(mean)'*`r(N)'-1<1e-4 // Make Sure each sums to 1
    replace pop_phone= pop_phone/(`r(mean)'*`r(N)') 

    * Gender
    gen gender=sex_st=="Female"

    * Urban/Rural
    gen urban = urban_rural_st=="Urban"
	
    * Age (-2 years to update age structure since survey is 2 years old)
    gen     age=1 if age_st=="16-23"
    replace age=2 if age_st=="24-42"
    replace age=3 if age_st=="43+"
    /*
    foreach pop of varlist `population_vars' {
        gen `pop'1 = age16_23 * `pop'
        gen `pop'2 = age24_42 * `pop'
        gen `pop'3 = age43    * `pop'
    }

    drop `population_vars'
    reshape long `population_vars', i(division urban gender) j(age)
    */

    lab def age_ranges  1 "18-25" 2 "26-44" 3 "45+"
    lab def urban 0 "Rural" 1 "Urban"
    lab def female 0 "Male" 1 "Female"

    lab var age "Age Range"
    lab val age age_ranges
    lab var gender "Gender"
    lab val gender female
    lab var urban "Urban/Rural"
    lab val urban urban
	
	encode division_st, gen(division)
	fre division
    lab def div 1 "BARISAL" 2 "CHITTAGONG" 3 "DHAKA" 4 "KHULNA" 5 "MYMENSINGH" 6 "RAJSHAHI" 7 "RANGPUR" 8 "SYLHET"

    collapse (sum) `population_vars' , by(`weight_vars')
	
	tempfile census
    save `census'

* Load Baseline
use $DATA/Bangladesh_Round1_Demographics.dta, clear

    * Gender
	*fre gender_main
	ren gender_main gender
    recode gender (1=0) (2=1)
    label value gender female
    label var gender "Gender"
    
	* Division
	*fre division
	ren division division_str
	encode division_str, g(division)
    lab var division "Division"
    lab val division div
	
	* Age
    gen age = 1+ (resp_age>25) + (resp_age>44)
    label val age age_ranges
    label var age "Age Range"

    gen urban = currentlocation==2
    lab def urban 0 "Rural" 1 "Urban"
    lab var urban "Urban/Rural"
    lab val urban urban

	merge m:1 `weight_vars' using `census', keepusing(`population_vars')

	keep if _m==3
    drop _merge

    if `raking'==0 {
        bysort `weight_vars': egen grp_size=count(caseid)
        egen N = count(caseid)
        replace grp_size=grp_size/N
        foreach pop of varlist `population_vars' {
            gen weight_`pop' = `pop' /grp_size
        }
    }

    else if `raking'==1 {
        foreach pop of varlist `population_vars' {
            gen weight_`pop' = 1 // Start with weight=1
            foreach var of varlist `weight_vars' {
                bysort `var': egen total_`pop' = sum(`pop') // 
                bysort `var': egen total = count(caseid) // 
                replace weight_`pop'=  weight_`pop'*total_`pop'/total
                drop total*
    }
    }
    }

    loc varname "Weights: "
    foreach v of varlist `weight_vars' {
        loc lab: variable label `v'
        loc varname = "`varname', `lab'"
        disp "`varname'"
    }
    foreach w of varlist weight* { // Topcode and Standardize
        * replace `w' = `w'/contacts
        gen `w'_top99 = `w'
        qui sum `w', d
        replace `w'_top99=r(p99) if `w'>r(p99)
        lab var `w' "`varname'"
        lab var `w'_top99 "`varname'"

        *egen avg  = mean(`w')
        *egen avg99= mean(`w'_top99)
        *replace `w' = `w'/avg
        *replace `w'_top99 = `w'_top99/avg99
        *drop avg*
    }

    gen weight_raw = weight_pop_phone
    gen weight`version' = weight_pop_phone_top99
    label var weight`version' "`varname'"

    keep caseid `population_vars' `weight_vars' weight*
    order caseid weight* `population_vars' `weight_vars' 

** SAVE
tempfile baseline
save `baseline'
save "../Data/Bangladesh_weights`version'.dta", replace

use "../Data/Bangladesh_weights.dta", clear

merge 1:1 caseid using "../Data/Bangladesh_weights`version'.dta", keepusing(weight`version') update replace
drop _m

save "../Data/Bangladesh_weights.dta", replace
    
disp "`weight_vars'"    
