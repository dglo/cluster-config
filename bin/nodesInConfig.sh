#!/bin/bash

# Save the location of this script and the dir this script is
# being executed from.  Used for locating other needed files.
SCRIPT=`basename $0`
SCRIPT_DIR=`dirname $0`
START_DIR=`pwd`
DESC_DIR=${START_DIR}/${SCRIPT_DIR}
WS_DIR=`cd ${DESC_DIR}/../..; pwd`
BUILD_DIR=${WS_DIR}/build/cluster-config

# Pick up CLUSTER
source ${BUILD_DIR}/daq-node-list

if [ "${CLUSTER}" != "merc" ]; then
  # Get the postgres jboss passwd
  read -sp "jboss' password: " loosers
  echo
fi

echo "SELECT COMPONENTTYPE, COMPONENTID FROM DAQCOMPONENTSINCONFIGBEAN" > temp.sql
echo "WHERE DAQCOMPONENTSINCONFIGBEAN.COMPONENTDEPLOYED=TRUE;" >> temp.sql

dbPasswd=${loosers} ${WS_DIR}/daq-db-init/daq_db_init.sh -l 4 -f temp.sql | sed -e 1,13d >temp.out

i=0
index=0
echo "Components listed as deployed in this configuration:"
while read line; do
  let "index=$i % 3"
  if [ $index -eq 0 ]; then
      component=$line
  fi
  if [ $index -eq 1 ]; then
      unit=$line
  fi
  if [ $index -eq 2 ]; then
      echo "$component $unit"
  fi
  let "i+=1"
done <temp.out
echo

# now look for those that are also listed as found in this configuration
echo "SELECT COMPONENTTYPE, COMPONENTID FROM DAQCOMPONENTSINCONFIGBEAN" > temp.sql
echo "WHERE DAQCOMPONENTSINCONFIGBEAN.COMPONENTDEPLOYED=TRUE" >> temp.sql
echo "AND DAQCOMPONENTSINCONFIGBEAN.COMPONENTINCONFIG=TRUE;" >> temp.sql

dbPasswd=${loosers} ${WS_DIR}/daq-db-init/daq_db_init.sh -l 4 -f temp.sql | sed -e 1,14d >temp.out

i=0
index=0
echo "Components listed as deployed and also discoverd in this configuration:"
while read line; do
  let "index=$i % 3"
  if [ $index -eq 0 ]; then
      component=$line
  fi
  if [ $index -eq 1 ]; then
      unit=$line
  fi
  if [ $index -eq 2 ]; then
      echo "$component $unit"
  fi
  let "i+=1"
done <temp.out

rm -rf temp.out
rm -rf temp.sql
