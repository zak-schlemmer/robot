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
docker exec -t ${project}_web_1 bash -c "sed -i '3i\serveralias '${server_alias}'\;' /etc/apache2/sites-available/${project}.robot"
docker exec -t nginx_1 bash -c 'sed -i -e "s/${project}\.robot\;/${project}\.robot '${server_alias}'\;/g" /etc/nginx/nginx.conf'

# reload apache we modified
docker exec -t ${project}_web_1 bash -c "/etc/init.d/apache2 reload"

# reload nginx to get any needed changes
docker exec -t robot_nginx_1 bash -c "nginx -s reload"
