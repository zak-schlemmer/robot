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
#remove me#docker cp /etc/robot/projects/custom/$1/mysql/${1}.sql ${1}_db_1:/ && docker exec -t ${1}_db_1 bash -c "mysql -u ${1} -p${1} ${1} < ${1}.sql"

docker exec -t $1_web_1 bash -c "chown -R robot:robot /$1"

# everything done
echo "" && echo "$1 - Finished" && echo ""
