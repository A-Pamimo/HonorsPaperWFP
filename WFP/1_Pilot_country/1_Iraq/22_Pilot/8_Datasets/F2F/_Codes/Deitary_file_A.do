*dietary module
*Date 22-01-2023
*Author: Alirah

use "C:\Users\alirah.weyori\World Food Programme\RAMAN - Needs Assessments and Targeting Unit - General\01. Food security assessments\1.3 Research & Reviews\2_CARI_validation\1_rCARI validation study\DataSets\Iraq_2023\F2F\stata_files\DIETAR~1.DTA", replace

drop ___xform_id ___submitted_by ___duration ___version ___notes ___id ___uuid ___tags ___parent_table_name ___submission_time 
format %25s HHFoodItemOth
rename ___parent_index HH_index

save "C:\Users\alirah.weyori\World Food Programme\RAMAN - Needs Assessments and Targeting Unit - General\01. Food security assessments\1.3 Research & Reviews\2_CARI_validation\1_rCARI validation study\DataSets\Iraq_2023\F2F\stata_files\DIETARY_Final", replace

merge m:1 HH_index using "C:\Users\alirah.weyori\World Food Programme\RAMAN - Needs Assessments and Targeting Unit - General\01. Food security assessments\1.3 Research & Reviews\2_CARI_validation\1_rCARI validation study\DataSets\Iraq_2023\F2F\stata_files\Master_A"

tab _merge

/*
   Matching result from |
                  merge |      Freq.     Percent      Cum.
------------------------+---------------------------------
        Master only (1) |        21      	1.31     1.31
            Matched (3) |      1,585    	98.69    100.00
------------------------+---------------------------------
                  Total |      1,606      100.00

*/

sort _merge
tab HH_index if _m==1

/*
_parent_ind |
         ex |      Freq.     Percent        Cum.
------------+-----------------------------------
         43 |          4       19.05       19.05
         76 |          6       28.57       47.62
        227 |          5       23.81       71.43
        231 |          6       28.57      100.00
------------+-----------------------------------
      Total |         21      100.00
*/

drop if _m==1
drop _merge

save "C:\Users\alirah.weyori\World Food Programme\RAMAN - Needs Assessments and Targeting Unit - General\01. Food security assessments\1.3 Research & Reviews\2_CARI_validation\1_rCARI validation study\DataSets\Iraq_2023\F2F\stata_files\DIETARY_HHID", replace

**exit

