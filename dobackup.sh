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
MYSQL_USER=USERNAME
MYSQL_PWD=YOURPASSWORD
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

for db in $(echo 'SHOW DATABASES;'|mysql -u$MYSQL_USER -p$MYSQL_PWD -h$HOST|grep -v '^Database$'|grep -E 'db1|db2|db3');
do
		mysqldump \
			-u$MYSQL_USER -p$MYSQL_PWD -h$HOST \
			-Q -c -C --opt \
			$db | gzip --best -c > $COPY_TO/$DBBACKUPNAME-$db.sql.gz | tee -a $FLOG;
			echo "Backup of" $db | tee -a $FLOG;
done;

echo | tee -a $FLOG
echo "###############################################################################" | tee -a $FLOG
echo "# WEB BACKUP `date '+%F'`at ` date '+%T'`                                     #" | tee -a $FLOG
echo "###############################################################################" | tee -a $FLOG

for x in $(find $COPY_FROM -maxdepth 1 -type d \( -name web1 -o -name web2 -o -name web3 \) -print0 | xargs -0)
do
  tar -cpzf $COPY_TO/$WEB_BCK_NAME-$(basename $x).tar.gz $x &> /dev/null
  echo "`date '+%T'` - $(basename $x)" | tee -a $FLOG
done;

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
