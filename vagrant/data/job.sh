#!/bin/bash

#SBATCH --job-name=test
#SBATCH --output=res.txt
#SBATCH --partition=cluster

#SBATCH --time=2:00
#SBATCH --ntasks=2
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1

srun hostname
srun sleep 30
