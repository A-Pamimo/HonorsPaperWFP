* Encoding: UTF-8.


 *******************************************************************************
Food Consumption Score
 *******************************************************************************

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


*remote A dataset

STRING EnuName_rcod (A20).
recode EnuName (1='Aya salh') (2='Husain yuonis') (3='Fahad salah') (4='Duhah younis') into EnuName_rcod.

frequencies  EnuName_rcod.

rename variables EnuName=EnuName_old. 

recode EnuName_old (1=41) (2=42) (3=43) (4=44) (5=45) into EnuName.
value labels EnuName
41	'Aya salh'
42	'Husain yuonis'
43	'Fahad salah'
44	'Duhah younis'
45	'Waheda jameel'.

*remote B dataset
    
rename variables EnuName=EnuName_old.

RECODE EnuName_old (1=46) (2=47) (3=48) (4=49) (5=50) INTO EnuName.
EXECUTE.

value labels EnuName
46	'Manar younis'
47	'Zina abdulstar'
48	'Safa talal'
49	'Vian khder'
50	'Ahmed mahmood'.

*F2F A & B datasets
    

RECODE EnuName (ELSE=Copy) INTO EnuName_rcod.
EXECUTE.


STRING EnuName_rcod (A25).
recode EnuName
(	1	=	'Taha Nafi'		                  )
(	2	=	'Hamda Sultan Manzil'		)
(	3	=	'Zuhdiya Mohammed Abid'	)
(	4	=	'Sagban NAwfal Khudhier'	)
(	5	=	'Bunyan Younis Ibrahim'		)
(	6	=	'Abeir Muhammid Kheer Ramo'	)
(	7	=	'Muhannad Fahim Mala Hassan'	)
(	8	=	'Lana Sharif Sulaiman'		)
(	9	=	'Saeed Ayoub Al-Said Khalaf'	)
(	10	=	'Shilan Filzour Murad'		)
(	11	=	'Karwan Rasheed Elyas'		)
(	12	=	'Fawaz Barakat Ali'		)
(	13	=	'Frqad Nambr Khudhir'		)
(	14	=	'Lamia Salih Ahmed'		)
(	15	=	'Basma Barakat Qasim'		)
(	16	=	'Izzadin Khalil Abdi'		)
(	17	=	'Muhammid Aziden Abdullah'	)
(	18	=	'Lalikhan Abdulkarim Khalil'	)
(	19	=	'Fatim Bozan Abdullah'		)
(	20	=	'Jima Amin Muhamad Ali'	)
(	21	=	'Sulav Mahmoud Abbas'		)
(	22	=	'Amkeen Bade Ali'		)
(	23	=	'Mohammed Qani Zaidan'	)
(	24	=	'Karim Abdulrahman Yousif'	)
(	25	=	'Dara Abdulaziz Hasso'		)
(	26	=	'Gulstan Shakir'		)
(	27	=	'Faisal Mirza'		)
(	28	=	'Salim Badal Hamid'		)
(	29	=	'Rojeen Naman Khudir'		)
(	30	=	'Dlvin Sabri'		                  )
(	31	=	'Khalat Akram Aulaiman'		)
(	32	=	'Iman Khurshid Sharu'		)
(	33	=	'Masrur Hussein Mustafa'	)
(	34	=	'Farhad Mohammed Saeed'	)
(	35	=	'Ahmed Akram Mohammed'	)
(	36	=	'Dhuha Adnan Mahmoud'		)
(	37	=	'Marwan Rahim Abbas'		)
(	38	=	'Mutaz Attia Mahdi'		)
(	39	=	'Riyadh Ahmed Khalifa'		)
(	40	=	'Yousif Mohammed Ali Saber'	)  into EnuName_rcod.
value labels EnuName_rcod
1	'Taha Nafi'
2	'Hamda Sultan Manzil'
3	'Zuhdiya Mohammed Abid'
4	'Sagban NAwfal Khudhier'
5	'Bunyan Younis Ibrahim'
6	'Abeir Muhammid Kheer Ramo'
7	'Muhannad Fahim Mala Hassan'
8	'Lana Sharif Sulaiman'
9	'Saeed Ayoub Al-Said Khalaf'
10	'Shilan Filzour Murad'
11	'Karwan Rasheed Elyas'
12	'Fawaz Barakat Ali'
13	'Frqad Nambr Khudhir'
14	'Lamia Salih Ahmed'
15	'Basma Barakat Qasim'
16	'Izzadin Khalil Abdi'
17	'Muhammid Aziden Abdullah'
18	'Lalikhan Abdulkarim Khalil'
19	'Fatim Bozan Abdullah'
20	'Jima Amin Muhamad Ali'
21	'Sulav Mahmoud Abbas'
22	'Amkeen Bade Ali'
23	'Mohammed Qani Zaidan'
24	'Karim Abdulrahman Yousif'
25	'Dara Abdulaziz Hasso'
26	'Gulstan Shakir'
27	'Faisal Mirza'
28	'Salim Badal Hamid'
29	'Rojeen Naman Khudir'
30	'Dlvin Sabri'
31	'Khalat Akram Aulaiman'
32	'Iman Khurshid Sharu'
33	'Masrur Hussein Mustafa'
34	'Farhad Mohammed Saeed'
35	'Ahmed Akram Mohammed'
36	'Dhuha Adnan Mahmoud'
37	'Marwan Rahim Abbas'
38	'Mutaz Attia Mahdi'
39	'Riyadh Ahmed Khalifa'
40	'Yousif Mohammed Ali Saber'
41              'Aya salh'
 42             'Husain yuonis' 
43              'Fahad salah' 
44              'Duhah younis'
45              'Zina abdulstar'
 46             'Safa talal' 
47             'Vian khder' 
48               'Ahmed mahmood'.

*Taha Nafi

do if
(	HHID	=	320101005	)	|
(	HHID	=	320101008	)	|
(	HHID	=	320101020	)	|
(	HHID	=	320101024	)	|
(	HHID	=	320101030	)	|
(	HHID	=	320101044	)	|
(	HHID	=	320101064	)	|
(	HHID	=	320101136	)	|
(	HHID	=	3201010170	)	|
(	HHID	=	4200101006	)	|
(	HHID	=	4200101012	)	|
(	HHID	=	4200101029	)	|
(	HHID	=	4200101037	)	|
(	HHID	=	4200101047	)	|
(	HHID	=	4200101048	)	|
(	HHID	=	4200101055	)	|
(	HHID	=	4200101063	)	|
(	HHID	=	4200101072	)	|
(	HHID	=	4200101127	)	.
compute quality_enu_1=1.
else.
compute quality_enu_1=0. 
end if.
EXECUTE.

*Hamda Sultan Manzil

do if
(	HHID	=	320101018	)	|
(	HHID	=	320101021	)	|
(	HHID	=	320101022	)	|
(	HHID	=	320101034	)	|
(	HHID	=	320101046	)	|
(	HHID	=	320101053	)	|
(	HHID	=	320101065	)	|
(	HHID	=	320101073	)	|
(	HHID	=	320101078	)	|
(	HHID	=	320101080	)	|
(	HHID	=	320101091	)	|
(	HHID	=	320101109	)	|
(	HHID	=	320101122	)	|
(	HHID	=	320101135	)	|
(	HHID	=	420010101	)	|
(	HHID	=	420010108	)	|
(	HHID	=	420010112	)	|
(	HHID	=	4200101015	)	|
(	HHID	=	4200101018	)	|
(	HHID	=	4200101020	)	|
(	HHID	=	4200101025	)	|
(	HHID	=	4200101027	)	|
(	HHID	=	4200101030	)	|
(	HHID	=	4200101033	)	|
(	HHID	=	4200101044	)	|
(	HHID	=	4200101046	)	|
(	HHID	=	4200101050	)	|
(	HHID	=	4200101051	)	|
(	HHID	=	4200101058	)	|
(	HHID	=	4200101069	)	|
(	HHID	=	4200101074	)	|
(	HHID	=	4200101079	)	|
(	HHID	=	4200101081	)	|
(	HHID	=	4200101094	)	|
(	HHID	=	4200101100	)	|
(	HHID	=	4200101112	)	|
(	HHID	=	4200101124	)	|
(	HHID	=	4200101131	)	|
(	HHID	=	4200101137	)	.
compute quality_enu_2=1.
else.
compute quality_enu_2=0. 
end if.
EXECUTE.

*Zuhdiya Mohammed Abid

do if
(	HHID	=	320101001	)	|
(	HHID	=	320101011	)	|
(	HHID	=	320101029	)	|
(	HHID	=	320101032	)	|
(	HHID	=	320101036	)	|
(	HHID	=	320101043	)	|
(	HHID	=	320101045	)	|
(	HHID	=	320101054	)	|
(	HHID	=	320101058	)	|
(	HHID	=	320101083	)	|
(	HHID	=	320101088	)	|
(	HHID	=	320101105	)	|
(	HHID	=	320101126	)	|
(	HHID	=	320101131	)	|
(	HHID	=	4200101002	)	|
(	HHID	=	4200101004	)	|
(	HHID	=	4200101008	)	|
(	HHID	=	4200101013	)	|
(	HHID	=	4200101019	)	|
(	HHID	=	4200101036	)	|
(	HHID	=	4200101039	)	|
(	HHID	=	4200101040	)	|
(	HHID	=	4200101041	)	|
(	HHID	=	4200101053	)	|
(	HHID	=	4200101070	)	|
(	HHID	=	4200101076	)	|
(	HHID	=	4200101084	)	|
(	HHID	=	4200101090	)	|
(	HHID	=	4200101104	)	|
(	HHID	=	4200101105	)	|
(	HHID	=	4200101108	)	|
(	HHID	=	4200101120	)	|
(	HHID	=	4200101122	)	|
(	HHID	=	4200101126	)	|
(	HHID	=	4200101129	)	|
(	HHID	=	4200101140	)	.
compute quality_enu_3=1.
else.
compute quality_enu_3=0. 
end if.
EXECUTE.

*Sagban NAwfal Khudhier

do if
(	HHID	=	320101017	)	|
(	HHID	=	320101035	)	|
(	HHID	=	320101060	)	|
(	HHID	=	320101063	)	|
(	HHID	=	4200101001	)	|
(	HHID	=	4200101005	)	|
(	HHID	=	4200101009	)	|
(	HHID	=	4200101010	)	|
(	HHID	=	4200101021	)	|
(	HHID	=	4200101024	)	|
(	HHID	=	4200101032	)	|
(	HHID	=	4200101034	)	|
(	HHID	=	4200101059	)	|
(	HHID	=	4200101061	)	|
(	HHID	=	4200101097	)	|
(	HHID	=	4200101103	)	|
(	HHID	=	4200101121	)	|
(	HHID	=	4200101132	)	.
compute quality_enu_4=1.
else.
compute quality_enu_4=0. 
end if.
EXECUTE.

*Bunyan Younis Ibrahim

do if 
(	HHID	=	320101004	)	|
(	HHID	=	320101006	)	|
(	HHID	=	320101010	)	|
(	HHID	=	320101015	)	|
(	HHID	=	320101025	)	|
(	HHID	=	320101037	)	|
(	HHID	=	320101039	)	|
(	HHID	=	320101040	)	|
(	HHID	=	320101052	)	|
(	HHID	=	320101056	)	|
(	HHID	=	320101059	)	|
(	HHID	=	320101062	)	|
(	HHID	=	320101086	)	|
(	HHID	=	320101087	)	|
(	HHID	=	320101114	)	|
(	HHID	=	320101133	)	|
(	HHID	=	320101141	)	|
(	HHID	=	2100101193	)	|
(	HHID	=	4200101001	)	|
(	HHID	=	4200101002	)	|
(	HHID	=	4200101004	)	|
(	HHID	=	4200101005	)	|
(	HHID	=	4200101006	)	|
(	HHID	=	4200101007	)	|
(	HHID	=	4200101008	)	|
(	HHID	=	4200101009	)	|
(	HHID	=	4200101010	)	|
(	HHID	=	4200101011	)	|
(	HHID	=	4200101012	)	|
(	HHID	=	4200101013	)	|
(	HHID	=	4200101014	)	|
(	HHID	=	4200101015	)	|
(	HHID	=	4200101016	)	|
(	HHID	=	4200101017	)	|
(	HHID	=	4200101020	)	|
(	HHID	=	4200101025	)	|
(	HHID	=	4200101027	)	|
(	HHID	=	4200101028	)	|
(	HHID	=	4200101030	)	|
(	HHID	=	4200101032	)	|
(	HHID	=	4200101037	)	|
(	HHID	=	4200101039	)	|
(	HHID	=	4200101040	)	|
(	HHID	=	4200101041	)	|
(	HHID	=	4200101042	)	|
(	HHID	=	4200101043	)	|
(	HHID	=	4200101044	)	|
(	HHID	=	4200101047	)	|
(	HHID	=	4200101048	)	|
(	HHID	=	4200101051	)	|
(	HHID	=	4200101052	)	|
(	HHID	=	4200101054	)	|
(	HHID	=	4200101055	)	|
(	HHID	=	4200101058	)	|
(	HHID	=	4200101059	)	|
(	HHID	=	4200101062	)	|
(	HHID	=	4200101067	)	|
(	HHID	=	4200101068	)	|
(	HHID	=	4200101070	)	|
(	HHID	=	4200101074	)	|
(	HHID	=	4200101076	)	|
(	HHID	=	4200101078	)	|
(	HHID	=	4200101079	)	|
(	HHID	=	4200101083	)	|
(	HHID	=	4200101084	)	|
(	HHID	=	4200101088	)	|
(	HHID	=	4200101090	)	|
(	HHID	=	4200101093	)	|
(	HHID	=	4200101097	)	|
(	HHID	=	4200101100	)	|
(	HHID	=	4200101101	)	|
(	HHID	=	4200101103	)	|
(	HHID	=	4200101105	)	|
(	HHID	=	4200101106	)	|
(	HHID	=	4200101108	)	|
(	HHID	=	4200101110	)	|
(	HHID	=	4200101112	)	|
(	HHID	=	4200101120	)	|
(	HHID	=	4200101121	)	|
(	HHID	=	4200101124	)	|
(	HHID	=	4200101126	)	|
(	HHID	=	4200101127	)	|
(	HHID	=	4200101129	)	|
(	HHID	=	4200101131	)	|
(	HHID	=	4200101137	)	|
(	HHID	=	4200101140	)	.
compute quality_enu_5=1.
else.
compute quality_enu_5=0. 
end if.
EXECUTE.

do if
(	HHID	=	110101086	)	|
(	HHID	=	110101091	)	|
(	HHID	=	110101095	)	|
(	HHID	=	110101098	)	|
(	HHID	=	110101103	)	|
(	HHID	=	110101107	)	|
(	HHID	=	110101116	)	|
(	HHID	=	110101118	)	|
(	HHID	=	110101146	)	|
(	HHID	=	110101147	)	|
(	HHID	=	110101150	)	|
(	HHID	=	110101165	)	|
(	HHID	=	206701127	)	|
(	HHID	=	207201122	)	|
(	HHID	=	208301111	)	|
(	HHID	=	209701097	)	|
(	HHID	=	1010109000	)	|
(	HHID	=	1010110200	)	|
(	HHID	=	1010110500	)	|
(	HHID	=	2100101134	)	|
(	HHID	=	2100101146	)	|
(	HHID	=	2100101148	)	|
(	HHID	=	2100101154	)	|
(	HHID	=	2100101155	)	|
(	HHID	=	2100101159	)	|
(	HHID	=	2100101161	)	|
(	HHID	=	2100101193	)	|
(	HHID	=	2100101218	)	|
(	HHID	=	2100101224	)	.
compute quality_enu_6=1.
else.
compute quality_enu_6=0. 
end if. 
execute.

*Lana Sharif Sulaiman

do if    
(	HHID	=	10101087	)	|
(	HHID	=	101010096	)	|
(	HHID	=	110101110	)	|
(	HHID	=	110101115	)	|
(	HHID	=	110101117	)	|
(	HHID	=	110101122	)	|
(	HHID	=	110101123	)	|
(	HHID	=	110101129	)	|
(	HHID	=	110101130	)	|
(	HHID	=	110101137	)	|
(	HHID	=	110101142	)	|
(	HHID	=	110101144	)	|
(	HHID	=	110101145	)	|
(	HHID	=	110101149	)	|
(	HHID	=	110101157	)	|
(	HHID	=	110101177	)	|
(	HHID	=	110101178	)	|
(	HHID	=	110101180	)	|
(	HHID	=	110101181	)	|
(	HHID	=	206101133	)	|
(	HHID	=	206201132	)	|
(	HHID	=	206301131	)	|
(	HHID	=	206901125	)	|
(	HHID	=	207401120	)	|
(	HHID	=	207801116	)	|
(	HHID	=	208101113	)	|
(	HHID	=	208401110	)	|
(	HHID	=	208501109	)	|
(	HHID	=	208801106	)	|
(	HHID	=	209001104	)	|
(	HHID	=	209501099	)	|
(	HHID	=	2100101139	)	|
(	HHID	=	2100101145	)	|
(	HHID	=	2100101150	)	|
(	HHID	=	2100101156	)	|
(	HHID	=	2100101164	)	|
(	HHID	=	2100101168	)	.
compute quality_enu_8=1.
else.
compute quality_enu_8=0. 
end if.
execute. 

*9

do if
(	HHID	=	101010094	)	|
(	HHID	=	110101128	)	|
(	HHID	=	208901105	)	|
(	HHID	=	2100101136	)	|
(	HHID	=	2100101147	)	|
(	HHID	=	2100101170	)	|
(	HHID	=	2100101196	)	|
(	HHID	=	2102010092	)	.
compute quality_enu_9=1.
else.
compute quality_enu_9=0. 
end if.
execute. 

*10

do if
(	HHID	=	101011001	)	|
(	HHID	=	101011006	)	|
(	HHID	=	110101119	)	|
(	HHID	=	110101121	)	|
(	HHID	=	110101124	)	|
(	HHID	=	110101127	)	|
(	HHID	=	110101132	)	|
(	HHID	=	110101133	)	|
(	HHID	=	110101135	)	|
(	HHID	=	110101136	)	|
(	HHID	=	110101140	)	|
(	HHID	=	110101154	)	|
(	HHID	=	110101155	)	|
(	HHID	=	110101158	)	|
(	HHID	=	110101167	)	|
(	HHID	=	110101175	)	|
(	HHID	=	110101179	)	|
(	HHID	=	110101182	)	|
(	HHID	=	206501129	)	|
(	HHID	=	206801126	)	|
(	HHID	=	207601118	)	|
(	HHID	=	207701117	)	|
(	HHID	=	208701107	)	|
(	HHID	=	209601098	)	|
(	HHID	=	209801096	)	|
(	HHID	=	2100101149	)	|
(	HHID	=	2100101157	)	|
(	HHID	=	2100101158	)	|
(	HHID	=	2100101163	)	|
(	HHID	=	2100101165	)	|
(	HHID	=	2100101166	)	|
(	HHID	=	2100101167	)	|
(	HHID	=	2100101173	)	|
(	HHID	=	2100101176	)	|
(	HHID	=	2100101181	)	|
(	HHID	=	2100101185	)	|
(	HHID	=	2100101190	)	|
(	HHID	=	2100101192	)	|
(	HHID	=	2100101197	)	|
(	HHID	=	2100101203	)	|
(	HHID	=	2100101215	)	.
compute quality_enu_10=1.
else.
compute quality_enu_10=0. 
end if.
execute. 


*31

do if					
(	HHID	=	110201003	)	|
(	HHID	=	110201018	)	|
(	HHID	=	110201019	)	|
(	HHID	=	110201022	)	|
(	HHID	=	110201028	)	|
(	HHID	=	110201029	)	|
(	HHID	=	110201033	)	|
(	HHID	=	110201038	)	|
(	HHID	=	110201046	)	|
(	HHID	=	110201051	)	|
(	HHID	=	110201052	)	|
(	HHID	=	110201062	)	|
(	HHID	=	110201063	)	|
(	HHID	=	110201068	)	|
(	HHID	=	110201072	)	|
(	HHID	=	110201075	)	|
(	HHID	=	110201078	)	|
(	HHID	=	210201004	)	|
(	HHID	=	210201028	)	|
(	HHID	=	210201037	)	|
(	HHID	=	210201038	)	|
(	HHID	=	210201042	)	|
(	HHID	=	2100201062	)	|
(	HHID	=	2100201070	)	|
(	HHID	=	2100201071	)	|
(	HHID	=	2100201072	)	|
(	HHID	=	2100201082	)	|
(	HHID	=	2100201083	)	|
(	HHID	=	2100201102	)	|
(	HHID	=	2100201106	)	|
(	HHID	=	2100201107	)	|
(	HHID	=	2100201108	)	|
(	HHID	=	2100201117	)	|
(	HHID	=	2100201125	)	|
(	HHID	=	2100201127	)	|
(	HHID	=	2100201129	)	|
(	HHID	=	2100201133	)	|
(	HHID	=	2100201136	)	|
(	HHID	=	2100201142	)	.
compute quality_enu_31 =1.
else.
compute quality_enu_31 =0. 
end if.
EXECUTE.

*32

do if					
(	HHID	=	110201030	)	|
(	HHID	=	110201037	)	|
(	HHID	=	110201041	)	|
(	HHID	=	110201044	)	|
(	HHID	=	110201059	)	|
(	HHID	=	110201060	)	|
(	HHID	=	110201061	)	|
(	HHID	=	110201067	)	|
(	HHID	=	110201069	)	|
(	HHID	=	110201070	)	|
(	HHID	=	110201071	)	|
(	HHID	=	110201085	)	|
(	HHID	=	210201005	)	|
(	HHID	=	210201044	)	|
(	HHID	=	2100201046	)	|
(	HHID	=	2100201050	)	|
(	HHID	=	2100201052	)	|
(	HHID	=	2100201057	)	|
(	HHID	=	2100201066	)	|
(	HHID	=	2100201073	)	|
(	HHID	=	2100201079	)	|
(	HHID	=	2100201080	)	|
(	HHID	=	2100201098	)	|
(	HHID	=	2100201099	)	|
(	HHID	=	2100201100	)	|
(	HHID	=	2100201103	)	|
(	HHID	=	2100201110	)	|
(	HHID	=	2100201121	)	|
(	HHID	=	2100201124	)	|
(	HHID	=	2100201147	)	.
compute quality_enu_32 =1.
else.
compute quality_enu_32 =0. 
end if.
EXECUTE.

*33

do if					
(	HHID	=	110201004	)	|
(	HHID	=	110201021	)	|
(	HHID	=	110201036	)	|
(	HHID	=	110201040	)	|
(	HHID	=	110201043	)	|
(	HHID	=	110201053	)	|
(	HHID	=	110201054	)	|
(	HHID	=	110201065	)	|
(	HHID	=	110201076	)	|
(	HHID	=	110201077	)	|
(	HHID	=	110201079	)	|
(	HHID	=	110201084	)	|
(	HHID	=	110201086	)	|
(	HHID	=	110201094	)	|
(	HHID	=	210201003	)	|
(	HHID	=	210201009	)	|
(	HHID	=	210201014	)	|
(	HHID	=	210201017	)	|
(	HHID	=	210201018	)	|
(	HHID	=	210201045	)	|
(	HHID	=	1102201058	)	|
(	HHID	=	2100201055	)	|
(	HHID	=	2100201058	)	|
(	HHID	=	2100201059	)	|
(	HHID	=	2100201063	)	|
(	HHID	=	2100201064	)	|
(	HHID	=	2100201078	)	|
(	HHID	=	2100201085	)	|
(	HHID	=	2100201090	)	|
(	HHID	=	2100201091	)	|
(	HHID	=	2100201109	)	|
(	HHID	=	2100201130	)	|
(	HHID	=	2100201141	)	.
compute quality_enu_33 =1.
else.
compute quality_enu_33 =0. 
end if.
EXECUTE.

*34
    
do if					
(	HHID	=	110201001	)	|
(	HHID	=	110201006	)	|
(	HHID	=	110201007	)	|
(	HHID	=	110201008	)	|
(	HHID	=	110201011	)	|
(	HHID	=	110201014	)	|
(	HHID	=	110201017	)	|
(	HHID	=	110201020	)	|
(	HHID	=	110201023	)	|
(	HHID	=	110201024	)	|
(	HHID	=	110201026	)	|
(	HHID	=	110201042	)	|
(	HHID	=	110201049	)	|
(	HHID	=	110201056	)	|
(	HHID	=	110201057	)	|
(	HHID	=	110201066	)	|
(	HHID	=	110201074	)	|
(	HHID	=	110201081	)	|
(	HHID	=	110201087	)	|
(	HHID	=	110201093	)	|
(	HHID	=	110201095	)	|
(	HHID	=	210201006	)	|
(	HHID	=	210201011	)	|
(	HHID	=	210201021	)	|
(	HHID	=	210201026	)	|
(	HHID	=	210201027	)	|
(	HHID	=	210201031	)	|
(	HHID	=	210201033	)	|
(	HHID	=	210201034	)	|
(	HHID	=	210201043	)	|
(	HHID	=	2100201061	)	|
(	HHID	=	2100201065	)	|
(	HHID	=	2100201077	)	|
(	HHID	=	2100201081	)	|
(	HHID	=	2100201088	)	|
(	HHID	=	2100201114	)	|
(	HHID	=	2100201116	)	|
(	HHID	=	2100201120	)	.
compute quality_enu_34 =1.
else.
compute quality_enu_34 =0. 
end if.
EXECUTE.

*Ahmed Akram Mohammed

do if
(	HHID	=	110101097	)	|
(	HHID	=	110101113	)	|
(	HHID	=	110101125	)	|
(	HHID	=	110101131	)	|
(	HHID	=	110101139	)	|
(	HHID	=	110101148	)	|
(	HHID	=	110101152	)	|
(	HHID	=	110101163	)	|
(	HHID	=	110101166	)	|
(	HHID	=	110101171	)	|
(	HHID	=	110101176	)	|
(	HHID	=	110101183	)	|
(	HHID	=	110201010	)	|
(	HHID	=	110201013	)	|
(	HHID	=	206401130	)	|
(	HHID	=	206601128	)	|
(	HHID	=	207301121	)	|
(	HHID	=	1010108900	)	|
(	HHID	=	2100101138	)	|
(	HHID	=	2100101142	)	|
(	HHID	=	2100101144	)	|
(	HHID	=	2100101162	)	|
(	HHID	=	2100101175	)	|
(	HHID	=	2100101177	)	|
(	HHID	=	2100101183	)	|
(	HHID	=	2100101186	)	|
(	HHID	=	2100101200	)	|
(	HHID	=	2100101220	).	
compute quality_enu_35 =1.
else.
compute quality_enu_35 =0. 
end if.
EXECUTE.

*36
    
do if					
(	HHID	=	320101147	)	|
(	HHID	=	430201092	)	|
(	HHID	=	430201102	)	|
(	HHID	=	430201144	)	|
(	HHID	=	430201146	)	|
(	HHID	=	430201151	)	|
(	HHID	=	430201168	)	|
(	HHID	=	3300201109	)	|
(	HHID	=	3300201151	)	|
(	HHID	=	3300201171	)	|
(	HHID	=	3300201218	)	|
(	HHID	=	3300201252	)	|
(	HHID	=	3300201326	)	.
compute quality_enu_36 =1.
else.
compute quality_enu_36 =0. 
end if.
EXECUTE.

*37
    
do if					
(	HHID	=	320101165	)	|
(	HHID	=	320101178	)	|
(	HHID	=	320101194	)	|
(	HHID	=	330101094	)	|
(	HHID	=	430201093	)	|
(	HHID	=	430201098	)	|
(	HHID	=	430201103	)	|
(	HHID	=	430201119	)	|
(	HHID	=	430201125	)	|
(	HHID	=	430201130	)	|
(	HHID	=	430201137	)	|
(	HHID	=	430201143	)	|
(	HHID	=	430201160	)	|
(	HHID	=	430201163	)	|
(	HHID	=	430201164	)	|
(	HHID	=	430201178	)	|
(	HHID	=	430201182	)	|
(	HHID	=	430201183	)	|
(	HHID	=	430201189	)	|
(	HHID	=	430201193	)	|
(	HHID	=	3300201135	)	|
(	HHID	=	3300201165	)	|
(	HHID	=	3300201194	)	|
(	HHID	=	3300201203	)	|
(	HHID	=	3300201207	)	|
(	HHID	=	3300201236	)	|
(	HHID	=	3300201242	)	|
(	HHID	=	3300201263	)	|
(	HHID	=	3300201297	)	.
compute quality_enu_37 =1.
else.
compute quality_enu_37 =0. 
end if.
EXECUTE.

*38
    
do if					
(	HHID	=	320101148	)	|
(	HHID	=	320101155	)	|
(	HHID	=	320101162	)	|
(	HHID	=	320101175	)	|
(	HHID	=	320101182	)	|
(	HHID	=	320101185	)	|
(	HHID	=	430201097	)	|
(	HHID	=	430201105	)	|
(	HHID	=	430201107	)	|
(	HHID	=	430201110	)	|
(	HHID	=	430201114	)	|
(	HHID	=	430201116	)	|
(	HHID	=	430201117	)	|
(	HHID	=	430201123	)	|
(	HHID	=	430201132	)	|
(	HHID	=	430201138	)	|
(	HHID	=	430201140	)	|
(	HHID	=	430201141	)	|
(	HHID	=	430201147	)	|
(	HHID	=	430201148	)	|
(	HHID	=	430201149	)	|
(	HHID	=	430201154	)	|
(	HHID	=	430201170	)	|
(	HHID	=	430201173	)	|
(	HHID	=	430201174	)	|
(	HHID	=	430201176	)	|
(	HHID	=	430201179	)	|
(	HHID	=	430201180	)	|
(	HHID	=	430201214	)	|
(	HHID	=	3300201097	)	|
(	HHID	=	3300201117	)	|
(	HHID	=	3300201134	)	|
(	HHID	=	3300201148	)	|
(	HHID	=	3300201154	)	|
(	HHID	=	3300201162	)	|
(	HHID	=	3300201166	)	|
(	HHID	=	3300201179	)	|
(	HHID	=	3300201184	)	|
(	HHID	=	3300201199	)	|
(	HHID	=	3300201234	)	|
(	HHID	=	3300201253	)	|
(	HHID	=	3300201262	)	|
(	HHID	=	3300201304	)	|
(	HHID	=	3300201312	)	|
(	HHID	=	3300201317	)	|
(	HHID	=	3300201328	)	.
compute quality_enu_38 =1.
else.
compute quality_enu_38 =0. 
end if.
EXECUTE.
    
*39

do if					
(	HHID	=	320101151	)	|
(	HHID	=	320101156	)	|
(	HHID	=	320101173	)	|
(	HHID	=	320101193	)	|
(	HHID	=	320101198	)	|
(	HHID	=	430201025	)	|
(	HHID	=	430201091	)	|
(	HHID	=	430201095	)	|
(	HHID	=	430201100	)	|
(	HHID	=	430201104	)	|
(	HHID	=	430201106	)	|
(	HHID	=	430201108	)	|
(	HHID	=	430201109	)	|
(	HHID	=	430201111	)	|
(	HHID	=	430201120	)	|
(	HHID	=	430201121	)	|
(	HHID	=	430201127	)	|
(	HHID	=	430201133	)	|
(	HHID	=	430201134	)	|
(	HHID	=	430201136	)	|
(	HHID	=	430201142	)	|
(	HHID	=	430201145	)	|
(	HHID	=	430201155	)	|
(	HHID	=	430201166	)	|
(	HHID	=	430201177	)	|
(	HHID	=	430201181	)	|
(	HHID	=	430201195	)	|
(	HHID	=	3300201096	)	|
(	HHID	=	3300201138	)	|
(	HHID	=	3300201170	)	|
(	HHID	=	3300201172	)	|
(	HHID	=	3300201178	)	|
(	HHID	=	3300201180	)	|
(	HHID	=	3300201192	)	|
(	HHID	=	3300201201	)	|
(	HHID	=	3300201214	)	|
(	HHID	=	3300201231	)	|
(	HHID	=	3300201259	)	.
compute quality_enu_39=1.
else.
compute quality_enu_39=0. 
end if.
EXECUTE.

*Yousif Mohamed Ali Saber

do if 
(	HHID	=	230201112	)	|
(	HHID	=	320101150	)	|
(	HHID	=	320101170	)	|
(	HHID	=	320101176	)	|
(	HHID	=	430201094	)	|
(	HHID	=	430201096	)	|
(	HHID	=	430201099	)	|
(	HHID	=	430201113	)	|
(	HHID	=	430201115	)	|
(	HHID	=	430201126	)	|
(	HHID	=	430201128	)	|
(	HHID	=	430201129	)	|
(	HHID	=	430201131	)	|
(	HHID	=	430201139	)	|
(	HHID	=	430201150	)	|
(	HHID	=	430201152	)	|
(	HHID	=	430201156	)	|
(	HHID	=	430201157	)	|
(	HHID	=	430201159	)	|
(	HHID	=	430201167	)	|
(	HHID	=	430201171	)	|
(	HHID	=	430201175	)	|
(	HHID	=	430201186	)	|
(	HHID	=	430201213	)	|
(	HHID	=	430201224	)	|
(	HHID	=	3300201108	)	|
(	HHID	=	3300201118	)	|
(	HHID	=	3300201130	)	|
(	HHID	=	3300201137	)	|
(	HHID	=	3300201163	)	|
(	HHID	=	3300201164	)	|
(	HHID	=	3300201182	)	|
(	HHID	=	3300201187	)	|
(	HHID	=	3300201205	)	|
(	HHID	=	3300201227	)	|
(	HHID	=	3300201240	)	|
(	HHID	=	3300201246	)	.
compute quality_enu_40=1.
else.
compute quality_enu_40=0. 
end if.


