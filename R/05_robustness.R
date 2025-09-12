
# code/05_robustness.R ----------------------------------------------------------
suppressPackageStartupMessages({
  library(tidyverse); library(fixest); library(MASS); library(modelsummary); library(broom); library(here)
})
source(here::here("code","utils.R")); log_msg("05_robustness: start")

d <- readRDS(here::here("output","intermediate","analytic_harmonized.rds"))
cluster_var <- cluster_picker(d)
ctrls <- intersect(c("HHSize","RESPFemale","HHH_Sex","HHH_Age","HHH_Education","HHUrbRur","asset_index","earners"), names(d))
ctrl_fml <- if (length(ctrls)>0) paste(ctrls, collapse = " + ") else "1"

mods <- list()

# Enumerator FE if available
enum_var <- intersect(c("EnuName","EnuName_Di~y","EnuName_Diay","EnuName_Diry"), names(d))
if (length(enum_var) > 0) {
  for (y in intersect(c("FCS","rCSI","FES","LCS_crisem"), names(d))) {
    f <- as.formula(paste0(y, " ~ Remote + ", ctrl_fml, " | country + ", enum_var[1]))
    mods[[paste0("enumFE_", y)]] <- feols(f, data = d, cluster = cluster_var)
  }
}

# Winsorized FES
if ("FES" %in% names(d)) {
  d <- d %>% mutate(FES_w = winsorize(FES))
  f <- as.formula(paste0("FES_w ~ Remote + ", ctrl_fml, " | country"))
  mods[["FES_w"]] <- feols(f, data = d, cluster = cluster_var)
}

# Categorical: LCS_crisem via logit
if ("LCS_crisem" %in% names(d)) {
  f <- as.formula(paste0("LCS_crisem ~ Remote + ", ctrl_fml, " | country"))
  mods[["LCS_logit"]] <- feglm(f, data = d, family = binomial(), cluster = cluster_var)
}

tex <- modelsummary(mods, output = "latex",
                    gof_map = c("n","r.squared","rmse","aic","bic"))
write_tex(tex, here::here("output","tables","TableA_robustness.tex"))
tidied <- purrr::map_df(names(mods), ~ broom::tidy(mods[[.x]], conf.int = TRUE) %>% mutate(model = .x))
readr::write_csv(tidied, here::here("output","tables","TableA_robustness.csv"))
log_msg("05_robustness: complete")
