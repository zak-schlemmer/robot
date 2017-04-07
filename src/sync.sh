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
        # see if the sync container is running for the project
        if [ `docker ps | grep -i "${project}"-rsync | grep -c -i "restart"` == "1" ]; then
            echo "" && echo "You sync container for this project seems messed up."
            echo "I'm going to go ahead and fix that for you."
            docker-sync stop -c /etc/robot/projects/$project_folder/$project/docker-sync/docker-compose.yml --dir ~/robot.dev/docker-sync"${where}" > /dev/null 2>&1
            docker-sync clean -c /etc/robot/projects/$project_folder/$project/docker-sync/docker-compose.yml > /dev/null 2>&1
            docker rm -f "${project}"-rsync > /dev/null 2>&1
            docker-sync start -c /etc/robot/projects/$project_folder/$project/docker-sync/docker-compose.yml --dir ~/robot.dev/docker-sync"${where}" --daemon
            echo "" && echo "docker-sync for this project should be fixed." && echo ""
        else
        # show status
            if [ ! -f ~/robot.dev/docker-sync"${where}"/daemon.pid ]; then
                echo "" && echo "auto-sync for this project is: STOPPED" && echo ""
            else
                echo "" && echo "auto-sync for this project is: RUNNING" && echo ""
            fi
        fi

        ;;

    # manually checks if a new file will sync
    test )
        # create a file
        touch ~/robot.dev/$project/sync-test-file.txt
        # wait
        echo "" && echo "Checking sync now. One moment." && echo ""
        sleep 8
        # see if file exists
        if [ `docker exec "${project}"_web_1 bash -c "cd /$project && ls | grep -c 'sync-test-file.txt'"` == "1" ]; then
            echo "The files sync'd successfully." && echo ""
            rm ~/robot.dev/$project/sync-test-file.txt
            docker exec "${project}"_web_1 bash -c "rm /$project/sync-test-file.txt"
            echo "I have removed the test file for you." && echo ""
        else
            echo "Your sync didn't appear to work." && echo ""
            echo "Running 'robot sync status' can look for issues and attempt to fix them now."
            echo "Maybe try that." && echo ""
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
