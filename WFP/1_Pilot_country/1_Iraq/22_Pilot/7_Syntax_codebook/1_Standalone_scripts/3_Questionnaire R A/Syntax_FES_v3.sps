* Encoding: UTF-8.

* SPSS Syntax for the Food Expenditure Share (FES) indicator (REMOTE A)
 *******************************************************************************
 *Author:Wishah

*-------------------------------------------------------------------------------*
*1. Create variables for food expenditure, by source	
*-------------------------------------------------------------------------------*

*** 1.a Label variables: 

VARIABLE LABELS   
HHExpStap_MNCRD_7D 'Expenditures on staple food (such as cereals, tubers, legumes)'
HHExpStap_GiftAid_7D 'Consumption of staple food (such as cereals, tubers, legumes) from gift or assistance'
HHExpStap_Own_7D 'Consumption of staple food (such as cereals, tubers, legumes) from own production'
HHExpPro_MNCRD_7D 'Expenditures on protein-rich food (such as meat, egg, fish, milk, and dairy product)'
HHExpPro_GiftAid_7D 'Consumption of protein-rich food (such as meat, egg, fish, milk, and dairy product) from gift or assistance'
HHExpPro_Own_7D 'Consumption of protein-rich food (such as meat, egg, fish, milk, and dairy product) from own production'
HHExpFruVeg_MNCRD_7D 'Expenditures on fruits and vegetables'
HHExpFruVeg_GiftAid_7D 'Consumption of fruits and vegetables from gift or assistance'
HHExpFruVeg_Own_7D 'Consumption of fruits and vegetables from own production'
HHExpFOther_MNCRD_7D 'Expenditures on other foods (oil, sugar, nuts, sweets, condiments, drinks, etc.)'
HHExpFOther_GiftAid_7D 'Consumption of other foods (oil, sugar, nuts, sweets, condiments, drinks, etc.) from gift or assistance'
HHExpFOther_Own_7D 'Consumption of other foods (oil, sugar, nuts, sweets, condiments, drinks, etc.) from own production'.


*recall period of _7D or _1M to the variables names below depending on what has been selected for your CO. It is recommended to follow standard recall periods as in the module.

*** 1.b Calculate total value of food expenditures/consumption by source

*If the expenditure recall period is 7 days; make sure to express the newly created variables in monthly terms by multiplying by 30/7

*Monthly food expenditures in cash/credit 

COMPUTE  HHExp_Food_Purch_MN_1M=SUM(HHExpStap_MNCRD_7D, HHExpPro_MNCRD_7D, HHExpFruVeg_MNCRD_7D, HHExpFOther_MNCRD_7D).
    COMPUTE HHExp_Food_Purch_MN_1M=HHExp_Food_Purch_MN_1M*(30/7).  /* conversion in monthly terms - do it only if recall period for food was 7 days.
 VARIABLE LABELS HHExp_Food_Purch_MN_1M 'Total monthly food expenditure (cash and credit)'.
EXECUTE.

*Monthly value of consumed food from gift/aid 

COMPUTE HHExp_Food_GiftAid_MN_1M=SUM(HHExpStap_GiftAid_7D, HHExpFruVeg_GiftAid_7D,HHExpFOther_GiftAid_7D). 
COMPUTE HHExp_Food_GiftAid_MN_1M=HHExp_Food_GiftAid_MN_1M*(30/7). /*conversion in monthly terms - do it only if recall period for food was 7 days.
 VARIABLE LABELS  HHExp_Food_GiftAid_MN_1M 'Total monthly food consumption from gifts/aid'.
EXECUTE.

*Monthly value of consumed food from own-production 

COMPUTE HHExp_Food_Own_MN_1M=SUM(HHExpStap_Own_7D, HHExpPro_Own_7D,HHExpFruVeg_Own_7D, HHExpFOther_Own_7D). 
COMPUTE HHExp_Food_Own_MN_1M=HHExp_Food_Own_MN_1M*(30/7). /* conversion in monthly terms - do it only if recall period for food was 7 day.
 VARIABLE LABELS HHExp_Food_Own_MN_1M 'Total monthly food consumption from own-production'.
EXECUTE.


*-------------------------------------------------------------------------------*
*2. Create variables for non-food expenditure, by source 	
*-------------------------------------------------------------------------------*

*** 2.a Label variables: 

*1 month recall period - variables labels.
VARIABLE LABELS
HHExpNFHyg_MNCRD_1M 'Expenditures on hygiene and personal care items'
HHExpNFHyg_GiftAid_1M 'Consumption of hygiene and personal care items from gift or assistance'
HHExpNFTranspPh_MNCRD_1M 'Expenditures on transportation and communication'
HHExpNFTranspPh_GiftAid_1M 'Consumption of transportation and communication from gift or assistance'
HHExpNFUtilities_MNCRD_1M 'Expenditures on housing and utilities'
HHExpNFUtilities_GiftAid_1M 'Consumption of housing and utilities from gift or assistance'
HHExpNFAlcTobac_MNCRD_1M 'Expenditures on tobacco and alcohol'
HHExpNFAlcTobac_GiftAid_1M 'Consumption of tobacco and alcohol from gift or assistance'
HHExpNFEduMedCloth_MNCRD_1M 'Expenditures on education, health and clothing'
HHExpNFEduMedCloth_GiftAid_1M 'Consumption of education, health and clothing from gift or assistance'. 
    

*** 2.b Calculate total value of non-food expenditures/consumption by source

** Total non-food expenditure (cash/credit)

* 30 days recall.
COMPUTE HHExpNFTotal_Purch_MN_1M=SUM(
 HHExpNFHyg_MNCRD_1M,
HHExpNFTranspPh_MNCRD_1M,
HHExpNFUtilities_MNCRD_1M,
HHExpNFAlcTobac_MNCRD_1M,
HHExpNFEduMedCloth_MNCRD_1M). 
EXECUTE.


** Total value of consumed non-food from gift/aid

* 30 days recall.
COMPUTE HHExpNFTotal_GiftAid_MN_1M=SUM(
HHExpNFHyg_GiftAid_1M,
HHExpNFTranspPh_GiftAid_1M,
HHExpNFUtilities_GiftAid_1M,
HHExpNFAlcTobac_GiftAid_1M,
HHExpNFEduMedCloth_GiftAid_1M). 
EXECUTE.


*-------------------------------------------------------------------------------*
*3.Calculate total food and non-food consumption expenditures
*-------------------------------------------------------------------------------*

* Aggregate food expenditures, value of consumed food from gifts/assistance, and value of consumed food from own production.
COMPUTE HHExpF_1M=SUM(HHExp_Food_Purch_MN_1M,HHExp_Food_GiftAid_MN_1M, HHExp_Food_Own_MN_1M).
EXECUTE.

*Aggregate NF expenditures and value of consumed non-food from gifts/assistance. 
COMPUTE HHExpNF_1M=SUM(HHExpNFTotal_Purch_MN_1M, HHExpNFTotal_GiftAid_MN_1M).
EXECUTE.
    
*-------------------------------------------------------------------------------*
*4.Compute FES
*-------------------------------------------------------------------------------*

Compute FESv3= HHExpF_1M /SUM(HHExpF_1M , HHExpNF_1M).
EXECUTE.

VARIABLE LABELS FESv3 'Household food expenditure share'.
EXECUTE.

RECODE FESv3 (Lowest thru .4999999=1) (.50 thru .64999999=2) (.65 thru .74999999=3) (.75 thru Highest=4) 
    into Foodexp_4ptv3.
EXECUTE.

Variable labels Foodexp_4ptv3 'Food expenditure share categories (aggregated)'.
EXECUTE.

Value labels Foodexp_4ptv3 1 '<50%' 2 '50-65%'  3 '65-75%' 4' > 75%'. 

FREQUENCIES Foodexp_4ptv3.
    
