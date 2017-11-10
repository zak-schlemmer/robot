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
    echo "    create     Build a project from a template. (optional: provide a name as an argument)"
    echo "    update     This will trigger a check for updates, prompts for confirm to do so."
    echo "    projects   Show a list of projects available in robot."
    echo "    top        Shows active container resource usage table in real time."
    echo "    list       Show a list of running containers with helpful information on them."
    echo "    clean      Docker/robot cleanup. Warning! This is global. See 'robot clean help' for specifics."
    echo "    help       Shows command usage information."
    echo "" && echo ""
    echo "Commands Based on Current Local Working Directory:" && echo ""
    echo "    status     See information about the current project's containers"
    echo "    drush      Run a drush command on the web container of the project. (drupal projects)"
    echo "    wp         Run a wp-cli command on the web container of the project. (wordpress projects)"
    echo "    ssh        \"ssh\" the web container of the project (optional: provide a container name to ssh as root)"
    echo "    ngrok      Allows you to configure the project with an ngrok alias."
    echo "    db         Manage database actions. See 'robot db help' for more information."
    echo "    sync       Manage OSX file sync acitons. See 'robot sync help' for more information."
    echo "    backup     Backup and restore projects. (--all for everything)"
    echo "" && echo ""
    echo "Commands Taking Project Arguments - (See 'robot projects' for a list):" && echo ""
    echo "    build      This will build out the projects given as arguments."
    echo "    rebuild    This will rebuild the containers for provided projects."
    echo "    stop       This will stop containers for projects provided."
    echo "    start      This will start containers for projects provided."
    echo "    rm         This will remove the containers for stopped projects. (does not remove site files)"
    echo "" && echo ""
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

# help text for backup command
function backup_help
{
    echo ""
    echo "usage: robot backup COMMAND" && echo ""
    echo "Commands:"
    echo "    create            Create a backup of the project you are navigated to. (--all for everything)"
    echo "    restore           Restore a project from a backup."
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
    echo "    test          this will manually check that something syncs and then remove it"
    echo "    start         start auto-sync for your project location"
    echo "    stop          stop auto-sync for your project location"
    echo "    restart       restart auto-sync for your project location"
    echo "    up            force a 1 time sync from local -> container for your project location"
    echo "    back          force a 1 time sync from container -> local for your project location"
    echo ""
}