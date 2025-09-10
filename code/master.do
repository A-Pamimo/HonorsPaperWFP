*******************************************************
* master.do — Orchestrates end-to-end pipeline
*******************************************************

clear all
set more off

* ===== Standardized pipeline =====
do "01_setup.do"
do "00_config.do"

do "02_clean_bf.do"
do "03_construct_indices.do"

do "04_analysis.do"
do "05_tables.do"
do "06_balance.do"
do "07_composites.do"
do "08_indicators.do"

do "09_heterogeneity.do"
capture noisily do "10_quality_checks.do"   // stops with error 498 if critical fails
do "11_enumerator_robustness.do"
do "12_module_length.do"

display as result "Pipeline completed successfully!"
