#!/bin/bash

######################################
#         ROBOT DEVELOPMENT          #
#      robot sync functionality      #
#         by: Zak Schlemmer          #
######################################


# include help functions
. /etc/robot/src/help.functions.sh

# find project
project_list=(`ls -p /etc/robot/projects/* | grep / | grep -v : | tr -d '/' | tr '\n' ' '`)
for i in "${project_list[@]}"
do
    if [ `pwd | grep -c "/${i}"` == "1" ]; then
        # this is how it looks for multiple web head projects
        if [ `pwd | grep -coE "${i}[^/]+"` == "0" ]; then
            subproject=`pwd | grep -oE "${i}"`
        else
            subproject=`pwd | grep -oE "${i}[^/]+"`
        fi
    fi
done

# remove any sub-project stuff
project=`echo $subproject | cut -f1 -d"_"`

# probably need this for most things
project_folder=`ls -d /etc/robot/projects/*/* | grep "${project}*" | sed 's/.*projects\///' | sed "s/\/.*//"`

# determine project root
project_base=`pwd | grep -o ".*${subproject}" | sed "s@$subproject@@g"`

# arguments to 'robot sync'
case $2 in

    # force a 1 time sync from local -> container for your location
    up )
        docker cp "${project_base}${subproject}" "${subproject}"_web_1:/
        docker exec "${subproject}"_web_1 bash -c "chown -R robot:robot /${subproject}"
        ;;

    # force a 1 time sync from container -> local for your location
    back )
        docker cp "${subproject}"_web_1:/"${subproject}" "${project_base}"
        ;;

    # restart the auto sync for your location
    restart )
        cd /etc/robot/projects/$project_folder/$project/docker-sync/
        docker-sync-daemon stop --dir ~/robot.dev/docker-sync/"${subproject}"
        sleep 2
        docker-sync-daemon start --dir ~/robot.dev/docker-sync/"${subproject}"
        cd - > /dev/null 2>&1
        ;;

    # stop the auto sync for your location
    stop )
        cd /etc/robot/projects/$project_folder/$project/docker-sync/
        docker-sync-daemon stop --dir ~/robot.dev/docker-sync/"${subproject}"
        cd - > /dev/null 2>&1
        ;;

    # start the auto sync for your location
    start )
        cd /etc/robot/projects/$project_folder/$project/docker-sync/
        docker-sync-daemon start --dir ~/robot.dev/docker-sync/"${subproject}"
        cd - > /dev/null 2>&1
        ;;

    # check if sync is running
    status )
        # see if the sync container is running for the project
        if [ `docker ps | grep -i "${subproject}"-sync | grep -c -i "restart"` == "1" ]; then
            echo "" && echo "You sync container for this project seems messed up."
            echo "I'm going to go ahead and fix that for you."
            cd /etc/robot/projects/$project_folder/$project/docker-sync/
            docker-sync-daemon stop --dir ~/robot.dev/docker-sync/"${subproject}" > /dev/null 2>&1
            docker-sync clean -c /etc/robot/projects/$project_folder/$project/docker-sync/docker-compose.yml > /dev/null 2>&1
            docker rm -f "${subproject}"-sync > /dev/null 2>&1
            docker-sync-daemon start --dir ~/robot.dev/docker-sync/"${subproject}"
            cd - > /dev/null 2>&1
            echo "" && echo "docker-sync for this project should be fixed." && echo ""
        else
        # show status
            if [ ! -f ~/robot.dev/docker-sync/"${subproject}"/daemon.pid ]; then
                echo "" && echo "auto-sync for this project is: STOPPED" && echo ""
            else
                echo "" && echo "auto-sync for this project is: RUNNING" && echo ""
            fi
        fi

        ;;

    # manually checks if a new file will sync
    test )
        # create a file
        touch "${project_base}${subproject}"/sync-test-file.txt
        # wait
        echo "" && echo "Checking sync now. One moment." && echo ""
        sleep 10
        # see if file exists
        if [ `docker exec "${subproject}"_web_1 bash -c "cd /${subproject} && ls | grep -c 'sync-test-file.txt'"` == "1" ]; then
            echo "The test sync was: SUCCESSFUL." && echo ""
            rm "${project_base}${subproject}"/sync-test-file.txt
            echo "I have removed the test file for you." && echo ""
        else
            rm "${project_base}${subproject}"/sync-test-file.txt
            echo "The test sync: FAILED." && echo ""
            echo "Running 'robot sync status' can look for issues and attempt to fix them now." && echo ""
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
