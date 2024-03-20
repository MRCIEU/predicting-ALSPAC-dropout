#!/bin/bash
#SBATCH --job-name=preprocess_data
#SBATCH --partition=cpu
#SBATCH --account=ACC123
#SBATCH --nodes=10
#SBATCH --ntasks-per-node=1
#SBATCH --time=5:00:00
#SBATCH --mem=20G
#SBATCH --output=../../results/output_files/importance/slurm_%j.out

echo 'Feature Importance Values for dropout_11 clinic'

module add languages/r/4.2.1

cd "${SLURM_SUBMIT_DIR}"

date
Rscript --vanilla 3-analysis/master_scripts/run_all_imp_features.R
date
