packs <- c("data.table","dplyr","survival","readr")
invisible(lapply(packs, function(p){ if(!require(p, character.only=TRUE)) install.packages(p); library(p, character.only=TRUE)}))

dat <- readRDS("results/data_clean.rds")
cohort <- dat$cohort; transf <- dat$transf
classes <- readr::read_csv("results/trajectory_classes.csv")

transf_stay <- transf %>% distinct(stay_id) %>% mutate(transfused = 1)

dat_s <- cohort %>%
  left_join(classes, by="stay_id") %>%
  left_join(transf_stay, by="stay_id") %>%
  mutate(transfused = replace_na(transfused, 0))

# (A) 调整变量
fit_adj <- survival::coxph(Surv(time_to_death_days, death28d) ~ factor(class) + transfused + age + sex + sofa, data = dat_s %>% filter(keep_primary))
saveRDS(fit_adj, "results/cox_adj_transfusion.rds")

# (B) 排除输血
fit_exc <- survival::coxph(Surv(time_to_death_days, death28d) ~ factor(class) + age + sex + sofa, data = dat_s %>% filter(keep_primary, transfused==0))
saveRDS(fit_exc, "results/cox_exclude_transfusion.rds")

# (C) ≥3 次测量敏感性
fit_3 <- survival::coxph(Surv(time_to_death_days, death28d) ~ factor(class) + age + sex + sofa, data = dat_s %>% filter(keep_sens3))
saveRDS(fit_3, "results/cox_ge3meas.rds")

