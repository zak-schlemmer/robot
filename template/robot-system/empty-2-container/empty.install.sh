#!/bin/bash

###################################
#       ROBOT DEVELOPMENT         #
#        drupal7 install          #
#       by: Zak Schlemmer         #
###################################


# find operating system
OS=`uname -s`

# tell the user what is happening
echo "" && echo "" && echo -e "Building $1." && echo ""

# start auto sync and use osx-specific .yml file if using OSX
if [ "$OS" == "Darwin" ]; then
    # docker-sync
    echo "Getting docker-sync ready. Just a moment." && echo ""
    cd /etc/robot/projects/custom/$1/docker-sync/
    docker-sync-daemon start --dir ~/robot.dev/docker-sync/$1
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

# optional db dump
#remove me#echo "" && echo "Importing Database" && docker cp /etc/robot/projects/custom/$1/mysql/${1}.sql ${1}_db_1:/ && docker exec -t ${1}_db_1 bash -c "mysql -u ${1} -probot ${1} < ${1}.sql"

# optional drush
#remove me drush#echo "" && echo "Installing drush" && docker exec -t $1_web_1 bash -c "wget http://files.drush.org/drush.phar && chmod +x drush.phar && mv drush.phar /usr/local/bin/drush"

# optional wp-cli
#remove me wp#echo "" && echo "Installing wp-cli" && docker exec -t $1_web_1 bash -c "curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chown robot:robot wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp"


docker exec -t $1_web_1 bash -c "chown -R robot:robot /$1"

# everything done
echo "" && echo "$1 - Finished" && echo ""
