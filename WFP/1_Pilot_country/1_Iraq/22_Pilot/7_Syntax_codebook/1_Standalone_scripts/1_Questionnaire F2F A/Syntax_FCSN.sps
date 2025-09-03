* Encoding: UTF-8.

*CARI Validation Study 
    **questionnaire A f2f
    **author:Wishah

***************************************************************
Food Consumption Score – Nutrition
***************************************************************

Variable labels 
FCSNPrMeatF	‘Flesh meats consumption over the past 7 days’ 
FCSNPrMeatO	‘Organ meats consumption over the past 7 days’ 
FCSNPrFish       	 ‘Fish/shellfish Consumption over the past 7 days’ 
FCSNPrEggs        	 ‘Eggs consumption over the past 7 days’ 
FCSNVegOrg      	‘Orange vegetables consumption over the past 7 days’ 
FCSNVegGre     	  ‘Dark green leafy vegetables consumption over the past 7 days’ 
FCSNFruiOrg     	‘Orange fruits consumption over the past 7 days’.

frequencies 
FCSNPrMeatF	
FCSNPrMeatO	
FCSNPrFish       	 
FCSNPrEggs        	
FCSNVegOrg      	
FCSNVegGre     	  
FCSNFruiOrg.
    

***compute aggregates of key micronutrient consumption – vitamin, iron and protein
    
Compute FGVitA = sum(FCSDairy, FCSNPrMeatO, FCSNPrEggs, FCSNVegOrg, FCSNVegGre, FCSNFruiOrg).

Variable labels FGVitA 'Consumption of vitamin A-rich foods'.
EXECUTE.
 
Compute FGProtein = sum(FCSPulse, FCSDairy, FCSNPrMeatF, FCSNPrMeatO, FCSNPrFish, FCSNPrEggs).
Variable labels FGProtein 'Consumption of protein-rich foods'.
EXECUTE.

Compute FGHIron = sum(FCSNPrMeatF, FCSNPrMeatO, FCSNPrFish).
Variable labels FGHIron 'Consumption of hem iron-rich foods'.
EXECUTE.

*** recode into nutritious groups 

Recode FGVitA (0=1) (1 thru 6=2) (7 thru 42=3) into FGVitACat.
Variable labels FGVitACat 'Consumption of vitamin A-rich foods'.
EXECUTE.

Recode FGProtein (0=1) (1 thru 6=2) (7 thru 42=3) into FGProteinCat.
Variable labels FGProteinCat 'Consumption of protein-rich foods'.
EXECUTE.

Recode FGHIron (0=1) (1 thru 6=2) (7 thru 42=3) into FGHIronCat.
Variable labels FGHIronCat 'Consumption of hem iron-rich foods'.
EXECUTE.

*** define variables labels and properties for " FGVitACat FGProteinCat FGHIronCat ".

Value labels FGVitACat FGProteinCat FGHIronCat
1.00 '0 times' 2.00 '1-6 times' 3.00 '7 time or more'.
EXECUTE.

frequencies FGVitACat FGProteinCat FGHIronCat.
