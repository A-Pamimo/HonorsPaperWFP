# Created by Sara Viviani and Pablo Diego-Rosell in November 2019
# Contact Sara.Viviani@fao.org or pablo_diego-rosell@gallup.co.uk for questions
# To run script, close any existing RStudio sessions and open a new session by double-clicking on 'MASTER.R'
# Then follow instructions below

# Clean global environment and set seed for reproducibility
rm(list = ls(all = TRUE))
set.seed(100)
setwd("C:/Users/C_Pablo_Diego-Rosell/Desktop/Projects/WFP/Rasch Modeling/2019 check/To Sara")
# Load needed packages
if (!require("pacman")) install.packages("pacman")
library ("pacman")
pacman::p_load(foreign, RM.weights, psych, mirt, FactoMineR, factoextra, missMDA, mRm, ggvis, DT, knitr)

# Load the data (Make sure it is saved to the same directory as the "ANALYSIS.R" script)
dd1=read.spss("WFP_092719.sav", use.value.labels = T, to.data.frame = T)

# Load the function to perform the analysis 
# Make sure it is saved to the same directory as the "ANALYSIS.R" script
source("FUNCTION.R")

# Identify countries available
dd1$countrynew=factor(dd1$WP5)
table(dd1$countrynew)  # Countries and sample sizes available

# The render function below will generate a report aggregating all countries in the dataset. 
# If only one country is needed, replace assignment for 'countryName' below ("All") 
# with an element from 'country.list' (e.g. "Venezuela")

countryName <- "All"
rmarkdown::render("ANALYSIS.R", 
                 output_file = paste(countryName, "/IRT_", countryName, ".html", sep =""))

# The for loop below will fit the model and export output for each available country separately

for (i in levels(dd1$countrynew)) {
  countryName <- i
  print(countryName)
  dir.create(countryName)
  rmarkdown::render("ANALYSIS.R", 
                    output_file = paste(countryName, "/IRT_", countryName, ".html", sep =""))
  }
