********************************************************************************
*					PART 1: Create Clean Variables
*******************************************************************************/
	
	use "${dta}/Iraq_F2F_Household_Analysis.dta", clear
	
	
				   
********************************************************************************
*							PART 2: Summarize Variables
*******************************************************************************/

	estpost summ $var_assets $var_dwell $var_tenure $var_wall $var_roof $var_floor ///
				 $var_toilet $var_cook $var_light $var_water
				 
	estout using "${docs}/Wealth_Index/Iraq_F2F_Group_A_WI_Summary.xls", 		   ///
		   replace cells("count mean sd min max") label

********************************************************************************
*							PART 3: Define WI Variables
*******************************************************************************/
	
	
	*** Elimination of indicator variables with no variation *** 
	// Usually due to low prevalence - mean < 0.01 or sd < 0.2
	
	gl  wi_assets HHAsset_WaterFilter HHAsset_Carpet HHAsset_ElecLamp  HHAsset_ElecStove HHAsset_WaterTank HHAsset_MicroOven HHAsset_Fridge HHAsset_Blender HHAsset_GasHeater HHAsset_ElecFan HHAsset_Freezer HHAsset_AC HHAsset_ElecGen HHAsset_ElecVac HHAsset_WashMachine HHAsset_TickTokCar HHAsset_Taxi HHAsset_PriCarTruck HHAsset_Motor HHAsset_Bicycle		    
	
	gl  wi_house HHDwell_House HHDwell_LeatherTent HHTenure_FreeCon HHTenure_FreeNoCon HHWall_BakedBrick HHWall_UnbakedBrick HHWall_Cement HHWall_PlasticSheet HHRoof_Brick HHRoof_IronSheet HHRoof_Tent HHFloor_Cement HHFloor_Dirt HHFloor_Tiles HHToilet_FlushPit HHToilet_ImprovedPit HHEnerCook_Gas HHEnerLight_Elec HHEnerLight_Gen HHWater_Pipe HHWater_Tube HHWater_Tank
				   
********************************************************************************
*							PART 4: Create Wealth Score
*******************************************************************************/
	
	* Common
	pca $wi_assets $wi_house, factors(1)
	
	predict HHWealth_Score, score
	
	* Percentile & Quintile
	sort 	HHWealth_Score
	pctile 	WI_Ppct = HHWealth_Score, nq(306) genp(WI_Ppercent)
	gen  	WI_Ppercentile = round(WI_Ppercent)
	egen 	WI_Pquin = cut(WI_Ppercentile), at (0,20,40,60,80,100) 
	gen 	WI_Pquintile = (WI_Pquin / 20) + 1 
	
	drop WI_Pquin
	
	lab var HHWealth_Score 	"Household Common Wealth Score PCA"
	lab var WI_Ppct 		"Household wealth score for percentile"
	lab var WI_Ppercent		"Household wealth score raw percentage"
	lab var WI_Ppercentile	"Household wealth score rounded percentage"
	lab var WI_Pquintile	"Household wealth score quintile"
	
	sum 	HHWealth_Score, detail
	hist 	HHWealth_Score, freq
