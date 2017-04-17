#!/bin/bash

###################################
#       ROBOT DEVELOPMENT         #
#      install robot script       #
#        by: Zak Schlemmer        #
###################################


# check for docker-compose
./src/dependancies.sh

# put the bin file in place
sudo cp -f src/robot.sh /usr/local/bin/robot
sudo chown `whoami` /usr/local/bin/robot

# makes sure the robot command works
if ! [ -x "$(command -v robot)" ]; then
        echo 'Sorry, something went wrong there.'
        echo 'Please try again.' && echo ""
        # die if not installed or not executable
        exit 1
else
	# notify that all is well
	echo "" && echo "The 'robot' command is ready for use." && echo ""
fi

# copy all the necessary stuff into place
echo "Copying over all the needed files." && echo ""
sudo mkdir -p /etc/robot
sudo cp -rf ./* /etc/robot
sudo cp -rf ./.gi* /etc/robot
sudo chown -R `whoami` /etc/robot

# check for osx
os=`uname -s`

# make loopback alias and launch daemon
if [ $os == "Darwin" ]; then
    # create this loop back as that will now be needed
    sudo ifconfig lo0 alias 10.254.254.254 > /dev/null 2>&1
    sudo cp -f /etc/robot/src/robot.plist /Library/LaunchDaemons/ > /dev/null 2>&1
fi


# create base robot-nginx and mailhog projects

# robot-nginx
# see if one exists
if [ -d "/etc/robot/projects/robot-system/robot-nginx" ]; then
    # probably no need to do anything aside from not overwrite
    echo "You already have an existing 'robot-nginx'." && echo ""
else
    mkdir -p /etc/robot/projects/robot-system
    # use an osx specific robot-nginx
    if [ $os == "Darwin" ]; then
        cp -r /etc/robot/template/robot-system/robot-nginx-osx /etc/robot/projects/robot-system/robot-nginx
    else
        cp -r /etc/robot/template/robot-system/robot-nginx /etc/robot/projects/robot-system/robot-nginx
    fi
    echo "robot-nginx project created." && echo ""
fi

# mailhog #
# see if one exists
if [ -d "/etc/robot/projects/robot-system/mailhog" ]; then
    # probably no need to do anything aside from not overwrite
    echo "You already have an existing 'mailhog'." && echo ""
else
    # just use exactly the template for now
    mkdir -p /etc/robot/projects/robot-system
    cp -r /etc/robot/template/robot-system/mailhog /etc/robot/projects/robot-system/
    echo "mailhog project created." && echo ""
fi

#check for entries in /etc/hosts
existing_entries=`grep -rhc "\.robot" /etc/hosts`

# if there are no entries make the start of them
if [ "$existing_entries" -lt "1" ]; then

	# make the entries
	if [ "$os" == "Darwin" ]; then
        # point osx to loop back alias
        sudo bash -c 'echo "" >> /etc/hosts'
        sudo bash -c 'echo "# current robot dev" >> /etc/hosts'
		sudo bash -c 'echo "10.254.254.254 mailhog.robot" >> /etc/hosts'
	else
		# point linux to nginx
		sudo bash -c 'echo "" >> /etc/hosts'
		sudo bash -c 'echo "# current robot dev" >> /etc/hosts'
		sudo bash -c 'echo "172.72.72.254 mailhog.robot" >> /etc/hosts'
	fi
fi

# done
echo "You're all set! Enjoy!" && echo ""
