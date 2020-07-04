#!/bin/bash

set -e
set -u

if [ $# != 2 ]; then
    echo "please enter a db host and a table suffix"
    exit 1
fi

export DBHOST=$1
export TSUFF=$2

psql \
    -X \
    -U user \
    -h $DBHOST \
    -f /path/to/sql/file.sql \
    --echo-all \
    --set AUTOCOMMIT=off \
    --set ON_ERROR_STOP=on \
    --set TSUFF=$TSUFF \
    --set QTSTUFF=\'$TSUFF\' \
    mydatabase

psql_exit_status = $?

if [ $psql_exit_status != 0 ]; then
    echo "psql failed while trying to run this sql script" 1>&2
    exit $psql_exit_status
fi

echo "sql script successful"
exit 0
