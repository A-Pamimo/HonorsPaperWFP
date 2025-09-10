*======================================================
* FILE: code/12_module_length.do
*======================================================

*******************************************************
* 12_module_length.do — Interview/module timing
*******************************************************

version 17
set more off

do "00_utils.do"

* Load dataset (prefer cleaned analytic)
use "$OUT_CLEAN", clear
_mk_label

* ===== Time conversion guards =====
capture confirm variable starttime
if _rc {
    capture confirm variable starttime_raw
    if !_rc {
        gen double starttime = clock(starttime_raw, "YMDhms")
        format starttime %tc
    }
}

capture confirm variable endtime
if _rc {
    capture confirm variable endtime_raw
    if !_rc {
        gen double endtime = clock(endtime_raw, "YMDhms")
        format endtime %tc
    }
}

capture confirm variable interview_minutes
if _rc {
    capture confirm variable starttime
    capture confirm variable endtime
    if !_rc {
        gen double interview_minutes = (endtime - starttime) / 60000
    }
    else {
        gen double interview_minutes = .
    }
}

* ---------- Summary by mode ----------
preserve
    collapse (count) N = interview_minutes (mean) mean_long = interview_minutes (sd) sd = interview_minutes, by($MODE)
    tostring $MODE, gen(mode_str)
    replace mode_str = cond($MODE==0, "F2F", "Remote")
    gen mean_short = .
    gen tstat = .
    gen pval = .
    gen str20 stat = "Interview"
    keep stat mode_str mean_long mean_short sd tstat pval N
    tempfile __time
    save `__time'
restore

* Export interview-time summary
use `__time', clear
_xlsx_export, sheet("Interview_Time")

* ===== Long vs short FCS modules (paired) =====
tempfile __tests
preserve
    keep FCS FCS_S $MODE

    * Ensure numeric fields to avoid type issues
    _ensure_numeric FCS
    local F1 `r(name)'
    _ensure_numeric FCS_S
    local F2 `r(name)'

    * Keep only rows with both values
    keep if !missing(`F1', `F2')

    * Paired t-test overall
    quietly ttest `F1' == `F2'
    scalar t_all = r(t)
    scalar p_all = r(p)
    quietly summarize `F1'
    scalar m_long  = r(mean)
    quietly summarize `F2'
    scalar m_short = r(mean)
    scalar diff    = m_long - m_short
    scalar Npairs  = r(N)

    * Build tiny results table
    clear
    set obs 1
    gen str20 stat = "FCS long vs short"
    gen double mean_long  = m_long
    gen double mean_short = m_short
    gen double diff_mean  = diff
    gen double tstat      = t_all
    gen double pval       = p_all
    gen double N          = Npairs

    _xlsx_export, sheet("FCS_Paired")
restore
