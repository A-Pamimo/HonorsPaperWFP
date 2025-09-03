## Clear the environment ------------------------------------------------------#

rm(list=ls())

## Load Packages --------------------------------------------------------------#
library(tidyverse)
library(dplyr)
library(tidyr)
library(readxl)
library(openxlsx)
library(mosaic)
library(foreign)
library(gt)
library(gtsummary)
library(modelsummary)
library(desctable)
library(survey)
library(srvyr) 
library(rmarkdown)
library(haven)
library(sjlabelled)
library(car)
library(dataReporter)
library(labelled) 
library(cutpointr)
library(caret)
library(magrittr)
library(pacman)
library(rattle)
library(rio)
library(ggplot2)
library(ggtext)
library(tictoc)
library(expss)
library(officer)
library(devtools)
library(wfpthemes)
library(stargazer)

#update.packages(ask = FALSE)
#evtools::install_github("WFP-VAM/wfpthemes")
#devtools::install_github("kupietz/kableExtra")
#devtools::install_github("collectivemedia/tictoc")

# Set path ---------------------------------------------------------------------

if (Sys.info()["user"] == "nicolewu") {
  
  rCARI <- file.path("/Users/nicolewu/Library/CloudStorage/OneDrive-WorldFoodProgramme/2_CARI_validation/1_rCARI_study/1_Pilot_country")
  
} 

Iraq_Analysis      <- file.path(rCARI,"1_Iraq/9_Analysis"  ) # folder for the country

Data               <- file.path(Iraq_Analysis,"1_Data"          ) 
Temp               <- file.path(Iraq_Analysis,"4_Temp"          ) 
Paper              <- file.path(Iraq_Analysis,"8_Manuscript"    ) 

TeXTab             <- file.path(Paper,"2_tables"                ) 


# Load Data --------------------------------------------------------------------

Iraq_Gender_MDD <- read_dta(file.path(Temp, 
                            "Iraq_MDD_F2F_Analysis.dta"))


# Define the list of variables you want to analyze
variables <- c("StapRoo", "Pulse", "Nuts", "Milk", "Dairy", "PrMeatO", "PrMeatF", "PrMeatPro",
               "PrMeatWhite", "PrFish", "PrEgg", "VegGre", "VegOrg", "FruitOrg", "VegOth",
               "FruitOth", "Snf", "Staples", "Pulses", "NutsSeeds", "Dairies", "MeatFish",
               "Eggs", "LeafGVeg", "VitA", "OtherVeg", "OtherFruits", "Index")

# Convert _M and _F variables to numeric
for (var in variables) {
  Iraq_Gender_MDD[[paste0(var, "_M")]] <- as.numeric(Iraq_Gender_MDD[[paste0(var, "_M")]])
  Iraq_Gender_MDD[[paste0(var, "_F")]] <- as.numeric(Iraq_Gender_MDD[[paste0(var, "_F")]])
  
  # Exclude missing values
  Iraq_Gender_MDD <- Iraq_Gender_MDD[complete.cases(Iraq_Gender_MDD[[paste0(var, "_M")]]),
  ]
  Iraq_Gender_MDD <- Iraq_Gender_MDD[complete.cases(Iraq_Gender_MDD[[paste0(var, "_F")]]),
  ]
}

# Create an empty data frame to store the results
results <- data.frame(variable = character(),
                      n = integer(),
                      mean1 = numeric(),
                      mean2 = numeric(),
                      diff = numeric(),
                      p_value = numeric(),
                      stringsAsFactors = FALSE)

# Perform paired t-test for each variable
for (var in variables) {
  # Calculate the differences between female and male responses
  diff <- Iraq_Gender_MDD[[paste0(var, "_F")]] - Iraq_Gender_MDD[[paste0(var, "_M")]]
  
  # Perform paired t-test
  t_test <- t.test(Iraq_Gender_MDD[[paste0(var, "_F")]], Iraq_Gender_MDD[[paste0(var, "_M")]], paired = TRUE)
  
  # Extract the relevant statistics
  n <- length(Iraq_Gender_MDD[[paste0(var, "_F")]])
  mean1 <- mean(Iraq_Gender_MDD[[paste0(var, "_F")]], na.rm = TRUE)
  mean2 <- mean(Iraq_Gender_MDD[[paste0(var, "_M")]], na.rm = TRUE)
  p_value <- t_test$p.value
  
  # Append the results to the data frame
  results <- rbind(results, data.frame(variable = var,
                                       n = n,
                                       mean1 = mean1,
                                       mean2 = mean2,
                                       diff = mean(diff, na.rm = TRUE),
                                       p_value = p_value))
}

stargazer(results)
