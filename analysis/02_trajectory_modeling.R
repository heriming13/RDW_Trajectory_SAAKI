packs <- c("data.table","dplyr","lubridate","lcmm")
invisible(lapply(packs, function(p){ if(!require(p, character.only=TRUE)) install.packages(p); library(p, character.only=TRUE)}))

dat <- readRDS("results/data_clean.rds")
cohort <- dat$cohort; rdw <- dat$rdw

# Build longitudinal dataset with time since ICU admit (hours)
rdw_long <- rdw %>%
  inner_join(cohort %>% filter(keep_primary) %>% select(stay_id, intime), by = "stay_id") %>%
  mutate(t_hr = as.numeric(difftime(charttime, intime, units="hours"))) %>%
  filter(t_hr >= 0, t_hr <= 240)   # first 10 days window

# Example 3-class GBTM using lcmm::hlme (adjust K as needed)
# Note: You will tune number of classes, polynomials, BIC minimization, etc.
m3 <- hlme(fixed = rdw_value ~ poly(t_hr, 2, raw=TRUE),
           random = ~ 1,
           subject = 'stay_id',
           ng = 3,
           data = rdw_long,
           mixture = ~ poly(t_hr, 2, raw=TRUE),
           nwg = TRUE,
           verbose = TRUE)

saveRDS(m3, "results/gbtm_m3.rds")

# Posterior class assignment
post <- data.frame(stay_id = m3$pprob$subject, class = m3$pprob$class)
write.csv(post, "results/trajectory_classes.csv", row.names = FALSE)

