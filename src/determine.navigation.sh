#!/bin/bash

###################################
#        ROBOT DEVELOPMENT        #
#      where to navigate to       #
#        by: Zak Schlemmer        #
###################################


# TO DO : will need to replace what remains here in favor of something dynamic

case `pwd | sed 's/.*robot.dev\///'` in


    "vanilla_drupal"* )
        echo "/vanilla_drupal"
        exit
        ;;

esac
shift


