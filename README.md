
# Predicting study dropout / non-participation in ALSPAC

## Project Overview
The aim of this project is to assess participant dropout rates at age 11 in the Avon Longitudinal Study of Parents and Children (ALSPAC) by employing machine learning and statistical methods. The study's findings support the utility of targeted interventions to enhance retention rates in ALSPAC and potentially other longitudinal studies. A high Pearson correlation of 0.98 between clinic and questionnaire data lends credence to the consistency of these predictors.

The project repository is broken down into three main components:
1. Data preparation
2. Data processing
3. Analysis

## Directory Structure
```
.
├── 1-data-prep
│
├── 2-data-processing
│   ├── child_completed
│   │   └── preprocess_child_completed_11.R
│   ├── dropout_11
│   │   └── dropout_11.R
│   ├── dropout_17
│   │   └── dropout_17.R
│   ├── focus_11
│   │   └── preprocess_focus_11.R
│   ├── mother
│   │   └── preprocess_mother.R
│   ├── load_libraries_data.R
│   └── README.md
│
├── 3-analysis
│   ├── master_scripts
│   │   ├── run_all_dropout11_clinic.R
│   │   ├── run_all_dropout11_questionnaire.R
│   │   ├── run_all_dropout17.R
│   │   └── run_all_imp_features.R
│   └── model_analysis
│       ├── important_features.R
│       ├── rf_dropout11_clinic.R
│       ├── rf_dropout11_questionnaire.R
│       └── rf_dropout17.R
│
├── Report.pdf
└── README.md
```
## Folder Descriptions
- 1-data-prep: Contains the scripts used for preparing the initial datasets.
- 2-data-processing: Holds the data processing scripts.
- 3-analysis: Contains analysis scripts and models.

## Environment details

R version: R-4.2.1.

The code is run on the University of Bristol's HPC service (on BlueCrystal phase 4 unless otherwise stated).


The code uses some environment variables, which needs to be set in your linux environment. 

The results and project data directories are temporarily set with:

```bash
export CODE_DIR="${HOME}/2023-msc-alspac-dropout/code"
export RES_DIR="${HOME}/2023-msc-alspac-dropout/results"
export PROJECT_DATA="${HOME}/2023-msc-alspac-dropout/data"
```

## Getting Started
1. Clone the Repository:
```bash
git clone https://github.com/MRCIEU/predicting-ALSPAC-dropout.git
```
2. Navigate into the Project Directory:
```bash
cd $CODE_DIR
```

## Running the Analysis using Shell Scripts
This project uses Slurm Workload Manager to automate the tasks. The shell scripts are designed to execute all the necessary steps for each analysis set. For example, the script run_analysis_dropout_11_clinic.sh performs all the tasks required for analyzing clinic dropout at age 11.

## How to Run
1. Navigate to your Slurm submission directory:
```bash
cd [Your Slurm Submission Directory]
```
2. Submit the job to Slurm:
```bash
sbatch run_analysis_dropout_11_clinic.sh
```
This will schedule the job and run all the tasks specified in 3-analysis/master_scripts/run_all_dropout11_clinic.R.

## Shell Script Details
Here's what the shell script run_analysis_dropout_11_clinic.sh is set to do:
- It specifies job configurations, such as partition, number of nodes, and memory requirements, using Slurm's #SBATCH options.
- It loads the R module (version 4.2.1).
- It navigates to the directory from which the job was submitted ($SLURM_SUBMIT_DIR).
- It runs the R script 3-analysis/master_scripts/run_all_dropout11_clinic.R using Rscript.
- It timestamps the beginning and end of the run using date.

## Acknowledgements

I would like to express my sincere gratitude to my dissertation supervisors at the University of Bristol:

- Dr. Louise Millard
- Professor Kate Tilling
- Dr. Apostolos Gkatzionis

Thank you for your invaluable guidance, support, and expertise throughout the development of this project.

Thank you all for your contributions and encouragement!



