*Author: Alirah
*Date-29/03/23
*Title: rCSI calculation of the individual level


drop dup ___id ___submission_time instanceID

gen rcsilessQlty_O = rCSILessQlty_oth
gen rcsiborrow_O = rCSIBorrow_oth
gen rcsimealNb_O = rCSIMealNb_oth 
gen rcsimealSize_O = rCSIMealSize_oth
gen rcsimealAdult_O = rCSIMealAdult_oth

lab var rcsilessQlty_O "Relied on less preferred, less expensive food"
lab var rcsiborrow_O "Borrowed food or relied on help from friends or relatives"
lab var rcsimealNb_O "Reduced the number of meals eaten per day"
lab var rcsimealSize_O "Reduced portion size of meals at meals time"
lab var rcsimealAdult_O "Restrict consumption by adults in order for young-children to eat"

*Compute rCSI
gen rCSI_ind=(rcsilessQlty_O*1) + (rcsiborrow_O*2) + (rcsimealNb_O*1) + (rcsimealSize_O*3) + (rcsimealAdult_O*1)
lab var rCSI_ind "Reduced Consumption Strategies Index at the individual"
tab rCSI_ind
 bysort rCSIRESPSex_oth: tab rCSI_ind
  bysort rCSIRESPSex_oth: sum rCSI_ind, de