# code/04_heterogeneity.R -------------------------------------------------------
suppressPackageStartupMessages({
  library(tidyverse); library(fixest); library(modelsummary); library(broom); library(here)
})
source(here::here("utils.R")); log_msg("04_heterogeneity: start")

d <- readRDS(here::here("output","intermediate","analytic_harmonized.rds"))
cluster_var <- cluster_picker(d)

has_variation <- function(x) length(unique(na.omit(x))) >= 2
prune_controls <- function(df, candidates, max_na = 0.6) {
  present <- intersect(candidates, names(df)); if (!length(present)) return(character(0))
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

# single country?
single_cty <- "country" %in% names(d) && length(na.omit(unique(d$country))) == 1
fe_part    <- if (single_cty) NULL else "country"

# controls
all_ctrls <- c("HHSize","RESPFemale","HHH_Sex","HHH_Age","HHH_Education","HHUrbRur","asset_index","earners")
ctrls     <- prune_controls(d, all_ctrls, max_na = 0.6)
ctrl_fml  <- if (length(ctrls)) paste(ctrls, collapse = " + ") else "1"
log_msg("04_heterogeneity: controls used -> ", if (length(ctrls)) ctrl_fml else "none")

# build asset quintiles if numerical
if ("asset_index" %in% names(d) && is.numeric(d$asset_index) && has_variation(d$asset_index)) {
  d <- d %>% mutate(asset_q = ntile(asset_index, 5))
}

# choose interactors
interactors <- c()
if ("HHH_Education" %in% names(d)) interactors <- c(interactors, "HHH_Education")
if ("HHSize"        %in% names(d)) interactors <- c(interactors, "HHSize")
if ("HHUrbRur"      %in% names(d)) interactors <- c(interactors, "HHUrbRur")
if ("asset_q"       %in% names(d)) interactors <- c(interactors, "asset_q")

outcomes <- intersect(c("FCS","rCSI","FES","LCS_crisem"), names(d))

fit_interaction <- function(df, y, ctrls, interactor, fe = NULL, cluster_var = NULL) {
  if (!(y %in% names(df)) || !(interactor %in% names(df))) return(NULL)
  req <- unique(c("Remote", y, interactor, ctrls))
  di  <- df %>% select(any_of(req)) %>% drop_na(Remote, all_of(y), all_of(interactor))
  if (!nrow(di)) return(NULL)
  if (length(ctrls)) di <- di %>% filter(rowSums(is.na(across(all_of(ctrls)))) < length(ctrls))
  if (!has_variation(di[[y]]) || !has_variation(di[[interactor]])) return(NULL)

  di[[interactor]] <- if (is.factor(di[[interactor]])) droplevels(di[[interactor]]) else factor(di[[interactor]])
  rhs_ctrls <- if (length(ctrls)) paste(ctrls, collapse = " + ") else "1"
  fe_str    <- if (is.null(fe)) "" else paste0(" | ", fe)
  fml <- as.formula(paste0(y, " ~ Remote*", interactor, " + ", rhs_ctrls, fe_str))

  is_binary <- is.logical(di[[y]]) ||
    (is.numeric(di[[y]]) && all(na.omit(di[[y]]) %in% c(0,1))) ||
    (is.factor(di[[y]])  && nlevels(di[[y]]) == 2)

  m <- try(
    if (is_binary) feglm(fml, data = di, family = "logit", cluster = cluster_var)
    else           feols (fml, data = di, cluster = cluster_var),
    silent = TRUE
  )
  if (inherits(m, "try-error")) return(NULL)
  m
}

mods <- list()
for (y in outcomes) for (z in interactors) {
  key <- paste0(z, "_", y)
  mods[[key]] <- fit_interaction(d, y, ctrls, interactor = z, fe = fe_part, cluster_var = cluster_var)
}
mods <- mods[!vapply(mods, is.null, logical(1))]

if (!length(mods)) {
  write_tex("No heterogeneity models could be estimated (insufficient variation).",
            here::here("output","tables","Table5_heterogeneity.tex"))
  readr::write_csv(tibble(), here::here("output","tables","Table5_heterogeneity.csv"))
} else {
  tex <- modelsummary(
    mods, output = "latex",
    gof_map = c("n","r.squared","rmse","aic","bic"),
    notes = paste0(
      "Country: ", if (single_cty) as.character(na.omit(unique(d$country)))[1] else "multiple",
      ". Controls: ", if (length(ctrls)) ctrl_fml else "none",
      ". FE: ", if (is.null(fe_part)) "none (single country)" else "country",
      ". SEs: ", ifelse(is.null(cluster_var), "robust (HC)", cluster_var), "."
    ),
    stars = TRUE
  )
  write_tex(tex, here::here("output","tables","Table5_heterogeneity.tex"))

  tidied <- purrr::map_df(names(mods), ~ broom::tidy(mods[[.x]], conf.int = TRUE) %>% mutate(model = .x))
  readr::write_csv(tidied, here::here("output","tables","Table5_heterogeneity.csv"))
}
log_msg("04_heterogeneity: complete")
