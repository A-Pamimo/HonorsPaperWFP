# HonorsPaperWFP
The repo of my honors paper where all the data analysis of the project will be done

# Measuring Food Security: F2F vs Remote — R Pipeline

**How to run (one line):**
```bash
make
# or
bash run_all.sh
```

This project uses `renv` for reproducibility. The first run will initialize and restore package versions, then execute each script in order.

**Inputs included** (from your upload):
- `data/raw/Complete_BF_Household_Analysis.dta`
- PDFs for reference (not parsed): Abate et al. (2023), Impact_of_Survey_Modality..., Measuring_Food_Security__F2F_vs__Remote

**Outputs:**
- Clean analytic: `output/intermediate/analytic_harmonized.rds/.csv`
- Tables (LaTeX/CSV/XLSX): `output/tables/`
- Figures (PDF): `output/figures/`
- Logs: `output/logs/` (timestamped run log + `session_info.txt`)

**Notes:**
- Raw data are never modified. All derivations are documented in `output/intermediate/TableA1_varmap.csv` and comments in `01_prepare.R`.
- Clustering rule: PSU > enumerator > robust; chosen cluster is logged.
- All model tables note controls, FE, and clustering choice.
