#!/bin/sh

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# TODO: Read from backup instead of blindly dropping the table
psql -c "DROP DATABASE IF EXISTS charliemcgrady;"

# create databases
psql -c "CREATE DATABASE charliemcgrady;"

# add extensions to databases
psql charliemcgrady -c "CREATE EXTENSION postgis;"
psql charliemcgrady -c "CREATE EXTENSION cube;"
