* Encoding: UTF-8.

********************************************************************************
 CARI VALIDATION STUDY HARMONIZED FS INDICATORS 
********************************************************************************
*Author:Wishah
 

 **************************************************
Food Consumption Score
 **************************************************

***define labels  

Variable labels 
FCSStap          ‘How many days over the last 7 days, did members of your household eat cereals, rains, roots and tubers?’ 
FCSPulse         ‘How many days over the last 7 days, did members of your household eat legumes/nuts?’ 
FCSDairy         ‘How many days over the last 7 days, did members of your household drink/eat milk and other dairy products?’ 
FCSPr              ‘How many days over the last 7 days, did members of your household eat meat, fish and eggs?’ 
FCSVeg           ‘How many days over the last 7 days, did members of your household eat vegetables and leaves?’ 
FCSFruit          ‘How many days over the last 7 days, did members of your household eat fruits?’ 
FCSFat             ‘How many days over the last 7 days, did members of your household consume oil?’ 
FCSSugar        ‘How many days over the last 7 days, did members of your household eat sugar, or sweets?’ 
FCSCond	       ‘How many days over the last 7 days, did members of your household eat condiments / spices?’.

frequencies 
FCSStap          
FCSPulse       
FCSDairy        
FCSPr              
FCSVeg           
FCSFruit          
FCSFat            
FCSSugar        
FCSCond. 

Compute FCS = sum(FCSStap*2, FCSPulse*3, FCSDairy*4, FCSPr*4, FCSVeg*1, FCSFruit*1, FCSFat*0.5, FCSSugar*0.5).  

Variable labels FCS "Food Consumption Score". 
EXECUTE.

*** Use this when analyzing a country with high consumption of sugar and oil – thresholds 28-42

Recode FCS (lowest thru 28 =1) (28.5 thru 42 =2) (42.5 thru highest =3) into FCSCat28.
Variable labels FCSCat28 "FCS Categories".
EXECUTE.

*** define value labels and properties for "FCS Categories".
Value labels FCSCat28 1.00 'Poor' 2.00 'Borderline' 3.00 'Acceptable '.
EXECUTE.


 *******************************************************************************
Reduced Coping Strategy Index
 *******************************************************************************
 
***define variables 

Variable labels
rCSILessQlty        ‘Rely on less preferred and less expensive food in the past 7 days’
rCSIBorrow          ‘Borrow food or rely on help from a relative or friend in the past 7 days’
rCSIMealNb         ‘Reduce number of meals eaten in a day in the past 7 days’
rCSIMealSize       ‘Limit portion size of meals at meal times in the past 7 days’
rCSIMealAdult     ‘Restrict consumption by adults in order for small children to eat in the past 7 days’.

frequencies 
rCSILessQlty 
rCSIBorrow          
rCSIMealNb        
rCSIMealSize
rCSIMealAdult.

Compute rCSI = sum(rCSILessQlty*1,rCSIBorrow*2,rCSIMealNb*1,rCSIMealSize*1,rCSIMealAdult*3).
Variable labels rCSI 'Reduced coping strategies index (rCSI)'.
EXECUTE.

 *******************************************************************************
Combining rCSI with FCS_4pt for CARI calculation (current consumption) 
 *******************************************************************************
    
Recode FCSCat28 (1=4) (2=3) (3=1) INTO FCS_4pt. 
Variable labels FCS_4pt '4pt FCG'.
EXECUTE.

Frequencies VARIABLES=FCS_4pt /ORDER=ANALYSIS. 
Value labels FCS_4pt 1.00 'Acceptable' 3.00 'Borderline' 4.00 'Poor'. 
EXECUTE.

Do if (rCSI  >= 4).
Recode FCS_4pt (1=2).
End if.
EXECUTE.

Value labels FCS_4pt 1.00 'Acceptable' 2.00 ' Acceptable and rCSI>4' 3.00 'Borderline' 4.00 'Poor'. 
EXECUTE.

Frequencies FCS_4pt.

 *******************************************************************************
Economic Vulnerability (INCOME & INCOME CHANGE)
 *******************************************************************************

********------define variables:
Value labels HHIncFirst_SRi
1	Wage Labor - Professional
2	Wage Labor - Skilled
3	Wage Labor - Unskilled/Casual/Agriculture
4	Wage Labor - Unskilled/Casual/non-agriculture
5	Pension
6	Remittances
7	Aid/gifts
8	Borrowing money/Living off debt
9	High risk activity (e.g. begging, scavenging)
10              Saving/selling assets
11	Petty trade/selling on streets
12	Small trade (own business)
13	Medium/large trade (own business)
14	Small Agriculture production including livestock (own land/livestock)
15	Medium/large agriculture production including livestock (own land/livestock)
999	Other (specify).


if ((HHIncFirst_SRi = 1) | (HHIncFirst_SRi=2) | (HHIncFirst_SRi =5) | (HHIncFirst_SRi =12) |
    (HHIncFirst_SRi =13) | (HHIncFirst_SRi =15)) 
   & ((HHIncChg=0) | (HHIncChg=1) | (HHIncChg=5)) CARI_Inc =1.

if ((HHIncFirst_SRi = 1) | (HHIncFirst_SRi=2) | (HHIncFirst_SRi =5) | (HHIncFirst_SRi =12) |
    (HHIncFirst_SRi =13) | (HHIncFirst_SRi =15))   
    & ((HHIncChg=2) | (HHIncChg=3) | (HHIncChg=4)) CARI_Inc =2.

if ((HHIncFirst_SRi =3) | (HHIncFirst_SRi = 4) | 
    (HHIncFirst_SRi = 6) | HHIncFirst_SRi = 11) 
    & ((HHIncChg=0) | (HHIncChg=1) | (HHIncChg=5)) CARI_Inc =2.

if ((HHIncFirst_SRi =3) | (HHIncFirst_SRi = 4) | 
    (HHIncFirst_SRi = 6) | HHIncFirst_SRi = 11) 
    & ((HHIncChg=2) | (HHIncChg=3) | (HHIncChg=4)) CARI_Inc =3.

if (HHIncNb=0) | (HHIncFirst_SRi=7) | (HHIncFirst_SRi =8) | (HHIncFirst_SRi =9) | (HHIncFirst_SRi=10) CARI_Inc =4. 

if (HHIncFirst_SRi =999) CARI_Inc =5.  

    */ If no further information is available, other needs to be set to missing. We suggest either case wise deletion, or to leave economic vulnerability missing, but reweight the other indicators for building the index. 

RECODE CARI_Inc (5=SYSMIS) INTO CARI_Inc.
EXECUTE.

VALUE LABELS CARI_Inc
1 ' Regular employment (formal labour or self-employed) – no change or increase'
2 ' Regular employment but reduced income or informal labour/ remittances no change/ increase'
3 ' Informal labour /remittances but reduced income'
4 ' No income, dependent on assistance or support'.
EXECUTE.


