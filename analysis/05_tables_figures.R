packs <- c("broom","dplyr","readr","ggplot2")
invisible(lapply(packs, function(p){ if(!require(p, character.only=TRUE)) install.packages(p); library(p, character.only=TRUE)}))

# Load models and export tidy tables
export_tbl <- function(model, path){
  broom::tidy(model, exponentiate = TRUE, conf.int = TRUE) %>%
    dplyr::mutate(across(where(is.numeric), ~round(., 3))) %>%
    readr::write_csv(path)
}
export_tbl(readRDS("results/cox_landmark.rds"), "results/tables/cox_landmark.csv")
export_tbl(readRDS("results/cox_adj_transfusion.rds"), "results/tables/cox_adj_transfusion.csv")
export_tbl(readRDS("results/cox_exclude_transfusion.rds"), "results/tables/cox_exclude_transfusion.csv")
export_tbl(readRDS("results/cox_ge3meas.rds"), "results/tables/cox_ge3meas.csv")

