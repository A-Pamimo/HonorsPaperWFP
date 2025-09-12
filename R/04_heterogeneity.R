
# code/04_heterogeneity.R -------------------------------------------------------
suppressPackageStartupMessages({
  library(tidyverse); library(fixest); library(modelsummary); library(broom); library(here)
})
source(here::here("R","utils.R")); log_msg("04_heterogeneity: start")

d <- readRDS(here::here("output","intermediate","analytic_harmonized.rds"))
cluster_var <- cluster_picker(d)

# Subgroups
subs <- list(
  female_head = "HHH_Sex",
  urban = "HHUrbRur",
  asset_quint = "asset_index"
)
present <- subs[sapply(subs, function(v) v %in% names(d))]

# Build asset quintiles if present
if (!is.null(present$asset_quint)) {
  d <- d %>% mutate(asset_q = if (is.numeric(.data[[present$asset_quint]])) ntile(.data[[present$asset_quint]], 5) else NA_integer_)
}

outcomes <- intersect(c("FCS","rCSI","FES","LCS_crisem"), names(d))
ctrls <- intersect(c("HHSize","RESPFemale","HHH_Sex","HHH_Age","HHH_Education","HHUrbRur","asset_index","earners"), names(d))
ctrl_fml <- if (length(ctrls)>0) paste(ctrls, collapse = " + ") else "1"

mods <- list()
for (y in outcomes) {
  if ("HHH_Sex" %in% names(d)) {
    f <- as.formula(paste0(y, " ~ Remote*HHH_Sex + ", ctrl_fml, " | country"))
    mods[[paste0("sex_", y)]] <- feols(f, data = d, cluster = cluster_var)
  }
  if ("HHUrbRur" %in% names(d)) {
    f <- as.formula(paste0(y, " ~ Remote*HHUrbRur + ", ctrl_fml, " | country"))
    mods[[paste0("urban_", y)]] <- feols(f, data = d, cluster = cluster_var)
  }
  if ("asset_q" %in% names(d)) {
    f <- as.formula(paste0(y, " ~ Remote*factor(asset_q) + ", ctrl_fml, " | country"))
    mods[[paste0("assetq_", y)]] <- feols(f, data = d, cluster = cluster_var)
  }
}

tex <- modelsummary(mods, output = "latex",
                    gof_map = c("n","r.squared","rmse"))
write_tex(tex, here::here("output","tables","Table5_heterogeneity.tex"))

# CSV
tidied <- purrr::map_df(names(mods), ~ broom::tidy(mods[[.x]], conf.int = TRUE) %>% mutate(model = .x))
readr::write_csv(tidied, here::here("output","tables","Table5_heterogeneity.csv"))
log_msg("04_heterogeneity: complete")
