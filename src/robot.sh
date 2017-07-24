#!/bin/bash

###################################
#        ROBOT DEVELOPMENT        #
# "robot" /usr/local/bin command  #
#        by: Zak Schlemmer        #
###################################



# check - be somewhere that exists!
if [[ `uname -s` == "Linux" && `ls -la | grep -c "total 0"` == "1" ]] || [[ `uname -s` == "Darwin" && `ls -la` == "" ]]; then
    echo "" && echo "Hi! - It appears you are navigated to a directory that no longer exists!" && echo ""
    echo "Rumor has it, robot prefers to exists within existence." && echo ""
    echo "Please find your way back to existence." && echo ""
    echo "Running:" && echo "" && echo "cd ~" && echo ""
    echo "Would do the trick!" && echo ""
    exit
fi


# include help functions
. /etc/robot/src/help.functions.sh


# repetitive nginx check function
function nginx_check
{
    if [ "$(docker ps | grep -c nginx_1)" == 0 ]; then
        if [ "$(docker ps -a | grep -c nginx_1)" == 0 ]; then
            docker-compose -p robot -f /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml build
        fi
        docker-compose -p robot -f /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml up -d
    fi
}

# determine projects list function
function available_projects
{
    project_list=(`ls -p /etc/robot/projects/* | grep / | grep -v : | tr -d '/' | tr '\n' ' '`)
}

# determine project, output project name
function determine_project
{
    available_projects
    for i in "${project_list[@]}"
    do
        # find the project in question
        if [ `pwd | grep -c "/${i}"` == "1" ]; then
            # this is how it looks for multiple web head projects
            if [ `pwd | grep -coE "${i}[^/]+"` == "0" ]; then
                echo `pwd | grep -oE "${i}"`
            else
                echo `pwd | grep -oE "${i}[^/]+"`
            fi
        fi
    done
}

# check if a user is navigated to a robot project, return true or false in form: 1 or 0
function pwd_robot_project
{
    echo `pwd | grep -c "robot.dev/"`
}

# quick sync check and warning for osx
function osx_sync_check
{
    if [ `uname -s` == "Darwin" ] && [ ! -f ~/robot.dev/docker-sync/`determine_project`/daemon.pid ]; then
        echo "" && echo "!!!WARNING!!! - SYNC FOR THIS PROJECT IS STOPPED!!!" && echo ""
    fi
}



#-------------------------#
#   MAIN CASE STATEMENT   #
#-------------------------#

if [ "$1" != "" ]; then
    case $1 in


        # this will be used to create new projects from templates
        create )

            # run the create subscript as source
            . /etc/robot/src/create.sh "${@:2}"
            ;;


        # this will build all arguments provided to it
        build )
            # make projects list
            available_projects
            . /etc/robot/src/dependancies.sh
            nginx_check
            # MAILHOG
            if [ `echo ${*:2}| grep -c "mailhog"` == 1 ]; then
                docker-compose -p robot -f /etc/robot/projects/robot-system/mailhog/docker-compose.yml build
                docker-compose -p robot -f /etc/robot/projects/robot-system/mailhog/docker-compose.yml up -d
            fi
            # EVERYTHING ELSE
            for project in "${project_list[@]}"
            do
                # determine that projects containing folder
                project_folder=`ls -d /etc/robot/projects/*/* | grep $project | head -1 | sed 's/.*projects\///' | sed "s/\/.*//"`
                for arg in `echo ${*:2}`
                do
                # build if not mailhog
                    if [[ "${arg}" == "${project}" ]] && [[ ! $project == "mailhog" ]]; then
                        . /etc/robot/projects/$project_folder/$project/$project.install.sh $project
                    fi
                done
            done
            ;;

        # this will rebuild containers for arguments provided
        rebuild )
            nginx_check
            # make projects list
            available_projects
            # MAILHOG
            if [ `echo ${*:2}| grep -c "mailhog"` == 1 ]; then
                . /etc/robot/src/dependancies.sh
                nginx_check
                docker-compose -p robot -f /etc/robot/projects/robot-system/mailhog/docker-compose.yml build
                docker-compose -p robot -f /etc/robot/projects/robot-system/mailhog/docker-compose.yml up -d  | grep -vi warning
            fi
            # EVERYTHING ELSE
            for project in "${project_list[@]}"
            do
                # determine that projects containing folder
                project_folder=`ls -d /etc/robot/projects/*/* | grep $project | head -1 | sed 's/.*projects\///' | sed "s/\/.*//"`

                # rebuild if not mailhog
                if [ ! $project == "mailhog" ] && [ ! $project == "robot-nginx" ]; then
                    for arg in `echo ${*:2}`
                    do
                        if [[ "${arg}" == "${project}" ]] || [[ "$2" == "all" && `docker ps -a | grep -c "${project}"` -gt 0 ]]; then
                            if [ `uname -s` == "Darwin" ]; then
                                docker-compose -p robot -f /etc/robot/projects/"${project_folder}"/"${project}"/osx-docker-compose.yml build
                                docker-compose -p robot -f /etc/robot/projects/"${project_folder}"/"${project}"/osx-docker-compose.yml up -d
                            else
                                docker-compose -p robot -f /etc/robot/projects/"${project_folder}"/"${project}"/docker-compose.yml build
                                docker-compose -p robot -f /etc/robot/projects/"${project_folder}"/"${project}"/docker-compose.yml up -d
                            fi
                        fi
                    done
                fi
            done
            ;;


        stop )
            # make projects list
            available_projects
            # MAILHOG
            if [ `echo ${*:2}| grep -c "mailhog"` == 1 ] || [ "$2" == "all" ]; then
                    docker-compose -p robot -f /etc/robot/projects/robot-system/mailhog/docker-compose.yml stop
            fi
            # EVERYTHING ELSE
            for project in "${project_list[@]}"
            do
                # determine that projects containing folder
                project_folder=`ls -d /etc/robot/projects/*/* | grep $project | head -1 | sed 's/.*projects\///' | sed "s/\/.*//"`

                # stop if not mailhog or robot-nginx
                if [ ! $project == "robot-nginx" ] && [ ! $project == "mailhog" ]; then
                    for arg in `echo ${*:2}`
                    do
                        if [[ "${arg}" == "${project}" ]] || [[ "$2" == "all" && `docker ps -a | grep -c "${project}"` -gt 0 ]]; then
                            if [ `uname -s` == "Darwin" ]; then
                                docker-compose -p robot -f /etc/robot/projects/"${project_folder}"/"${project}"/osx-docker-compose.yml stop
                            else
                                docker-compose -p robot -f /etc/robot/projects/"${project_folder}"/"${project}"/docker-compose.yml stop
                            fi
                        fi
                    done
                fi
            done
            # NGINX and DOCKER-SYNC
            if [ "$2" == "all" ]; then
                docker-compose -p robot -f /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml stop
            fi
            ;;

        start )
            # make projects list
            available_projects
            # MAILHOG
            if [[ `echo ${*:2}| grep -c "mailhog"` == 1 ]] || [[ "$2" == "all"  && `docker ps -a | grep -c mailhog` -gt 0 ]]; then
                nginx_check
                docker-compose -p robot -f /etc/robot/projects/robot-system/mailhog/docker-compose.yml start
            fi
            # EVERYTHING ELSE
            for project in "${project_list[@]}"
            do
                # determine that projects containing folder
                project_folder=`ls -d /etc/robot/projects/*/* | grep $project | head -1 | sed 's/.*projects\///' | sed "s/\/.*//"`
                nginx_check
                # start if not mailhog or robot-nginx
                if [ ! $project == "robot-nginx" ] && [ ! $project == "mailhog" ]; then
                    for arg in `echo ${*:2}`
                    do
                        if [[ "${arg}" == "${project}" ]] || [[ "$2" == "all" && `docker ps -a | grep -c "${project}"` -gt 0 ]]; then
                            if [ `uname -s` == "Darwin" ]; then
                                docker-compose -p robot -f /etc/robot/projects/"${project_folder}"/"${project}"/osx-docker-compose.yml start
                            else
                                docker-compose -p robot -f /etc/robot/projects/"${project_folder}"/"${project}"/docker-compose.yml start
                            fi
                        fi
                    done
                fi
            done
            exit
            ;;

        top )
            # same as docker stats but container name replaces hash
            docker stats $(docker ps | awk '{if(NR>1) print $NF}')
            exit
            ;;

        list )
            # only show robot projects
            echo ""
            #docker ps -f name=thing* -f name=example* -f name=site*
            docker ps
            echo ""
            exit
            ;;

        rm )
            # make projects list
            available_projects
            # MAILHOG
            if [ `echo ${*:2}| grep -c "mailhog"` == 1 ] || [ "$2" == "all" ]; then
                docker-compose -p robot -f /etc/robot/projects/robot-system/mailhog/docker-compose.yml rm -f
            fi
            # EVERYTHING ELSE
            for project in "${project_list[@]}"
            do
                # determine that projects containing folder
                project_folder=`ls -d /etc/robot/projects/*/* | grep $project | head -1 | sed 's/.*projects\///' | sed "s/\/.*//"`

                # rm if not mailhog or robot-nginx
                if [ ! $project == "robot-nginx" ] && [ ! $project == "mailhog" ]; then
                    for arg in `echo ${*:2}`
                    do
                        if [[ "${arg}" == "${project}" ]] || [[ "$2" == "all" && `docker ps -a | grep -c "${project}"` -gt 0 ]]; then
                            if [ `uname -s` == "Darwin" ]; then
                                docker-compose -p robot -f /etc/robot/projects/"${project_folder}"/"${project}"/osx-docker-compose.yml rm -f
                            else
                                docker-compose -p robot -f /etc/robot/projects/"${project_folder}"/"${project}"/docker-compose.yml rm -f
                            fi
                        fi
                    done
                fi
            done
            # NGINX
            if [ "$2" == "all" ]; then
                docker-compose -p robot -f /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml rm -f
            fi
            ;;

        drush )
            osx_sync_check
            # check pwd
            #if [ `pwd_robot_project` == "0" ]; then
            #    echo "" && echo "You need to be navigated to a project within ~/robot.dev/ to run a 'robot drush' command."
            #    echo "" && exit
            #fi
            # build string
            command="drush"
            # check all arguments after drush
            for i in "${@:2}"
            do
                # if there are spaces, the argument was quoted at cli
                if [ `echo $i | grep \ | wc -l` == "1" ]; then
                    # see if that argument contains double quotes (ie. singles were used)
                    if [ `echo $i | grep -c '"'` == "0" ]; then
                        # add double quotes if no double quotes contained in argument
                        command+=" \"$i\""
                    else
                        # add single quotes if there were double quotes
                        command+=" '$i'"
                    fi
                else
                    # if no spaces just add to the string
                    command+=" $i"
                fi
            done
            docker exec -u robot -i `determine_project`_web_1 bash -c "cd `determine_project` && ${command}"
            exit
            ;;

        wp )
            osx_sync_check
            # check pwd
            #if [ `pwd_robot_project` == "0" ]; then
            #    echo "" && echo "You need to be navigated to a project within ~/robot.dev/ to run a 'robot wp' command."
            #    echo "" && exit
            #fi
            # build string
            command="wp"
            # check all arguments after wp
            for i in "${@:2}"
            do
                # if there are spaces, the argument was quoted at cli
                if [ `echo $i | grep \ | wc -l` == "1" ]; then
                    # see if that argument contains double quotes (ie. singles were used)
                    if [ `echo $i | grep -c '"'` == "0" ]; then
                        # add double quotes if no double quotes contained in argument
                        command+=" \"$i\""
                    else
                        # add single quotes if there were double quotes
                        command+=" '$i'"
                    fi
                else
                    # if no spaces just add to the string
                    command+=" $i"
                fi
            done
            docker exec -u robot -i `determine_project`_web_1 bash -c "cd `determine_project` && ${command}"
            exit
            ;;

        ssh )
            if [ "$2" == "" ]; then
                osx_sync_check
                # check pwd
                #if [ `pwd_robot_project` == "0" ]; then
                #    echo "" && echo "You need to be navigated to a project within ~/robot.dev/ to use 'robot ssh' WITHOUT specifying a container name."
                #    echo "" && exit
                #fi
                # if web head for project files use robot user
                docker exec -u robot -it `determine_project`_web_1 bash
            else
                # otherwise root if container specified
                docker exec -it "$2" bash
            fi
            exit
            ;;

        update )
            # checks for updates, then prompts to make them if available
            . /etc/robot/src/self.update.sh
            exit
            ;;

        status )
            if [ "$2" == "" ]; then
                osx_sync_check
                # check pwd
                #if [ `pwd_robot_project` == "0" ]; then
                #    echo "" && echo "You need to be navigated to a project within ~/robot.dev/ to use 'robot status'."
                #    echo "" && exit
                #fi
                # print various status info
                echo ""
                echo "I see `docker ps | grep -c \`determine_project\`` containers running for this project." && echo ""
                echo "`docker ps | grep \`determine_project\`_ | grep -ic restart` of them are restarting." && echo ""
                echo "Run 'robot list' to see more information" && echo ""
            fi
            exit
            ;;

        projects )
            # table header
            echo "" && echo "You have the following projects at your disposal in robot:" && echo ""
            project_data=`echo -e " NAME\tBUILT\tRUNNING~--------\t--------\t--------~"`
            # for each project
            for project in `ls -p /etc/robot/projects/* | grep / | grep -v : | tr -d '/' && echo ""`
            do
                # handle robot-nginx slightly different
                if [ $project == "robot-nginx" ]; then
                     # find if built
                    if [ ! `docker ps -a | grep -c robot-nginx` == "0" ]; then
                        built="YES"
                        # if built find if running
                        if [ ! `docker ps | grep -c robot-nginx` == "0" ]; then
                            running="YES"
                        else
                            running="NO"
                        fi
                    else
                        built="NO"
                        running="n/a"
                    fi
                # everything else
                else
                    # find if built
                    if [ ! `docker ps -a | grep -c ${project}_` == "0" ]; then
                        built="YES"
                        # if built find if running
                        if [ ! `docker ps | grep -c ${project}_` == "0" ]; then
                            running="YES"
                        else
                            running="NO"
                        fi
                    else
                        built="NO"
                        running="n/a"
                    fi
                fi
                # combine project data
                project_data+=`echo -e " ${project}\t${built}\t${running}~"`
            done
            # print stuff
            echo $project_data | tr '~' '\n' | column -t
            echo ""
            ;;

        db )
            osx_sync_check
            # check pwd
            #if [ `pwd_robot_project` == "0" ]; then
            #    echo "" && echo "You need to be navigated to a project within ~/robot.dev/ to use 'robot db' commands."
            #    echo "" && exit
            #fi
            # make a 'file name friendly' date/time stamp
            datestamp=`date +"%Y-%m-%d--%H-%M-%S"`
            temp_project=`determine_project`
            # switch out for import / export
            case $2 in
                import )
                    if [ "$3" == "" ]; then
                        echo "Please provide a database dump file to import."
                        echo "robot db import <good-dump-file>.sql"
                        exit
                    fi
                    docker cp ./"${3}" "${temp_project}"_db_1:/
                    docker exec -t "${temp_project}"_db_1 bash -c "mysql ${temp_project} < ${3}"
                    exit
                    ;;
                export )
                    docker exec -t	"${temp_project}"_db_1 bash -c "mysqldump ${temp_project} > ${temp_project}.'${datestamp}'.sql"
                    docker cp "${temp_project}"_db_1:/"${temp_project}"."${datestamp}".sql ./
                    exit
                    ;;
                drop )
                    docker exec -t "${temp_project}"_db_1 bash -c "mysql -e 'drop database ${temp_project}'"
                    docker exec -t "${temp_project}"_db_1 bash -c "mysql -e 'create database ${temp_project}'"
                    exit
                    ;;
                # prints 'robot db' help text
                -h | --help | help | "" )
                    db_help
                    exit
                    ;;
                # typo catch + help text
                * )
                    echo ""
                    echo 'unrecognized command: robot' ${*}
                    db_help
                    exit
                    ;;
                esac
            exit
            ;;

        clean )
            # clean sub-script
            /etc/robot/src/clean.sh ${*}
            exit
            ;;


        sync )
            # check pwd
            #if [ `pwd_robot_project` == "0" ]; then
            #    echo "" && echo "You need to be navigated to a project within ~/robot.dev/ to use 'robot sync' commands."
            #    echo "" && exit
            #fi
            # clean sub-script
            /etc/robot/src/sync.sh ${*}
            exit
            ;;


        ngrok )
            osx_sync_check
            # check pwd
            #if [ `pwd_robot_project` == "0" ]; then
            #    echo "" && echo "You need to be navigated to a project within ~/robot.dev/ to use 'robot ngrok'."
            #    echo "" && exit
            #fi
            # makes the changes needed to use ngrok
            /etc/robot/src/ngrok.sh
            exit
            ;;

        backup )
            case $2 in
                create )
                    if [ "$3" == "--all" ]; then
                        datestamp=`date +"%Y-%m-%d--%H-%M-%S"`
                        for i in `ls ~/robot.dev/`
                            do
                                docker exec -t	"${i}"_db_1 bash -c "mysqldump ${i} > ${i}.'${datestamp}'.sql"
                                docker cp "${i}"_db_1:/"${i}"."${datestamp}".sql ~/robot.dev/${i}/
                                mkdir -p ~/robot.bak/ && cp -r ~/robot.dev/${i} ~/robot.bak/${i}.${datestamp}
                        done
                    else
                        datestamp=`date +"%Y-%m-%d--%H-%M-%S"`
                        temp_project=`determine_project`
                        docker exec -t	"${temp_project}"_db_1 bash -c "mysqldump ${temp_project} > ${temp_project}.'${datestamp}'.sql"
                        docker cp "${temp_project}"_db_1:/"${temp_project}"."${datestamp}".sql ./
                        mkdir -p ~/robot.bak/ && cp -r ~/robot.dev/${temp_project} ~/robot.bak/${temp_project}.${datestamp}
                    fi
                    ;;
                restore )
                    # useless atm
                    ;;
                # help things
                -h | --help | help | "" )
                    backup_help
                    exit
                    ;;
                # typo catch + help text
                * )
                    echo ""
                    echo 'unrecognized command: robot' ${*}
                    backup_help
                    exit
                    ;;
                esac
            ;;

        -h | --help | help )
            # same as no command, but good to do anyway
            usage
            exit
            ;;

        * )
            # this is nice for typos
            echo ""
            echo 'unrecognized command: robot' ${*}
            usage
            exit
            ;;

    esac
fi

# no arguments to robot show usage (help)
if [ "$1" == "" ]; then
    usage
    exit 1
fi
