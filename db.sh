#!/bin/bash
# operate for db: create, drop, import, dump.

DB_HOST="127.0.0.1"
DB_PORT=3306
DB_USER=topnews
DB_PWD=topnews2016
DB_NAME=vntopnews_shop
DB_IMPORT_FILE="${DB_NAME}.sql"
DB_DUMP_FILE="${DB_NAME}_all.sql"
DB_DUMP_STRUCT_FILE="${DB_NAME}_struct.sql"
DB_DUMP_DATA_FILE="${DB_NAME}_data.sql"
SQL=""

# 删除数据库
case "$1" in
    "help")
        echo "drop"
        echo "create"
        echo "dump"
        ;;
    "drop")
        echo "drop database: ${DB_NAME}"     
        SQL="DROP DATABASE IF EXISTS ${DB_NAME}"
        mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PWD -Ns -e "$SQL"
        ;;
    "create")
        echo "create database: ${DB_NAME}}"
        SQL="CREATE DATABASE IF NOT EXISTS $DB_NAME DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci"
        mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PWD -Ns -e "$SQL"
        if [ "$?" -eq 0 ]; then
            echo "${DB_USER} import data from: ${DB_IMPORT_FILE}"
            mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PWD $DB_NAME < "${DB_IMPORT_FILE}"  
        fi
        ;;
    "import")
        echo "import data from: ${DB_IMPORT_FILE}"
        mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PWD $DB_NAME < "${DB_IMPORT_FILE}"
        ;; 
    "dump")
        echo "dump struct from ${DB_NAME} to ${DB_DUMP_FILE}"
        mysqldump -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PWD $DB_NAME > "${DB_DUMP_FILE}"
        ;;
    "dump_struct")
        echo "dump data from ${DB_NAME} to ${DB_DUMP_STRUCT_FILE}"
        mysqldump -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PWD -d --add-drop-table $DB_NAME > "${DB_DUMP_STRUCT_FILE}"
        ;;
    "dump_data")
        echo "dump data from ${DB_NAME} to ${DB_DUMP_STRUCT_FILE}"
        mysqldump -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PWD $DB_NAME -t> "${DB_DUMP_DATA_FILE}"
        ;;
    *)
        echo "invalid cmd! find for help!"
        exit 1
        ;;
esac

exit 0
