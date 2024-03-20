# Analysis for Predicting ALSPAC Dropout

## Overview

This folder contains all the scripts and models associated with the data analysis for predicting dropout in the ALSPAC study. These scripts run various machine learning algorithms and output key metrics and visualizations.

## Subfolders

- **RData_files**: This folder contains serialized R objects used in the analysis.
- **master_scripts**: This folder contains master scripts for running complete analyses.
  - `run_all_dropout11_clinic.R`: Runs analysis for dropout at age 11 for clinic data.
  - `run_all_dropout11_questionnaire.R`: Runs analysis for dropout at age 11 for questionnaire data.
  - `run_all_dropout17.R`: Runs analysis for dropout at age 17.
  - `run_all_imp_features.R`: Runs feature importance analysis.
- **model_analysis**: This folder contains specific model analysis scripts.
  - `important_features.R`: Script to identify important features.
  - `rf_dropout11_clinic.R`: Script for Random Forest analysis for dropout at age 11 using clinic data.
  - `rf_dropout11_questionnaire.R`: Script for Random Forest analysis for dropout at age 11 using questionnaire data.
  - `rf_dropout17.R`: Script for Random Forest analysis for dropout at age 17.

