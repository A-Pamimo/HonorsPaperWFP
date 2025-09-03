* Encoding: UTF-8.

***************************************************************
    Livelihood Coping Strategies for Essential Needs 
***************************************************************

***define value labels 
LcsEN_stress_DomAsset
LcsEN_stress_CrdtFood
LcsEN_stress_Saving
LcsEN_stress_BorrowCash
LcsEN_crisis_ProdAssets
LcsEN_crisis_HealthEdu
LcsEN_crisis_OutSchool
LcsEN_em_ChildWork
LcsEN_em_Begged
LcsEN_em_IllegalAct
10 ‘No, because I did not need to’
20 ‘No because I already sold those assets or have engaged in this activity within the last 12 months and cannot continue to do it’
30 ‘Yes’
9999 ‘Not applicable’.

***stress strategies*** (must have 4 stress strategies to calculate LCS-EN, if you have more then use the most frequently applied strategies)

Variable labels 
LcsEN_stress_DomAsset	‘Sold household assets/goods (radio, furniture, refrigerator, television, jewellery etc.)’
LcsEN_stress_CrdtFood	                  ‘Purchased food or other essential items on credit’
LcsEN_stress_Saving	                  ‘Spent savings’
LcsEN_stress_BorrowCash	‘Borrowed money’.

frequencies LcsEN_stress_DomAsset
LcsEN_stress_CrdtFood
LcsEN_stress_Saving
LcsEN_stress_BorrowCash.

Do if (LcsEN_stress_DomAsset = 20) | (LcsEN_stress_DomAsset = 30) | (LcsEN_stress_CrdtFood = 20) | (LcsEN_stress_CrdtFood = 30) | 
    (LcsEN_stress_Saving =20) | (LcsEN_stress_Saving =30) | (LcsEN_stress_BorrowCash  =20) | (LcsEN_stress_BorrowCash=30).

Compute stress_coping_EN =1.
Else.
Compute stress_coping_EN =0.
End if.
EXECUTE.

  ***crisis strategies***(must have 3 crisis strategies to calculate LCS-EN, if you have more then use the most frequently applied strategies)

Variable labels 
LcsEN_crisis_ProdAssets	‘Sold productive assets or means of transport (sewing machine, wheelbarrow, bicycle, car, etc.)’
LcsEN_crisis_HealthEdu	‘Reduced expenses on health (including drugs) or education’
LcsEN_crisis_OutSchool	‘Withdrew children from school.’.

frequencies
    LcsEN_crisis_ProdAssets
LcsEN_crisis_HealthEdu
LcsEN_crisis_OutSchool.

Do if (LcsEN_crisis_ProdAssets = 20) | (LcsEN_crisis_ProdAssets =30) | (LcsEN_crisis_HealthEdu =20) | (LcsEN_crisis_HealthEdu=30) | 
    (LcsEN_crisis_OutSchool =20) | (LcsEN_crisis_OutSchool =30).

Compute crisis_coping_EN =1.
Else.
Compute crisis_coping_EN =0. 
End if.
EXECUTE.

***emergency strategies ***(must have 3 emergency strategies to calculate LCS, if you have more then use the most frequently applied strategies)

Variable labels 
LcsEN_em_ChildWork	 ‘Sent children (under the age of 15) to work
LcsEN_em_Begged	‘Begged and/or scavenged (asked strangers for money/food)’
LcsEN_em_IllegalAct	‘Had to engage in illegal income activities (theft, prostitution)’.

Do if (LcsEN_em_ChildWork = 20) | (LcsEN_em_ChildWork = 30) | (LcsEN_em_Begged = 20) | (LcsEN_em_Begged =30) | 
    (LcsEN_em_IllegalAct = 20) | (LcsEN_em_IllegalAct = 30).

Compute emergency_coping_EN =1.
Else.
Compute emergency_coping_EN = 0.
End if.
EXECUTE.

*** label new variable

variable labels stress_coping_EN 'Did the HH engage in stress coping strategies?'.
variable labels crisis_coping_EN 'Did the HH engage in crisis coping strategies?'.
variable labels emergency_coping_EN  'Did the HH engage in emergency coping strategies?'.

*** recode variables to compute one variable with coping behavior 

recode  stress_coping_EN (0=0) (1=2).
recode  crisis_coping_EN (0=0) (1=3).
recode  emergency_coping_EN (0=0) (1=4).

COMPUTE Max_coping_behaviourEN=MAX(stress_coping_EN,  crisis_coping_EN,  emergency_coping_EN).
RECODE Max_coping_behaviourEN (0=1).

Value labels Max_coping_behaviourEN 1 'HH not adopting coping strategies' 2 'Stress coping strategies ' 3 'Crisis coping strategies ' 4 'Emergencies coping strategies'.

Variable Labels Max_coping_behaviourEN 'Summary of asset depletion'.
EXECUTE.

Frequencies Max_coping_behaviourEN.


***define value labels 

Variable labels 
LhCSIEnAccess.1 ‘To buy food’
LhCSIEnAccess.2 ‘To pay for rent’
LhCSIEnAccess.3 ‘To pay school, education costs’
LhCSIEnAccess.4 ‘To cover health expenses‘
LhCSIEnAccess.5 ‘To buy essential non-food items (clothes, small furniture...)’
LhCSIEnAccess.6 ‘To access water or sanitation facilities’
LhCSIEnAccess.7 ‘To access essential dwelling services (electricity, energy, waste disposal…)’
LhCSIEnAccess.8 ‘To pay for existing debts’
LhCSIEnAccess.999 ‘Other, specify’.


*Create a multi-response dataset for reasons selected for applying livelihood coping strategies


***********************************Calculating LCS-FS using the LCS-EN module************************************

Do if (LhCSIEnAccess.1 = 1).
recode Max_coping_behaviourEN (1=1) (2=2) (3=3) (4=4) into Max_coping_behaviour. 
End if.
EXECUTE.

Value labels Max_coping_behaviour 1 'HH not adopting coping strategies' 2 'Stress coping strategies ' 3 'Crisis coping strategies ' 4 'Emergencies coping strategies'.

Frequencies Max_coping_behaviour. 
