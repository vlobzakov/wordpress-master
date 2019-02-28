#!/bin/bash
while read -ru 4 LINE; do
    status=`curl $LINE -k -s -f -o /dev/null && echo "SUCCESS" || echo "ERROR"`
    if [ $status = "SUCCESS" ]
    then
        echo "$LINE - OK"
        continue
    else
        echo "$LINE - KO"
    	echo "CDN is not ready yet."
        exit
    fi
done 4< "$1"
/usr/local/bin/wp lscache-admin set_option cdn true --allow-root --path="/var/www/webroot/ROOT" 
crontab -l | sed "/checkCdnStatus/d" | crontab -
wp cache flush  --path="/var/www/webroot/ROOT" 
wp lscache-purge all --path="/var/www/webroot/ROOT" 
rm -rf /home/litespeed/urls.txt  /home/litespeed/checkCdnStatus.sh
echo "CDN is ready! Enjoy."
