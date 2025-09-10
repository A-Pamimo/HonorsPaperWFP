*******************************************************
* 08_indicators.do — Indicator summaries by mode
*******************************************************

version 17
set more off
do "00_utils.do"

use "$IN_FOR_TABLES", clear
_mk_label

local indvars "FCS rCSI LCS FES income"
tempfile stats
tempname mem
postfile `mem' str20 indicator double mean_F2F sd_F2F N_F2F mean_Remote sd_Remote N_Remote tstat using `stats'

foreach v of local indvars {
    capture confirm variable `v'
    if !_rc {
        quietly ttest `v', by($MODE)
        post `mem' ("`v'") (r(mu_1)) (r(sd_1)) (r(N_1)) (r(mu_2)) (r(sd_2)) (r(N_2)) (r(t))
    }
}

postclose `mem'
use `stats', clear
order indicator mean_F2F sd_F2F N_F2F mean_Remote sd_Remote N_Remote tstat
_xlsx_export, sheet("Indicators")

display as result "08_indicators.do complete → Indicators sheet"

