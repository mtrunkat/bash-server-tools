#!/bin/bash

# Create VHOST configuration.
AVAILABLE=/etc/apache2/sites-available
ENABLED=/etc/apache2/sites-enabled
DOMAIN=$1 envsubst < ./VHOST_TEMPLATE > ${AVAILABLE}/$1.conf
ln -s ${AVAILABLE}/$1.conf ${ENABLED}/$1.conf
echo "Vhost files created."

# Create directory.
mkdir -p /var/www/$1
mkdir -p /var/www/$1/web
echo "Directories created."

# Check apache conf and restart.
apachectl configtest && service apache2 restart
echo "Apache restarted."

echo "Done."
