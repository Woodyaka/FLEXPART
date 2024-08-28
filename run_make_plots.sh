#!/bin/bash

# Define the absolute path to the AIRTRACER directory
AIRTRACER_DIR="/nobackup/py21cb/AREOTRACE_MPHASE/"

# For each subdirectory in AIRTRACER:
for DIR in $(find ${AIRTRACER_DIR} -mindepth 1 -maxdepth 1 -type d)
do
  pushd ${DIR} > /dev/null

  # Define the path to the plot_footprint directory
  PLOT_DIR="${DIR}/plot_footprint"

  # Check if the plot_footprint directory exists
  if [ -d "$PLOT_DIR" ]; then
    # Find and delete all .png files in the plot_footprint directory
    PNG_FILES=$(find "$PLOT_DIR" -type f -name "*.png")
    if [ -n "$PNG_FILES" ]; then
      echo "Deleting .png files in ${PLOT_DIR}"
      rm -f "$PLOT_DIR"/*.png
    else
      echo "No .png files to delete in ${PLOT_DIR}"
    fi
  else
    echo "Directory ${PLOT_DIR} does not exist."
  fi

  # Check if make_plots.sh exists before submitting the job
  if [ -e make_plots.sh ]; then
    qsub make_plots.sh
  else
    echo "Error: make_plots.sh not found in ${DIR}"
  fi

  popd > /dev/null
done
