#!/bin/bash

#SBATCH --job-name=j-addInclusion
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=2:0:0
#SBATCH --mem=100G
#SBATCH --account=ACC1234

#---------------------------------------------

date


cd $SLURM_SUBMIT_DIR

export PROJECT_DATA="${HOME}/2023-msc-alspac-dropout/data"

module add apps/stata/17

stata -b addInclusion.do


date
