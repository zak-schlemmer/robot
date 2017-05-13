#!/bin/bash

###################################
#       ROBOT DEVELOPMENT         #
#    ngrok functionality script   #
#       by: Zak Schlemmer         #
###################################


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

# prompt user for alias
echo ""
echo -n "Please enter the ngrok server alias for this project: "
read server_alias
echo ""

# create the server alias in the vhost based on project case
docker exec -t ${project}_web_1 bash -c "sed -i '3i\serveralias ${server_alias}' /etc/apache2/sites-available/${project}.robot"
docker exec -t robot_nginx_1 bash -c 'sed -i -e "s/'${project}'\.robot\;/'${project}'\.robot '${server_alias}'\;/g" /etc/nginx/nginx.conf'

# reload apache we modified
docker exec -t ${project}_web_1 bash -c "/etc/init.d/apache2 reload" && echo ""

# reload nginx to get any needed changes
docker exec -t robot_nginx_1 bash -c "nginx -s reload" && echo ""

echo "${server_alias} ready for ngrok." && echo ""
