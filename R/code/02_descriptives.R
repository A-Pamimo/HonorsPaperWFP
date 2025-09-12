
# code/02_descriptives.R --------------------------------------------------------
suppressPackageStartupMessages({
  library(tidyverse); library(data.table); library(modelsummary); library(gt); library(here)
})
source(here::here("code","utils.R")); log_msg("02_descriptives: start")

analytic <- readRDS(here::here("output","intermediate","analytic_harmonized.rds"))

# Balance table variables (numeric only + some key shares if present)
bal_vars <- intersect(c("FCS","rCSI","FES","HHSize","HHH_Age"), names(analytic))
bal_extra <- intersect(c("RESPFemale","HHH_Sex","HHUrbRur"), names(analytic))
bal_vars <- unique(c(bal_vars, bal_extra))

bal <- balance_fun(analytic, bal_vars, group = "Remote")

# Pretty table
bal_tbl <- bal %>%
  mutate(across(where(is.numeric), ~ round(.x, 3))) %>%
  select(variable, mean_F2F, sd_F2F, mean_Remote, sd_Remote, diff, p_value)

gt_tbl <- bal_tbl %>% gt() %>%
  tab_header(title = "Table 1. Baseline Balance by Modality") %>%
  fmt_number(columns = where(is.numeric), decimals = 3)

# Write TeX (via gtsave to .tex) and Excel
write_tex(gt_tbl, here::here("output","tables","Table1_Balance.tex"))
write_xlsx_sheets(list(Balance = bal_tbl), here::here("output","tables","Balance_by_country.xlsx"))
log_msg("02_descriptives: complete")
