*======================================================
* FILE: code/07_composites.do
*======================================================

*******************************************************
* 07_composites.do — Composite indicators by mode
*******************************************************

version 17
set more off
do "00_utils.do"

use "$IN_FOR_TABLES", clear
_mk_label

* Regress CARI/rCARI on modality and export coefficients
tempfile __coef
postfile _p str8 outcome double intercept coef_remote using `__coef'

foreach y in CARI rCARI {
    capture confirm variable `y'
    if !_rc {
        quietly _regw regress `y' i.$MODE
        scalar b0 = _b[_cons]
        capture scalar b1 = _b[1.$MODE]
        post _p ("`y'") (b0) (b1)
    }
}
postclose _p

use `__coef', clear
order outcome intercept coef_remote
_xlsx_export, sheet("Composites")
