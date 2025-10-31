## code to prepare `quarantine_sim` dataset goes here


data_quarantine<-read_csv("data-raw/data_quarantine.csv")

usethis::use_data(data_quarantine, overwrite = TRUE)
