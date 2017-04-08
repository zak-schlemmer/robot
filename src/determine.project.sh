#!/bin/bash

###############################################
#             ROBOT DEVELOPMENT               #
# determine what project based on working dir #
#             by: Zak Schlemmer               #
###############################################


# TO DO
# pretty simple, probably no need for this in a separate file anymore
echo `pwd | sed 's/.*robot.dev\///' | cut -f1 -d"/"`
