#!/bin/bash
################################################
#
# Backup all MySQL databases in separate files and compress those.
# Furthermore the script will create a folder with the current time stamp
# @author: Per Lasse Baasch (http://skycube.net)
# @Version: 2014-06-13
# NOTE: MySQL and gzip installed on the system
# and you will need write permissions in the directory where you executing this script
#
################################################
# MySQL User
USER="$3"
# MySQL Password
PASSWORD="$4"
# Backup Directory - NO TAILING SLAsh!
OUTPUT="/media"
##### And
TIMESTAMP=`date +%Y%m%d_%H%M%S`;
mkdir $OUTPUT/$1/backup_$1/;
mkdir $OUTPUT/$1/backup_$1/dbbackup/;
mkdir $OUTPUT/$1/backup_$1/dbbackup/$TIMESTAMP;
cd $OUTPUT/$1/backup_$1;
echo "Starting MySQL Backup";
echo `date`;
databases=`mysql --user=$USER --password=$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`
for db in $databases;do
    if [ "$db" != "information_schema" ] && [ "$db" != _* ] ; then
        echo "Dumping database: $db"
        mysqldump --host=$2 --force --opt --user=$USER --password=$PASSWORD --databases $db > $OUTPUT/$1/backup_$1/dbbackup/$TIMESTAMP/dbbackup-$TIMESTAMP-$db.sql
#	gzip $OUTPUT/dbbackup-$TIMESTAMP-$db.sql
    fi
done
echo "Finished MySQL Backup";
echo `date`;
