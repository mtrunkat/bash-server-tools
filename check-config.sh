#!/bin/bash

DIR=`pwd`
tput setaf 0

function print_error {
    tput setaf 1
    echo $1
    tput setaf 0
}

ls -l /var/www/ | tr -s ' ' | cut -d " " -f 9 | while read DOMAIN
do
    if [ "$DOMAIN" = "" ]; then
        continue
    fi
    if [ "$DOMAIN" = "html" ]; then
        continue
    fi

    echo "Checking $DOMAIN ..."
    cd /var/www/$DOMAIN/web

    if [ ! -f ./.htaccess ]; then
        print_error "--- htaccess doesn't exist!"
    else
        echo "--- htaccess OK"
    fi

    if [ -f ./sites/default/settings.php ]; then
        echo "--- running Drupal site checks ..."

        PUBLIC_FILES=`drush variable-get file_public_path --exact`
        PRIVATE_FILES=`drush variable-get file_private_path --exact`
        TMP_FILES=`drush variable-get file_temporary_path --exact`

        if [ $PUBLIC_FILES != "sites/default/files" ]; then
            print_error "------ public files directory not correct"
        else
            echo "------ public files directory OK"
        fi

        if [ $PRIVATE_FILES != "sites/default/private-files" ]; then
            print_error "------ private files directory not correct"
        else
            echo "------ private files directory OK"
        fi

        if [ $TMP_FILES != "/tmp/www/$DOMAIN" ]; then
            print_error "------ tmp files directory not correct"
        else
            echo "------ tmp files directory OK"
        fi

        PUBLIC_FILES_OWNER=`stat --format '%U' /var/www/$DOMAIN/web/sites/default/files`
        PRIVATE_FILES_OWNER=`stat --format '%U' /var/www/$DOMAIN/web/sites/default/private-files`
        TMP_FILES_OWNER=`stat --format '%U' /tmp/www/$DOMAIN`

        if [ $PUBLIC_FILES_OWNER != "www-data" ]; then
            print_error "------ public files owner not correct"
        else
            echo "------ public files owner OK"
        fi

        if [ $PRIVATE_FILES_OWNER != "www-data" ]; then
            print_error "------ private files owner not correct"
        else
            echo "------ private files owner OK"
        fi

        if [ $TMP_FILES_OWNER != "www-data" ]; then
            print_error "------ tmp files owner not correct"
        else
            echo "------ tmp files owner OK"
        fi

        SYSLOG=`drush pm-list --pipe --type=module --status=enabled | grep syslog`

        if [ $SYSLOG != "syslog" ]; then
            print_error "------ syslog not enabled"
        else
            echo "------ syslog OK"
        fi

        SYSLOG_IDENTITY=`drush variable-get syslog_identity --exact`

        if [ $SYSLOG_IDENTITY != $DOMAIN ]; then
            print_error "------ syslog configuration not correct"
        else
            echo "------ syslog configuration OK"
        fi
    fi

    cd $DIR
done

ls -l /var/www/ | tr -s ' ' | cut -d " " -f 9 | while read DOMAIN
do
    if [ "$DOMAIN" = "" ]; then
        continue
    fi
    if [ "$DOMAIN" = "html" ]; then
        continue
    fi

    cd /var/www/$DOMAIN/web

    if [ -f ./sites/default/settings.php ]; then
        echo "Checking updates $DOMAIN:"
        drush pm-updatestatus --security-only --pipe
    fi

    cd $DIR
done
