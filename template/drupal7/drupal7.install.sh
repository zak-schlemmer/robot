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
git clone --branch 7.54 https://git.drupal.org/project/drupal.git ~/robot.dev/$1

# start auto sync if using OSX
if [ "$OS" == "Darwin" ]; then
    docker-sync start -c /etc/robot/docker-sync/$1-docker-sync.yml --dir ~/robot.dev/docker-sync/$1 --daemon
    docker update --restart=always $1-rsync
fi

# docker-compose build / up
docker-compose -p robot -f /etc/robot/projects/$1/docker-compose.yml build
docker-compose -p robot -f /etc/robot/projects/$1/docker-compose.yml up -d
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

# drupal install
echo "" && echo "Drupal Install" && echo ""
docker exec -t $1_web_1 bash -c "cd /$1 && drush site-install -y standard --site-name=${1} --account-name=admin --account-pass=robot --account-mail=admin@robot.robot --db-url=mysql://root:root@${1}-db:9999/${1}"
docker exec -t $1_web_1 bash -c "cd /$1 && drush cc all"

# fix permissions
docker exec -t $1_web_1 bash -c "cd /$1/sites/default && chmod 644 default.settings.php"
docker exec -t $1_web_1 bash -c "chown -R robot:robot /$1"

# everything done
echo "" && echo "$1 - Finished"
