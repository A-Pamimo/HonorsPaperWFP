# code/99_session_info.R --------------------------------------------------------
suppressPackageStartupMessages({
  library(here)
})
sink(here::here("output","logs","session_info.txt"))
cat("---- sessionInfo() ----\n")
print(sessionInfo())
sink()
