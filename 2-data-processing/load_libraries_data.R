# adding required libraries
# List of libraries
libraries <- c("haven", "labelled", "dplyr", "tidyr", "purrr", "ggplot2", "mice", "VIM", "randomForest", "caret",
 "ranger", "missForest", "lightgbm","pROC", "stats", "ROCR", "iml", "randomForestExplainer")

# Use lapply to install and load each library
lapply(libraries, function(lib) {
   suppressPackageStartupMessages({
     if(!require(lib, character.only = TRUE)) {
       install.packages(lib)
     }
     library(lib, character.only = TRUE)
   })
})

print("libraries are loaded")

# loading the environmental variables
res_dir = Sys.getenv("RES_DIR")
project_data = Sys.getenv("PROJECT_DATA")
code_data = Sys.getenv("CODE_DIR")

# specifying the relative paths for the datasets
mother_based_path = file.path(project_data,"Millard_Mother_05June23.sav")
child_based_path = file.path(project_data,"Millard_Child_Based_05June23.sav")
child_completed_path = file.path(project_data,"Millard_Child completed_05June23.sav")
focus_11_path = file.path(project_data,"Millard_Child_F11_05June23.sav")
focus_17_path = file.path(project_data, "Millard_Child_TF4_05June23.sav")
focus_24_path = file.path(project_data, "Millard_Child_F24_05June23.sav")
focus_24_2_path = file.path(project_data, "Millard_Child_F24_2_05June23.sav")

# loading the datasets
mother_based = read_spss(mother_based_path)
child_based = read_spss(child_based_path)
child_completed = read_spss(child_completed_path)
focus_11 = read_spss(focus_11_path)
focus_17 = read_spss(focus_17_path)
focus_24 = read_spss(focus_24_path)
focus_24_2 = read_spss(focus_24_2_path)

# creating a function to get variable labels
get_labels <- function(df){
  labels <- map(df, var_label)
  return(labels)
}

# creating a function to get variable levels
get_levels <- function(df) {
     labels <- lapply(df, function(x) {
         if (is.labelled(x)) {
             unique(x)
         } else {
             NA
         }
     })
     return(labels)
}

print("loading data done")
save(mother_based, child_based, child_completed, focus_11, focus_17, focus_24, focus_24_2, file = "2-data-processing/RData_files/datasets.RData")
save(get_labels, get_levels, file = "2-data-processing/RData_files/get_labels_levels.RData")
