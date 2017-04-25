#!/bin/bash

##################################
#       ROBOT DEVELOPMENT        #
#    robot self update script    #
#       by: Zak Schlemmer        #
##################################


# check for updates
echo "" && echo "Checking for updates." && echo "One moment." && echo ""
cd /etc/robot && git fetch > /dev/null 2>&1

# let the user see what branch they are on
git status | head -n1

# see if there are updates
if [ `git status | grep -c up-to-date` == 1 ];then
	echo "Your robot is all up-to-date!" && echo ""
	exit 1
else
	echo "There are updates available for your robot."
	# wait for input
	while [ "$update_option" != 'y' ] && [ "$update_option" != 'n' ]; do
        	echo -n "Would you like me to give your robot a tune-up? [y/n] "
        	read -n 1 update_option && echo ""
        	if [ "$update_option" != 'y' ] && [ "$update_option" != 'n' ]; then
                	echo -e "Please enter: 'y' or 'n'" && echo ""
        	else
                	echo ""
        	fi
	done
	if [ "$update_option" == 'y' ]; then
	    # fetch is done, do the pull
		git pull > /dev/null 2>&1
		# replace the bin command
		cp -f /etc/robot/src/robot.sh /usr/local/bin/robot

		# get the halfway fix for docker-sync update in
		if [ `uname -s` == "Darwin" ]; then
		    # make it so docker-sync can update
            sudo chmod -R 2777 /Library/Ruby/Gems
		fi

		# instill happy thoughts
		echo "Your robot has been updated! Enjoy!" && echo ""
	fi
fi

