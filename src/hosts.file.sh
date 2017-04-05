#!/bin/bash

###################################
#       ROBOT DEVELOPMENT         #
#    /etc/hosts file script       #
#       by: Zak Schlemmer         #
###################################


# check for osx
os=`uname -s`

#check for entries in /etc/hosts
existing_entries=`grep -rhc "\.robot" /etc/hosts`

# redo if less than 8 ( 7 + 1 for the comment title )
if [ "$existing_entries" -lt "1" ]; then

    # remove old entries
	sudo sed -i -e '/robot/d' /etc/hosts

	# make the entries
	if [ "$os" == "Darwin" ]; then
        # point osx to docker-machine
        sudo bash -c 'echo "" >> /etc/hosts'
        sudo bash -c 'echo "# current robot dev" >> /etc/hosts'
		sudo bash -c 'echo "10.254.254.254 mailhog.robot" >> /etc/hosts'

	else
		# point linux to nginx
		sudo bash -c 'echo "" >> /etc/hosts'
		sudo bash -c 'echo "# current robot dev" >> /etc/hosts'
		sudo bash -c 'echo "172.72.72.222 mailhog.robot" >> /etc/hosts'

	fi
fi
