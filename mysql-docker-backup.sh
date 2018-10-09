#!/bin/bash
set -x
TIMESTAMP=$(date +”%F”)
BACKUP_DIR=”/backup-directory/mysql/$TIMESTAMP”  #create dir for daily backup
MYSQL_USER=”root”
MYSQL=/usr/bin/mysql
MYSQL_PASSWORD=”rootpassword”
MYSQLDUMP=/usr/bin/mysqldump
mkdir -p “$BACKUP_DIR”          #mkdir Daily … or depends on cronjob schedule
for MysqlDB in $(docker ps –format ‘{{.Names}}’ |grep mysql)  # where all mysql docker container include “mysql” in its name convention 
do
mkdir -p “$BACKUP_DIR/$MysqlDB” #create dir with database docker container name
BACKUP_DIR=”$BACKUP_DIR/$MysqlDB”
databases=$(docker exec ${MysqlDB} $MYSQL –user=${MYSQL_USER} -p${MYSQL_PASSWORD} -e “SHOW DATABASES;” | grep -Ev “(sys|mysql|Database|information_schema|performance_schema)”;) #only Non systems schemas DBs
for DBName in ${databases}
do
docker exec ${MysqlDB} ${MYSQLDUMP} –force –opt –user=${MYSQL_USER} -p${MYSQL_PASSWORD} –databases ${DBName} | gzip > “${BACKUP_DIR}/${DBName}.gz”
done
BACKUP_DIR=”${BACKUP_DIR}/mysql/$TIMESTAMP” #set BACKUP_DIR=to backup root dir again
done

 
