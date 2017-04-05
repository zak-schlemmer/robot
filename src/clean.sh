#!/bin/bash

########################################
#         ROBOT DEVELOPMENT            #
#      robot clean functionality       #
#         by: Zak Schlemmer            #
########################################


# include help functions
. /etc/robot/src/help.functions.sh

# arguments to 'robot clean'
case $2 in

    # removes ALL volumes in docker
    volumes )
        docker rm -f $(docker ps -a -q)
        docker volume rm $(docker volume ls -q)
        exit
        ;;
    # removes ALL the site files
    files )
        rm -rf ~/robot.dev/*
        exit
        ;;
    # just does the 2 above
    all )
        rm -rf ~/robot.dev/*
        docker rm -f $(docker ps -a -q)
        docker volume rm $(docker volume ls -q)
        exit
        ;;

    # possibly a bad idea
    with-bleach )
        rm -rf ~/robot.dev/*
        docker rm -f $(docker ps -a -q)
        docker volume rm $(docker volume ls -q)
        docker rmi -f $(docker images -a -q)
        docker network rm $(docker network ls -q)
        exit
        ;;

    # prints 'robot clean' help text
    -h | --help | help | "")
        clean_help
        exit
        ;;

    # typo catch + help text
    * )
        echo ""
        echo 'unrecognized command: robot' ${*}
        clean_help
        exit
        ;;

esac
