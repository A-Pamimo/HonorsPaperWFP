
# code/03_main_results.R --------------------------------------------------------
suppressPackageStartupMessages({
  library(tidyverse); library(fixest); library(sandwich); library(clubSandwich)
  library(modelsummary); library(broom); library(here)
})
source(here::here("code","utils.R")); log_msg("03_main_results: start")

d <- readRDS(here::here("output","intermediate","analytic_harmonized.rds"))
cluster_var <- cluster_picker(d)

# Controls present in dataset
ctrls <- intersect(c("HHSize","RESPFemale","HHH_Sex","HHH_Age","HHH_Education","HHUrbRur","asset_index","earners"), names(d))
ctrl_fml <- if (length(ctrls)>0) paste(ctrls, collapse = " + ") else "1"

# Outcomes
outcomes_cont <- intersect(c("FCS","rCSI","FES"), names(d))
outcomes_bin  <- intersect(c("LCS_crisem"), names(d))

mods <- list()

# Pooled with country FE
for (y in outcomes_cont) {
  f <- as.formula(paste0(y, " ~ Remote + ", ctrl_fml, " | country"))
  mods[[paste0("pooled_", y)]] <- feols(f, data = d, cluster = cluster_var)
}

for (y in outcomes_bin) {
  f <- as.formula(paste0(y, " ~ Remote + ", ctrl_fml, " | country"))
  mods[[paste0("pooled_", y)]] <- feols(f, data = d, cluster = cluster_var, family = "binomial")
}

# Country-specific (no FE)
for (ct in unique(d$country)) {
  di <- d %>% filter(country == ct)
  for (y in c(outcomes_cont, outcomes_bin)) {
    f <- as.formula(paste0(y, " ~ Remote + ", ctrl_fml))
    key <- paste0("c_", as.character(ct), "_", y)
    # Use gaussian for numeric; binomial if logical/factor 0/1
    if (y %in% outcomes_bin) {
      mods[[key]] <- feols(f, data = di, cluster = cluster_var, family = "binomial")
    } else {
      mods[[key]] <- feols(f, data = di, cluster = cluster_var)
    }
  }
}

# Export: modelsummary to TeX and Excel-like via data frames
notes <- paste0("Controls: ", ifelse(ctrl_fml=='1','none',ctrl_fml), 
                ". Country FE in pooled models. Clustered SE at: ",
                ifelse(is.null(cluster_var), "robust (HC)", cluster_var), ".")

tex <- modelsummary(mods,
                    output = "latex",
                    gof_map = c("n","r.squared","rmse"),
                    add_rows = data.frame(term = "Notes", ` ` = notes))

# Write TeX
write_tex(tex, here::here("output","tables","Table4_indicators.tex"))

# Also write a tidy sheet with Remote effects
tidied <- purrr::map_df(names(mods), ~ broom::tidy(mods[[.x]], conf.int = TRUE) %>% mutate(model = .x)) %>%
  filter(term %in% c("RemoteRemote"))

readr::write_csv(tidied, here::here("output","tables","Table4_indicators.csv"))
log_msg("03_main_results: complete")
