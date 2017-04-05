#!/bin/bash

###############################################
#             ROBOT DEVELOPMENT               #
# determine what project based on working dir #
#             by: Zak Schlemmer               #
###############################################


# TO DO : will need to replace what remains here in favor of something dynamic

case `pwd | sed 's/.*robot.dev\///'` in


    "vanilla_drupal"* )
		echo "vanilla"
		exit
		;;

esac
shift


