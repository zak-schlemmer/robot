#!/bin/bash

######################################
#         ROBOT DEVELOPMENT          #
#      robot sync functionality      #
#         by: Zak Schlemmer          #
######################################


# include help functions
. /etc/robot/src/help.functions.sh

# based on navigation to do per project get vars
where=`. /etc/robot/src/determine.navigation.sh`
project=` . /etc/robot/src/determine.project.sh`

# probably need this for most things
project_folder=`ls -d /etc/robot/projects/*/* | grep $project | sed 's/.*projects\///' | sed "s/\/${project}//"`

# arguments to 'robot sync'
case $2 in

    # force a 1 time sync from local -> container for your location
    up )
        docker cp ~"${where}" "${project}"_web_1:"${where}"
        docker exec -u robot -i "${project}"_web_1 bash -c 'cd ${where} && drush cc all'
        ;;

    # force a 1 time sync from container -> local for your location
    back )
        docker cp "${project}"_web_1:"${where}" ~/robot.dev
        ;;

    # restart the auto sync for your location
    restart )
        docker-sync stop -c /etc/robot/projects/$project_folder/$project/docker-sync/docker-compose.yml --dir ~/robot.dev/docker-sync"${where}"
        sleep 2
        docker-sync start -c /etc/robot/projects/$project_folder/$project/docker-sync/docker-compose.yml --dir ~/robot.dev/docker-sync"${where}" --daemon
        ;;

    # stop the auto sync for your location
    stop )
        docker-sync stop -c /etc/robot/projects/$project_folder/$project/docker-sync/docker-compose.yml --dir ~/robot.dev/docker-sync"${where}"
        ;;

    # start the auto sync for your location
    start )
        docker-sync start -c /etc/robot/projects/$project_folder/$project/docker-sync/docker-compose.yml --dir ~/robot.dev/docker-sync"${where}" --daemon
        ;;

    # check if sync is running
    status )
        if [ ! -f ~/robot.dev/docker-sync${where}/daemon.pid ]; then
            echo "" && echo "auto-sync for this project is: STOPPED" && echo ""
        else
            echo "" && echo "auto-sync for this project is: RUNNING" && echo ""
        fi
        ;;

    # prints 'robot clean' help text
    -h | --help | help | "")
        sync_help
        exit
        ;;

    # typo catch + help text
    * )
        echo ""
        echo 'unrecognized command: robot' ${*}
        sync_help
        exit
        ;;

esac
