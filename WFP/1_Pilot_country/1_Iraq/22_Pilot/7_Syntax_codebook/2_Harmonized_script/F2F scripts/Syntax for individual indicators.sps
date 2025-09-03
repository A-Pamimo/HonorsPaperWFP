* Encoding: UTF-8.
****************************************************************************************
    CARI VALIDATION STUDY INDIVIDUAL INDICATORS 
****************************************************************************************
***/Author: Wishah

*Calculate MDDW indicators based on https://docs.wfp.org/api/documents/WFP-0000140197/download/ pg.8

**************************************************
Minimum Dietary Diversity 
**************************************************
* for the main HH respondent 

Compute  MDDW_StaplesR = 0.
if (PWMDDWStapCerR) = 1 |  (PWMDDWStapRooR) = 1 | (PWMDDWSnfR = 1) MDDW_StaplesR= 1.
compute  MDDW_PulsesR = 0.
if (PWMDDWPulseR = 1) MDDW_PulsesR = 1.
Compute  MDDW_NutsSeedsR = 0.
if (PWMDDWNutsR = 1) MDDW_NutsSeedsR = 1.
Compute MDDW_DairyR = 0.
if (PWMDDWDairyR = 1) | (PWMDDWMilkR = 1) MDDW_DairyR = 1.
Compute  MDDW_MeatFishR = 0.
if (PWMDDWPrMeatOR = 1) | (PWMDDWPrMeatFR = 1) | (PWMDDWPrMeatProR = 1) | (PWMDDWPrMeatWhiteR = 1) |  (PWMDDWPrFishR = 1) MDDW_MeatFishR = 1.
Compute MDDW_EggsR = 0.
if (PWMDDWPrEggR = 1) MDDW_EggsR = 1.
Compute  MDDW_LeafGreenVegR = 0.
if (PWMDDWVegGreR = 1) MDDW_LeafGreenVegR = 1. 
Compute  MDDW_VitAR = 0.           
if (PWMDDWVegOrgR = 1) | (PWMDDWFruitOrgR = 1) MDDW_VitAR = 1.
Compute  MDDW_OtherVegR = 0.
if (PWMDDWVegOthR = 1) MDDW_OtherVegR = 1. 
Compute  MDDW_OtherFruitsR = 0.
if (PWMDDWFruitOthR = 1) MDDW_OtherFruitsR = 1.

*calculate MDDW variable by adding together food groups and classifying whether the individual consumed 5 or more food groups
*Standard MDDW method where SNF is counted in grains

compute MDDWR = sum(MDDW_StaplesR ,MDDW_PulsesR ,MDDW_NutsSeedsR ,MDDW_DairyR ,MDDW_MeatFishR ,MDDW_EggsR ,MDDW_LeafGreenVegR ,MDDW_VitAR ,MDDW_OtherVegR ,MDDW_OtherFruitsR).

*count how many individuals consumed 5 or more groups

Compute  MDDWR_5 = 0.
if (MDDWR >= 5) MDDWR_5 = 1.
Value labels  MDDWR_5 1 '>=5' 0  '<5 '.

Value labels  MDDWR_5 1 '>=5' 0  '<5 '.

frequencies MDDWR_5.


**************************************************
Minimum Dietary Diversity 
**************************************************
* for the equivalent respondent  

Compute  MDDW_Staples_oth = 0.
if (PWMDDWStapCer_oth) = 1 |  (PWMDDWStapRoo_oth) = 1 | (PWMDDWSnf_oth = 1) MDDW_Staples_oth= 1.
compute  MDDW_Pulses_oth = 0.
if (PWMDDWPulse_oth = 1) MDDW_Pulses_oth = 1.
Compute  MDDW_NutsSeeds_oth = 0.
if (PWMDDWNuts_oth = 1) MDDW_NutsSeeds_oth = 1.
Compute MDDW_Dairy_oth = 0.
if (PWMDDWDairy_oth = 1) | (PWMDDWMilk_oth = 1) MDDW_Dairy_oth = 1.
Compute  MDDW_MeatFish_oth = 0.
if (PWMDDWPrMeatO_oth = 1) | (PWMDDWPrMeatF_oth = 1) | (PWMDDWPrMeatPro_oth = 1) | (PWMDDWPrMeatWhite_oth = 1) |  (PWMDDWPrFish_oth = 1) MDDW_MeatFish_oth = 1.
Compute MDDW_Eggs_oth = 0.
if (PWMDDWPrEgg_oth = 1) MDDW_Eggs_oth = 1.
Compute  MDDW_LeafGreenVeg_oth = 0.
if (PWMDDWVegGre_oth = 1) MDDW_LeafGreenVeg_oth = 1.
Compute  MDDW_VitA_oth = 0.           
if (PWMDDWVegOrg_oth = 1) | (PWMDDWFruitOrg_oth = 1) MDDW_VitA_oth = 1.
Compute  MDDW_OtherVeg_oth = 0.
if (PWMDDWVegOth_oth = 1) MDDW_OtherVeg_oth = 1. 
Compute  MDDW_OtherFruits_oth = 0.
if (PWMDDWFruitOth_oth = 1) MDDW_OtherFruits_oth = 1.


*calculate MDDW variable by adding together food groups and classifying whether the individual consumed 5 or more food groups
*Standard MDDW method where SNF is counted in grains

compute MDDW_oth = sum(MDDW_Staples_oth ,MDDW_Pulses_oth ,MDDW_NutsSeeds_oth ,MDDW_Dairy_oth ,MDDW_MeatFish_oth ,MDDW_Eggs_oth ,MDDW_LeafGreenVeg_oth ,MDDW_VitA_oth ,MDDW_OtherVeg_oth ,MDDW_OtherFruits_oth).

*count how many women consumed 5 or more groups

Compute  MDDW_oth_5 = 0.
if (MDDW_oth >= 5) MDDW_oth_5 = 1.
Value labels  MDDW_oth_5 1 '>=5' 0  '<5 '.

Value labels  MDDW_oth_5 1 '>=5' 0  '<5 '.

frequencies MDDW_oth_5.

**************************************************
reduced COPING STRATEGIES INDEX 
**************************************************
* for the equivalent respondent  

rCSILessQlty_oth
rCSIBorrow_oth
rCSIMealSize_oth
rCSIGenderMealSize_oth
rCSIMealAdult_oth
rCSIGenderMealAdult_oth
rCSIMealNb_oth

Compute rCSI_oth = sum(rCSILessQlty_oth*1,rCSIBorrow_oth*2,rCSIMealNb_oth*1,rCSIMealSize_oth*1,rCSIMealAdult_oth*3).
Variable labels rCSI_oth 'Reduced coping strategies index (rCSI)'.
EXECUTE.

frequencies rCSI_oth.

**************************************************
Minimum Acceptable Diet 
**************************************************

Value labels PCMADBreastfeed,PCMADInfFormula,PCMADMilk,PCMADYogurtDrink, PCMADYogurt,PCMADStapCer,PCMADVegOrg,PCMADStapRoo,PCMADVegGre,PCMADVegOth,PCMADFruitOrg,
    PCMADFruitOth,PCMADPrMeatO,PCMADPrMeatPro,PCMADPrMeatF,PCMADPrEgg,PCMADPrFish,PCMADPulse,PCMADCheese,PCMADSnf 1 "Yes" 0  "No" 888 "Don't know".
    
 *Creat Minimum Acceptable Diet 6-23 months (MAD)
* for population assesments - SNF is counted in cereals group (MAD)

*this version of MDD is for population assessments - SNF is counted in cereals group

Compute MAD_BreastMilk  = 0.
if  PCMADBreastfeed = 1 MAD_BreastMilk  = 1.
Compute MAD_PWMDDWStapCer  = 0.
if  PCMADStapCer = 1 | PCMADStapRoo = 1  | PCMADSnf = 1 MAD_PWMDDWStapCer= 1.
Compute MAD_PulsesNutsSeeds  = 0.
if  PCMADPulse =  1 MAD_PulsesNutsSeeds = 1.

frequencies 
PCMADInfFormulaNum
PCMADMilkNum
PCMADYogurtDrinkNum. 

recode PCMADInfFormulaNum (0=0) (1 thru highest=1) into PCMADInfFormula. 
recode PCMADMilkNum (0=0) (1 thru highest=1) into PCMADMilk. 
recode PCMADYogurtDrinkNum (0=0) (1 thru highest=1) into PCMADYogurtDrink. 


Compute MAD_Dairy   = 0.
if  PCMADInfFormula = 1 | PCMADMilk = 1 | PCMADYogurtDrink = 1 | PCMADYogurt = 1 | PCMADCheese = 1 MAD_Dairy= 1.
Compute MAD_MeatFish   = 0.
if  PCMADPrMeatO = 1 |  PCMADPrMeatPro = 1 | PCMADPrMeatF = 1 | PCMADPrFish = 1 MAD_MeatFish= 1.
Compute MAD_Eggs   = 0.
if PCMADPrEgg = 1 MAD_Eggs = 1.
Compute MAD_VitA   = 0.
if  PCMADVegOrg = 1 | PCMADVegGre = 1 | PCMADFruitOrg = 1 MAD_VitA = 1.
Compute  MAD_OtherVegFruits  = 0.
if   PCMADFruitOth = 1 | PCMADVegOth = 1 MAD_OtherVegFruits= 1.

*add together food groups to see how many food groups consumed

compute MDD_score = sum(MAD_BreastMilk,MAD_PWMDDWStapCer,MAD_PulsesNutsSeeds,MAD_Dairy,MAD_MeatFish,MAD_Eggs,MAD_VitA,MAD_OtherVegFruits).

*create MDD variable which records whether child consumed five or more food groups

Compute  MDD = 0.
if (MDD_score >= 5) MDD = 1.
Variable labels MDD "Minimum Dietary Diversity (MDD)".
Value labels  MDD 1 'Meets MDD' 0  'Does not meet MDD'.



