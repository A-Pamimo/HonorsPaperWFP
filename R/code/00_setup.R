# code/00_setup.R ---------------------------------------------------------------

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
  renv::init(bare = TRUE)
} else {
  try(renv::restore(), silent = TRUE)
}

source(here::here("utils.R"))
log_msg("00_setup.R complete")
