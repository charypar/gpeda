#!/bin/bash
# Metacentrum task manager for deployd Matlab-compiled 'metacentrum_task_matlab' binary

# usage:
#   ./metacentrum_master_template.sh EXPID META_QUEUE IDs

# ExperimentID (string)
EXPID=$1

# Metacentrum queue/walltime (2h/4h/1d/2d/1w)
QUEUE=$2

# IDs of the tasks to be submitted
CWD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
EXPPATH_SHORT="$CWD/experiments"
# SCRIPT=`basename ${BASH_SOURCE[0]}`
if [ $# -gt 2 ]; then
  shift; shift;
  IDS=$*
else
  IDS=`cat $EXPPATH_SHORT/$EXPID/allids.txt`
fi

export EXPID
export EXPPATH_SHORT
export ID

for ID in $IDS; do
  echo qsub -N "${EXPID}__${ID}" -v EXPID,ID,EXPPATH_SHORT $EXPPATH_SHORT/$EXPID/binary_task.sh
  if [ ! $? -eq 0 ] ; then
    echo "Nepodarilo se zadat ulohu segment ${ID}! Koncim."; exit 1
  else
    echo "Job ${EXPID} / ${ID} submitted to the '$QUEUE' queue."
    touch "$EXPPATH_SHORT/$EXPID/queued_$ID"
  fi
done
