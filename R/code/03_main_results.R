# code/03_main_results.R --------------------------------------------------------
suppressPackageStartupMessages({
  library(tidyverse)
  library(fixest)      # feols / feglm
  library(sandwich)
  library(clubSandwich)
  library(modelsummary)
  library(broom)
  library(here)
})
source(here::here("R","utils.R")); log_msg("03_main_results: start")

d <- readRDS(here::here("output","intermediate","analytic_harmonized.rds"))
cluster_var <- cluster_picker(d)

# ------------------------ helpers ----------------------------------------------

# keep only controls that are not crazy-missing and have variation
prune_controls <- function(df, candidates, max_na = 0.6) {
  present <- intersect(candidates, names(df))
  if (!length(present)) return(character(0))
  keep <- c()
  for (v in present) {
    x <- df[[v]]
    na_rate <- mean(is.na(x))
    has_var <- (is.numeric(x) && sd(x, na.rm = TRUE) > 0) ||
      (is.factor(x)  && nlevels(droplevels(x)) > 1) ||
      (is.character(x) && length(unique(na.omit(x))) > 1) ||
      (is.logical(x) && length(unique(na.omit(x))) > 1)
    if (na_rate <= max_na && has_var) keep <- c(keep, v)
  }
  keep
}

# return TRUE if y has at least two distinct values after filtering
has_variation <- function(x) {
  ux <- unique(na.omit(x))
  length(ux) >= 2
}

# build formula string with optional FE part
make_fe_fml <- function(lhs, rhs_terms, fe = NULL) {
  rhs <- if (length(rhs_terms)) paste(rhs_terms, collapse = " + ") else "1"
  if (is.null(fe)) as.formula(paste0(lhs, " ~ Remote + ", rhs))
  else             as.formula(paste0(lhs, " ~ Remote + ", rhs, " | ", fe))
}

# fit one model (continuous -> feols; binary -> feglm/logit), skip if no variation
fit_one <- function(df, y, ctrls, fe = NULL, cluster_var = NULL) {
  # rows we can actually use
  req <- c("Remote", y, ctrls)
  di  <- df %>% select(any_of(req), country) %>% drop_na(Remote, all_of(y))
  if (!nrow(di)) return(NULL)
  
  # if controls exist, drop rows where all controls are NA
  if (length(ctrls)) {
    di <- di %>% filter(rowSums(is.na(across(all_of(ctrls)))) < length(ctrls))
  }
  
  if (!has_variation(di[[y]])) {
    log_msg("03_main_results: skipping ", y, " — dependent has no variation after filtering")
    return(NULL)
  }
  
  # choose engine by outcome type
  is_binary <- is.logical(di[[y]]) ||
    (is.numeric(di[[y]]) && all(na.omit(di[[y]]) %in% c(0,1))) ||
    (is.factor(di[[y]])  && nlevels(di[[y]]) == 2)
  
  # build formula
  f <- make_fe_fml(y, ctrls, fe)
  
  if (is_binary) {
    # feglm with logit link; fallback to LPM if something blocks MLE
    m <- try(suppressWarnings(feglm(f, data = di, family = "logit",
                                    cluster = cluster_var)), silent = TRUE)
    if (inherits(m, "try-error")) {
      log_msg("03_main_results: feglm failed for ", y, " — falling back to LPM")
      m <- try(suppressWarnings(feols(f, data = di, cluster = cluster_var)), silent = TRUE)
      if (inherits(m, "try-error")) return(NULL)
    }
  } else {
    m <- try(suppressWarnings(feols(f, data = di, cluster = cluster_var)), silent = TRUE)
    if (inherits(m, "try-error")) return(NULL)
  }
  m
}

# ------------------------ controls & outcomes ----------------------------------

all_ctrls <- c("HHSize","RESPFemale","HHH_Sex","HHH_Age","HHH_Education","HHUrbRur","asset_index","earners")
ctrls     <- prune_controls(d, all_ctrls, max_na = 0.6)
ctrl_fml  <- if (length(ctrls)) paste(ctrls, collapse = " + ") else "1"
log_msg("03_main_results: controls used -> ", if (length(ctrls)) ctrl_fml else "none")

outcomes_cont <- intersect(c("FCS","rCSI","FES"), names(d))
outcomes_bin  <- intersect(c("LCS_crisem"), names(d)) # can be empty if missing

# ------------------------ fit models -------------------------------------------

mods <- list()

# pooled with country FE
fe_str <- "country"
for (y in outcomes_cont) {
  mods[[paste0("pooled_", y)]] <- fit_one(d, y, ctrls, fe = fe_str, cluster_var = cluster_var)
}
for (y in outcomes_bin) {
  mods[[paste0("pooled_", y)]] <- fit_one(d, y, ctrls, fe = fe_str, cluster_var = cluster_var)
}

# country-specific (no FE)
if ("country" %in% names(d)) {
  for (ct in unique(d$country)) {
    di <- d %>% filter(country == ct)
    for (y in c(outcomes_cont, outcomes_bin)) {
      key <- paste0("c_", as.character(ct), "_", y)
      mods[[key]] <- fit_one(di, y, ctrls, fe = NULL, cluster_var = cluster_var)
    }
  }
}

# drop NULLs (skipped/failed fits)
mods <- mods[!vapply(mods, is.null, logical(1))]

# ------------------------ export ----------------------------------------------

notes <- paste0(
  "Controls: ", if (length(ctrls)) ctrl_fml else "none",
  ". Pooled models include country FE. ",
  "SEs clustered at: ", ifelse(is.null(cluster_var), "robust (HC)", cluster_var), ". ",
  "Binary outcomes estimated via feglm(logit) when possible; fallback to LPM if needed. ",
  "Models with constant dependent variables were skipped."
)

tex <- modelsummary(
  mods,
  output = "latex",
  gof_map = c("n","r.squared","rmse","aic","bic"),
  notes = notes,                 # use notes= (simpler than add_rows)
  stars = TRUE
)

write_tex(tex, here::here("output","tables","Table4_indicators.tex"))

tidied <- purrr::map_df(
  names(mods),
  ~ broom::tidy(mods[[.x]], conf.int = TRUE) %>% mutate(model = .x)
) %>% filter(term %in% c("RemoteRemote","Remote"))

readr::write_csv(tidied, here::here("output","tables","Table4_indicators.csv"))
log_msg("03_main_results: complete")
