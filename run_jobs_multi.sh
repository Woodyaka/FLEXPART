#!/bin/bash

# Modify the directory path here
BASE_DIR="/nobackup/py21cb/AREOTRACE_MPHASE/"
ALL_DIRS=$(find "$BASE_DIR" -maxdepth 1 -type d)

for DIR in ${ALL_DIRS}
do
  pushd ${DIR}
  if [ -d output ] && [ ! -e output/grid*.nc ] ; then
    qsub run_job.sh
  fi
  popd
done

