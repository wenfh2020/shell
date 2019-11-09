#!/bin/bash
# wfh/2018/09/18 - operate for db: create, drop, import, dump.

DB_HOST="127.0.0.1"
DB_PORT=3306
DB_USER=root
DB_PWD=123!@#
DB_NAME=db_test
DB_IMPORT_FILE="${DB_NAME}.sql"
DB_DUMP_FILE="${DB_NAME}_dump.sql"
SQL=""

clear

case "$1" in
    "help")
        echo "drop"
        echo "create"
        echo "import"
        echo "dump"
        ;;
    "drop")
        echo "${DB_USER} drop database: ${DB_NAME}"
        SQL="DROP DATABASE IF EXISTS ${DB_NAME}"
        mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PWD -Ns -e "$SQL"
        ;;
    "create")
        echo "${DB_USER} create database: ${DB_NAME}}"
        SQL="CREATE DATABASE IF NOT EXISTS $DB_NAME DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci"
        mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PWD -Ns -e "$SQL"
        ;;
    "import")
        echo "${DB_USER} import data from: ${DB_IMPORT_FILE}"
        mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PWD $DB_NAME < "${DB_IMPORT_FILE}"
        ;;
    "dump")
        echo "${DB_USER} dump data from ${DB_NAME} to ${DB_DUMP_FILE}"
        mysqldump -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PWD $DB_NAME > "${DB_DUMP_FILE}"
        ;;
    *)
        echo "invalid cmd! find for help!"
        exit 1
        ;;
esac

exit 0
