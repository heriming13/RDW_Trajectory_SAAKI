# Analysis Pipeline

1. Define cohort (adults, Sepsis-3, AKI, first ICU).
2. Extract RDW labs (CV/SD) and transfusion events within ICU window.
3. Clean, QC, and count RDW measures (primary ≥5; sensitivity ≥3).
4. Fit group-based trajectory models (choose #classes by BIC, inspect stability).
5. Assign posterior class and link to outcomes.
6. Survival analyses:
   - Standard Cox for 28/90-day mortality
7. Sensitivity:
   - ≥3 measures
   - Adjust for or exclude transfusions
8. Reporting:
   - Export tidy model tables to `results/tables/`
   - Generate figures to `results/figures/`

