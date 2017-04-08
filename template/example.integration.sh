#!/bin/bash

###################################
#        ROBOT DEVELOPMENT        #
#     integrate example script    #
#         by: Zak Schlemmer       #
###################################


# I included a version of this file in my organizational private repository

# The repository clones the projects into:
# /etc/robot/projects/<organization>
# Within that <organization> folder each project has it's own folder with project name

# That is how the robot project is current designed to work
# Each project folder has a wrapper folder to separate your projects

#-----------------------------------------------------------------------------------

# I WOULD HIGHLY RECOMMEND:
# that you create your organizational projects to variate port and IP allocation from the robot starting point
# this will ensure the user will not have conflicts with already generated custom robot projects

# The starting point for these allocations in robot are:

#       apache2 port:           81
#       mysql port:             3301
#       ip /24:                 .2
#       docker-sync port:       10801

# I just added switched apache ports to the format: 8081
# I then added 100 to the other values


#-----------------------------------------------------------------------------------

# !!!! WARNING !!!!

# THERE ARE VALUES TO REPLACE IN ALL THESE EXAMPLE CHUNKS
# most are in the format < thing >, but there are other example ports and such to replace
# please read thoroughly, you will need to modify this for your specific projects

#-----------------------------------------------------------------------------------


# SET LOCAL /etc/hosts ENTRIES AND UPDATE robot-nginx/template.nginx.conf


# if all your projects are a simple 'single web head' layout you can use a loop for this part

# just list the project names you will be integrating
for project in myproject1 myproject2 myproject3 myproject4
do
    # update local /etc/hosts
    export projects=$projects
    if [ `uname -s` == "Darwin" ]; then
        sudo -E bash -c 'echo "10.254.254.254 ${printsites}.robot" >> /etc/hosts'
    else
        sudo -E bash -c 'echo "172.72.72.254 ${printsites}.robot" >> /etc/hosts'
    fi
    # find project web port for robot-nginx integration
    port=`cat /etc/robot/projects/<my_organization>/apache2/$project.apache2.ports.conf | grep Listen | grep -v 443 | sed s'/Listen //'`
    # update nginx
    sed -i -e "s/} # the end of all the things//" /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf
    cat /etc/robot/projects/robot-system/robot-nginx/nginx.server.template.conf >> /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf
    sed -i -e "s/template/${project}/g" /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf
    sed -i -e "s/8080/${port}/g" /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf
done


######
# for projects that contain multiple web heads, or that don't other work in the loop format:

# update local /etc/hosts
if [ `uname -s` == "Darwin" ]; then
    sudo -E bash -c 'echo "10.254.254.254 <web_1>.robot" >> /etc/hosts'
    sudo -E bash -c 'echo "10.254.254.254 <web_2.robot" >> /etc/hosts'
else
    sudo -E bash -c 'echo "172.72.72.254 <web_1>.robot" >> /etc/hosts'
    sudo -E bash -c 'echo "172.72.72.254 <web_2>.robot" >> /etc/hosts'
fi

# then update nginx
# <web_1>
sed -i -e "s/} # the end of all the things//" /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf
cat /etc/robot/projects/robot-system/robot-nginx/nginx.server.template.conf >> /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf
sed -i -e "s/template//g" /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf
sed -i -e "s/8080/8085/g" /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf
# <web_2>
sed -i -e "s/} # the end of all the things//" /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf
cat /etc/robot/projects/robot-system/robot-nginx/nginx.server.template.conf >> /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf
sed -i -e "s/template/tupsscenter/g" /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf
sed -i -e "s/8080/8086/g" /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf


#-----------------------------------------------------------------------------------


# This part adds the IP allocation to the 'robot-nginx' container and rebuilds it

# I found it easier to set these one by one
if [ `grep -c myproject1 /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml` == "0" ]; then
    echo "      - 'myproject1.robot:172.72.72.101'" >> /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml
fi
if [ `grep -c myproject2 /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml` == "0" ]; then
    echo "      - 'myproject2.robot:172.72.72.103'" >> /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml
fi
if [ `grep -c myproject3 /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml` == "0" ]; then
    echo "      - 'myproject3.robot:172.72.72.105'" >> /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml
fi
if [ `grep -c myproject4 /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml` == "0" ]; then
    echo "      - 'myproject4.robot:172.72.72.107'" >> /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml
fi
if [ `grep -c <web_1> /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml` == "0" ]; then
    echo "      - '<web_1>.robot:172.72.72.110'" >> /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml
fi
if [ `grep -c <web_2> /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml` == "0" ]; then
    echo "      - '<web_2>.robot:172.72.72.112'" >> /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml
fi


# I have trouble with OSX sed, and was ending up with "<modified_file_name>-e" copies of files
# feel free to let me know how I'm dumb at that so I can fix it and remove this part
find /etc/robot/projects/robot-system/robot-nginx/ -name "*-e" | xargs rm -rf


# this last part rebuilds robot-nginx to reflect the new addtions we just made

docker-compose -p robot -f /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml build
docker-compose -p robot -f /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml up -d


# let me know if you have any comments, questions, or concerns

#               !!! ENJOY !!!
