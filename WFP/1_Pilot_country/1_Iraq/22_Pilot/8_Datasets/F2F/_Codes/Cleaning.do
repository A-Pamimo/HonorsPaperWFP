*Author: Alirah
*Date: 17/01/2023
//cleaning script for the Iraq Datasets
use "C:\Users\alirah.weyori\World Food Programme\RAMAN - Needs Assessments and Targeting Unit - General\01. Food security assessments\1.3 Research & Reviews\2_CARI_validation\1_rCARI validation study\DataSets\Iraq_2023\F2F\stata_files\HH_Data_vA.dta" , replace

tab HHID
describe HHID
destring HHID, replace
format %15.0g HHID
format %25s RESPName
format %25s HHSize
format %25s RepeatPID_count
duplicates tag HHID, gen(dup)
tab dup
br if dup>0
rename ___index HH_index
replace HHID = 101010094 if HHID==101010096 & HH_index==22
replace HHID = 110101154 if HHID==110101167 & HH_index==200
replace HHID = 110101182 if HHID==110101176 & HH_index==298
replace HHID = 2100101165 if HHID==207201122 & HH_index==63
replace HHID = 2100101154 if HHID==2100101145 & HH_index==37
replace HHID = 320101193 if HHID==320101194 & HH_index==287
replace HHID = 3300201148 if HHID==3300201151 & HH_index==45
replace HHID = 3300201165 if HHID==3300201163 & HH_index==40
replace HHID = 3300201171 if HHID==3300201172 & HH_index==70
replace HHID = 430201097 if HHID== 430201096 & HH_index==1
replace HHID = 430201099 if HHID==430201100 & HH_index==3
replace HHID = 430201111 if HHID==430201108 & HH_index==53
replace HHID = 430201163 if HHID==430201159 & HH_index==174
replace HHID = 430201098 if HHID == 430201099 & HH_index==9
replace HHID = 3300201171 if HHID == 3300201169 & HH_index ==76

drop dup
duplicates tag HHID, gen(dup)
tab dup
br if dup>0

drop dup ___tags ___notes ___version ___duration ___submitted_by ___xform_id ___uuid audit comments deviceid ___parent_table_name ___parent_index

format %35s end
format %35s start
format %35s HHStatusOth
format %25s RESPPercFoodSec
format %25s RepeatIntake_count
format %25s LhCSIEnAccess
format %25s LhCSIEnAccess_oth
format %25s percentage_diff
format %35s HHIncFirst_oth
format %25s HHDwellType_oth
format %25s HHTenureType_oth
format %25s HHWallType_oth
format %25s HHRoofType_oth
format %25s HHFloorType_oth
format %25s HHToiletType_oth
format %25s HHEnerCookSRC_oth
format %25s HHEnerLightSRC_oth
format %25s WealthSimpleHouseholdItems
format %25s WealthBasicElecItems
format %25s WealthTransportAssets
format %25s MDDWRESPNameR
format %25s GENRESPNameR
format %25s RepeatMAD_count
format %25s min_age_diff
format %25s index
format %25s name_person
format %25s MDDWRESPName_oth
format %25s rCSIRESPName_oth
format %25s GENRESPName_oth
format %25s RESPPhNmbAlt
format %35s instanceID

duplicates report HHID
duplicates tag HHID, gen(dup)
tab dup
br if dup>0


replace HHID = 320101151 if HHID==320101150	& HH_index==227
replace HHID = 320101156 if HHID==320101155	& HH_index==195
replace HHID = 3300201164 if HHID== 3300201165	& HH_index==43
replace HHID= 3300201170 if HHID== 3300201171 &HH_index==76



//save new edited file for Q_A
save "C:\Users\alirah.weyori\World Food Programme\RAMAN - Needs Assessments and Targeting Unit - General\01. Food security assessments\1.3 Research & Reviews\2_CARI_validation\1_rCARI validation study\DataSets\Iraq_2023\F2F\stata_files\HH_Data_vA.dta", replace





//Uploading the new file for Version B
use "C:\Users\alirah.weyori\World Food Programme\RAMAN - Needs Assessments and Targeting Unit - General\01. Food security assessments\1.3 Research & Reviews\2_CARI_validation\1_rCARI validation study\DataSets\Iraq_2023\F2F\stata_files\HH_Data_vB.dta" , replace


tab HHID
destring HHID, replace
format %15.0g HHID
format %25s RESPName
format %25s HHSize
format %25s RepeatPID_count
duplicates tag HHID, gen(dup)
tab dup
br if dup>0
rename ___index HH_index
duplicates tag HHID, gen(dup)
br if dup>0
replace HHID = 110201066 if HHID==110201067 & HH_index==190
replace HHID = 2100201083 if HHID==2100201082 & HH_index==144
replace HHID = 2100201129 if HHID==2100201130 & HH_index==244
replace HHID = 4200101025 if HHID==320101044 & HH_index==127
replace HHID = 3201010170 if HHID==320101054 & HH_index==98
replace HHID = 320101105 if HHID==320101109 & HH_index==97
replace HHID = 4200101006 if HHID==420010100 & HH_index==8
replace HHID = 4200101005 if HHID==420010100 & HH_index==7
replace HHID = 4200101009 if HHID==420010100 & HH_index==34
replace HHID = 4200101001 if HHID==420010100 & HH_index==11
replace HHID = 4200101029 if HHID==420010102 & HH_index==56
replace HHID = 4200101021 if HHID==420010102 & HH_index==57
replace HHID = 4200101024 if HHID==420010102 & HH_index==10
replace HHID = 4200101027 if HHID==420010102 & HH_index==33
replace HHID = 4200101034 if HHID==420010103 & HH_index==133
replace HHID = 4200101033 if HHID==420010103 & HH_index==119
replace HHID = 4200101030 if HHID==420010103 & HH_index==134
replace HHID = 4200101037 if HHID==420010103 & HH_index==86
replace HHID = 4200101032 if HHID==420010103 & HH_index==171
replace HHID = 4200101044 if HHID==420010104 & HH_index==135
replace HHID = 4200101048 if HHID==420010104 & HH_index==150
replace HHID = 4200101047 if HHID==420010104 & HH_index==121
replace HHID = 4200101041 if HHID==420010104 & HH_index==148
replace HHID = 4200101058 if HHID==420010105 & HH_index==118
replace HHID = 4200101059 if HHID==420010105 & HH_index==83
replace HHID = 4200101051 if HHID==420010105 & HH_index==55
replace HHID = 4200101063 if HHID==420010106 & HH_index==185
replace HHID = 4200101069 if HHID==420010106 & HH_index==9
replace HHID = 4200101081 if HHID==420010107 & HH_index==132
replace HHID = 4200101079 if HHID==420010107 & HH_index==156
drop dup
duplicates tag HHID, gen(dup)
tab dup
br if dup>0

drop dup
duplicates tag HHID, gen(dup)
tab dup
br if dup>0

drop dup ___tags ___notes ___version ___duration ___submitted_by ___xform_id ___uuid audit comments deviceid ___parent_table_name ___parent_index
replace HHID =4200101019 if HHID==4200101018 & HH_index==25


tostring HHID, gen(hhid_phase)
gen F2F_Rmt=substr(hhid_phase, 1,1)
tab F2F_Rmt
destring F2F_Rmt, replace
label define F2F_Rmt 4 "F2F first" 2 "F2F first" 1 "Remote first" 3 "Remote first", replace
lab values F2F_Rmt F2F_Rmt
tab F2F_Rmt
destring HHSize, replace
bysort ADMIN5Name F2F_Rmt: sum RESPAge RESPSex HHSize
label variable F2F_Rmt "Remote or F2F interview first"




//save new edited file for Q_B
save "C:\Users\alirah.weyori\World Food Programme\RAMAN - Needs Assessments and Targeting Unit - General\01. Food security assessments\1.3 Research & Reviews\2_CARI_validation\1_rCARI validation study\DataSets\Iraq_2023\F2F\stata_files\HH_Data_vB.dta", replace




use "C:\Users\alirah.weyori\World Food Programme\RAMAN - Needs Assessments and Targeting Unit - General\01. Food security assessments\1.3 Research & Reviews\2_CARI_validation\1_rCARI validation study\DataSets\Iraq_2023\Remote\Remote_CARI_version_A.dta", replace

drop dup
tab HHID
describe HHID
destring HHID, replace
format %20.0g HHID
duplicates tag HHID, gen (dup)
br if dup>0
rename ___index HH_index
replace HHID = 320101006 if HHID == 7704647214 & HH_index==30
replace HHID = 320101002 if HHID == 7704987889 & HH_index==27
replace HHID = 320101001 if HHID == 7706230392 & HH_index==26
replace HHID = 320101005 if HHID == 7724960495 & HH_index==29
replace HHID = 320101004 if HHID == 7731467223 & HH_index==28
replace HHID = 320101007 if HHID == 774648295 & HH_index==31

drop dup


/*
HH_index Old HHID   New_HHID
30 		7704647214 320101006
27 		7704987889	320101002
26 		7706230392	320101001
29 		7724960495	320101005
28 		7731467223	320101004
31 		774648295	320101007
*/

/*
110101176	110101179	346
110101176	110101177	352
110101176	110101180	351
110101176	110101182	348
110101176	110101181	347
110101176	110101176	342
110101176	110101178	344
110101176	110101184	353
110101176	110101183	349
*/

replace HHID = 110101179 if HHID == 110101176 & HH_index==346
replace HHID = 110101177 if HHID == 110101176 & HH_index==352
replace HHID = 110101180 if HHID == 110101176 & HH_index==351
replace HHID = 110101182 if HHID == 110101176 & HH_index==348
replace HHID = 110101181 if HHID == 110101176 & HH_index==347
replace HHID = 110101176 if HHID == 110101176 & HH_index==342
replace HHID = 110101178 if HHID == 110101176 & HH_index==344
replace HHID = 110101184 if HHID == 110101176 & HH_index==353
replace HHID = 110101183 if HHID == 110101176 & HH_index==349


duplicates tag HHID, gen(dup)
tab dup
br if dup>0

drop if HHID==110101176 & HH_index==348
drop if HHID==110101098	& HH_index==300
drop if HHID==320101044 & HH_index==369
drop if HHID==320101043	& HH_index==362
drop if HHID==320101037	& HH_index==360
drop if HHID==320101040	& HH_index==359
drop if HHID==320101039	& HH_index==358
drop if HHID==320101038	& HH_index==357
drop if HHID==320101030	& HH_index==328
drop if HHID==320101022	& HH_index==326
drop if HHID==320101020	& HH_index==325
drop if HHID==230101017	& HH_index==323
drop if HHID==320101155 & HH_index==291
drop if HHID==3201010010 & HH_index==290
drop if HHID==320101005	& HH_index==287
drop if HHID==230101044	& HH_index==149
drop dup
duplicates tag HHID, gen(dup)
tab dup

*duplicates by HHID
/*
        dup |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |        293       97.34       97.34
          1 |          8        2.66      100.00
------------+-----------------------------------
      Total |        301      100.00
*/

br if dup>0


/*The following HHIDs are still in duplicates*
which ones are mistakes and which ones are actual duplicates??
HHID
110201021
110201021
110201079
110201079
320101034
320101034
320101035
320101035
*/

duplicates drop HHID, force

save "C:\Users\alirah.weyori\World Food Programme\RAMAN - Needs Assessments and Targeting Unit - General\01. Food security assessments\1.3 Research & Reviews\2_CARI_validation\1_rCARI validation study\DataSets\Iraq_2023\Remote\Remote_version_A_NoDup.dta", replace 










