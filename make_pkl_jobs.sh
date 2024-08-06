#!/bin/bash

# Define the path to the AIRTRACER directory and the file to be copied
AIRTRACER_DIR="/nobackup/py21cb/AIRTRACER"
SCRIPT_TO_COPY="/nobackup/py21cb/templates/pos2txt0.sh"  # Update this path to the location of pos2txt.sh

# Iterate through each subdirectory in AIRTRACER
for DIR in $(find ${AIRTRACER_DIR} -mindepth 1 -maxdepth 1 -type d)
do
  # Extract the name of the subdirectory (basename of DIR)
  SUB_DIR_NAME=$(basename "${DIR}")

  # Remove any existing pos2txt.sh in the subdirectory
  if [ -e "${DIR}/pos2txt0.sh" ]; then
    rm "${DIR}/pos2txt0.sh"
    echo "Removed existing pos2txt0.sh from ${DIR}"
  fi

  # Copy the script to the subdirectory
  cp "${SCRIPT_TO_COPY}" "${DIR}/pos2txt0.sh"

  # Replace XRNX in the copied script with the subdirectory name
  sed -i "s|XRNX|${SUB_DIR_NAME}|g" "${DIR}/pos2txt0.sh"

  echo "Processed ${DIR} with XRNX replaced by ${SUB_DIR_NAME}"
done
