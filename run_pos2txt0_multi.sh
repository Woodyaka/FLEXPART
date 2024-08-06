#!/bin/bash

# Modify the directory path here
BASE_DIR="/nobackup/py21cb/AIRTRACER/"
ALL_DIRS=$(find "$BASE_DIR" -maxdepth 1 -type d)

for DIR in ${ALL_DIRS}
do
  pushd ${DIR}
  if [ -f pos2txt0.sh ] ; then
    qsub pos2txt0.sh
  fi
  popd
done
