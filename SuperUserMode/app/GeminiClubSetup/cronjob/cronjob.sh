#!/bin/bash

cronjob="3 5-8 1 1-7 2 ./backup.sh"

if ! crontab -l | grep -qF "$cronjob"
then    
    (crontab -l 2> /dev/null; echo "$cronjob") | crontab -
else
    echo "Cronjob has already been setup!"
fi