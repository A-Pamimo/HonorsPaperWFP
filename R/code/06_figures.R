# code/06_figures.R -------------------------------------------------------------
suppressPackageStartupMessages({
  library(tidyverse); library(ggplot2); library(ggdist); library(here)
})
source(here::here("code","utils.R")); log_msg("06_figures: start")

d <- readRDS(here::here("output","intermediate","analytic_harmonized.rds"))
dir.create(here::here("output","figures"), recursive = TRUE, showWarnings = FALSE)

num_outs <- intersect(c("FCS","rCSI","FES"), names(d))

# detect single-country (BF)
single_cty <- "country" %in% names(d) && length(na.omit(unique(d$country))) == 1
ct_label   <- if (single_cty) as.character(na.omit(unique(d$country)))[1] else NULL

if (single_cty) {
  di <- d
  for (y in num_outs) {
    p <- ggplot(di, aes(x = .data[[y]], y = Remote)) +
      ggdist::stat_slab(aes(thickness = after_stat(pdf))) +
      labs(title = paste0(y, " by Modality — ", ct_label), x = y, y = "") +
      theme_minimal()
    outp <- here::here("output","figures", paste0(y, "_density_", ct_label, ".pdf"))
    ggsave(outp, p, width = 7, height = 4); log_msg("Saved figure:", outp)
  }
} else {
  for (ct in unique(d$country)) {
    di <- d %>% filter(country == ct)
    for (y in num_outs) {
      p <- ggplot(di, aes(x = .data[[y]], y = Remote)) +
        ggdist::stat_slab(aes(thickness = after_stat(pdf))) +
        labs(title = paste0(y, " by Modality — ", as.character(ct)), x = y, y = "") +
        theme_minimal()
      outp <- here::here("output","figures", paste0(y, "_density_c", as.character(ct), ".pdf"))
      ggsave(outp, p, width = 7, height = 4); log_msg("Saved figure:", outp)
    }
  }
}

# LCS stacked (if available)
if ("LCS_Cat" %in% names(d)) {
  p2 <- d %>%
    mutate(LCS_Cat = forcats::fct_na_value_to_level(as_factor_safe(LCS_Cat), level = "Unknown")) %>%
    count(Remote, LCS_Cat) %>%
    group_by(Remote) %>% mutate(prop = n/sum(n)) %>% ungroup() %>%
    ggplot(aes(x = Remote, y = prop, fill = LCS_Cat)) +
    geom_col() + theme_minimal() +
    labs(title = "LCS severity share by modality", y = "Proportion", x = "")
  outp2 <- here::here("output","figures","LCS_severity_stack.pdf")
  ggsave(outp2, p2, width = 6, height = 4); log_msg("Saved figure:", outp2)
}

log_msg("06_figures: complete")
