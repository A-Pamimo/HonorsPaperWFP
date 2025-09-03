import pandas as pd
import numpy as np

#%% Food consumption


def FCS(df):
    """Compute Food Consumption Score (FCS)."""
    return df["FCSStap"]*2 + df["FCSPulse"]*3 + df["FCSDairy"]*4 + df["FCSPr"]*4 + df["FCSVeg"]*1 + df["FCSFruit"]*1 + df["FCSFat"]*0.5 + df["FCSSugar"]*0.5


def rCSI(df):
    """Calculate reduced Coping Strategy Index."""
    return df[["rCSILessQlty", "rCSIBorrow", "rCSIMealNb", "rCSIMealSize", "rCSIMealAdult"]].mul([1, 2, 1, 1, 3]).sum(axis=1)


def nutritional_indicators(data):
    """Calculate nutritional indicators."""
    for df in data:
        try:
            df["FGVitA"] = df[["FCSDairy", "FCSNPrMeatO", "FCSNPrEggs",
                               "FCSNVegOrg", "FCSNVegGre", "FCSNFruiOrg"]].sum(axis=1)
            df["FGProtein"] = df[["FCSPulse", "FCSDairy", "FCSNPrMeatF",
                                  "FCSNPrMeatO", "FCSNPrFish", "FCSNPrEggs"]].sum(axis=1)
            df["FGHIron"] = df[["FCSNPrMeatF",
                                "FCSNPrMeatO", "FCSNPrFish"]].sum(axis=1)
            df["FGVitACat"] = pd.cut(df["FGVitA"], bins=[0, 1, 6, np.inf], labels=[
                                     "Never consumed", "Sometimes consumed", "Always consumed"])
            df["FGProteinCat"] = pd.cut(df["FGProtein"], bins=[0, 1, 6, np.inf], labels=[
                                        "Never consumed", "Sometimes consumed", "Always consumed"])
            df["FGHIronCat"] = pd.cut(df["FGHIron"], bins=[0, 1, 6, np.inf], labels=[
                                      "Never consumed", "Sometimes consumed", "Always consumed"])
        except KeyError:
            pass
    return data


#%% LCS Essential needs
def stress_coping_EN(df):
    if (df["LcsEN_stress_DomAsset"] == 20) or (df["LcsEN_stress_DomAsset"] == 30) or (df["LcsEN_stress_CrdtFood"] == 20) or (df["LcsEN_stress_CrdtFood"] == 30) or (df["LcsEN_stress_Saving"] ==20) or (df["LcsEN_stress_Saving"] ==30) or (df["LcsEN_stress_BorrowCash"]  ==20) or (df["LcsEN_stress_BorrowCash"]==30):
        return 1
    else: 
        return 0

def crisis_coping_EN(df):
    if (df["LcsEN_crisis_ProdAssets"] == 20) or (df["LcsEN_crisis_ProdAssets"] ==30) or (df["LcsEN_crisis_HealthEdu"] ==20) or (df["LcsEN_crisis_HealthEdu"]==30) or (df["LcsEN_crisis_OutSchool"] ==20) or (df["LcsEN_crisis_OutSchool"] ==30):
        return 1
    else: 
        return 0

def emergency_coping_EN(df):
    if (df["LcsEN_em_ChildWork"] == 20) or (df["LcsEN_em_ChildWork"] == 30) or (df["LcsEN_em_Begged"] == 20) or (df["LcsEN_em_Begged"] ==30) or (df["LcsEN_em_IllegalAct"] == 20) or (df["LcsEN_em_IllegalAct"] == 30):
        return 1
    else: 
        return 0

def recode_lcs_en(df):
    if df["stress_coping_EN"] == 1:
        return 2
    if df["crisis_coping_EN"] == 1:
        return 3
    if df["emergency_coping_EN"] == 1:
        return 4
    else: 
        return 0

def max_coping_behaviour_en(df):
    if df["stress_coping_EN"] == 0 and df["crisis_coping_EN"] == 0 and df["emergency_coping_EN"] == 0:
        return 1
    else:
        return max( df["stress_coping_EN"], df["crisis_coping_EN"], df["emergency_coping_EN"])

#%%

# LCS Food Security
def stress_coping(df):
    if (df["LcsEN_stress_DomAsset"] == 20) or (df["LcsEN_stress_DomAsset"] == 30) or (df["LcsEN_stress_CrdtFood"] == 20) or (df["LcsEN_stress_CrdtFood"] == 30) or (df["LcsEN_stress_Saving"] ==20) or (df["LcsEN_stress_Saving"] ==30) or (df["LcsEN_stress_BorrowCash"]  ==20) or (df["LcsEN_stress_BorrowCash"]==30):
        return 1
    else: 
        return 0

def crisis_coping(df):
    if (df["LcsEN_crisis_ProdAssets"] == 20) or (df["LcsEN_crisis_ProdAssets"] ==30) or (df["LcsEN_crisis_HealthEdu"] ==20) or (df["LcsEN_crisis_HealthEdu"]==30) or (df["LcsEN_crisis_OutSchool"] ==20) or (df["LcsEN_crisis_OutSchool"] ==30):
        return 1
    else: 
        return 0

def emergency_coping(df):
    if (df["LcsEN_em_ChildWork"] == 20) or (df["LcsEN_em_ChildWork"] == 30) or (df["LcsEN_em_Begged"] == 20) or (df["LcsEN_em_Begged"] ==30) or (df["LcsEN_em_IllegalAct"] == 20) or (df["LcsEN_em_IllegalAct"] == 30):
        return 1
    else: 
        return 0

def recode_lcs(df):
    if df["stress_coping"] == 1:
        return 2
    if df["crisis_coping"] == 1:
        return 3
    if df["emergency_coping"] == 1:
        return 4
    else: 
        return 0

def max_coping_behaviour(df):
    if df["stress_coping"] == 0 and df["crisis_coping"] == 0 and df["emergency_coping"] == 0:
        return 1
    else:
        return max( df["stress_coping"], df["crisis_coping"], df["emergency_coping"])


# LCS Food Security
def stress_coping_fs(df):
    if (df["Lcs_stress_DomAsset"] == 20) or (df["Lcs_stress_DomAsset"] == 30) or (df["Lcs_stress_CrdtFood"] == 20) or (df["Lcs_stress_CrdtFood"] == 30) or (df["Lcs_stress_Saving"] ==20) or (df["Lcs_stress_Saving"] ==30) or (df["Lcs_stress_BorrowCash"]  ==20) or (df["Lcs_stress_BorrowCash"]==30):
        return 1
    else: 
        return 0

def crisis_coping_fs(df):
    if (df["Lcs_crisis_ProdAssets"] == 20) or (df["Lcs_crisis_ProdAssets"] ==30) or (df["Lcs_crisis_HealthEdu"] ==20) or (df["Lcs_crisis_HealthEdu"]==30) or (df["Lcs_crisis_OutSchool"] ==20) or (df["Lcs_crisis_OutSchool"] ==30):
        return 1
    else: 
        return 0

def emergency_coping_fs(df):
    if (df["Lcs_em_ChildWork"] == 20) or (df["Lcs_em_ChildWork"] == 30)or (df["Lcs_em_Begged"] == 20) or (df["Lcs_em_Begged"] ==30) or (df["Lcs_em_IllegalAct"] == 20) or (df["Lcs_em_IllegalAct"] == 30):
        return 1
    else: 
        return 0

def recode_lcs_fs(df):
    if df["stress_coping"] == 1:
        return 2
    if df["crisis_coping"] == 1:
        return 3
    if df["emergency_coping"] == 1:
        return 4
    else: 
        return 0

def max_coping_behaviour_fs(df):
    if df["stress_coping"] == 0 and df["crisis_coping"] == 0 and df["emergency_coping"] == 0:
        return 1
    else:
        return max( df["stress_coping"], df["crisis_coping"], df["emergency_coping"])

#%% Income indicators




#%% Apply indicators


# Apply indicators to dataset
def food_consumption_nutrition_rCSI(data):
    for df in data:
        try:
            df['FCS'] = df.apply(FCS, axis=1)
            df['FCSCat'] = pd.cut(df['FCS'], bins=[-np.inf,  28, 42, np.inf],
                                  labels=['Poor', 'Borderline', 'Acceptable'], precision=2)

            df['rCSI'] = rCSI(df)
            df["rCSICat"] = pd.cut(df["rCSI"], bins=[-np.inf, 3, 18, np.inf],
                                   labels=["Low", "Medium", "High"], precision=2)

            df = nutritional_indicators(data)
        except KeyError:
            pass
    return data

def essential_needs_coping(data):
    for i, df in enumerate(data):
        try:
            df["stress_coping_EN"] = df.apply(stress_coping_EN, axis=1)
            df["crisis_coping_EN"] = df.apply(crisis_coping_EN, axis=1)
            df["emergency_coping_EN"] = df.apply(emergency_coping_EN, axis=1)
            df["stress_coping_EN"] = df.apply(recode_lcs_en, axis=1)
            df["crisis_coping_EN"] = df.apply(recode_lcs_en, axis=1)
            df["emergency_coping_EN"] = df.apply(recode_lcs_en, axis=1)
            df["max_coping_behaviour_EN"] = df.apply(
                max_coping_behaviour_en, axis=1)
        except KeyError:
            # print(f'Error on dataset {i}')
            pass
    return data


def food_security_coping(data):
    for df in data[1:]:
        df["stress_coping"] = df.apply(stress_coping_fs, axis=1)
        df["crisis_coping"] = df.apply(crisis_coping_fs, axis=1)
        df["emergency_coping"] = df.apply(emergency_coping_fs, axis=1)
        df["stress_coping"] = df.apply(recode_lcs_fs, axis=1)
        df["crisis_coping"] = df.apply(recode_lcs_fs, axis=1)
        df["emergency_coping"] = df.apply(recode_lcs_fs, axis=1)
        df["max_coping_behaviour"] = df.apply(max_coping_behaviour_fs, axis=1)
    return data


def cari_income_indicator(data):
    for df in data:
        df["CARI_Inc"] = df.apply(cari_inc, axis=1)
    return data




if __name__ == "__main__":
    pass