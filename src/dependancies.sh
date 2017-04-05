#!/bin/bash

###################################
#       ROBOT DEVELOPMENT         #
#    dependency check script      #
#       by: Zak Schlemmer         #
###################################


# docker-compose check
if ! [ -x "$(command -v docker-compose)" ]; then
        echo 'Sorry, docker-compose is not installed, or not executable.' >&2
        echo 'Please install docker-compose and try again.' >&2
        # die if not installed or not executable
        exit 1
fi
