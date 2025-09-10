*******************************************************
* 04_analysis.do — Core analysis (diffs, regressions)
*******************************************************

version 17
set more off
do "00_utils.do"

use "$IN_FOR_TABLES", clear
_mk_label

capture noisily bysort $MODE: summarize FCS rCSI HHS

if "$SURVEY_DESIGN"=="1" & "$PSU"!="" {
    svyset $PSU
    if "$STRATA"!="" svyset, strata($STRATA)
}

capture confirm variable FCS
if !_rc {
    _regw regress FCS i.$MODE
}

display as result "04_analysis.do complete"
