#!/bin/bash

# Base directory path
BASE_DIR="/nobackup/py21cb/AREOTRACE_MPHASE/"

# Find all subdirectories under the base directory
SUBDIRS=$(find "$BASE_DIR" -mindepth 1 -maxdepth 1 -type d)

# Iterate over each subdirectory
for SUBDIR in ${SUBDIRS}; do
  echo "Processing subdirectory: $SUBDIR"

  # Define the path to the txts directory
  TXT_DIR="${SUBDIR}/output/txts"

  # Check if the txts directory exists and remove it
  if [ -d "$TXT_DIR" ]; then
    rm -rf "$TXT_DIR"
    echo "Directory $TXT_DIR has been deleted."
  else
    echo "Directory $TXT_DIR does not exist."
  fi

  # Change to the subdirectory
  pushd "${SUBDIR}" > /dev/null

  # Check for the script and submit if it exists
  if [ -f pos2txt0.sh ]; then
    qsub pos2txt0.sh
  fi

  # Return to the original directory
  popd > /dev/null
done

