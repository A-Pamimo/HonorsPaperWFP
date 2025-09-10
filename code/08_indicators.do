*******************************************************
* 08_indicators.do — Binary indicators by mode
*******************************************************

version 17
set more off
do "00_utils.do"

use "$IN_FOR_TABLES", clear
_mk_label

* Food insecurity indicator
capture drop food_insecure
gen byte food_insecure = (FCS < $FCS_CUTOFF) if !missing(FCS)

preserve
    collapse (count) N = food_insecure (mean) food_insecure, by($MODE)
    tostring $MODE, gen(mode_str)
    replace mode_str = cond($MODE==0, "F2F", "Remote")
    rename food_insecure prop_food_insecure
    order mode_str prop_food_insecure N
    _xlsx_export, sheet("Indicators")
restore

display as result "08_indicators.do complete → Indicators sheet"
