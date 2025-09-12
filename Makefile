
# Makefile — orchestrate the full pipeline
all:
	Rscript code/00_setup.R && \
	Rscript code/01_prepare.R && \
	Rscript code/02_descriptives.R && \
	Rscript code/03_main_results.R && \
	Rscript code/04_heterogeneity.R && \
	Rscript code/05_robustness.R && \
	Rscript code/06_figures.R && \
	Rscript code/99_session_info.R
