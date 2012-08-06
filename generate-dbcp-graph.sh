#!/bin/bash
#
# Write the history of DBCP connections, how many connections each thread holds at each point in time.
# To be used with the output of a Java app that uses commons-dbcp-1.4-monitored
#
# Author: Nicolas Raoul
# License: GNU-GPLv3
#
# Usage: ./generate-dbcp-graph.sh <your-program-output.log>

INPUT=${1:-catalina.out}
OUTPUT_CONNECTED=dbcp-connected-by-thread.csv
OUTPUT_WAITING=dbcp-waiting-by-thread.csv
ACCESSES=/tmp/accesses

# First-pass: Get the list of thread names
echo "First pass"
grep "^DBCPMONITOR" $INPUT \
 | egrep "AbandonnedObjectPool.borrowObject|AbandonnedObjectPool.returnObject" \
 > $ACCESSES
THREADS=`sed -e "s/;[^;]*$//g" -e "s/.*;//g" $ACCESSES | sort -Vu`
echo "Threads:"
echo $THREADS
echo ""

# Initialize array of thread states, and write CSV column headers
THREADSTATES_CONNECTED=()
THREADSTATES_WAITING=()
echo -n "Timestamp;" > $OUTPUT_CONNECTED
for THREAD in $THREADS; do
  THREADSTATES_CONNECTED+=("$THREAD:0")
  THREADSTATES_WAITING+=("$THREAD:0")
  echo -n "$THREAD;" >> $OUTPUT_CONNECTED
done
echo "" >> $OUTPUT_CONNECTED
cp $OUTPUT_CONNECTED $OUTPUT_WAITING


# Second-pass: Line of status for each time
echo "Second pass"
cat $ACCESSES | while read LINE; do
  TIME=`echo $LINE | sed -e "s/DBCPMONITOR;[^;]*;[^;]*;[^;]*;//g" -e "s/;.*//g"`
  THREAD=`echo $LINE | sed -e "s/;[^;]*$//g" -e "s/.*;//g"`
  ACTION_CONNECTED=`echo $LINE | sed -e "s/DBCPMONITOR;//g" -e "s/;.*//g"`
  ACTION_WAITING=`echo $LINE | sed -e "s/DBCPMONITOR;[^;]*;//g" -e "s/;.*//g"`
  echo "Modifying state of thread $THREAD with actions connected:$ACTION_CONNECTED waiting:$ACTION_WAITING"
  # Look for index of this thread
  for ((i=0; i<${#THREADSTATES_CONNECTED[*]}; i++)); do
    [[ ${THREADSTATES_CONNECTED[i]} = $THREAD:* ]] && break
  done
  PREVIOUS_STATE=${THREADSTATES_CONNECTED[i]##*:}
  NEW_STATE=$(($PREVIOUS_STATE+$ACTION_CONNECTED))
  #echo "PREVIOUS_STATE=$PREVIOUS_STATE, NEW_STATE=$NEW_STATE"
  THREADSTATES_CONNECTED[i]=$THREAD:$NEW_STATE
  PREVIOUS_STATE=${THREADSTATES_WAITING[i]##*:}
  NEW_STATE=$(($PREVIOUS_STATE+$ACTION_WAITING))
  #echo "PREVIOUS_STATE=$PREVIOUS_STATE, NEW_STATE=$NEW_STATE"
  THREADSTATES_WAITING[i]=$THREAD:$NEW_STATE
  
  # Write to output
  echo -n "$TIME;" >> $OUTPUT_CONNECTED
  echo -n "$TIME;" >> $OUTPUT_WAITING
  for THREADSTATE in ${THREADSTATES_CONNECTED[@]} ; do
    THREAD=${THREADSTATE%%:*}
    STATE=${THREADSTATE##*:}
    echo -n "$STATE;" >> $OUTPUT_CONNECTED
    #printf "Thread %s is in state %s.\n" $THREAD $STATE
  done
  for THREADSTATE in ${THREADSTATES_WAITING[@]} ; do
    THREAD=${THREADSTATE%%:*}
    STATE=${THREADSTATE##*:}
    echo -n "$STATE;" >> $OUTPUT_WAITING
    #printf "Thread %s is in state %s.\n" $THREAD $STATE
  done
  echo "" >> $OUTPUT_CONNECTED
  echo "" >> $OUTPUT_WAITING
done
