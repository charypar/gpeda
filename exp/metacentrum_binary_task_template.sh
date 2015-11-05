#!/bin/sh
#PBS -l nodes=1:ppn=1
#PBS -l mem=2gb
#PBS -l scratch=1gb

export SCRATCHDIR
export LOGNAME
EXPPATH="$EXPPATH_SHORT/$EXPID"

if [ -z "$EXPID" ] ; then
  echo "Error: EXPID (experiment ID) is not known"; exit 1
fi
if [ -z "$ID" ] ; then
  echo "Error: Task ID number is not known"; exit 1
fi
if [ -z "$EXPPATH_SHORT" ] ; then
  echo "Error: directory with the experiment is not known"; exit 1
fi

# clean up the lock-file
trap "rm -f $EXPPATH/queued_$ID" TERM EXIT

cd "$EXPPATH_SHORT/.."
ulimit -t unlimited

######### CALL #########
#
./metacentrum_task_matlab "$EXPID" "$EXPPATH_SHORT" $ID
#
########################

echo `date "+%Y-%m-%d %H:%M:%S"` "  **$EXPID**  ==== FINISHED ===="
