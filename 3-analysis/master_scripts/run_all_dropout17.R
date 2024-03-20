#master script for all the scripts related to dropout_11

# Load libraries and data
source("2-data-processing/load_libraries_data.R")

# Load saved workspace after data loading
load("2-data-processing/RData_files/datasets.RData")
load("2-data-processing/RData_files/get_labels_levels.RData")

# Preprocessing scripts
source("2-data-processing/mother/preprocess_mother.R")
source("2-data-processing/child_completed/preprocess_child_completed_11.R")

# Load saved workspace after preprocessing mother dataset
load("2-data-processing/RData_files/cleandatasets.RData")

# defining outcome variable
source("2-data-processing/dropout_17/dropout_17.R")

# Load saved workspace after defining the outcome variable
load("2-data-processing/RData_files/cleandatasets.RData")

# building and evluating the random forest model to predict the dropout at age 11
source("3-analysis/model_analysis/rf_dropout17.R")
