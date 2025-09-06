# Cox proportional hazards models for mortality
# Inputs:
#   - results/data_clean.rds: list with $cohort (one row per ICU stay)
#       expected columns (rename if different):
#         stay_id, keep_primary (>=5 RDW), keep_sens3 (>=3 RDW, optional),
#         age, sex (0/1 or factor), sofa, apsiii, oasis,
#         time_to_death_days, death28d  (time in days to death or censor; 28‑day status 1/0)
#         OPTIONAL: time_to_death90_days, death90d
#   - results/trajectory_classes.csv: stay_id, class (posterior class from GBTM)
#
# Outputs:
#   - results/cox_28d_primary.rds
#   - results/cox_90d_primary.rds (if 90‑day variables exist)
#   - results/tables/cox_28d_primary.csv (tidy HR table)
#   - results/tables/cox_90d_primary.csv (if applicable)

suppressPackageStartupMessages({
  libs <- c("survival","dplyr","readr","broom")
  invisible(lapply(libs, function(p){ if(!require(p, character.only=TRUE)) install.packages(p); library(p, character.only=TRUE)}))
})

# IO
dir.create("results", showWarnings = FALSE)
dir.create("results/tables", showWarnings = FALSE)

dat_list <- readRDS("results/data_clean.rds")
cohort   <- dat_list$cohort
classes  <- readr::read_csv("results/trajectory_classes.csv", show_col_types = FALSE)

# Merge class and keep primary cohort (>=5 RDW measures)
dat <- cohort %>%
  inner_join(classes, by = "stay_id") %>%
  filter(keep_primary) %>%
  mutate(
    class = factor(class),                # ensure factor for categorical HRs
    sex   = as.factor(sex)               # adapt if already factor
  )

# Helper: fit cox and export tidy HR table
fit_and_export <- function(formula, data, rds_path, csv_path){
  fit <- survival::coxph(formula, data = data, ties = "efron")
  saveRDS(fit, rds_path)
  broom::tidy(fit, exponentiate = TRUE, conf.int = TRUE) |>
    mutate(across(where(is.numeric), ~ round(., 3))) |>
    readr::write_csv(csv_path)
  invisible(fit)
}

# 28‑day mortality Cox model
# NOTE: change covariates to your final set (e.g., first‑24h scores only)
stopifnot(all(c("time_to_death_days","death28d") %in% names(dat)))
form28 <- as.formula(Surv(time_to_death_days, death28d) ~ class + age + sex + sofa + apsiii + oasis)
cox28  <- fit_and_export(
  formula = form28,
  data    = dat,
  rds_path = "results/cox_28d_primary.rds",
  csv_path = "results/tables/cox_28d_primary.csv"
)

# Optional: 90‑day mortality Cox model (only if columns exist)
if(all(c("time_to_death90_days","death90d") %in% names(dat))){
  form90 <- as.formula(Surv(time_to_death90_days, death90d) ~ class + age + sex + sofa + apsiii + oasis)
  cox90  <- fit_and_export(
    formula = form90,
    data    = dat,
    rds_path = "results/cox_90d_primary.rds",
    csv_path = "results/tables/cox_90d_primary.csv"
  )
} else {
  message("90-day variables not found; skipped 90-day Cox model.")
}

# (Optional) Sensitivity: ≥3 次测量（若需要可解除注释）
# dat3 <- cohort %>% inner_join(classes, by="stay_id") %>% filter(keep_sens3) %>% mutate(class=factor(class), sex=as.factor(sex))
# if(all(c("time_to_death_days","death28d") %in% names(dat3))){
#   fit_and_export(
#     formula = form28,
#     data    = dat3,
#     rds_path = "results/cox_28d_ge3meas.rds",
#     csv_path = "results/tables/cox_28d_ge3meas.csv"
#   )
# }


