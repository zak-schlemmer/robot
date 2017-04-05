#!/bin/bash

###################################
#        ROBOT DEVELOPMENT        #
#     functions for help text     #
#        by: Zak Schlemmer        #
###################################


# look for projects
# TO DO : make this ALL arguments
if [ ! -d "/etc/robot/projects/$1" ]; then
    echo "" && echo "I don't see that project available in your projects directory." && echo ""
    while [ "$use_template" != 'y' ] && [ "$use_template" != 'n' ]; do
        echo -n "Would you like to use a template? [y/n] "
        read use_template && echo ""
        if [ "$use_template" != 'y' ] && [ "$use_template" != 'n' ]; then
                echo -e "Please enter: 'y' or 'n'" && echo ""
        else
                echo ""
        fi
	done

	# some sort of option of the template to use
	echo "Please pick a base template to use:"
	echo "       ( 1 ) drupal 7.54"
    echo "       ( 2 ) drupal 8.2.7"
    echo ""
    echo -n "Numbered Choice: "
    read template_select_option && echo ""

    # get project name from user
    echo "What would you like to use as a project name?"
    echo -n "(You will want to keep it short and simple): "
    read project_name && echo ""


    # create project from template
    case $template_select_option in

        1 )
            # make all the things for the new project, using the name provided
            mkdir /etc/robot/projects/$project_name
   	        cp -r /etc/robot/template/drupal7/* /etc/robot/projects/$project_name/
	        cp -r /etc/robot/template/apache2 /etc/robot/projects/$project_name/
	        cp -r /etc/robot/template/mysql /etc/robot/projects/$project_name/

	        # replace the word template in stuff
	        sed -i -e "s/template/${project_name}/g" /etc/robot/projects/$project_name/docker-compose.yml \
	            /etc/robot/projects/$project_name/apache2/Dockerfile \
	            /etc/robot/projects/$project_name/mysql/Dockerfile \
	            /etc/robot/projects/$project_name/apache2/template.apache2.vhost.conf

	        # project specific file names
	        mv /etc/robot/projects/$project_name/apache2/template.apache2.ports.conf /etc/robot/projects/$project_name/apache2/$project_name.apache2.ports.conf
	        mv /etc/robot/projects/$project_name/apache2/template.apache2.vhost.conf /etc/robot/projects/$project_name/apache2/$project_name.apache2.vhost.conf
            mv /etc/robot/projects/$project_name/drupal7.install.sh /etc/robot/projects/$project_name/$project_name.install.sh


            # find next available apache2 port
            for ((i=81;i<=181;i++)); do
                if [ `cat /etc/robot/projects/*/apache2/*.apache2.ports.conf | grep Listen | tr -d 'Listen ' | grep -c $i` == "0" ]; then
                    apache_port=$i
                    break
                fi
            done

            # find next available mysql port
            for ((i=3301;i<=3401;i++)); do
                if [ `cat /etc/robot/projects/*/mysql/default.my.cnf | grep port | tr -d 'port = ' | grep -c $i` == "0" ]; then
                    mysql_port=$i
                    break
                fi
            done

            # find next available IP
            for ((i=2;i<=254;i++)); do
                if [ `docker inspect $(docker ps -a -q) | grep IPv4Address | sed 's@"IPv4Address": "@@g' | tr -d '"' | grep -c "172.72.72.${i}"` == "0" ]; then
                    next_ip=$i
                    break
                fi
            done


            # apache port
            sed -i -e "s/8080/${apache_port}/g" /etc/robot/projects/$project_name/apache2/$project_name.apache2.ports.conf \
                /etc/robot/projects/$project_name/apache2/$project_name.apache2.vhost.conf

            # mysql port
            sed -i -e "s/9999/${mysql_port}/g" /etc/robot/projects/$project_name/mysql/default.my.cnf \
                /etc/robot/projects/$project_name/$project_name.install.sh \
                /etc/robot/projects/$project_name/docker-compose.yml

            # ip
            sed -i -e "s/333/${next_ip}/g" /etc/robot/projects/$project_name/docker-compose.yml
            apache2_next_ip=$((next_ip+1))
            sed -i -e "s/444/${apache2_next_ip}/g" /etc/robot/projects/$project_name/docker-compose.yml



	     ;;




	     2 )
	        # TO DO : all of d8 here

	     ;;



	esac




	#case $1 in

	    # TO DO : move mailhog to just a robot thing like nginx
	    #mailhog )
	    #    cp -r /etc/robot/template/mailhog /etc/robot/projects/
	    #;;



	#esac
fi



