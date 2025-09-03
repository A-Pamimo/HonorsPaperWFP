* Encoding: UTF-8.

 *******************************************************************************
Food Expenditure Share (FES).v2
 *******************************************************************************
 
*Important note: the value of consumed in-kind assistance/gifts should be considered in the calculation of FES for both assessment exercises as well as monitoring exercises  
 
*-------------------------------------------------------------------------------*
*1. Create variables for food expenditure, by source	
*-------------------------------------------------------------------------------*

*Important note: add recall period of _7D or _1M to the variables names below depending on what has been selected for your CO. It is recommended to follow standard recall periods as in the module.

*** 1.a Label variables: 

VARIABLE LABELS
 HHExpFCer_Purch_MN_7D 'Expenditures on cereals'
 HHExpFCer_GiftAid_MN_7D 'Value of consumed in-kind assistance and gifts - cereals'
 HHExpFCer_Own_MN_7D 'Value of consumed own production - cereals'
 HHExpFTub_Purch_MN_7D 'Expenditures on tubers'
 HHExpFTub_GiftAid_MN_7D 'Value of consumed in-kind assistance and gifts - tubers'
 HHExpFTub_Own_MN_7D 'Value of consumed own production - tubers'
 HHExpFPuls_Purch_MN_7D 'Expenditures on pulses & nuts'
 HHExpFPuls_GiftAid_MN_7D 'Value of consumed in-kind assistance and gifts - pulses and nuts'
 HHExpFPuls_Own_MN_7D 'Value of consumed own production - pulses & nuts'
 HHExpFVegFrt_Purch_MN_7D 'Expenditures on vegetables & fruits'
 HHExpFVegFrt_GiftAid_MN_7D 'Value of consumed in-kind assistance and gifts - vegetables & fruits'
 HHExpFVegFrt_Own_MN_7D 'Value of consumed own production - vegetables & fruits'
 HHExpFAnimMeatFishEgg_Purch_MN_7D 'Expenditures on meat, fish & eggs'
 HHExpFAnimMeatFishEgg_GiftAid_MN_7D 'Value of consumed in-kind assistance and gifts - meat, fish & eggs'
HHExpFAnimMeatFishEgg_Own_MN_7D 'Value of consumed own production - meat, fish & eggs'
 HHExpFFatsDairy_Purch_MN_7D 'Expenditures on fats & milk/dairy products'
 HHExpFFatsDairy_GiftAid_MN_7D 'Value of consumed in-kind assistance and gifts - fats & milk/dairy products'
 HHExpFFatsDairy_Own_MN_7D 'Value of consumed own production - fats & milk/dairy products'
 HHExpFSgrCond_Purch_MN_7D 'Expenditures on sugar/confectionery/desserts & condiments'
 HHExpFSgrCond_GiftAid_MN_7D 'Value of consumed in-kind assistance and gifts - sugar/confectionery/desserts & condiments'
 HHExpFSgrCond_Own_MN_7D 'Value of consumed own production - sugar/confectionery/desserts & condiments'
 HHExpFBev_Purch_MN_7D 'Expenditures on beverages'
 HHExpFBev_GiftAid_MN_7D 'Value of consumed in-kind assistance and gifts - beverages'
 HHExpFBev_Own_MN_7D 'Value of consumed own production - beverages'
 HHExpFOut_Purch_MN_7D 'Expenditures on snacks/meals prepared outside'
 HHExpFOut_GiftAid_MN_7D 'Value of consumed in-kind assistance and gifts - snacks/meals prepared outside'
 HHExpFOut_Own_MN_7D 'Value of consumed own production - snacks/meals prepared outside'.
EXECUTE.

* If the questionnaire included further food categories/items label the respective variables


*** 1.b Calculate total value of food expenditures/consumption by source

*If the expenditure recall period is 7 days; make sure to express the newly created variables in monthly terms by multiplying by 30/7

*Monthly food expenditures in cash/credit (combined groups)

COMPUTE  HHExp_Food_Purch_MN_1Mv2=SUM(HHExpFCer_Purch_MN_7D, HHExpFTub_Purch_MN_7D, HHExpFPuls_Purch_MN_7D,  
    HHExpFVegFrt_Purch_MN_7D, HHExpFAnimMeatFishEgg_Purch_MN_7D, HHExpFFatsDairy_Purch_MN_7D, 
    HHExpFSgrCond_Purch_MN_7D, HHExpFBev_Purch_MN_7D, HHExpFOut_Purch_MN_7D).
COMPUTE HHExp_Food_Purch_MN_1M=HHExp_Food_Purch_MN_1M*(30/7).  /* conversion in monthly terms - do it only if recall period for food was 7 days.
 VARIABLE LABELS HHExp_Food_Purch_MN_1M 'Total monthly food expenditure (cash and credit)'.
EXECUTE.

*Monthly value of consumed food from gift/aid (combined groups)

COMPUTE HHExp_Food_GiftAid_MN_1Mv2=SUM(HHExpFCer_GiftAid_MN_7D, HHExpFTub_GiftAid_MN_7D, HHExpFPuls_GiftAid_MN_7D, + 
HHExpFVegFrt_GiftAid_MN_7D, HHExpFAnimMeatFishEgg_GiftAid_MN_7D, HHExpFFatsDairy_GiftAid_MN_7D, + 
HHExpFSgrCond_GiftAid_MN_7D, HHExpFBev_GiftAid_MN_7D, HHExpFOut_GiftAid_MN_7D).
COMPUTE HHExp_Food_GiftAid_MN_1M=HHExp_Food_GiftAid_MN_1M*(30/7). /*conversion in monthly terms - do it only if recall period for food was 7 days.
 VARIABLE LABELS  HHExp_Food_GiftAid_MN_1M 'Total monthly food consumption from gifts/aid'.
EXECUTE.


*Monthly value of consumed food from own-production (combined groups)

COMPUTE HHExp_Food_Own_MN_1Mv2=SUM(HHExpFCer_Own_MN_7D, HHExpFTub_Own_MN_7D, HHExpFPuls_Own_MN_7D, + 
HHExpFVegFrt_Own_MN_7D, HHExpFAnimMeatFishEgg_Own_MN_7D, HHExpFFatsDairy_Own_MN_7D, + 
HHExpFSgrCond_Own_MN_7D, HHExpFBev_Own_MN_7D, HHExpFOut_Own_MN_7D).
COMPUTE HHExp_Food_Own_MN_1M=HHExp_Food_Own_MN_1M*(30/7). /* conversion in monthly terms - do it only if recall period for food was 7 day.
 VARIABLE LABELS HHExp_Food_Own_MN_1M 'Total monthly food consumption from own-production'.
EXECUTE.


*-------------------------------------------------------------------------------*
*2. Create variables for non-food expenditure, by source 	
*-------------------------------------------------------------------------------*

*** 2.a Label variables: 

*1 month recall period - variables labels.
VARIABLE LABELS
 HHExpNFHyg_Purch_MN_1M  'Expenditures on hygiene'
 HHExpNFHyg_GiftAid_MN_1M 'Value of consumed in-kind assistance-gifts - hygiene'
 HHExpNFTranspFuel_Purch_MN_1M 'Expenditures on transport & fuel'
 HHExpNFTranspFuel_GiftAid_MN_1M 'Value of consumed in-kind assistance-gifts - transport & fuel'
 HHExpNFWat_Purch_MN_1M 'Expenditures on water'
 HHExpNFWat_GiftAid_MN_1M 'Value of consumed in-kind assistance-gifts - water'
 HHExpNFDwelSer_Purch_MN_1M 'Expenditures on services related to dwelling'
 HHExpNFDwelSer_GiftAid_MN_1M 'Value of consumed in-kind assistance-gifts - services related to dwelling'
 HHExpNFPhone_Purch_MN_1M 'Expenditures on communication'
 HHExpNFPhone_GiftAid_MN_1M 'Value of consumed in-kind assistance-gifts - communication'
 HHExpNFRecr_Purch_MN_1M 'Expenditures on recreation'
 HHExpNFRecr_GiftAid_MN_1M 'Value of consumed in-kind assistance-gifts - recreation'
 HHExpNFAlcTobac_Purch_MN_1M 'Expenditures on alchol/tobacco'
 HHExpNFAlcTobac_GiftAid_MN_1M 'Value of consumed in-kind assistance-gifts - alcohol/tobacco'.
EXECUTE.
* If the questionnaire included further non-food categories/items label the respective variables
    

*6 months recall period - variables lables.
VARIABLE LABELS
HHExpNFMedServGood_Purch_MN_6M 'Expenditures on health services & medicines and health products'
 HHExpNFMedServGood_GiftAid_MN_6M 'Value of consumed in-kind assistance-gifts - health services & medicines and health products'
 HHExpNFCloth_Purch_MN_6M 'Expenditures on clothing and footwear'
 HHExpNFCloth_GiftAid_MN_6M 'Value of consumed in-kind assistance-gifts - clothing and footwear'
HHExpNFEduFeeGood_Purch_MN_6M 'Expenditures on education services & goods'
HHExpNFEduFeeGood_GiftAid_MN_6M 'Value of consumed in-kind assistance-gifts - education services & goods'
HHExpNFHHSoftMaint_Purch_MN_6M 'Expenditures on non-durable furniture/utensils & household routine maintenance'
HHExpNFHHSoftMaint_GiftAid_MN_6M 'Value of consumed in-kind assistance-gifts - non-durable furniture/utensils & household routine maintenance'.
EXECUTE.

* If the questionnaire included further non-food categories/items label the respective variables.

*** 2.b Calculate total value of non-food expenditures/consumption by source

** Total non-food expenditure (cash/credit)

* 30 days recall.
COMPUTE HHExpNFTotal_Purch_MN_30Dv2=SUM(HHExpNFHyg_Purch_MN_1M, HHExpNFTranspFuel_Purch_MN_1M,  
 HHExpNFWat_Purch_MN_1M, HHExpNFDwelSer_Purch_MN_1M, HHExpNFPhone_Purch_MN_1M, 
 HHExpNFRecr_Purch_MN_1M, HHExpNFAlcTobac_Purch_MN_1M).
EXECUTE.

* 6 months recall.
COMPUTE HHExpNFTotal_Purch_MN_6Mv2=SUM(HHExpNFMedServGood_Purch_MN_6M, HHExpNFCloth_Purch_MN_6M, 
HHExpNFEduFeeGood_Purch_MN_6M, HHExpNFHHSoftMaint_Purch_MN_6M). /* careful with rent: should include only if also incuded in MEB.
EXECUTE.

* Express 6 months in monthly terms.
COMPUTE HHExpNFTotal_Purch_MN_6Mv2=HHExpNFTotal_Purch_MN_6Mv2/6.
EXECUTE.

* Sum.
COMPUTE HHExpNFTotal_Purch_MN_1Mv2=SUM(HHExpNFTotal_Purch_MN_30Dv2, HHExpNFTotal_Purch_MN_6Mv2).
EXECUTE.
 VARIABLE LABELS HHExpNFTotal_Purch_MN_1Mv2 'Total monthly non-food expenditure (cash and credit)'.

delete variables HHExpNFTotal_Purch_MN_6Mv2 HHExpNFTotal_Purch_MN_30Dv2.
EXECUTE.

** Total value of consumed non-food from gift/aid

* 30 days recall.
COMPUTE HHExpNFTotal_GiftAid_MN_30Dv2=SUM(HHExpNFHyg_GiftAid_MN_1M, HHExpNFTranspFuel_GiftAid_MN_1M, HHExpNFWat_GiftAid_MN_1M, 
    HHExpNFDwelSer_GiftAid_MN_1M, HHExpNFPhone_GiftAid_MN_1M, HHExpNFRecr_GiftAid_MN_1M, HHExpNFAlcTobac_GiftAid_MN_1M).
EXECUTE.

* 6 months recall.
COMPUTE HHExpNFTotal_GiftAid_MN_6Mv2=SUM(HHExpNFMedServGood_GiftAid_MN_6M, HHExpNFCloth_GiftAid_MN_6M, 
 HHExpNFEduFeeGood_GiftAid_MN_6M, HHExpNFHHSoftMaint_GiftAid_MN_6M). /* careful with rent: should include only if also incuded in MEB.
EXECUTE.

* Express 6 months in monthly terms.
COMPUTE HHExpNFTotal_GiftAid_MN_6Mv2=HHExpNFTotal_GiftAid_MN_6Mv2/6.
EXECUTE.

* Sum.
COMPUTE HHExpNFTotal_GiftAid_MN_1Mv2=SUM(HHExpNFTotal_GiftAid_MN_30D, HHExpNFTotal_GiftAid_MN_6M).
 VARIABLE LABELS HHExpNFTotal_GiftAid_MN_1Mv2 'Total monthly non-food consumption from gifts/aid'.
 EXECUTE.

delete variables HHExpNFTotal_GiftAid_MN_6Mv2 HHExpNFTotal_GiftAid_MN_30Dv2.
EXECUTE.

*-------------------------------------------------------------------------------*
*3.Calculate total food and non-food consumption expenditures
*-------------------------------------------------------------------------------*

* Aggregate food expenditures, value of consumed food from gifts/assistance, and value of consumed food from own production.
COMPUTE HHExpF_1Mv2=SUM(HHExp_Food_Purch_MN_1Mv2,HHExp_Food_GiftAid_MN_1Mv2, HHExp_Food_Own_MN_1Mv2).
EXECUTE.

*Aggregate NF expenditures and value of consumed non-food from gifts/assistance. 
COMPUTE HHExpNF_1Mv2=SUM(HHExpNFTotal_Purch_MN_1Mv2, HHExpNFTotal_GiftAid_MN_1Mv2).
EXECUTE.
    
*-------------------------------------------------------------------------------*
*4.Compute FES.v2
*-------------------------------------------------------------------------------*

Compute FESv2= HHExpF_1M /SUM(HHExpF_1M , HHExpNF_1M).
EXECUTE.

VARIABLE LABELS FESv2 'Household food expenditure share'.
EXECUTE.

RECODE FESv2 (Lowest thru .4999999=1) (.50 thru .64999999=2) (.65 thru .74999999=3) (.75 thru Highest=4) 
    into Foodexp_4ptv2.
EXECUTE.

Variable labels Foodexp_4ptv2 'Food expenditure share categories (aggregated) version2'.
EXECUTE.

Value labels Foodexp_4ptv2 1 '<50%' 2 '50-65%'  3 '65-75%' 4' > 75%'. 

FREQUENCIES Foodexp_4ptv2.
