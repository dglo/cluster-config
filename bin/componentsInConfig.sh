#!/bin/sh

# Save the location of this script and the dir this script is
# being executed from.  Used for locating other needed files.
SCRIPT=`basename $0`
SCRIPT_DIR=`dirname $0`
START_DIR=`pwd`
DESC_DIR=${START_DIR}/${SCRIPT_DIR}
WS_DIR=`cd ${DESC_DIR}/../..; pwd`
BUILD_DIR=${WS_DIR}/build/cluster-config

# Now load the components in this configuration
${WS_DIR}/daq-db-init/daq_db_init.sh -f ${BUILD_DIR}/componentsInConfig.sql

