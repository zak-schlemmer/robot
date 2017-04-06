#!/bin/bash

###################################
#        ROBOT DEVELOPMENT        #
#  create project from template   #
#        by: Zak Schlemmer        #
###################################


# some sort of option of the template to use
echo ""
echo "Please pick a base template to use:" && echo ""
echo "       ( 1 ) drupal 7.54      <-  a vanilla d7 install in 2 containers apache2/mysql"
echo "       ( 2 ) drupal 8.2.7     <-  a vanilla d8 install in 2 containers apache2/mysql"
echo ""
echo -n "Numbered Choice: "
read template_select_option && echo ""


# create project from template
case $template_select_option in



    ###############
    # drupal 7.54 #
    ###############
    1 )
        # take in a project name for this one
        echo "What would you like to use as a project name?"
        echo -n "(You will want to keep it short and simple): "
        read project_name && echo ""
        # make all the things for the new project, using the name provided
        project_path=/etc/robot/projects/custom/$project_name
        mkdir -p $project_path
        cp -rf /etc/robot/template/drupal7/* $project_path/
        cp -rf /etc/robot/template/apache2 $project_path/
        cp -rf /etc/robot/template/mysql $project_path/
        cp -rf /etc/robot/template/docker-sync $project_path/
        # replace the word template in stuff
        sed -i -e "s/template/${project_name}/g" \
            $project_path/docker-compose.yml \
            $project_path/apache2/Dockerfile \
            $project_path/mysql/Dockerfile \
            $project_path/apache2/template.apache2.vhost.conf \
            $project_path/docker-sync/docker-compose.yml \
            $project_path/osx-docker-compose.yml
        # project specific file names
        mv $project_path/apache2/template.apache2.ports.conf $project_path/apache2/$project_name.apache2.ports.conf
        mv $project_path/apache2/template.apache2.vhost.conf $project_path/apache2/$project_name.apache2.vhost.conf
        mv $project_path/drupal7.install.sh $project_path/$project_name.install.sh
        # find next available apache2 port
        for ((i=81;i<=181;i++)); do
            if [ `cat /etc/robot/projects/*/*/apache2/*.apache2.ports.conf | grep Listen | tr -d 'Listen ' | grep -c $i` == "0" ]; then
                apache_port=$i
                break
            fi
        done
        # find next available mysql port
        for ((i=3301;i<=3401;i++)); do
            if [ `cat /etc/robot/projects/*/*/mysql/default.my.cnf | grep port | tr -d 'port = ' | grep -c $i` == "0" ]; then
                mysql_port=$i
                break
            fi
        done
        # find next available docker-sync port
        for ((i=10801;i<=10901;i++)); do
            if [ `cat /etc/robot/projects/*/*/docker-sync/docker-compose.yml | grep "sync_host_port" | tr -d 'sync_host_port: ' | grep -c $i` == "0" ]; then
                docker_sync_port=$i
                break
            fi
        done
        # find next available IP
        for ((i=2;i<=254;i++)); do
            if [ `grep -rh "ipv4_address: 172.72.72" /etc/robot/projects/*/*/docker-compose.yml | sed  's/        ipv4_address: //' | grep -c "172.72.72.${i}"` == "0" ]; then
                next_ip=$i
                break
            fi
        done
        # set apache port
        sed -i -e "s/8080/${apache_port}/g" $project_path/apache2/$project_name.apache2.ports.conf \
            $project_path/apache2/$project_name.apache2.vhost.conf
        # set mysql port
        sed -i -e "s/9999/${mysql_port}/g" $project_path/mysql/default.my.cnf \
            $project_path/$project_name.install.sh \
            $project_path/docker-compose.yml \
            $project_path/osx-docker-compose.yml
        # set docker-sync port
        sed -i -e "s/10800/${docker_sync_port}/g" $project_path/docker-sync/docker-compose.yml
        # set ip
        sed -i -e "s/333/${next_ip}/g" $project_path/docker-compose.yml $project_path/osx-docker-compose.yml
        apache2_next_ip=$((next_ip+1))
        sed -i -e "s/444/${apache2_next_ip}/g" $project_path/docker-compose.yml $project_path/osx-docker-compose.yml
        # update local /etc/hosts
        export project_name=$project_name
        echo "I will update your local /etc/hosts file for you." && echo ""
        if [ `uname -s` == "Darwin" ]; then
            sudo -E bash -c 'echo "10.254.254.254 ${project_name}.robot" >> /etc/hosts'
        else
            sudo -E bash -c 'echo "172.72.72.254 ${project_name}.robot" >> /etc/hosts'
        fi
        # update nginx
        sed -i -e "s/} # the end of all the things//" /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf
        cat /etc/robot/projects/robot-system/robot-nginx/nginx.server.template.conf >> /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf
        sed -i -e "s/template/${project_name}/g" /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf
        sed -i -e "s/8080/${apache_port}/g" /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf
        echo "      - '${project_name}.robot:172.72.72.${apache2_next_ip}'" >> /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml
        docker-compose -p robot -f /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml build
        docker-compose -p robot -f /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml up -d

        # cleanup for poor work on OSX sed's
        find $project_path/ -name "*-e" | xargs rm -rf
    ;;

    ################
    # drupal 8.2.7 #
    ################
    2 )

       # TO DO : put all of d8 here

    ;;


esac

