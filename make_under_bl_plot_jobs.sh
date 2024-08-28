#!/bin/bash

# absolut path to dir containing runs:
AIRTRACER_DIR='/nobackup/py21cb/MPHASE/'

# job running script:
RUN_SCRIPT=$(dirname $(readlink -f ${0}))/under_bl_job.sh

# for each directory in AIRTRACER:
for DIR in $(find ${AIRTRACER_DIR} -mindepth 1 -maxdepth 1 -type d)
do
    # copy the job script and set the correct permissions:
    \cp ${RUN_SCRIPT} ${DIR}/under_bl_job.sh
    chmod 755 ${DIR}/under_bl_job.sh
done
