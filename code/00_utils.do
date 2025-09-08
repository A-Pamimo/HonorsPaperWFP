*******************************************************
* 00_utils.do — Utility programs (e.g., _coerce_num)
*******************************************************
version 17

* Coerce variables to numeric when they arrive as strings.
* - Handles "yes/no", "oui/non", "0/1/2" numeric strings, commas
cap program drop _coerce_num
program define _coerce_num
    syntax varlist
    foreach v of local varlist {
        capture confirm numeric variable `v'
        if _rc {
            * Attempt to destring first (ignore commas/spaces)
            capture destring `v', replace ignore(", ")
            if _rc {
                * If still not numeric, map common text to numbers
                gen double __tmp_num = .
                replace __tmp_num = 1 if lower(trim(`v'))=="yes" | lower(trim(`v'))=="oui" | trim(`v')=="1"
                replace __tmp_num = 0 if lower(trim(`v'))=="no"  | lower(trim(`v'))=="non" | trim(`v')=="0"
                replace __tmp_num = real(`v') if missing(__tmp_num) & regexm(`v',"^-?[0-9.]+$")
                drop `v'
                rename __tmp_num `v'
            }
        }
    }
end
