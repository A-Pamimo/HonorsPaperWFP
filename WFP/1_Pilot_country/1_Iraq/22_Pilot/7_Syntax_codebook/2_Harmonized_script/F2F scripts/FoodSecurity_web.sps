* Encoding: UTF-8.

 *******************************************************************************
    Number of Meals & Worried 
 *******************************************************************************

*****Meals ******
********define variables:
RESPMeals=1		‘One or none’ 
RESPMeals=2		‘Two’
RESPMeals=3		‘Three or more’
RESPPercFoodSec.4 = 1	‘Went at least one whole day and night without eating’

IF (RESPMeals = 3) CARI_Meals = 1.
IF (RESPMeals = 2) CARI_Meals = 2.
IF (RESPMeals = 1) CARI_Meals = 3.
IF (RESPMeals =1 & RESPPercFoodSec.4 = 1) CARI_Meals = 4.  /* There is no option for zero meals, it is proxied as stated here. 

VALUE LABELS CARI_Meals 
1 'Three meals'
2 'Two meals'
3 'One meal'
4 'No meals'. 
EXECUTE. 

FREQUENCIES CARI_Meals.

*****Worry+Coping*****
********------define variables:
RESPFoodWorry_YN=1 	 ‘In the past 30 days, felt worried about not having enough food to eat?’
RESPFoodWorry_YN=0 	 ‘In the past 30 days, did not feel worried about not having enough food to eat?’
RESPPercFoodSec.3=1 	 ‘Skipped meals or ate less than usual’
RESPPercFoodSec.4=1 	 ‘Went at least one whole day and night without eating’ 

IF (RESPFoodWorry_YN =0) CARI_Worry = 1.
IF (RESPFoodWorry_YN =1) CARI_Worry = 2.
IF (RESPFoodWorry_YN =1 & RESPPercFoodSec.3 =1) CARI_Worry = 3.
IF (RESPFoodWorry_YN =1 & RESPPercFoodSec.4 = 1) CARI_Worry = 4. 

VALUE LABELS CARI_Worry
1 'Not worried'
2 'Worried'
3 'Worried & skipping meals'
4 'Worried & going day/night without eating'.
EXECUTE.

FREQUENCIES CARI_Worry.
