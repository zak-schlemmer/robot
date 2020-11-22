#!/bin/bash

###################################
#       ROBOT DEVELOPMENT         #
#        drupal8 install          #
#       by: Zak Schlemmer         #
###################################


# find operating system
OS=`uname -s`

# tell the user what is happening
echo "" && echo "" && echo -e "Building $1." && echo ""

# get drupal
cd ~/robot.dev/ && wget https://www.drupal.org/download-latest/tar.gz
mkdir $1 && tar -xzf tar.gz -C $1 --strip-components 1 && rm -rf tar.gz*

# composer install
echo "" && echo "Composer - $1"
cd ~/robot.dev/$1/ && composer require drush/drush && composer -n install --prefer-dist
sleep 1

# start auto sync and use osx-specific .yml file if using OSX
if [ "$OS" == "Darwin" ]; then
    # docker-sync
    echo "Getting docker-sync ready. Just a moment." && echo ""
    cd /etc/robot/projects/custom/$1/docker-sync/
    docker-sync start --dir ~/robot.dev/docker-sync/$1
    docker update --restart=always $1-sync
    cd - > /dev/null 2>&1
    # docker-compose build / up
    docker-compose -p robot -f /etc/robot/projects/custom/$1/osx-docker-compose.yml build
    docker-compose -p robot -f /etc/robot/projects/custom/$1/osx-docker-compose.yml up -d
else
    # docker-compose build / up
    docker-compose -p robot -f /etc/robot/projects/custom/$1/docker-compose.yml build
    docker-compose -p robot -f /etc/robot/projects/custom/$1/docker-compose.yml up -d
fi
sleep 8

# handle site file readiness assurance based on operating system
if [ "$OS" == "Darwin" ]; then
    # just until I'm sure the sync works
    docker cp ~/robot.dev/$1/ $1_web_1:/
else
    # get ready for install
    docker exec -t $1_web_1 bash -c "chown -R robot:robot /$1"
fi
sleep 3

# drush
docker exec -t $1_web_1 bash -c "ln -s /$1/vendor/drush/drush/drush /usr/local/bin"

# drupal install
echo "" && echo "Drupal Install" && echo ""
docker exec -t $1_web_1 bash -c "cd /$1 && drush site-install -y standard --site-name=${1} --account-name=admin --account-pass=robot --account-mail=admin@robot.com --db-url=mysql://root:root@${1}-db:3306/${1}"
docker exec -t $1_web_1 bash -c "cd /$1 && drush cr"

# fix permissions
docker exec -t $1_web_1 bash -c "cd /$1/sites/default && chmod 644 default.settings.php settings.php"
docker exec -t $1_web_1 bash -c "chown -R robot:robot /$1"

# optional memcache bits
#remove me memcache#docker exec -t $1_web_1 bash -c "cd /$1 && drush en -y memcache"
#remove me memcache#cat /etc/robot/projects/custom/$1/memcache/template.drupal8.settings.php >> ~/robot.dev/${1}/sites/default/settings.php

# everything done
echo "" && echo "$1 - Finished" && echo ""
