# RDW_Trajectory_SAAKI

Reproducible code for longitudinal RDW trajectories and mortality in sepsis‑associated AKI using MIMIC‑IV.

## Data Access and Ethics
No patient-level data are stored in this repository. Obtain data access from PhysioNet for MIMIC-IV under their DUAs. All analyses use de-identified data only.

## Repository Structure
- data_extraction/sql/: SQL for cohort definition, RDW extraction, transfusion data
- analysis/: R scripts for processing, group-based trajectory modeling, Cox/landmark survival, sensitivity analyses
- documentation/: Pipeline and reporting notes

## Quick Start
1. Install R (>= 4.2). Optional: `renv::restore()` after cloning.
2. Create a `.Renviron` with your DB connection (PostgreSQL) or use a SQL client to export CSVs:
3. Run scripts in order:
- `analysis/01_data_processing.R` (loads exported CSVs or queries DB)
- `analysis/02_trajectory_modeling.R` (GBTM via lcmm)
- `analysis/03_survival_landmark.R` (Cox)
- `analysis/04_sensitivity_transfusion.R` (adjust/exclude transfusions; ≥3 measures)
- `analysis/05_tables_figures.R` (reproduce tables/figures)
- Or simply `analysis/run_all.R`

## Reproducibility
- Exact SQL and R scripts are provided.
- Sensitivity analyses: (1) ≥3 RDW measures, (2) transfusion-adjusted/excluded.
- Release `v0.1.0` corresponds to the revision submitted to PLOS ONE. A frozen snapshot is archived on Zenodo (DOI to be added).

## License and Citation
Code: MIT License.  
Please cite the paper and this repository (see `CITATION.cff`).
