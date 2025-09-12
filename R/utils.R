
# code/utils.R — shared helpers -------------------------------------------------

suppressPackageStartupMessages({
  library(tidyverse)
  library(data.table)
  library(janitor)
  library(stringr)
  library(broom)
  library(broom.helpers)
  library(modelsummary)
  library(gt)
  library(here)
})

# -- very small logger that writes to output/logs and stdout --------------------
log_init <- function() {
  dir.create(here::here("output","logs"), showWarnings = FALSE, recursive = TRUE)
  ts <- format(Sys.time(), "%Y%m%d_%H%M%S")
  logfile <- here::here("output","logs", paste0("run_", ts, ".log"))
  options("mfsfp.logfile" = logfile)
  writeLines(paste0("== Run started: ", Sys.time()), con = logfile)
  message("Logging to: ", logfile)
}

log_msg <- function(...) {
  msg <- paste(..., collapse = " ")
  cat(msg, "\n")
  logfile <- getOption("mfsfp.logfile", default = NULL)
  if (!is.null(logfile)) write(msg, file = logfile, append = TRUE)
}

# -- reproducible write helpers -------------------------------------------------
write_tex <- function(obj, path) {
  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  if (inherits(obj, "gt_tbl")) {
    gt::gtsave(obj, path)
  } else if (inherits(obj, "data.frame")) {
    # default: modelsummary table saved as TeX via 'msummary(..., output="latex")'
    writeLines(as.character(obj), con = path)
  } else if (is.character(obj)) {
    writeLines(obj, con = path)
  }
  log_msg("Wrote:", path)
}

write_xlsx_sheets <- function(named_list, path) {
  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  writexl::write_xlsx(named_list, path)
  log_msg("Wrote:", path)
}

# -- winsorizer -----------------------------------------------------------------
winsorize <- function(x, probs = c(0.01, 0.99), na.rm = TRUE) {
  if (!is.numeric(x)) return(x)
  qs <- quantile(x, probs = probs, na.rm = na.rm, names = FALSE)
  x <- pmax(pmin(x, qs[2]), qs[0+1])
  return(x)
}

# -- cluster picker -------------------------------------------------------------
cluster_picker <- function(df) {
  # Prefer PSU > enumerator_id > NULL
  psu_opts <- c("ADMIN3Name","ADMIN2Name")
  enum_opts <- c("EnuName","EnuName_Di~y","EnuName_Diay","EnuName_Diry")
  has <- function(v) any(v %in% names(df))
  choice <- NULL
  if (has(psu_opts)) {
    choice <- psu_opts[psu_opts %in% names(df)][1]
  } else if (has(enum_opts)) {
    choice <- enum_opts[enum_opts %in% names(df)][1]
  } else {
    choice <- NULL
  }
  if (is.null(choice)) log_msg("cluster_picker: No cluster variable found; using robust HC1/HC2")
  else log_msg("cluster_picker: Using cluster =", choice)
  return(choice)
}

# -- balance function -----------------------------------------------------------
balance_fun <- function(df, vars, group = "Remote") {
  stopifnot(group %in% names(df))
  out <- lapply(vars, function(v) {
    if (!v %in% names(df)) return(NULL)
    x <- df[[v]]
    g <- df[[group]]
    # Numeric mean/SD; factor/share if non-numeric
    if (is.numeric(x)) {
      m <- df %>% group_by(.data[[group]]) %>% summarize(mean = mean(.data[[v]], na.rm=TRUE),
                                                        sd = sd(.data[[v]], na.rm=TRUE), .groups="drop")
      # Welch t-test
      tt <- tryCatch(t.test(x ~ g), error = function(e) NULL)
      tibble(variable=v,
             type="numeric",
             mean_F2F = m$mean[m[[group]]=="F2F"],
             mean_Remote = m$mean[m[[group]]=="Remote"],
             sd_F2F = m$sd[m[[group]]=="F2F"],
             sd_Remote = m$sd[m[[group]]=="Remote"],
             diff = mean_Remote - mean_F2F,
             p_value = if (!is.null(tt)) tt$p.value else NA_real_)
    } else {
      # share = 1 for TRUE/yes if logical; or for most frequent level
      if (is.logical(x)) {
        x_num <- as.numeric(x)
      } else if (is.factor(x) || is.character(x)) {
        # Convert to 1 if equals modal level overall
        modal <- names(sort(table(x), decreasing = TRUE))[1]
        x_num <- as.numeric(x == modal)
      } else {
        x_num <- as.numeric(x)
      }
      m <- df %>% group_by(.data[[group]]) %>% summarize(mean = mean(x_num, na.rm=TRUE), .groups="drop")
      tt <- tryCatch(t.test(x_num ~ g), error = function(e) NULL)
      tibble(variable=v,
             type="share",
             mean_F2F = m$mean[m[[group]]=="F2F"],
             mean_Remote = m$mean[m[[group]]=="Remote"],
             sd_F2F = NA_real_,
             sd_Remote = NA_real_,
             diff = mean_Remote - mean_F2F,
             p_value = if (!is.null(tt)) tt$p.value else NA_real_)
    }
  })
  bind_rows(out)
}

# -- tidy coefficients to CSV (for dot-whisker) --------------------------------
coefs_to_csv <- function(models, term = "RemoteRemote", path_csv) {
  td <- purrr::map_df(models, ~broom::tidy(.x, conf.int = TRUE) %>% mutate(model = deparse(formula(.x))))
  res <- td %>% filter(term == !!term) %>%
    transmute(model, estimate, conf.low, conf.high, std.error, statistic, p.value)
  dir.create(dirname(path_csv), showWarnings = FALSE, recursive = TRUE)
  readr::write_csv(res, path_csv)
  log_msg("Wrote:", path_csv)
}

# -- safe factorify helper ------------------------------------------------------
as_factor_safe <- function(x, levels = NULL, labels = NULL) {
  if (is.factor(x)) return(x)
  if (!is.null(levels) && !is.null(labels)) return(factor(x, levels = levels, labels = labels))
  return(as.factor(x))
}
