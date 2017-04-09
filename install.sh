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

# get docker-sync
if [ $os == "Darwin" ]; then

    # create this loop back as that will now be needed
    sudo ifconfig lo0 alias 10.254.254.254 > /dev/null 2>&1
    sudo cp -f /etc/robot/src/robot.plist /Library/LaunchDaemons/ > /dev/null 2>&1

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
        cp -r /etc/robot/template/robot-nginx-osx /etc/robot/projects/robot-system/robot-nginx
    else
        cp -r /etc/robot/template/robot-nginx /etc/robot/projects/robot-system/robot-nginx
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
    cp -r /etc/robot/template/mailhog /etc/robot/projects/robot-system/
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
