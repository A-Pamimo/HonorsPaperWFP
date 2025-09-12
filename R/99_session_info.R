
# code/99_session_info.R --------------------------------------------------------
suppressPackageStartupMessages({library(here)})
sink(here::here("output","logs","session_info.txt"))
print(sessionInfo())
sink()
cat("sessionInfo() written to output/logs/session_info.txt\n")
