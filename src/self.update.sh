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

		# check for osx
        os=`uname -s`

        # get docker-sync
        if [ $os == "Darwin" ]; then

            # composer
            if ! [ -x "$(command -v composer)" ]; then
                php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
                php -r "if (hash_file('SHA384', 'composer-setup.php') === '55d6ead61b29c7bdee5cccfb50076874187bd9f21f65d8991d46ec5cc90518f447387fb9f76ebae1fbbacf329e583e30') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
                php composer-setup.php
                cp composer.phar /usr/bin/composer
                php -r "unlink('composer-setup.php');"
                rm composer.phar
            fi

            # docker-sync things
            if ! [ -x "$(command -v docker-sync)" ]; then
                # get homebrew if not installed
                if ! [ -x "$(command -v brew)" ]; then
                    echo "Installing homebrew just because...."
                    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
                fi
                # use homebrew to grab unison locally
                if ! [ -x "$(command -v unison)" ]; then
                    echo "Installing unison." && echo ""
                    brew install unison
                fi
                # unison-fsmonitor for sync
                if ! [ -x "$(command -v unison-fsmonitor)" ]; then
                    if ! [ -x "$(command -v pip)" ]; then
                        echo "Installing pip." && echo ""
                        sudo easy_install pip
                    fi
                    echo "Setting up unison-fsmonitor." && echo ""
                    sudo pip install MacFSEvents
                    curl -o /usr/local/bin/unison-fsmonitor -L https://raw.githubusercontent.com/hnsl/unox/master/unox.py
                    chmod +x /usr/local/bin/unison-fsmonitor
                fi
                brew install fswatch
                sudo gem install docker-sync
            fi
        fi

		# instill happy thoughts
		echo "" && echo "Your robot has been updated! Enjoy!" && echo ""
	fi
fi

