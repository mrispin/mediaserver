#!/bin/bash

ALLSUCCESS=0

DEST1=/mnt/merged/backup_BAY1
DEST2=/mnt/merged/backup_BAY2

SONARR=/mnt/merged/opt/sonarr/config/Backups/scheduled/
RADARR=/mnt/merged/opt/radarr/config/Backups/scheduled/
READARR=/mnt/merged/opt/readarr/config/Backups/scheduled/
LIDARR=/mnt/ssd/lidarr/config/Backups/scheduled/

printBackupSuccess() {
	if [ "${SUCCESS}" -ne 0 ]; then
		echo "Backup failed.";
		ALLSUCCESS=1;
	else
		echo "Success.";
	fi
}


echo "Starting backup"


# Copy all *arr deployment backups to backup folders
echo "Copying backups for sonarr..."
SUCCESS=0
rsync -a ${SONARR} ${DEST1}/sonarr
if [ "$?" -ne 0 ]; then	SUCCESS=1; fi;
rsync -a ${SONARR} ${DEST2}/sonarr
if [ "$?" -ne 0 ]; then	SUCCESS=1; fi;
printBackupSuccess;

echo "Copying backups for radarr..."
SUCCESS=0
rsync -a ${RADARR} ${DEST1}/radarr
if [ "$?" -ne 0 ]; then	SUCCESS=1; fi;
rsync -a ${RADARR} ${DEST2}/radarr
if [ "$?" -ne 0 ]; then	SUCCESS=1; fi;
printBackupSuccess;

echo "Copying backups for readarr..."
SUCCESS=0
rsync -a ${READARR} ${DEST1}/readarr
if [ "$?" -ne 0 ]; then	SUCCESS=1; fi;
rsync -a ${READARR} ${DEST2}/readarr
if [ "$?" -ne 0 ]; then	SUCCESS=1; fi;
printBackupSuccess;

echo "Copying backups for lidarr..."
SUCCESS=0
rsync -a ${LIDARR} ${DEST1}/lidarr
if [ "$?" -ne 0 ]; then	SUCCESS=1; fi;
rsync -a ${LIDARR} ${DEST2}/lidarr
if [ "$?" -ne 0 ]; then	SUCCESS=1; fi;
printBackupSuccess;

# Backup mysql
SUCCESS=0
MYSQLBASE=/tmp/mysqlbackup # No trailing slash
BACKUPNAME=mysql-$(date +%Y-%m-%d).tar.gz
mkdir -p ${MYSQLBASE}
mkdir -p ${DEST1}/mysql/
mkdir -p ${DEST2}/mysql/

echo "Performing mysql backup..."
mysqldump --protocol=tcp -A >${MYSQLBASE}/mysql.sql
if [ "$?" -ne 0 ]; then	SUCCESS=1; echo "mysqldump failed"; fi;
tar -zcvf ${MYSQLBASE}/${BACKUPNAME} ${MYSQLBASE}/mysql.sql &>/dev/null
if [ "$?" -ne 0 ]; then	SUCCESS=1; echo "tar failed"; fi;
cp ${MYSQLBASE}/${BACKUPNAME} ${DEST1}/mysql/
if [ "$?" -ne 0 ]; then	SUCCESS=1; echo "copy to BAY1 failed"; fi;
cp ${MYSQLBASE}/${BACKUPNAME} ${DEST2}/mysql/
if [ "$?" -ne 0 ]; then	SUCCESS=1; echo "copy to BAY2 failed"; fi;
rm -rf ${MYSQLBASE};
if [ "$?" -ne 0 ]; then	SUCCESS=1; echo "removal of tmp dir failed"; fi;
printBackupSuccess;


exit ${ALLSUCCESS};
