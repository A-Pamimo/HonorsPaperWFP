# code/05_robustness.R ----------------------------------------------------------
suppressPackageStartupMessages({
  library(tidyverse); library(fixest); library(modelsummary); library(broom); library(here)
})
source(here::here("code","utils.R")); log_msg("05_robustness: start")

d <- readRDS(here::here("output","intermediate","analytic_harmonized.rds"))
cluster_var <- cluster_picker(d)

# helpers
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
fit_binary <- function(df, y, ctrls, fe_country = TRUE) {
  req <- unique(c("Remote", y, ctrls, "country"))
  di  <- df %>% select(any_of(req)) %>% tidyr::drop_na(Remote, all_of(y))
  if (!nrow(di) || !has_variation(di[[y]])) return(NULL)

  rhs_ctrls <- if (length(ctrls)) paste(ctrls, collapse = " + ") else "1"
  if (fe_country && "country" %in% names(di) && has_variation(di$country)) {
    fml <- as.formula(paste0(y, " ~ Remote + ", rhs_ctrls, " | country"))
    m <- try(suppressWarnings(feglm(fml, data = di, family = "logit", cluster = cluster_var)), silent = TRUE)
    if (!inherits(m, "try-error")) return(m)
  }
  if ("country" %in% names(di) && has_variation(di$country)) {
    fml <- as.formula(paste0(y, " ~ Remote + ", rhs_ctrls, " + factor(country)"))
  } else {
    fml <- as.formula(paste0(y, " ~ Remote + ", rhs_ctrls))
  }
  m2 <- try(suppressWarnings(glm(fml, data = di, family = binomial())), silent = TRUE)
  if (inherits(m2, "try-error")) return(NULL)
  m2
}

# controls
all_ctrls <- c("HHSize","RESPFemale","HHH_Sex","HHH_Age","HHH_Education","HHUrbRur","asset_index","earners")
ctrls     <- prune_controls(d, all_ctrls, max_na = 0.6)
ctrl_fml  <- if (length(ctrls)) paste(ctrls, collapse = " + ") else "1"
log_msg("05_robustness: controls -> ", if (length(ctrls)) ctrl_fml else "none")

mods <- list()

# Enumerator FE (if enumerator variable exists)
enum_candidates <- intersect(names(d), c("EnuName","EnuName_Diay","EnuName_Diry","EnuName_Di~y","enumerator","enum_id"))
enum_col <- if (length(enum_candidates)) enum_candidates[1] else NA_character_

if (!is.na(enum_col)) {
  for (y in intersect(c("FCS","rCSI","FES"), names(d))) {
    req <- unique(c("Remote", y, ctrls, "country", enum_col))
    di  <- d %>% select(any_of(req)) %>% tidyr::drop_na(Remote, all_of(y))
    if (!nrow(di) || !has_variation(di[[y]])) next
    f <- as.formula(paste0(y, " ~ Remote + ", ctrl_fml, " | country + ", enum_col))
    mods[[paste0("enumFE_", y)]] <- try(suppressWarnings(feols(f, data = di, cluster = cluster_var)), silent = TRUE)
  }
  if ("LCS_crisem" %in% names(d)) {
    req <- unique(c("Remote","LCS_crisem", ctrls, "country", enum_col))
    di  <- d %>% select(any_of(req)) %>% tidyr::drop_na(Remote, LCS_crisem)
    if (nrow(di) && has_variation(di$LCS_crisem)) {
      f <- as.formula(paste0("LCS_crisem ~ Remote + ", ctrl_fml, " | country + ", enum_col))
      mods[["enumFE_LCS_logit"]] <- try(suppressWarnings(feglm(f, data = di, family = "logit", cluster = cluster_var)), silent = TRUE)
    }
  }
}

# Winsorized FES (1st/99th pct)
if ("FES" %in% names(d)) {
  d <- d %>% mutate(FES_w = winsorize(FES))
  req <- unique(c("Remote","FES_w", ctrls, "country"))
  di  <- d %>% select(any_of(req)) %>% tidyr::drop_na(Remote, FES_w)
  if (nrow(di) && has_variation(di$FES_w)) {
    f <- as.formula(paste0("FES_w ~ Remote + ", ctrl_fml, " | country"))
    mods[["FES_w"]] <- try(suppressWarnings(feols(f, data = di, cluster = cluster_var)), silent = TRUE)
  }
}

# Binary: LCS_crisem via logit/GLM
if ("LCS_crisem" %in% names(d)) {
  mods[["LCS_logit"]] <- fit_binary(d, "LCS_crisem", ctrls, fe_country = TRUE)
}

# export
mods <- mods[!vapply(mods, function(m) is.null(m) || inherits(m, "try-error"), logical(1))]

if (!length(mods)) {
  write_tex("No robustness models could be estimated.", here::here("output","tables","TableA_robustness.tex"))
  readr::write_csv(tibble(), here::here("output","tables","TableA_robustness.csv"))
} else {
  notes <- paste0(
    "Controls: ", if (length(ctrls)) ctrl_fml else "none",
    ". FE: country where feasible; enumerator FE when available. ",
    "SEs clustered at: ", ifelse(is.null(cluster_var), "robust (HC)", cluster_var), ". ",
    "FES winsorized at 1st/99th pct. Binary outcomes via FE-logit/GLM."
  )
  tex <- modelsummary(mods, output = "latex", gof_map = c("n","r.squared","rmse","aic","bic"),
                      notes = notes, stars = TRUE)
  write_tex(tex, here::here("output","tables","TableA_robustness.tex"))

  tidied <- purrr::map_df(names(mods), ~ broom::tidy(mods[[.x]], conf.int = TRUE) %>% mutate(model = .x))
  readr::write_csv(tidied, here::here("output","tables","TableA_robustness.csv"))
}
log_msg("05_robustness: complete")
