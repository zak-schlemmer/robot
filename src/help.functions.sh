#!/bin/bash

###################################
#        ROBOT DEVELOPMENT        #
#     functions for help text     #
#        by: Zak Schlemmer        #
###################################


# prints the usage of the command
function usage
{
    echo ""
    echo "usage: robot COMMAND [arg...]"
    echo "" && echo ""
    echo "Global Commands:" && echo ""
    echo "    update     This will trigger a check for updates, prompts for confirm to do so."
    echo "    top        Shows active container resource usage table in real time."
    echo "    list       Show a list of running containers with helpful information on them."
    echo "    hosts      Manually triggers a local /etc/hosts file check and update."
    echo "    clean      Docker/robot cleanup. Warning! This is global. (arguments: volumes, files, all, with-bleach)"
    echo "    help       Shows command usage information."
    echo "" && echo ""
    echo "Commands Based on Current Local Working Directory:" && echo ""
    echo "    drush      Run a drush command on the web container of the project."
    echo "    ssh        \"ssh\" the web container of the project (optional: provide a container name to ssh as root)"
    echo "    ngrok      Allows you to configure the project with an ngrok alias."
    echo "    db         (arguments: import, export) See 'robot db help' for more information."
    echo "    sync       Transfer files between local machine and container."
    echo "" && echo ""
    echo "Commands Taking Project Arguments - (See \"Project Arguments\" Below):" && echo ""
    echo "    create     Build a project from a template."
    echo "    build      This will build out the projects given as arguments."
    echo "    stop       This will stop containers for projects provided."
    echo "    start      This will start containers for projects provided."
    echo "    rm         This will remove the containers for stopped projects. (does not remove site files)"
    echo "    connect    Connect local projects together."
    echo "" && echo ""
    echo "Project Arguments:" && echo ""
    echo "    mailhog"
    echo "    vanilla"
    echo "    all        <- (does all the things)"
    echo ""
}

# help text for clean command
function clean_help
{
    echo ""
    echo "usage: robot clean COMMAND" && echo ""
    echo "Commands:"
    echo "    volumes           Removes all docker docker containers and removes all volumes."
    echo "    files             Removes all ~/robot.dev files, no container actions are taken."
    echo "    all               Removes all files, containers, and volumes."
    echo "    with-bleach       Removes EVERYTHING! (files, volumes, containers, images, networks)"
    echo "    help              Shows this help text."
    echo ""
}

# help text for db command
function db_help
{
    echo ""
    echo "usage: robot db COMMAND" && echo ""
    echo "Commands:"
    echo "    export            Dumps the database for the project in format: <project_name><time_stamp>.sql"
    echo "    import            Takes the additional argument: <mysql_dump_file>"
    echo "    drop              Drops the database for the project and re-creates empty."
    echo "    help              Shows this help text."
    echo ""
}


# help text for sync command
function sync_help
{
    echo ""
    echo "usage: robot sync COMMAND" && echo ""
    echo "Commands:"
    echo "    status        show if the auto sync is STOPPED or RUNNING for your project location"
    echo "    start         start auto-sync for your project location"
    echo "    stop          stop auto-sync for your project location"
    echo "    restart       restart auto-sync for your project location"
    echo "    up            force a 1 time sync from local -> container for your project location"
    echo "    back          force a 1 time sync from container -> local for your project location"
    echo ""
}