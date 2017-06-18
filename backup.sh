#!/bin/bash

DIR=`pwd`
TARGET=~/backups

mkdir -p $TARGET

ls -l /var/www/ | tr -s ' ' | cut -d " " -f 9 | while read DOMAIN
do
    if [ "$DOMAIN" = "" ]; then
        continue
    fi

    tar -zcf $TARGET/$DOMAIN-web.tar.gz /var/www/$DOMAIN

    # Check if the site is based on Drupal so that we can use Drush to back MySQL
    if [ -f /var/www/$DOMAIN/web/sites/default/settings.php ]; then
        cd /var/www/$DOMAIN/web

        drush sql-dump > $TARGET/$DOMAIN-db.sql

        cd $DIR
    fi
done
