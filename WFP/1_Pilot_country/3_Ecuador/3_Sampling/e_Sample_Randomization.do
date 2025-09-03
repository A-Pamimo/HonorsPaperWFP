/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - Myanmar 			   * 
*																 			   *
*  PURPOSE:  			Randomization of Sample 							   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				May 10, 2023										   *
*  LATEST UPDATE: 															   *
*		  																	   *
********************************************************************************
					
	** REQUIRES:	"${sample}/Selected_villages and camps list_rCARI.xlsx"
					
	** CREATES:		"${sample}/Myanmar_rCARI_Sample_Randomization_Results_Shan.xlsx"
					
	** NOTES:		Parroquia "Qtr2 Lhaovo Baptist Church" has 76 households in 
					total, which is below the projected sample size. Thus, we 
					take all households in this village with randomly selected 
					90 households in other villages and equally & randomly 
					assigned them into
						- F2F (45 per village): 	Long (22) vs. Short (23)
						- Remote (45 per village):  Long (22) vs. Short (23)
						
					For "Qtr2 Lhaovo Baptist Church", 38 in each modality and
					19 for each length.

********************************************************************************
*                	PART 1:  INSTALL PACKAGES AND SET UP		               *
*******************************************************************************/


local user_commands ietoolkit iefieldkit sumstats markstat whereis 

	foreach command of local user_commands {
		cap which `command'
		if _rc == 111 ssc install `command'
	} 

*Standardize settings accross users
	ieboilstart, version(17.0)  
	`r(version)'  

	*set global for today
	gl today :	display %tdCCYYNNDD date(c(current_date),"DMY")

********************************************************************************
*				PART 2:  PREPARE FOLDER PATHS AND DEFINE PROGRAMS			   *
*******************************************************************************/

	* add your directory below
	display c(username)	// Get your username and add path to the working folder
	
	global nicole    0
	global alirah    1

	* set the GD Folder
if $nicole {
	global rcari  	"/Users/nicolewu/Library/CloudStorage/OneDrive-WorldFoodProgramme/2_CARI_validation/1_rCARI_study/1_Pilot_country"
	}

	* Alirah to add
if $alirah {
	global rcari  "\Users\alirah.weyori\OneDrive - World Food Programme\2_CARI_validation\1_rCARI_study\1_Pilot_country"
	
	} 
	
	* Subfolder globals
	* -----------------

	gl ecuador 		"${rcari}/5_Ecuador"
	
	gl sample		"${ecuador}/3_Sampling"
	gl analysis 	"${ecuador}/9_Analysis"
		
	gl dta			"${analysis}/1_Data"
	gl dofile		"${analysis}/2_Dofile"
	gl logs 		"${analysis}/3_Log"
	gl temp 		"${analysis}/4_Temp"
	gl tabs 		"${analysis}/5_Tables"
	gl figs 		"${analysis}/6_Figures"
	gl paper 		"${analysis}/8_Manuscript"
	gl docs			"${analysis}/9_Documentation"
	
********************************************************************************
*						PART 3:  RUN RANDOMIZATION - COSTA				       *
********************************************************************************

/*	tempfile test
	
	import excel "${sample}/Myanmar_rCARI_Sample_Randomization_Results_COSTA_test.xlsx", firstrow clear
	
	save `test'
*/
	* Load sample
	*------------
	import excel "${sample}/2023006 BARRIDO Base FINAL - RND.xlsx", 	///
				 sheet("COSTA") firstrow clear
	
	move NombreCompleto_F Calleprincipal
	move Edad Calleprincipal 
	move Género Calleprincipal
				 
	*drop G Samplingsetup I J Random
	ren  cod Index
	
	missings dropvars, force 	// remove extra vars
	missings dropobs , force 	// remove empty observations

	* Set the environment to make randomization replicable
    isid Index, sort 
    set  seed 1239870  //set the random seed for replication
	
	********* Sample selection
	tab Parroquia

	/*
	
      Parroquia |      Freq.     Percent        Cum.
----------------+-----------------------------------
       COLONCHE |         65       14.77       14.77
     EL SALITRE |         61       13.86       28.64
GENERAL VERNAZA |         88       20.00       48.64
     JUNQUILLAL |         74       16.82       65.45
    MANGLARALTO |         76       17.27       82.73
  SIMÓN BOLIVAR |         76       17.27      100.00
----------------+-----------------------------------
          Total |        440      100.00

		  */
	
    bysort Parroquia: gen Sample_RandomNum = uniform() 
	// Generate random values between 0 to 1 
	
	bysort Parroquia: egen Sample_Order = rank(Sample_RandomNum) 
	// Order each observation from small to large
    
	gen 	Sample_Eligible = 1 if Sample_Order<= 90
	replace Sample_Eligible = 2 if mi(Sample_Eligible)
	
	bysort Parroquia: count if Sample_Eligible == 1

	bysort Parroquia: egen TotSample  = max(Sample_Order) if Sample_Eligible == 1
	
    * Assign sample frame to F2F and Remote 
	bysort Parroquia: gen  Modality_RandomNum = uniform() 			if Sample_Eligible == 1
	bysort Parroquia: egen Modality_Order = rank(Modality_RandomNum) if Sample_Eligible == 1
	
    gen 	Modality_Type = (Modality_Order <= TotSample/2) if Sample_Eligible == 1 
	
	********* Form Length 
	bysort Parroquia Modality_Type: gen  Length_RandomNum = uniform() 		  if !mi(Modality_Type)
	bysort Parroquia Modality_Type: egen Length_Order = rank(Length_RandomNum) if !mi(Modality_Type)
	bysort Parroquia Modality_Type: egen TotModality  = max(Length_Order) if Sample_Eligible == 1
	
	gen     Length_Type = (Length_Order <= TotModality/2) if Sample_Eligible == 1
	
	gen UniqueID=.
	rename NombreCompleto_F NombreCompleto
	
	label var Index					"Sample Index"
	label var Cantón 				"ADMIN3"
	label var Parroquia				"Village"
	label var NombreCompleto		"Respondent Name"
	label var UniqueID				"Unique ID"
	label var Sample_RandomNum		"Sample Selection: Random Number"
	label var Sample_Order			"Sample Selection: Order"
	label var Sample_Eligible		"Sample Selection: Eligibility"
	label var TotSample 			"Total number of household by Village"
	label var Modality_RandomNum	"Modality Assignment: Random Number"
	label var Modality_Order		"Modality Assignment: Order"
	label var Modality_Type			"Modality Assignment: Type"
	label var Length_RandomNum		"Form Length Assignment: Random Number"
	label var Length_Order			"Form Length Assignment: Order"
	label var TotModality			"Total number of household by Village and Modality"
	label var Length_Type			"Form Length Assignment: Type"
	
	label def Sample_L	 			1 "Selected"  2 "Not Selected"
	label val Sample_Eligible		Sample_L
		
	label def Modality_L			1 "Remote"	  0 "Face-to-Face"
	label val Modality_Type			Modality_L
	
	label def Length_L				1 "Long Form" 0 "Short Form"
	label val Length_Type			Length_L
	
	sort Sample_Eligible Región Cantón Parroquia Modality_Type Length_Type, stable
	
/*	mmerge Index using `test'	, type(1:1) uname(a_)
*	
	global check_var Sample_RandomNum Sample_Order Sample_Eligible TotSample Modality_RandomNum Modality_Order Modality_Type Length_RandomNum Length_Order TotModality Length_Type
	
foreach var of global check_var {
	assert `var' == a_`var'
}
*/

keep Index Región Cantón Parroquia Edad Género NombreCompleto Numeracióndelacasa Descripciónoreferencia Ustedesellajefedehogar Cuáleselnombrecompletodee Enlaspróximas3semanasenq Cuáleselnumeroconvencional Cuálesunnúmerodecelularal Tieneotronúmerocelulardeal Sample_RandomNum Sample_Order Sample_Eligible TotSample Modality_RandomNum Modality_Order Modality_Type Length_RandomNum Length_Order TotModality Length_Type UniqueID

	export excel using "${sample}/ECU_rCARI_Sample_Randomization_Results_COSTA.xlsx", ///
		   firstrow(variables) replace
		   
********************************************************************************
*						PART 4:  RUN RANDOMIZATION - SIERRA				       *
********************************************************************************

	* Load sample
	*------------
	import excel "${sample}/2023006 BARRIDO Base FINAL - RND.xlsx", ///
				 sheet("SIERRA") firstrow clear
				 
	ren  cod Index
	
	
	move NombreCompleto_F Localidad
	move Género NombreCompleto_F
	move  NombreCompleto_F Género
	move  Edad Género

	missings dropvars, force 	// remove extra vars
	missings dropobs , force 	// remove empty observations

	* Set the environment to make randomization replicable
    isid Index, sort
    set  seed 1239870  //set the random seed for replication
    
	** Generate Admin variables for randomization 
	// combine villages with less households)
	**clonevar VillageAdmin = Parroquia
	  
	
	
	
	********* Sample selection
	
	tab Parroquia
	
/*	                Parroquia |      Freq.     Percent        Cum.
--------------------------+-----------------------------------
                   APUELA |         73       11.61       11.61
                  CEBADAS |         66       10.49       22.10
                  GUAMOTE |         80       12.72       34.82
                  IMANTAG |         95       15.10       49.92
                  PALMIRA |         79       12.56       62.48
                PEÑARRERA |         55        8.74       71.22
                  QUIROGA |         98       15.58       86.80
SEIS DE JULIO DE CUELLAJE |         83       13.20      100.00
--------------------------+-----------------------------------
                    Total |        629      100.00

					*/
	
    bysort Parroquia: gen Sample_RandomNum = uniform() 
	// Generate random values between 0 to 1 
	
	bysort Parroquia: egen Sample_Order = rank(Sample_RandomNum) 
	// Order each observation from small to large
    
	gen 	Sample_Eligible = 1 if Sample_Order<= 98
	replace Sample_Eligible = 2 if mi(Sample_Eligible)
	
	bysort Parroquia: count if Sample_Eligible == 1

	bysort Parroquia: egen TotSample  = max(Sample_Order) if Sample_Eligible == 1
	
    * Assign sample frame to F2F and Remote 
	bysort Parroquia: gen  Modality_RandomNum = uniform() if Sample_Eligible == 1
	bysort Parroquia: egen Modality_Order = rank(Modality_RandomNum) if Sample_Eligible == 1
	
    gen 	Modality_Type = (Modality_Order <= TotSample/2) if Sample_Eligible == 1 
	
	********* Form Length 
	
	bysort Parroquia Modality_Type: gen  Length_RandomNum = uniform() 		  if !mi(Modality_Type)
	bysort Parroquia Modality_Type: egen Length_Order = rank(Length_RandomNum) if !mi(Modality_Type)
	bysort Parroquia Modality_Type: egen TotModality  = max(Length_Order) if Sample_Eligible == 1
	
	gen     Length_Type = (Length_Order <= TotModality/2) if Sample_Eligible == 1
	
	gen UniqueID=.
	rename NombreCompleto_F NombreCompleto
	label var Index					"Sample Index"
	label var Cantón 				"ADMIN3"
	label var Parroquia				"Village"
	label var NombreCompleto		"Respondent Name"
	label var UniqueID				"Unique ID"
	label var Sample_RandomNum		"Sample Selection: Random Number"
	label var Sample_Order			"Sample Selection: Order"
	label var Sample_Eligible		"Sample Selection: Eligibility"
	label var TotSample 			"Total number of household by Village"
	label var Modality_RandomNum	"Modality Assignment: Random Number"
	label var Modality_Order		"Modality Assignment: Order"
	label var Modality_Type			"Modality Assignment: Type"
	label var Length_RandomNum		"Form Length Assignment: Random Number"
	label var Length_Order			"Form Length Assignment: Order"
	label var TotModality			"Total number of household by Village and Modality"
	label var Length_Type			"Form Length Assignment: Type"
	
	
	label def Sample_L	 			1 "Selected"  2 "Not Selected"
	label val Sample_Eligible		Sample_L
		
	label def Modality_L			1 "Remote"	  0 "Face-to-Face"
	label val Modality_Type			Modality_L
	
	label def Length_L				1 "Long Form" 0 "Short Form"
	label val Length_Type			Length_L
	
	
keep Index Región Cantón Parroquia Edad Género NombreCompleto Numeracióndelacasa Descripciónoreferencia Ustedesellajefedehogar Cuáleselnombrecompletodee Enlaspróximas3semanasenq Cuáleselnumeroconvencional Cuálesunnúmerodecelularal Tieneotronúmerocelulardeal Sample_RandomNum Sample_Order Sample_Eligible TotSample Modality_RandomNum Modality_Order Modality_Type Length_RandomNum Length_Order TotModality Length_Type UniqueID
	
	
	sort Sample_Eligible Región Cantón Parroquia Modality_Type Length_Type, stable
	
	export excel using "${sample}/ECU_rCARI_Sample_Randomization_Results_SIERRA.xlsx", ///
		   firstrow(variables) replace

		   
		   
		   
********************************************************************************
*						PART 5:  RUN RANDOMIZATION - ORIENTE			       *
********************************************************************************

	* Load sample
	*------------
	import excel "${sample}/2023006 BARRIDO Base FINAL - RND.xlsx", ///
				 sheet("ORIENTE") firstrow clear
				 
	ren  cod Index
		
	move NombreCompleto_F Localidad
	move Género NombreCompleto_F
	move  NombreCompleto_F Género
	move  Edad Género

	missings dropvars, force 	// remove extra vars
	missings dropobs , force 	// remove empty observations

	* Set the environment to make randomization replicable
    isid Index, sort 
    set  seed 1239870  //set the random seed for replication
    
	** Generate Admin variables for randomization 
	// combine villages with less households)
	**clonevar VillageAdmin = Parroquia
	  
	
		
	********* Sample selection
	tab Parroquia
	
	/*
	             Parroquia |      Freq.     Percent        Cum.
-----------------------+-----------------------------------
               ARAJUNO |        100       23.42       23.42
                LORETO |        127       29.74       53.16
       PUERTO MURIALDO |         62       14.52       67.68
   SAN JOSE DE DAHUANO |         48       11.24       78.92
  SAN JOSÉ DE PAYAMINO |         36        8.43       87.35
SAN VICENTE HUATICOCHA |         54       12.65      100.00
-----------------------+-----------------------------------
                 Total |        427      100.00
*/
	
    bysort Parroquia: gen Sample_RandomNum = uniform() 
	// Generate random values between 0 to 1 
	
	bysort Parroquia: egen Sample_Order = rank(Sample_RandomNum) 
	// Order each observation from small to large
    
	gen 	Sample_Eligible = 1 if Sample_Order<= 120
	replace Sample_Eligible = 2 if mi(Sample_Eligible)
	
	bysort Parroquia: count if Sample_Eligible == 1

	bysort Parroquia: egen TotSample  = max(Sample_Order) if Sample_Eligible == 1
	
    * Assign sample frame to F2F and Remote 
	bysort Parroquia: gen  Modality_RandomNum = uniform() if Sample_Eligible == 1
	bysort Parroquia: egen Modality_Order = rank(Modality_RandomNum) if Sample_Eligible == 1
	
    gen 	Modality_Type = (Modality_Order <= TotSample/2) if Sample_Eligible == 1 
	
	********* Form Length 
	
	bysort Parroquia Modality_Type: gen  Length_RandomNum = uniform() 		  if !mi(Modality_Type)
	bysort Parroquia Modality_Type: egen Length_Order = rank(Length_RandomNum) if !mi(Modality_Type)
	bysort Parroquia Modality_Type: egen TotModality  = max(Length_Order) if Sample_Eligible == 1
	
	gen     Length_Type = (Length_Order <= TotModality/2) if Sample_Eligible == 1
	
	gen UniqueID=.
	rename NombreCompleto_F NombreCompleto
	label var Index					"Sample Index"
	label var Cantón 				"ADMIN3"
	label var Parroquia				"Village"
	label var NombreCompleto		"Respondent Name"
	label var UniqueID				"Unique ID"
	label var Sample_RandomNum		"Sample Selection: Random Number"
	label var Sample_Order			"Sample Selection: Order"
	label var Sample_Eligible		"Sample Selection: Eligibility"
	label var TotSample 			"Total number of household by Village"
	label var Modality_RandomNum	"Modality Assignment: Random Number"
	label var Modality_Order		"Modality Assignment: Order"
	label var Modality_Type			"Modality Assignment: Type"
	label var Length_RandomNum		"Form Length Assignment: Random Number"
	label var Length_Order			"Form Length Assignment: Order"
	label var TotModality			"Total number of household by Village and Modality"
	label var Length_Type			"Form Length Assignment: Type"
	
	
	label def Sample_L	 			1 "Selected"  2 "Not Selected"
	label val Sample_Eligible		Sample_L
		
	label def Modality_L			1 "Remote"	  0 "Face-to-Face"
	label val Modality_Type			Modality_L
	
	label def Length_L				1 "Long Form" 0 "Short Form"
	label val Length_Type			Length_L
	
	
keep Index Región Cantón Parroquia Edad Género NombreCompleto Numeracióndelacasa Descripciónoreferencia Ustedesellajefedehogar Cuáleselnombrecompletodee Enlaspróximas3semanasenq Cuáleselnumeroconvencional Cuálesunnúmerodecelularal Tieneotronúmerocelulardeal Sample_RandomNum Sample_Order Sample_Eligible TotSample Modality_RandomNum Modality_Order Modality_Type Length_RandomNum Length_Order TotModality Length_Type UniqueID
	
	
	sort Sample_Eligible Región Cantón Parroquia Modality_Type Length_Type, stable
	
	export excel using "${sample}/ECU_rCARI_Sample_Randomization_Results_ORIENTE.xlsx", ///
		   firstrow(variables) replace

		   
		   
		   
*************************************************************************************************************   
 *		   2ND PHASE RANDOMIZATION  To make up for the shortfall in the first round of interviews			*
 *																								 *			*
*************************************************************************************************************

********************************************************************************
*						PART 6:  RUN RANDOMIZATION - SIERRA				       *
********************************************************************************

/*	tempfile test
	
	import excel "${sample}/Myanmar_rCARI_Sample_Randomization_Results_COSTA_test.xlsx", firstrow clear
	
	save `test'
*/
	* Load sample
	*------------
	import excel "${sample}/Base_nuevo_barrido_PMA_2nd phase.xlsx", 	///
				 sheet("PMA") firstrow clear
	
				 
	*drop G Samplingsetup I J Random
	ren  ID Index
	
	missings dropvars, force 	// remove extra vars
	missings dropobs , force 	// remove empty observations

	* Set the environment to make randomization replicable
    isid Index, sort 
    set  seed 1239870  //set the random seed for replication
	
	********* Sample selection
	tab PARROQUIA
	ren PARROQUIA Parroquia

	/*
	
        Village |      Freq.     Percent        Cum.
----------------+-----------------------------------
        CEBADAS |         37        7.10        7.10
        Columbe |         59       11.32       18.43
     EL SALITRE |         48        9.21       27.64
        IMANTAG |         58       11.13       38.77
         LORETO |         39        7.49       46.26
    MANGLARALTO |         70       13.44       59.69
       PALMIRA  |         44        8.45       68.14
PUERTO MURIALDO |         72       13.82       81.96
        QUIROGA |         94       18.04      100.00
----------------+-----------------------------------
          Total |        521      100.00
		  */
	
    bysort Parroquia: gen Sample_RandomNum = uniform() 
	// Generate random values between 0 to 1 
	
	bysort Parroquia: egen Sample_Order = rank(Sample_RandomNum) 
	// Order each observation from small to large
    
	gen 	Sample_Eligible = 1 if Sample_Order<= 100
	replace Sample_Eligible = 2 if mi(Sample_Eligible)
	
	bysort Parroquia: count if Sample_Eligible == 1

	bysort Parroquia: egen TotSample  = max(Sample_Order) if Sample_Eligible == 1
	
    * Assign sample frame to F2F and Remote 
	bysort Parroquia: gen  Modality_RandomNum = uniform() 			if Sample_Eligible == 1
	bysort Parroquia: egen Modality_Order = rank(Modality_RandomNum) if Sample_Eligible == 1
	
    gen 	Modality_Type = (Modality_Order <= TotSample/2) if Sample_Eligible == 1 
	
	********* Form Length 
	bysort Parroquia Modality_Type: gen  Length_RandomNum = uniform() 		  if !mi(Modality_Type)
	bysort Parroquia Modality_Type: egen Length_Order = rank(Length_RandomNum) if !mi(Modality_Type)
	bysort Parroquia Modality_Type: egen TotModality  = max(Length_Order) if Sample_Eligible == 1
	
	gen     Length_Type = (Length_Order <= TotModality/2) if Sample_Eligible == 1
	
	gen UniqueID=.
	
	
	label var Index					"Sample Index"
	label var CANTON 				"ADMIN3"
	label var Parroquia				"Village"
	label var NOMBRE				"Respondent Name"
	label var UniqueID				"Unique ID"
	label var Sample_RandomNum		"Sample Selection: Random Number"
	label var Sample_Order			"Sample Selection: Order"
	label var Sample_Eligible		"Sample Selection: Eligibility"
	label var TotSample 			"Total number of household by Village"
	label var Modality_RandomNum	"Modality Assignment: Random Number"
	label var Modality_Order		"Modality Assignment: Order"
	label var Modality_Type			"Modality Assignment: Type"
	label var Length_RandomNum		"Form Length Assignment: Random Number"
	label var Length_Order			"Form Length Assignment: Order"
	label var TotModality			"Total number of household by Village and Modality"
	label var Length_Type			"Form Length Assignment: Type"
	
	label def Sample_L	 			1 "Selected"  2 "Not Selected"
	label val Sample_Eligible		Sample_L
		
	label def Modality_L			1 "Remote"	  0 "Face-to-Face"
	label val Modality_Type			Modality_L
	
	label def Length_L				1 "Long Form" 0 "Short Form"
	label val Length_Type			Length_L
	
	sort Sample_Eligible CANTON Parroquia Modality_Type Length_Type, stable
	
/*	mmerge Index using `test'	, type(1:1) uname(a_)
*	
	global check_var Sample_RandomNum Sample_Order Sample_Eligible TotSample Modality_RandomNum Modality_Order Modality_Type Length_RandomNum Length_Order TotModality Length_Type
	
foreach var of global check_var {
	assert `var' == a_`var'
}
*/

keep CEL CEL2 Index REGION CANTON Parroquia LOCALIDAD GEOLatitude GEOLongitude GEOAltitude GEOAccuracy Estado_civil Nivel_Educación Años_educación Númer_miembros_hogar Núm_niños_menores_a_15_años mayores_60_años Personas_discapacidad GENERO EDAD NOMBRE NOMBRE2  Sample_RandomNum Sample_Order Sample_Eligible TotSample Modality_RandomNum Modality_Order Modality_Type Length_RandomNum Length_Order TotModality Length_Type UniqueID


	export excel using "${sample}/ECU_rCARI_Sample_Randomization_Phase2.xlsx", ///
		   firstrow(variables) replace
		   
		   
		   
		   
********************************************************************************	   
****Second batch of the phase 2	
****
***Date 09/07/2023  
********************************************************************************
*						PART 6:  RUN RANDOMIZATION - SIERRA				       *
********************************************************************************

/*	tempfile test
	
	import excel "${sample}/Myanmar_rCARI_Sample_Randomization_Results_COSTA_test.xlsx", firstrow clear
	
	save `test'
*/
	* Load sample
	*------------
	import excel "${sample}/BASE_NUEVO_BARRIDO_PARTE2.xlsx", sheet("PMA_P2") firstrow clear
	
	ren  id Index
	
	missings dropvars, force 	// remove extra vars
	missings dropobs , force 	// remove empty observations

	* Set the environment to make randomization replicable
    isid Index, sort 
    set  seed 1239870  //set the random seed for replication
	
	********* Sample selection
	tab Parroquia
	tab REGION

	/*
	
             Parroquia |      Freq.     Percent        Cum.
-----------------------+-----------------------------------
               Arajuno |         41       12.39       12.39
       GENERAL VERNAZA |         18        5.44       17.82
            JUNQUILLAL |         41       12.39       30.21
SAN JOSE DE QUICHINCHE |         64       19.34       49.55
    SAN JUAN DE ILUMAN |         78       23.56       73.11
         SIMÓN BOLIVAR |         89       26.89      100.00
-----------------------+-----------------------------------
                 Total |        331      100.00
		  */
		  
		  
/*		  .         tab REGION

     REGION |      Freq.     Percent        Cum.
------------+-----------------------------------
   AMAZONIA |         41       12.39       12.39
      COSTA |        148       44.71       57.10
     SIERRA |        142       42.90      100.00
------------+-----------------------------------
      Total |        331      100.00
*/


*dropping households with incomplete listing information.

tab ESTADO
/*
     ESTADO |      Freq.     Percent        Cum.
------------+-----------------------------------
   COMPLETO |        323       97.58       97.58
 INCOMPLETO |          8        2.42      100.00
------------+-----------------------------------
      Total |        331      100.00
*/

drop if ESTADO=="INCOMPLETO" 		//8 households with incomplete data dropped from the sample

	
    bysort Parroquia: gen Sample_RandomNum = uniform() 
	// Generate random values between 0 to 1 
	
	bysort Parroquia: egen Sample_Order = rank(Sample_RandomNum) 
	// Order each observation from small to large
    
	gen 	Sample_Eligible = 1 if Sample_Order<= 90
	replace Sample_Eligible = 2 if mi(Sample_Eligible)
	
	bysort Parroquia: count if Sample_Eligible == 1

	bysort Parroquia: egen TotSample  = max(Sample_Order) if Sample_Eligible == 1
	
    * Assign sample frame to F2F and Remote 
	bysort Parroquia: gen  Modality_RandomNum = uniform() 			if Sample_Eligible == 1
	bysort Parroquia: egen Modality_Order = rank(Modality_RandomNum) if Sample_Eligible == 1
	
    gen 	Modality_Type = (Modality_Order <= TotSample/2) if Sample_Eligible == 1 
	
	********* Form Length 
	bysort Parroquia Modality_Type: gen  Length_RandomNum = uniform() 		  if !mi(Modality_Type)
	bysort Parroquia Modality_Type: egen Length_Order = rank(Length_RandomNum) if !mi(Modality_Type)
	bysort Parroquia Modality_Type: egen TotModality  = max(Length_Order) if Sample_Eligible == 1
	
	gen     Length_Type = (Length_Order <= TotModality/2) if Sample_Eligible == 1
	
	gen UniqueID=.
	
	
	label var Index					"Sample Index"
	label var Ciudad 				"ADMIN3"
	label var Parroquia				"Village"
	label var Nombrecompleto		"Respondent Name"
	label var UniqueID				"Unique ID"
	label var Sample_RandomNum		"Sample Selection: Random Number"
	label var Sample_Order			"Sample Selection: Order"
	label var Sample_Eligible		"Sample Selection: Eligibility"
	label var TotSample 			"Total number of household by Village"
	label var Modality_RandomNum	"Modality Assignment: Random Number"
	label var Modality_Order		"Modality Assignment: Order"
	label var Modality_Type			"Modality Assignment: Type"
	label var Length_RandomNum		"Form Length Assignment: Random Number"
	label var Length_Order			"Form Length Assignment: Order"
	label var TotModality			"Total number of household by Village and Modality"
	label var Length_Type			"Form Length Assignment: Type"
	
	label def Sample_L	 			1 "Selected"  2 "Not Selected"
	label val Sample_Eligible		Sample_L
		
	label def Modality_L			1 "Remote"	  0 "Face-to-Face"
	label val Modality_Type			Modality_L
	
	label def Length_L				1 "Long Form" 0 "Short Form"
	label val Length_Type			Length_L
	
	sort Sample_Eligible REGION PROVINCIA Parroquia Modality_Type Length_Type, stable
	
/*	mmerge Index using `test'	, type(1:1) uname(a_)
*	
	global check_var Sample_RandomNum Sample_Order Sample_Eligible TotSample Modality_RandomNum Modality_Order Modality_Type Length_RandomNum Length_Order TotModality Length_Type
	
foreach var of global check_var {
	assert `var' == a_`var'
}
*/

keep Index REGION PROVINCIA Ciudad Parroquia GEOLatitude GEOLongitude GEOAltitude GEOAccuracy Calleprincipal Callesecundaria Nombrecompleto Género Edad Estadocivil Niveldeeducación Añosdeeducación Númerodemiembrosdelhogar Númerodeniñosmenoresa15año Númerodemiembrosmayoresa60 Personascondiscapacidad Personascontrabajoformal Sample_RandomNum Sample_Order Sample_Eligible TotSample Modality_RandomNum Modality_Order Modality_Type Length_RandomNum Length_Order TotModality Length_Type UniqueID


	export excel using "${sample}/ECU_rCARI_Sample_Randomization_20230711.xlsx", ///
		   firstrow(variables) replace