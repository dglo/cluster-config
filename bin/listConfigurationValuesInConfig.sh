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

echo -n "Enter DAQ configuration to search on: "
read configID
echo

if [ "${CLUSTER}" != "merc" ]; then
  # Get the postgres jboss passwd
  read -sp "jboss' password: " loosers
  echo
fi

# now look for those that are also listed as found in this configuration
echo "SELECT COMPONENTTYPE, COMPONENTID FROM DAQCOMPONENTSINCONFIGBEAN" > temp.sql
echo "WHERE DAQCOMPONENTSINCONFIGBEAN.COMPONENTDEPLOYED=TRUE" >> temp.sql
echo "AND DAQCOMPONENTSINCONFIGBEAN.COMPONENTINCONFIG=TRUE;" >> temp.sql

dbPasswd=${loosers} ${WS_DIR}/daq-db-init/daq_db_init.sh -l 4 -f temp.sql | sed -e 1,14d >temp.out

i=0
index=0
while read line; do
    let "index=$i % 3"
    if [ $index -eq 0 ]; then
	component=$line
	echo "Configuration ids for $component: "

	echo "SELECT ASSOCIATEDCOMPONENT, TARGETCOMPONENTTYPE, TARGETCOMPONENTVALUE" > temp.sql
	echo "FROM DAQCONFIGURATIONDATABEAN" >> temp.sql
	echo "WHERE ASSOCIATEDCOMPONENT = '$component'" >> temp.sql
	echo "AND CONFIGURATIONID =" >> temp.sql
	echo "(SELECT TARGETCOMPONENTVALUE FROM DAQCONFIGURATIONDATABEAN" >> temp.sql
	echo "WHERE TARGETCOMPONENTTYPE = '$component'" >> temp.sql
	echo "AND CONFIGURATIONID = '$configID');" >> temp.sql

	dbPasswd=${loosers} ${WS_DIR}/daq-db-init/daq_db_init.sh -l 4 -f temp.sql | sed -e 1,19d >temp.ou

	j=0
	innerindex=0
	while read innerline; do
	    let "innerindex=$j % 4"
	    if [ $innerindex -eq 0 ]; then
		component=$innerline
	    fi
	    if [ $innerindex -eq 1 ]; then
		table=$innerline
	    fi
	    if [ $innerindex -eq 2 ]; then
		id=$innerline
		echo $'\t'"$table $id"
	    fi
	    let "j+=1"
        done <temp.ou
    fi
    let "i+=1"
done <temp.out
echo

rm -rf temp.out
rm -rf temp.ou
rm -rf temp.sql
