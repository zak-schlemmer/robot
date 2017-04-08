#!/bin/bash

###################################
#        ROBOT DEVELOPMENT        #
# "robot" /usr/local/bin command  #
#        by: Zak Schlemmer        #
###################################



# include help functions
. /etc/robot/src/help.functions.sh


# repetitive nginx check
function nginx_check
{
    if [ "$(docker ps | grep -c nginx_1)" == 0 ]; then
        if [ "$(docker ps -a | grep -c nginx_1)" == 0 ]; then
            docker-compose -p robot -f /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml build
        fi
        docker-compose -p robot -f /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml up -d
    fi
}

# determine projects list
function available_projects
{
    project_list=(`ls -p /etc/robot/projects/* | grep / | grep -v : | tr -d '/' | tr '\n' ' '`)
}



#-------------------------#
#   MAIN CASE STATEMENT   #
#-------------------------#

if [ "$1" != "" ]; then
    case $1 in


        # this will be used to create new projects from templates
        create )

            # run the create subscript as source
            . /etc/robot/src/create.sh "$2"
            ;;


        # this will build all arguments provided to it
        build )

            # make projects list
            available_projects

            # in case nginx is down
            if [ "$2 " == "all" ]; then
                # get rid of old unused stuff here
                docker volume rm $(docker volume ls -qf dangling=true) > /dev/null 2>&1
                # start with this, if doing everything
                nginx_check
            fi
            # MAILHOG / TO DO : figure out a better plan for this
            if [ `echo ${*:2}| grep -c "mailhog"` == 1 ] || [ "$2" == "all" ]; then
                . /etc/robot/src/dependancies.sh
                nginx_check
                docker-compose -p robot -f /etc/robot/projects/robot-system/mailhog/docker-compose.yml build
                docker-compose -p robot -f /etc/robot/projects/robot-system/mailhog/docker-compose.yml up -d  | grep -vi warning
            fi

            # GOOD DYNAMIC PROJECT ACTION
            for project in "${project_list[@]}"
            do
                # determine that projects containing folder
                project_folder=`ls -d /etc/robot/projects/*/* | grep $project | sed 's/.*projects\///' | sed "s/\/${project}//"`

                # build if not mailhog
                if [ `echo ${*:2}| grep -c "${project}"` == "1" ] || [ "$2" == "all" ] && [ ! $project == "mailhog" ]; then
                    . /etc/robot/src/dependancies.sh
                    nginx_check
                    . /etc/robot/projects/$project_folder/$project/$project.install.sh $project
                fi
            done
            ;;

        hosts )
            # entire command is in case something goes weird
            . /etc/robot/src/hosts.file.sh
            exit
            ;;

        stop )
            # MAILHOG
            if [ `echo ${*:2}| grep -c "mailhog"` == 1 ] || [ "$2" == "all" ]; then
                    docker-compose -p robot -f /etc/robot/templates/mailhog/docker-compose.yml stop
            fi
            # VANILLA DRUPAL
            if [ `echo ${*:2}| grep -c "vanilla"` == 1 ] || [ "$2" == "all" ]; then
                    docker-compose -p robot -f /etc/robot/docker-compose/vanilla.yml stop
            fi
            # NGINX and DOCKER-SYNC
            if [ "$2" == "all" ]; then
                docker-compose -p robot -f /etc/robot/templates/robot-nginx/docker-compose.yml stop
            fi
            ;;

    start )
        # MAILHOG
        if [[ `echo ${*:2}| grep -c "mailhog"` == 1 ]] || [[ "$2" == "all"  && `docker ps -a | grep -c mailhog` -gt 0 ]]; then
            nginx_check
            docker-compose -p robot -f /etc/robot/docker-compose/mailhog.yml start
        fi
        # VANILLA DRUPAL
        if [[ `echo ${*:2}| grep -c "vanilla"` == 1 ]] || [[ "$2" == "all"  && `docker ps -a | grep -c vanilla` -gt 0 ]]; then
            nginx_check
            docker-compose -p robot -f /etc/robot/docker-compose/vanilla.yml start
        fi
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
        # MAILHOG
        if [ `echo ${*:2}| grep -c "mailhog"` == 1 ] || [ "$2" == "all" ]; then
            docker-compose -p robot -f /etc/robot/docker-compose/mailhog.yml rm -fa
        fi
        # VANILLA DRUPAL
        if [ `echo ${*:2}| grep -c "vanilla"` == 1 ] || [ "$2" == "all" ]; then
            docker-compose -p robot -f /etc/robot/docker-compose/vanilla.yml rm -fa
        fi
        # NGINX
        if [ "$2" == "all" ]; then
            docker-compose -p robot -f /etc/robot/docker-compose/nginx.yml rm -fa
        fi
        ;;

	drush )
	    # look where local user is
		where=`. /etc/robot/src/determine.navigation.sh`
		# catch sql-query/sqlq to get quotes through
		if [ "$2" == "sql-query" ] || [ "$2" == "sqlq" ]; then
		    docker exec -u robot -i `. /etc/robot/src/determine.project.sh`_web_1 bash -c "cd ${where} && drush sqlq \"${@:3}\""
		else
		    # otherwise just do the old way for now
		    docker exec -u robot -i `. /etc/robot/src/determine.project.sh`_web_1 bash -c "cd ${where} && drush ${*:2}"
		fi
		exit
		;;

	ssh )
		if [ "$2" == "" ]; then
		    # if web head for project files use robot user
			docker exec -u robot -it `. /etc/robot/src/determine.project.sh`_web_1 bash
		else
		    # otherwise root
			docker exec -it "$2" bash
		fi
		exit
		;;

	update )
	    # checks for updates, then prompts to make them if available
	    # makes changes, checks hosts, removes dangling volumes
		. /etc/robot/src/self.update.sh
		exit
		;;


	db )
 	    # based on current local file location
	    project=`. /etc/robot/src/determine.project.sh`

        # make a 'file name friendly' date/time stamp
	    datestamp=`date +"%Y-%m-%d--%H-%M-%S"`
	    # switch out for import / export
	    case $2 in
            import )
                if [ "$3" == "" ]; then
                    echo "Please provide a database dump file to import."
                    echo "robot db import <good-dump-file>.sql"
                    exit
                fi
	            docker cp "${3}" "${project}"_db_1:/
	            docker exec -t "${project}"_db_1 bash -c "mysql '${project}' < ${3}"
	            exit
	            ;;
	        export )
                docker exec -t	"${project}"_db_1 bash -c "mysqldump '${project}' > '${project}'.'${datestamp}'.sql"
                docker cp "${project}"_db_1:/"${project}"."${datestamp}".sql ./
                exit
                ;;
            drop )
                docker exec -t "${project}"_db_1 bash -c "mysql -e 'drop database ${project}'"
                docker exec -t "${project}"_db_1 bash -c "mysql -e 'create database ${project}'"
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
        # clean sub-script
        /etc/robot/src/sync.sh ${*}
        exit
        ;;


	ngrok )
	    # makes the changes needed to use ngrok
		/etc/robot/src/ngrok.sh
		exit
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
