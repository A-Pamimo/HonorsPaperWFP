* Encoding: UTF-8.

******* CARI & rCARI VALIDATION STUDY *******
   
**********************************
FES shortest version
**********************************

*-------------------------------------------------------------------------------*
*1. Create variables for food expenditure, by source	
*-------------------------------------------------------------------------------*

*recall period of _7D or _1M to the variables names below depending on what has been selected for your CO. It is recommended to follow standard recall periods as in the module.

*** 1.b Calculate total value of food expenditures/consumption by source

*If the expenditure recall period is 7 days; make sure to express the newly created variables in monthly terms by multiplying by 30/7

*Monthly food expenditures in cash/credit 

COMPUTE  HHExp_Food_Purch_MN_1M=HHExpF_MNCRD_7D*(30/7).  /* conversion in monthly terms - do it only if recall period for food was 7 days.
 VARIABLE LABELS HHExp_Food_Purch_MN_1M 'Total monthly food expenditure (cash and credit)'.
EXECUTE.

*Monthly value of consumed food from gift/aid 

COMPUTE HHExp_Food_GiftAid_MN_1M=HHExpF_GiftAid_7D*(30/7). /*conversion in monthly terms - do it only if recall period for food was 7 days.
 VARIABLE LABELS  HHExp_Food_GiftAid_MN_1M 'Total monthly food consumption from gifts/aid'.
EXECUTE.

*Monthly value of consumed food from own-production 

COMPUTE HHExp_Food_Own_MN_1M=HHExpF_Own_7D*(30/7). /* conversion in monthly terms - do it only if recall period for food was 7 day.
 VARIABLE LABELS HHExp_Food_Own_MN_1M 'Total monthly food consumption from own-production'.
EXECUTE.


*-------------------------------------------------------------------------------*
*2.Calculate total food and non-food consumption expenditures
*-------------------------------------------------------------------------------*

* Aggregate food expenditures, value of consumed food from gifts/assistance, and value of consumed food from own production.
COMPUTE HHExpF_1M=SUM(HHExp_Food_Purch_MN_1M,HHExp_Food_GiftAid_MN_1M, HHExp_Food_Own_MN_1M).
EXECUTE.

*Aggregate NF expenditures and value of consumed non-food from gifts/assistance. 
COMPUTE HHExpNF_1M=SUM(HHExpNF_MNCRD_1M, HHExpNF_GiftAid_1M).
EXECUTE.
    
*-------------------------------------------------------------------------------*
*3.Compute FES 
*-------------------------------------------------------------------------------*

Compute FES= HHExpF_1M /SUM(HHExpF_1M , HHExpNF_1M).
EXECUTE.

VARIABLE LABELS FES 'Household food expenditure share'.
EXECUTE.

RECODE FES (Lowest thru .4999999=1) (.50 thru .64999999=2) (.65 thru .74999999=3) (.75 thru Highest=4) 
    into Foodexp_4ptv4.
EXECUTE.

Variable labels Foodexp_4ptv4 'Food expenditure share categories (aggregated)'.
EXECUTE.

Value labels Foodexp_4ptv4 1 '<50%' 2 '50-65%'  3 '65-75%' 4' > 75%'. 

FREQUENCIES Foodexp_4ptv4.
    

