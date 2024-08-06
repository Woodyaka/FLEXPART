#!/bin/bash
#$ -cwd -V
#$ -l h_rt=1:30:00
#$ -pe smp 1
#$ -l h_vmem=8G
####################################################
#              Run while in iris env               #
####################################################
# print date:
date

# load modules:
#module purge

# load conda environment with iris:
#. home/home02/py21cb/.conda/envs/iris
#conda activate iris

# check which modules are loaded:
#module list

# python script:
PLOT_SCRIPT='/nobackup/py21cb/templates/plot_flexpart_polar_subplots.py' # Path to python script

# plot the time steps:
mkdir -p plot_footprint
cd plot_footprint
python3 ${PLOT_SCRIPT} ../output/grid*.nc AIRTRACER 

# print the date:
date
