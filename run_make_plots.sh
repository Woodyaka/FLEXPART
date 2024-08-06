#!/bin/bash

# Define the absolute path to the AIRTRACER directory
AIRTRACER_DIR="/nobackup/py21cb/AIRTRACER/"

# For each subdirectory in AIRTRACER:
for DIR in $(find ${AIRTRACER_DIR} -mindepth 1 -maxdepth 1 -type d)
do
  pushd ${DIR}
  # Check if there are no .png files in the plot_footprint directory
  if [ ! -e plot_footprint/*.png ] ; then
    # Check if run_plot_footprint_job.sh exists before submitting the job
    if [ -e make_plots.sh ]; then
      qsub make_plots.sh
    else
      echo "Error: run_plot_footprint_job.sh not found in ${DIR}"
    fi
  fi
  popd
done

