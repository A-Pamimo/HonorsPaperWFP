
# code/01_prepare.R -------------------------------------------------------------
suppressPackageStartupMessages({
  library(tidyverse); library(data.table); library(haven); library(labelled)
  library(janitor); library(stringr); library(lubridate); library(here)
})

source(here::here("code","utils.R")); log_msg("01_prepare: start")

raw_path <- here::here("data","raw","Complete_BF_Household_Analysis.dta")
stopifnot(file.exists(raw_path))

df <- haven::read_dta(raw_path) %>%
  janitor::clean_names()

log_msg("Loaded rows:", nrow(df), " cols:", ncol(df))

# Keep a copy of original names for mapping
names_orig <- names(df)

# --- Variable mapping per system prompt ---------------------------------------
pick_first <- function(df, candidates) {
  for (cand in candidates) {
    # allow regex-like shortnames (with ~)
    c_regex <- gsub("~", ".*", cand)
    hit <- names(df)[str_detect(names(df), fixed(cand, ignore_case = FALSE)) |
                      str_detect(names(df), regex(c_regex, ignore_case = TRUE))]
    if (length(hit) > 0) return(hit[1])
  }
  return(NA_character_)
}

# Modality -> Remote factor(F2F, Remote)
mod_col <- pick_first(df, c("Modality","Modality_T~e","Modality_L~h"))
if (is.na(mod_col)) stop("No modality column found by candidates")
df <- df %>% mutate(Remote = ifelse(.data[[mod_col]] %in% c("Remote","Phone","CATI",1L, "1","remote","phone"), 1L, 0L),
                    Remote = factor(Remote, levels=c(0,1), labels=c("F2F","Remote")))

# Country
country_col <- pick_first(df, c("FCG_Country","FCG_Countr~r","ADMIN1Name","S_Geo_Admin1"))
if (is.na(country_col)) country_col <- "country" # fallback if already harmonized
df <- df %>% mutate(country_raw = .data[[country_col]], country = as_factor_safe(.data[[country_col]]))

# FCS and groups
fcs_col <- pick_first(df, c("FCS"))
fcs_grp <- pick_first(df, c("FCSCat28","FCS_4pt_CARI","FCS_4pt_CA~y"))
df <- df %>% mutate(FCS = suppressWarnings(as.numeric(.data[[fcs_col]])))
if (!is.na(fcs_grp) && fcs_grp %in% names(df)) {
  df <- df %>% mutate(FCS_group = as_factor_safe(.data[[fcs_grp]]))
} else {
  df <- df %>% mutate(FCS_group = cut(FCS, breaks=c(-Inf,21,35,Inf), labels=c("poor","borderline","acceptable")))
}

# rCSI and group
rcsi_col <- pick_first(df, c("rCSI","RCSI","rcsi"))
rcsi_grp <- pick_first(df, c("rCSI_Group"))
if (!is.na(rcsi_col)) df <- df %>% mutate(rCSI = suppressWarnings(as.numeric(.data[[rcsi_col]])))
if (!is.na(rcsi_grp) && rcsi_grp %in% names(df)) {
  df <- df %>% mutate(rCSI_group = as_factor_safe(.data[[rcsi_grp]]))
} else if (!is.na(rcsi_col)) {
  df <- df %>% mutate(rCSI_group = case_when(rCSI <= 4 ~ "low",
                                             rCSI <= 19 ~ "median",
                                             TRUE ~ "severe") %>% factor(levels=c("low","median","severe")))
}

# LCS severity flags
lcs_cat <- pick_first(df, c("LCS_Cat"))
lcs_prefixes <- c("^lcs_","^lcsen_","^lcsen_em_","^lcs_stress","^lcs_crisis","^lcs_em_")
lcs_cols <- names(df)[str_detect(names(df), paste(lcs_prefixes, collapse="|"))]
if (!is.na(lcs_cat) && lcs_cat %in% names(df)) {
  df <- df %>% mutate(LCS_Cat = as_factor_safe(.data[[lcs_cat]]))
}
df <- df %>% mutate(LCS_crisem = if ("LCS_Cat" %in% names(.)) {
                      .data[["LCS_Cat"]] %in% c("Crisis","Emergency")
                    } else if (length(lcs_cols) > 0) {
                      # proxy: if any emergency/crisis coping strategy used (na->FALSE)
                      rowSums(across(all_of(lcs_cols), ~ as.numeric(.x %in% c(1,TRUE,"yes","Yes"))), na.rm = TRUE) > 0
                    } else {
                      NA
                    })

# FES and bands
fes_col <- pick_first(df, c("FES","fes"))
fes_band <- pick_first(df, c("FES_Cat","CARI_FES_Cat","CC_FES_Cat"))
if (!is.na(fes_col)) {
  df <- df %>% mutate(FES = suppressWarnings(as.numeric(.data[[fes_col]])),
                      FES = ifelse(!is.na(FES) & FES > 1, FES/100, FES))
  if (!is.na(fes_band) && fes_band %in% names(df)) {
    df <- df %>% mutate(FES_band = as_factor_safe(.data[[fes_band]]))
  } else {
    df <- df %>% mutate(FES_band = cut(FES, breaks=c(-Inf,0.50,0.65,0.75,Inf),
                                       labels=c("<50%","50–65%","65–75%","≥75%")))
  }
}

# Income (prefer 4-cat CARI_Inc_Cat; else reconstruct)
inc_primary <- pick_first(df, c("CARI_Inc_Cat"))
if (!is.na(inc_primary) && inc_primary %in% names(df)) {
  df <- df %>% mutate(Income4 = as_factor_safe(.data[[inc_primary]]))
} else {
  # crude reconstruction placeholder: document in Appendix A1 after inspecting sources
  alt1 <- pick_first(df, c("CARI_Inc","CARI_Inc_Re","CARI_Inc_Raw","rCARI_Inc_~","HHIncome_3pt","HHIncChg_3pt"))
  df <- df %>% mutate(Income4 = factor(case_when(
    !is.na(.data[[alt1]]) & as.numeric(.data[[alt1]]) <= 1 ~ "lowest",
    !is.na(.data[[alt1]]) & as.numeric(.data[[alt1]]) == 2 ~ "low",
    !is.na(.data[[alt1]]) & as.numeric(.data[[alt1]]) == 3 ~ "medium",
    !is.na(.data[[alt1]]) & as.numeric(.data[[alt1]]) >= 4 ~ "high",
    TRUE ~ NA_character_
  ), levels=c("lowest","low","medium","high")))
}

# Controls (select one proxy per concept if available)
pick_one <- function(cands) {
  hit <- NA_character_
  for (c in cands) {
    c_regex <- gsub("~", ".*", c)
    nm <- names(df)[str_detect(names(df), fixed(c, ignore_case = FALSE)) |
                      str_detect(names(df), regex(c_regex, ignore_case = TRUE))]
    if (length(nm) > 0) { hit <- nm[1]; break }
  }
  hit
}
ctrls <- list(
  HHSize = pick_one(c("HHSize","S_hh_size")),
  RESPFemale = pick_one(c("RESPFemale")),
  HHH_Sex = pick_one(c("HHH_Sex","S_hh_head_~x")),
  HHH_Age = pick_one(c("HHH_Age")),
  HHH_Education = pick_one(c("HHH_Educat~n","HHH_Literate")),
  HHUrbRur = pick_one(c("HHUrbRur")),
  asset_index = pick_one(c("EXP_pctile","WealthSimp~s","WealthBasi~s","WealthAdvE~s","MDD_Index")),
  earners = pick_one(c("R_Num_Adult","R_Num_Male","R_Num_Female"))
)
log_msg("Chosen controls:", paste(names(rlang::compact(ctrls)), collapse=", "))

# Save mapping table
varmap <- tibble(
  analysis_name = c("Remote","country","FCS","FCS_group","rCSI","rCSI_group",
                    "LCS_Cat","LCS_crisem","FES","FES_band","Income4",
                    names(ctrls)),
  source_column = c(mod_col,country_col,fcs_col, ifelse(is.na(fcs_grp),"derived",fcs_grp),
                    rcsi_col, ifelse(is.na(rcsi_grp),"derived",rcsi_grp),
                    lcs_cat,"derived",fes_col, ifelse(is.na(fes_band),"derived",fes_band),
                    ifelse(!is.na(inc_primary), inc_primary, "reconstructed"),
                    unlist(ctrls, use.names = FALSE))
)
readr::write_csv(varmap, here::here("output","intermediate","TableA1_varmap.csv"))

# Build analytic dataset
keep_ctrls <- unlist(ctrls, use.names = FALSE)
analytic <- df %>%
  select(any_of(c("Remote","country","country_raw","FCS","FCS_group","rCSI","rCSI_group",
                  "LCS_Cat","LCS_crisem","FES","FES_band","Income4", keep_ctrls))) %>%
  rename(!!!setNames(keep_ctrls, names(ctrls))) %>%
  mutate(across(where(is.labelled), haven::zap_labels))

saveRDS(analytic, here::here("output","intermediate","analytic_harmonized.rds"))
readr::write_csv(analytic, here::here("output","intermediate","analytic_harmonized.csv"))
log_msg("01_prepare: saved analytic_harmonized.* and varmap")
