#!/bin/bash
#SBATCH --job-name=preprocess_data
#SBATCH --partition=cpu
#SBATCH --account=ACC123
#SBATCH --nodes=20
#SBATCH --ntasks-per-node=1
#SBATCH --time=5-00:00:0
#SBATCH --mem=20G
#SBATCH --output=../../results/output_files/dropout_11/clinic/slurm_%j.out

echo 'Predicting ALSPAC Dropout in clinic at age_11'

module add languages/r/4.2.1

cd "${SLURM_SUBMIT_DIR}"

date
Rscript --vanilla 3-analysis/master_scripts/run_all_dropout11_clinic.R
date

