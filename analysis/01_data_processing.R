# Packages
packs <- c("data.table","dplyr","lubridate","readr")
invisible(lapply(packs, function(p){ if(!require(p, character.only=TRUE)) install.packages(p); library(p, character.only=TRUE)}))

# Set paths for exported CSVs from SQL clients, e.g., psql \copy
dir.create("results", showWarnings = FALSE)
dir.create("results/tables", showWarnings = FALSE)
dir.create("results/figures", showWarnings = FALSE)

# Read cohort, RDW, transfusion
cohort <- readr::read_csv("results/cohort_mimiciv.csv")         # exported from mimiciv_cohort_sepsis_aki.sql
rdw    <- readr::read_csv("results/rdw_mimiciv.csv")            # exported from mimiciv_rdw.sql
transf <- readr::read_csv("results/transfusion_mimiciv.csv")    # exported from mimiciv_transfusion.sql

# Basic cleaning
rdw <- rdw %>%
  mutate(charttime = ymd_hms(charttime)) %>%
  filter(rdw_value > 5 & rdw_value < 50) %>%     # sanity range
  arrange(subject_id, charttime)

# Count measures per stay
rdw_n <- rdw %>% group_by(stay_id) %>% summarize(n_meas = n())

# Keep stays with ≥5 (primary) and mark ≥3 for sensitivity
cohort <- cohort %>%
  left_join(rdw_n, by = "stay_id") %>%
  mutate(n_meas = replace_na(n_meas, 0),
         keep_primary = n_meas >= 5,
         keep_sens3   = n_meas >= 3)

saveRDS(list(cohort=cohort, rdw=rdw, transf=transf), "results/data_clean.rds")

