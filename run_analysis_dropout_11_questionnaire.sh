#!/bin/bash
#SBATCH --job-name=preprocess_data
#SBATCH --partition=cpu
#SBATCH --account=ACC123
#SBATCH --nodes=20
#SBATCH --ntasks-per-node=2
#SBATCH --time=4-00:00:0
#SBATCH --mem=20G
#SBATCH --output=../../results/output_files/dropout_11/questionnaire/slurm_%j.out

echo 'Predicting ALSPAC Dropout in questionnaire at age_11'

module add languages/r/4.2.1

cd "${SLURM_SUBMIT_DIR}"

date
Rscript --vanilla 3-analysis/master_scripts/run_all_dropout11_questionnaire.R
date
