# code/00_setup.R ---------------------------------------------------------------

# Auto-detect project root
`%||%` <- function(x,y) if(!is.null(x)) x else y
this_file <- normalizePath(sys.frames()[[1]]$ofile %||% rstudioapi::getSourceEditorContext()$path, winslash = "/")
project_root <- dirname(dirname(this_file))
setwd(project_root)
message("Working directory set to: ", getwd())

suppressPackageStartupMessages({
  library(here)
  library(renv)
})

set.seed(12345)

# Create directories
dirs <- c(
  here::here("output","intermediate"),
  here::here("output","logs"),
  here::here("output","tables"),
  here::here("output","figures")
)
invisible(lapply(dirs, dir.create, recursive = TRUE, showWarnings = FALSE))

# Initialize renv if not already present
if (!file.exists(here::here("renv.lock"))) {
  renv::init(bare = TRUE, force = TRUE)
}
# Declare required packages (will be installed/recorded into lock)
pkgs <- c("tidyverse","data.table","haven","labelled","janitor","stringr","lubridate",
          "fixest","sandwich","clubSandwich","estimatr","broom","broom.helpers",
          "modelsummary","gt","writexl","readxl","kableExtra","ggplot2","ggdist","patchwork","here","MASS")
renv::record(setNames(rep("*", length(pkgs)), pkgs))
renv::restore(confirm = FALSE)

# Load utilities
source(here::here("R","utils.R"))
log_init()
log_msg("00_setup.R complete")
