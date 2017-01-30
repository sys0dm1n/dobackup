#!/bin/bash
#
# Backup DocumentRoot and DataBase
# Script is to be scheduled with cron
#

#-------------------------------------------------------------------------------------------------
# Backup Settings
#-------------------------------------------------------------------------------------------------
DATE=`date +%F`
COPY_TO=/var/backup/$DATE
COPY_FROM=/var/www/sites

FLOG=$COPY_TO/backup-$DATE.log

#-------------------------------------------------------------------------------------------------
# DataBase Settings
#-------------------------------------------------------------------------------------------------
DB_BCK_NAME="mysql-"$DATE
WEB_BCK_NAME="website-"$DATE
MYSQL_USER=root
MYSQL_PWD=root_PASSWORD
HOST=localhost

#-------------------------------------------------------------------------------------------------
# The Begining
#-------------------------------------------------------------------------------------------------
if [ ! -d "$COPY_TO" ]; then
        mkdir -p $COPY_TO
        echo "CREATING BACKUP FOLDER" | tee -a $FLOG
fi

echo | tee $FLOG
echo "###############################################################################" | tee -a $FLOG
echo "# DB BACKUP `date '+%F'`at ` date '+%T'`                                      #" | tee -a $FLOG
echo "###############################################################################" | tee -a $FLOG

for db in $(mysql --user=$MYSQL_USER --password=$MYSQL_PWD -e 'show databases' -s --skip-column-names|grep -vEi 'information_schema|performance_schema');
do mysqldump --user=$MYSQL_USER --password=$MYSQL_PWD --opt $db | gzip > "$COPY_TO/mysqldump-$HN-$db-$(date +%Y-%m-%d).gz";
done;

echo | tee -a $FLOG
echo "###############################################################################" | tee -a $FLOG
echo "# WEB BACKUP `date '+%F'`at ` date '+%T'`                                     #" | tee -a $FLOG
echo "###############################################################################" | tee -a $FLOG

  tar -cpzf $COPY_TO/$DATE-DocumentRoot.tar.gz $COPY_FROM &> /dev/null
  echo "`date '+%T'` - DocumentRoot" | tee -a $FLOG

echo | tee -a $FLOG
echo "###############################################################################" | tee -a $FLOG
echo "# DELETE OLD BACKUP `date '+%F'`at ` date '+%T'`                              #" | tee -a $FLOG
echo "###############################################################################" | tee -a $FLOG

echo "`find $COPY_TO -mtime +2`" | tee -a $FLOG
find $COPY_TO -mtime +2 | xargs rm -rf

echo | tee -a $FLOG
echo "###############################################################################" | tee -a $FLOG
echo "# EOF `date '+%T'`                                                            #" | tee -a $FLOG
echo "###############################################################################" | tee -a $FLOG
