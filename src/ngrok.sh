#!/bin/bash

###################################
#       ROBOT DEVELOPMENT         #
#    ngrok functionality script   #
#       by: Zak Schlemmer         #
###################################


# determine project (breaking it down this for purpose of vhost file names)
project=`. /etc/robot/src/determine.project.sh`

# prompt user for alias
echo -n "Please enter the ngrok server alias for this project: "
read server_alias

# create the server alias in the vhost based on project case
case $project in
    sfdev )
        docker exec -t ${project}_web_1 bash -c "sed -i '3i\serveralias '${server_alias}'\;' /etc/apache2/sites-available/storefrontdevelop.robot"
        docker exec -t nginx_1 bash -c 'sed -i -e "s/develop\.robot\;/develop\.robot '${server_alias}'\;/g" /etc/nginx/nginx.conf'
        ;;
    sfdev )
        docker exec -t ${project}_web_1 bash -c "sed -i '3i\serveralias '${server_alias}'\;' /etc/apache2/sites-available/storefrontedge.robot"
        docker exec -t nginx_1 bash -c 'sed -i -e "s/edge\.robot\;/edge\.robot '${server_alias}'\;/g" /etc/nginx/nginx.conf'
        ;;
    fc )
        docker exec -t ${project}_web_1 bash -c "sed -i '3i\serveralias '${server_alias}'\;' /etc/apache2/sites-available/flightcontrol.robot"
        docker exec -t nginx_1 bash -c 'sed -i -e "s/control\.robot\;/control\.robot '${server_alias}'\;/g" /etc/nginx/nginx.conf'
        ;;
    designer )
        docker exec -t ${project}_web_1 bash -c "sed -i '3i\serveralias '${server_alias}'\;' /etc/apache2/sites-available/designer.robot"
        docker exec -t nginx_1 bash -c 'sed -i -e "s/designer\.robot\;/designer\.robot '${server_alias}'\;/g" /etc/nginx/nginx.conf'
        ;;
    tupss_bo )
        docker exec -t ${project}_web_1 bash -c "sed -i '3i\serveralias '${server_alias}'\;' /etc/apache2/sites-available/tupssbo.robot"
        docker exec -t nginx_1 bash -c 'sed -i -e "s/bo\.robot\;/bo\.robot '${server_alias}'\;/g" /etc/nginx/nginx.conf'
        ;;
    tupss_center )
        docker exec -t ${project}_web_1 bash -c "sed -i '3i\serveralias '${server_alias}'\;' /etc/apache2/sites-available/tupsscenter.robot"
        docker exec -t nginx_1 bash -c 'sed -i -e "s/center\.robot\;/center\.robot '${server_alias}'\;/g" /etc/nginx/nginx.conf'
        ;;
esac

# reload apache we modified
docker exec -t ${project}_web_1 bash -c "/etc/init.d/apache2 reload"

# reload nginx to get any needed changes
docker exec -t nginx_1 bash -c "nginx -s reload"
