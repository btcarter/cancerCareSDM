# Objective - run all scripts for the study and create outputs.

# vars
SCRIPT_DIR = file.path("C:",
                       "Users",
                       "CarteB",
                       "BILLINGS CLINIC",
                       "Collaborative Science & Innovation (CSI) - Documents",
                       "Ye Olde V Drive",
                       "PROJECT - Cancer Care",
                       "DATA",
                       "R")

OUT_DIR = file.path("C:",
                    "Users",
                    "CarteB",
                    "BILLINGS CLINIC",
                    "Collaborative Science & Innovation (CSI) - Documents",
                    "Ye Olde V Drive",
                    "PROJECT - Cancer Care",
                    "DATA")


# run preprocessing - this returns a dataframe to the global environment called 
#                     'df' for use in the scripts that follow. Changes here will
#                     change thinge everywhere!

source(file = file.path(SCRIPT_DIR,
                        "preprocessing.R"))

# RUN GENERAL REPORT ####
rmarkdown::render(
  input = file.path(SCRIPT_DIR,
                    "descr_gen.Rmd"),
  output_format = c("html_document"),
  output_dir = OUT_DIR,
  output_file = c("general_report")
)
