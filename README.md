# robot #

## docker-compose based local development ##

This project allows you to easily manage all your local development.

You can create new projects from templates, that can be saved to seperate repositories.

I originally created this as an organizational specific project.

I have already managed to re-create those organizational projects in this new open source format.

I will be working to outline this process here, create documentation, and create examples for reference.

----------------

### Requirements ###

* [docker-compose](https://docs.docker.com/compose/)
* [composer](https://getcomposer.org)

There are additional requirements for using robot in osx.

The install and update will try to install/use homebrew to implement these, but that doesn't work very well yet.

I would recomend attempting to implement these items manually:

* unison
* unison-fsmonitor
* fswatch
* docker-sync

The install/update scripts will skill attempting to implement these items if they exist.

----------------

### Running ###
**It doesn't matter where you run this from:**
```
git clone git@github.com:zak-schlemmer/robot.git robot
cd robot
./install.sh
```
-----------------

**Your site files will be located in...**

(once you have built that project out):
```
~/robot.dev
```

**The db credentials are:**
```
db = <project_name>
user = <project_name>
pw = robot
```

**site credentials:**
```
u: admin
p: robot
e: admin@robot.com
```

----------------

### Site URL ###
```
< the name you give it>.robot
```

----------------

### Global Commands ####

**create a project for use**
```
robot create
robot create <project_name>
```
-----------------

### Commands Using Project Arguements ###

**build out the projects:**

```
robot build < my_project_name >
robot build < my_project > < another_project > < any_number_of_projects >
```

**rebuild project containers:**

```
robot rebuild < my_project > < other_my_project >
```

**other project management:**

```
robot stop < project_one > < project_two >
robot rm < project_two >
robot start < project_one> < project_three >
```

-----------------

### Commands Based on Current Working Directory ###

**run a drush command:**
```
robot drush cc all
robot drush -y en entities
robot drush sql-query "select * from users"
```

**ssh to the web container of the project:**

you will be the user: **robot**
```
cd ~/robot.dev/my_sweet_project
robot ssh
```

**ssh to a specific container from anywhere:**

*(you can determine the name in 'robot list' or 'robot top')*

you will be the user: **root**
```
robot ssh project5_db_1
```

**configure a ngrok vhost:**
```
robot ngrok
```

**Import / Export / Drop a Database**
```
robot db export
robot db import my.sweet.db.dump.sql
robot db drop
```

**Manage File Syncing**
(osx only)
```
robot sync status
robot sync test
robot sync restart
robot sync start
robot sync stop
robot sync up
robot sync back
```

---------------------

### Global Commands ###

**update the robot project**

```
robot update
```

**see active container resource usage**

```
robot top
```

**list contains with information about them**

```
robot list
```

**run dangerous global clean commands**
```
robot clean volumes
robot clean files
robot clean all
robot clean with-bleach
```


