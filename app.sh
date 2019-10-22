#!/bin/bash

# NAME:   APP.SH
# DESC:   RUN SPRING BOOT APP
# DATE:   25-09-2019
# LANG:   BASH
# AUTHOR: LAGUTIN R.A.
# EMAIL:  RLAGUTIN@MTA4.RU

# https://spring.io/guides/gs/spring-boot-docker/

APPLICATION_YML_FILE=${APPLICATION_YML_FILE:-"/application.yml"}
APPLICATION_DB_YML_FILE=${APPLICATION_DB_YML_FILE:-"/application-db.yml"}
JAVA_OPTIONS=${JAVA_OPTIONS:-"-Djava.security.egd=file:/dev/./urandom -Xms256m -Xmx2048m"}

# SIGTERM handler
function _term() {

   echo "Stopping container."
   echo "SIGTERM received, shutting down the server!"
   kill -15 $childPID
   exit 0 # 128+15

}

# SIGKILL handler
function _kill() {

   echo "SIGKILL received, shutting down the server!"
   kill -9 $childPID
   # exit 137 # 128+9

}

# Set SIGTERM handler
trap _term SIGTERM

# Set SIGKILL handler
trap _kill SIGKILL

if [ ! -e "${APPLICATION_YML_FILE}" ]; then
    echo "A application_yml_file file needs to be supplied."
    exit 1
fi

if [ ! -e "${APPLICATION_DB_YML_FILE}" ]; then
    echo "A application_db_yml_file file needs to be supplied."
    exit 1
fi

if [ -z "${JAVA_OPTIONS}" ]; then
    echo "A java_options needs to be supplied."
    exit 1
fi

java -jar /app.jar $JAVA_OPTIONS --spring.config.location=$APPLICATION_YML_FILE &

childPID=$!
wait $childPID
