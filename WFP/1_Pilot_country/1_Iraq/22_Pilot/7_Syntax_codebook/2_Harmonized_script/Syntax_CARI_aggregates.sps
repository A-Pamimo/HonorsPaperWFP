* Encoding: UTF-8.
**************************************************************
    CARI & rCARI syntax 
**************************************************************

****** CARI (WITH FOOD EXPENDITURE F2F A STANDARD) ******

Compute Mean_coping_capacity_FES = MEAN (Max_coping_behaviour, Foodexp_4pt).  
Compute CARI_unrounded_FES = MEAN (FCS_4pt, Mean_coping_capacity_FES). 
Compute CARI_FES = RND (CARI_unrounded_FES).  
Execute. 

Value labels CARI_FES 1 'Food secure'   2 'Marginally food secure'   3 'Moderately food insecure'   4 'Severely food insecure'.
EXECUTE.

Frequencies CARI_FES.

****** CARI (WITH FOOD EXPENDITURE F2F B REDUCED V2) ******

Compute Mean_coping_capacity_FES = MEAN (Max_coping_behaviour, Foodexp_4ptv2).  
Compute CARI_unrounded_FES = MEAN (FCS_4pt, Mean_coping_capacity_FES). 
Compute CARI_FES = RND (CARI_unrounded_FES).  
Execute. 

Value labels CARI_FES 1 'Food secure'   2 'Marginally food secure'   3 'Moderately food insecure'   4 'Severely food insecure'.
EXECUTE.

Frequencies CARI_FES.


****** CARI (WITH FOOD EXPENDITURE REMOTE A REDUCED V3) ******

Compute Mean_coping_capacity_FES = MEAN (Max_coping_behaviour, Foodexp_4ptv3).  
Compute CARI_unrounded_FES = MEAN (FCS_4pt, Mean_coping_capacity_FES). 
Compute CARI_FES = RND (CARI_unrounded_FES).  
Execute. 

Value labels CARI_FES 1 'Food secure'   2 'Marginally food secure'   3 'Moderately food insecure'   4 'Severely food insecure'.
EXECUTE.

Frequencies CARI_FES.

****** CARI (WITH FOOD EXPENDITURE REMOTE B SHORTEST V4) ******

Compute Mean_coping_capacity_FES = MEAN (Max_coping_behaviour, Foodexp_4ptv4).  
Compute CARI_unrounded_FES = MEAN (FCS_4pt, Mean_coping_capacity_FES). 
Compute CARI_FES = RND (CARI_unrounded_FES).  
Execute. 

Value labels CARI_FES 1 'Food secure'   2 'Marginally food secure'   3 'Moderately food insecure'   4 'Severely food insecure'.
EXECUTE.

Frequencies CARI_FES.

****** rCARI CATI (WITH INCOME) ******

Compute Mean_coping_capacity_IncCATI = MEAN (Max_coping_behaviour, CARI_Inc).  
Compute FS_class_unrounded_IncCATI = MEAN (FCS_4pt, Mean_coping_capacity_IncCATI). 
Compute rCARI_IncCATI= RND (FS_class_unrounded_IncCATI).  
value labels rCARI_IncCATI
1 "Food secure" 2 "Marginally food secure" 3"Moderately food insecure" 4 "Severely food insecure".
execute.


