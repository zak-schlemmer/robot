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

# git clone
git clone https://github.com/WordPress/WordPress.git ~/robot.dev/$1

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

# wp-cli
echo "" && echo "wp-cli Install" && echo ""
docker exec -t $1_web_1 bash -c "curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar"
docker exec -t $1_web_1 bash -c "chown robot:robot wp-cli.phar"
docker exec -t $1_web_1 bash -c "chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp"

# wordpress install
echo "" && echo "Wordpress Install" && echo ""
docker exec -t $1_web_1 bash -c "cd /$1 && wp --allow-root core config --dbname=${1} --dbuser=root --dbpass=root --dbhost=${1}-db:9999"
docker exec -t $1_web_1 bash -c "cd /$1 && wp --allow-root core install --url=${1}.robot  --title=${1} --admin_user=admin --admin_password=robot --admin_email="admin@robot.com""

# fix permissions
docker exec -t $1_web_1 bash -c "chown -R robot:robot /$1"

# everything done
echo "" && echo "$1 - Finished" && echo ""
