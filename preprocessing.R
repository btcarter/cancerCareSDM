# Preamble ####
# author: Benjamin T. Carter, PhD
# This script modifies data to make it more workable
# It does not apply any analytical methods

# LIBRARY LOADING #########################################################################################

# libraries
library(readxl)
library(dplyr)

# LOAD DATA ################################################################################################

# load data
DATA.DIR <- file.path(
  "C:",
  "Users",
  "CarteB",
  "BILLINGS CLINIC",
  "Collaborative Science & Innovation (CSI) - Documents",
  "Ye Olde V Drive",
  "PROJECT - Cancer Care",
  "DATA"
)


df.raw <- read_xlsx(
  file.path(DATA.DIR,
            "CancerCare_Nurses_Final_Data 03.16.21.xlsx"),
  skip = 1
)

df.var.names <- read_xlsx(
  file.path(DATA.DIR,
            "CancerCare_Nurses_Final_Data 03.16.21.xlsx"),
  skip = 1,
  n_max = 98,
  sheet = "Labels"
)

df.var.values <- read_xlsx(
  file.path(DATA.DIR,
            "CancerCare_Nurses_Final_Data 03.16.21.xlsx"),
  skip = 101,
  n_max = 258,
  sheet = "Labels"
)

# EXCLUSIONS ###################################################################
df.raw <- df.raw[is.na(df.raw$q0006_0001),]

# CLEAN VARIABLES ##############################################################
# fill in missing entries in variable label df
df.var.values <- df.var.values %>% 
  tidyr::fill(Value, .direction = "down") %>% 
  rename(
    entry = `...2`
  )

# CLEAN THE DF #################################################################
# make ids strings
df.raw$RespondentID <- as.character(df.raw$RespondentID)

# get non-likert columns
nl_cols <- setdiff(colnames(df.raw),
                   df.var.values$Value)

df <- df.raw[nl_cols]

# clean and add the likerts
clean_response <- function(x, col_nom){
  if (!is.na(x)){
    a <- df.var.values$Label[
      df.var.values$Value == col_nom &
        df.var.values$entry == x]
    return(a)
  } else {
    return(x)
  }
}

clean_responses <- function(x){
  ret_col <- sapply(df.raw[[x]], 
                    clean_response,
                    col_nom = x)
  
  return(ret_col)
}

ar.cols <- df.var.values$Value

df.likerts <- sapply(ar.cols,
                     clean_responses,
                     USE.NAMES = TRUE)

df.likerts <- as.data.frame(df.likerts)[unique(colnames(df.likerts))]

df.likerts <- apply(df.likerts,
                    2,
                    as.character)

df <- cbind(df, df.likerts)

# make a missingness df
ar.cols <- grep("q\\d{4}$",
                colnames(df.raw))

ar.cols <- colnames(df.raw)[ar.cols]

ar.cols <- setdiff(ar.cols,
                   "q0022")

df.bin <- df.raw[ar.cols]

ar.cols <- grep("q\\d{4}_.{4}$",
                colnames(df.raw))

ar.cols <- colnames(df.raw)[ar.cols]

ar.cols.binned <- unique(
  gsub("(q\\d{4})_.{4}$",
       "\\1",
       ar.cols)
)

ar.cols.binned <- sapply(ar.cols.binned,
                                 function(x){
                                   apply(
                                     !is.na(df.raw %>% select(starts_with(x))),
                                     1,
                                     sum
                                   )
                                 })

ar.cols.binned[ar.cols.binned == 0] <- NA

df.bin <- cbind(df.bin, ar.cols.binned)

ar.cols <- grep("q\\d{4}_\\d{4}_\\d{4}$",
                colnames(df.raw))

df.bin <- cbind(df.bin, df.raw[ar.cols])

df.bin <- df.bin[sort(colnames(df.bin))]

df.bin <- apply(df.bin,
                1:2,
                function(x){
                  return(!is.na(x))
                })

df.bin <- as.data.frame(df.bin)

df.bin$RespondentID <- df.raw$RespondentID



# MAKE GLOBAL OUTPUTS ##########################################################
ar.demographics <- paste("q000",
                         1:6,
                         sep = "")

ar.demographics <- paste(ar.demographics, ".*", sep = "")
ar.demographics <- paste(ar.demographics, collapse = "|")

ar.demographics <- grep(ar.demographics, colnames(df))
ar.demographics <- colnames(df)[ar.demographics]

# outcomes.vec <- c()

# stratify.vec <- c()

# quant.vecs <- c()

case.id <- "RespondentID"

# write output to check later ####
# write.csv(df,
#           file = file.path(DATA.DIR,
#                            "R-traumaDB.csv"))
# 
# write.csv(df.icd,
#           file = file.path(DATA.DIR,
#                            "R-traumaIcdDB.csv"))
