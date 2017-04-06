# robot #
## docker-compose based local development ##

-----------------

This is just the begining.

This was a organizational specific project, that I've taken a knife to.

I'm still working to sew it back up.

This readme is true to that, and doesn't have much use at the moment.

----------------

### Requirements ###

* [docker-compose](https://docs.docker.com/compose/)

There are additional requirements for using robot in osx.

The install and update will try to install/use homebrew.

If you do not want homebrew on your machine, you will need:

* unison
* unison-fsmonitor
* fswatch
* docker-sync

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
**db ports**

(allows for mysql GUI client connections on osx)
```
TO DO
```

**site credentials:**
```
u: admin
p: robot
e: admin@robot.robot
```

----------------

### Site URL's ###
```
< the name you give it>.robot
```

----------------

### Global Commands ####

**create a project for use**
```
robot create
```

### Project Arguments ###

* < the name you give it >

-----------------

### Commands Using Project Arguements ###

**build out the projects:**

```
robot build < my project name >
```

