#!/bin/bash

if [[ ! -d /backup ]]
then 
    mkdir -p /backup
fi

DATE=$(date +%d-%m-%Y_%H-%M-%S)
BACKUP_LOCATION="/backup/$DATE"

mysqldump -u $MYSQL_USER -p $MYSQL_ROOT_PASSWORD -h $MYSQL_HOST $MYSQL_DATABASE > $BACKUP_LOCATION

gzip $BACKUP_LOCATION
