# code/utils.R ------------------------------------------------------------------
suppressPackageStartupMessages({
  requireNamespace("dplyr", quietly = TRUE)
  requireNamespace("tibble", quietly = TRUE)
  requireNamespace("tidyr", quietly = TRUE)
  requireNamespace("purrr", quietly = TRUE)
  requireNamespace("stringr", quietly = TRUE)
  requireNamespace("haven", quietly = TRUE)
  requireNamespace("gt", quietly = TRUE)
  requireNamespace("writexl", quietly = TRUE)
})

log_msg <- function(...) {
  ts <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  msg <- paste(..., collapse = "")
  cat(sprintf("%s %s\n", ts, msg))
}

as_factor_safe <- function(x) {
  if ("haven_labelled" %in% class(x)) {
    tryCatch(haven::as_factor(x, levels = "default", ordered = FALSE),
             error = function(e) factor(as.character(x)))
  } else if (is.numeric(x) || is.character(x) || is.logical(x)) {
    factor(x)
  } else {
    factor(as.character(x))
  }
}

write_tex <- function(tex_obj, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  if (inherits(tex_obj, "gt_tbl")) {
    gt::gtsave(tex_obj, filename = path)
  } else if (is.character(tex_obj) && length(tex_obj) == 1L) {
    con <- file(path, open = "w", encoding = "UTF-8"); on.exit(close(con), add = TRUE)
    writeLines(tex_obj, con = con, sep = "\n")
  } else {
    con <- file(path, open = "w", encoding = "UTF-8"); on.exit(close(con), add = TRUE)
    capture.output(print(tex_obj), file = con)
  }
  log_msg("Wrote: ", path)
}

write_xlsx_sheets <- function(sheets, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writexl::write_xlsx(sheets, path); log_msg("Wrote: ", path)
}

winsorize <- function(x, probs = c(0.01, 0.99), na.rm = TRUE) {
  if (!is.numeric(x)) return(x)
  qs <- stats::quantile(x, probs = probs, na.rm = na.rm, names = FALSE, type = 7)
  x <- pmin(pmax(x, qs[1]), qs[2]); x
}

cluster_picker <- function(df) {
  psu_candidates  <- c("ADMIN3Name","ADMIN2Name","psu","cluster","S_Geo_Admin3","S_Geo_Admin2")
  enum_candidates <- c("EnuName","EnuName_Diay","EnuName_Diry","EnuName_Di~y","enumerator","enum_id")

  pick_first <- function(cands) {
    nm <- names(df)
    for (c in cands) {
      c_regex <- gsub("~", ".*", c)
      hit <- nm[stringr::str_detect(nm, stringr::fixed(c)) |
                  stringr::str_detect(nm, stringr::regex(c_regex, ignore_case = TRUE))]
      if (length(hit)) {
        if (length(unique(stats::na.omit(df[[hit[1]]]))) > 1) return(hit[1])
      }
    }
    return(NA_character_)
  }

  psu  <- pick_first(psu_candidates)
  enum <- pick_first(enum_candidates)

  if (!is.na(psu))  { log_msg("cluster_picker: clustering on PSU: ", psu);  return(psu) }
  if (!is.na(enum)) { log_msg("cluster_picker: clustering on enumerator: ", enum); return(enum) }
  log_msg("cluster_picker: No cluster variable found; using robust HC1/HC2"); return(NULL)
}

balance_fun <- function(df, vars, group = "Remote") {
  stopifnot(group %in% names(df))
  dplyr::bind_rows(lapply(vars, function(v) {
    if (!v %in% names(df)) return(NULL)
    x <- df[[v]]; g <- df[[group]]
    if (is.logical(x)) x <- as.numeric(x)
    if (is.factor(x))  x <- as.numeric(x)
    xv <- x[!is.na(x) & !is.na(g)]
    gv <- droplevels(as.factor(g[!is.na(x) & !is.na(g)]))
    if (nlevels(gv) != 2L) return(NULL)
    levs <- levels(gv)
    x0 <- xv[gv == levs[1]]; x1 <- xv[gv == levs[2]]
    pval <- tryCatch(stats::t.test(x1, x0, var.equal = FALSE)$p.value, error = function(e) NA_real_)
    tibble::tibble(
      variable   = v,
      group0     = levs[1], group1 = levs[2],
      mean_F2F   = ifelse(levs[1] %in% c("F2F","0"), mean(x0, na.rm = TRUE), mean(x1, na.rm = TRUE)),
      sd_F2F     = ifelse(levs[1] %in% c("F2F","0"),  stats::sd(x0, na.rm = TRUE), stats::sd(x1, na.rm = TRUE)),
      mean_Remote= ifelse(levs[2] %in% c("Remote","1"), mean(x1, na.rm = TRUE), mean(x0, na.rm = TRUE)),
      sd_Remote  = ifelse(levs[2] %in% c("Remote","1"),  stats::sd(x1, na.rm = TRUE), stats::sd(x0, na.rm = TRUE)),
      diff       = (mean(x1, na.rm = TRUE) - mean(x0, na.rm = TRUE)),
      p_value    = pval,
      n_F2F      = ifelse(levs[1] %in% c("F2F","0"), sum(!is.na(x0)), sum(!is.na(x1))),
      n_Remote   = ifelse(levs[2] %in% c("Remote","1"), sum(!is.na(x1)), sum(!is.na(x0)))
    )
  })) %>% dplyr::arrange(variable)
}

coefs_to_csv <- function(models, out_csv, remote_terms = c("RemoteRemote","Remote")) {
  df <- purrr::map_df(names(models), function(nm) {
    m <- models[[nm]]; if (is.null(m)) return(NULL)
    tt <- tryCatch(broom::tidy(m, conf.int = TRUE), error = function(e) NULL)
    if (is.null(tt)) return(NULL)
    tt %>% dplyr::filter(.data$term %in% remote_terms) %>%
      dplyr::mutate(model = nm,
                    term = dplyr::if_else(.data$term == "RemoteRemote", "Remote", .data$term))
  })
  if (!is.null(out_csv)) {
    dir.create(dirname(out_csv), recursive = TRUE, showWarnings = FALSE)
    readr::write_csv(df, out_csv); log_msg("Wrote: ", out_csv)
  }
  df
}

`%notin%` <- function(x, y) !x %in% y
options("modelsummary_format_numeric_latex" = "plain")
