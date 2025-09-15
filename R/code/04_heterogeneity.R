# code/04_heterogeneity.R -------------------------------------------------------
suppressPackageStartupMessages({
  library(tidyverse); library(fixest); library(modelsummary); library(broom); library(here)
})
source(here::here("R","utils.R")); log_msg("04_heterogeneity: start")

d <- readRDS(here::here("output","intermediate","analytic_harmonized.rds"))
cluster_var <- cluster_picker(d)

# ------------------------ helpers ----------------------------------------------

has_variation <- function(x) {
  ux <- unique(na.omit(x))
  length(ux) >= 2
}

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

# Fit with interaction: continuous -> feols; binary -> feglm(logit). Skip if no variation.
fit_interaction <- function(df, y, ctrls, interactor, fe = "country", cluster_var = NULL) {
  if (!(y %in% names(df)) || !(interactor %in% names(df))) return(NULL)
  
  # working copy with needed columns
  req <- unique(c("Remote", y, interactor, ctrls, "country"))
  di  <- df %>% select(any_of(req))
  
  # drop rows missing DV or Remote or interactor
  di  <- di %>% drop_na(any_of(c("Remote", y, interactor)))
  if (!nrow(di)) return(NULL)
  
  # if controls exist, drop rows where all controls are NA
  if (length(ctrls)) {
    di <- di %>% filter(rowSums(is.na(across(all_of(ctrls)))) < length(ctrls))
  }
  
  # require variation in DV and in interactor
  if (!has_variation(di[[y]])) {
    log_msg("04_heterogeneity: skip ", y, "×", interactor, " — DV has no variation after filtering")
    return(NULL)
  }
  if (!has_variation(di[[interactor]])) {
    log_msg("04_heterogeneity: skip ", y, "×", interactor, " — interactor has no variation")
    return(NULL)
  }
  
  # ensure interactor is factor for cleaner interactions
  di[[interactor]] <- if (is.factor(di[[interactor]])) droplevels(di[[interactor]]) else factor(di[[interactor]])
  
  # build formula string
  rhs_ctrls <- if (length(ctrls)) paste(ctrls, collapse = " + ") else "1"
  fe_part   <- if (!is.null(fe)) paste0(" | ", fe) else ""
  fml <- as.formula(paste0(y, " ~ Remote*", interactor, " + ", rhs_ctrls, fe_part))
  
  # choose engine by outcome type
  is_binary <- is.logical(di[[y]]) ||
    (is.numeric(di[[y]]) && all(na.omit(di[[y]]) %in% c(0,1))) ||
    (is.factor(di[[y]])  && nlevels(di[[y]]) == 2)
  
  m <- try(
    if (is_binary) {
      feglm(fml, data = di, family = "logit", cluster = cluster_var)
    } else {
      feols(fml, data = di, cluster = cluster_var)
    },
    silent = TRUE
  )
  if (inherits(m, "try-error")) return(NULL)
  m
}

# ------------------------ prepare subgroups & controls --------------------------

# Build asset quintiles only if asset_index exists and varies
if ("asset_index" %in% names(d) && is.numeric(d$asset_index) && has_variation(d$asset_index)) {
  d <- d %>% mutate(asset_q = ntile(asset_index, 5))
}

all_ctrls <- c("HHSize","RESPFemale","HHH_Sex","HHH_Age","HHH_Education","HHUrbRur","asset_index","earners")
ctrls     <- prune_controls(d, all_ctrls, max_na = 0.6)
ctrl_fml  <- if (length(ctrls)) paste(ctrls, collapse = " + ") else "1"
log_msg("04_heterogeneity: controls used -> ", if (length(ctrls)) ctrl_fml else "none")

outcomes <- intersect(c("FCS","rCSI","FES","LCS_crisem"), names(d))

# Which interactors are present?
interactors <- c()
if ("HHH_Sex"   %in% names(d)) interactors <- c(interactors, "HHH_Sex")
if ("HHUrbRur"  %in% names(d)) interactors <- c(interactors, "HHUrbRur")
if ("asset_q"   %in% names(d)) interactors <- c(interactors, "asset_q")

# ------------------------ fit models -------------------------------------------

mods <- list()
for (y in outcomes) {
  for (z in interactors) {
    key <- paste0(z, "_", y)
    mods[[key]] <- fit_interaction(d, y, ctrls, interactor = z, fe = "country", cluster_var = cluster_var)
  }
}

# drop NULLs
mods <- mods[!vapply(mods, is.null, logical(1))]

# ------------------------ export ----------------------------------------------

if (length(mods) == 0) {
  log_msg("04_heterogeneity: no estimable models (skipped all)")
  # write an empty but informative CSV to avoid downstream surprises
  readr::write_csv(tibble(model = character(), term = character(), estimate = numeric(),
                          conf.low = numeric(), conf.high = numeric(), p.value = numeric()),
                   here::here("output","tables","Table5_heterogeneity.csv"))
  write_tex("No heterogeneity models could be estimated (insufficient variation).",
            here::here("output","tables","Table5_heterogeneity.tex"))
} else {
  tex <- modelsummary(
    mods,
    output  = "latex",
    gof_map = c("n","r.squared","rmse","aic","bic"),
    notes   = paste0(
      "Controls: ", if (length(ctrls)) ctrl_fml else "none",
      ". Country FE included. ",
      "SEs clustered at: ", ifelse(is.null(cluster_var), "robust (HC)", cluster_var), ". ",
      "Binary outcomes via feglm(logit). Models with constant DV or no subgroup variation are skipped."
    ),
    stars   = TRUE
  )
  write_tex(tex, here::here("output","tables","Table5_heterogeneity.tex"))
  
  tidied <- purrr::map_df(
    names(mods),
    ~ broom::tidy(mods[[.x]], conf.int = TRUE) %>% mutate(model = .x)
  )
  readr::write_csv(tidied, here::here("output","tables","Table5_heterogeneity.csv"))
}

log_msg("04_heterogeneity: complete")
