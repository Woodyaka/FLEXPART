#!/bin/bash
#$ -cwd -V
#$ -l h_rt=1:30:00
#$ -pe smp 1
#$ -l h_vmem=8G

# print date:
date

# load modules:
#module purge
#module load anaconda

# load conda environment with iris:
#. activate iris

# check which modules are loaded:
#module list

# python script:
PLOT_SCRIPT='/nobackup/py21cb/templates/plot_flexpart_polar_subplots.py' # Path to python script

# plot the time steps:
mkdir -p plot_footprint
cd plot_footprint
python3 ${PLOT_SCRIPT} XRNX/output/*grid*.nc AERO-TRACE 

# print the date:
date
