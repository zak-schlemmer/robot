#robot#
## docker-compose based local development ##

-----------------

This is just the begining.

This was a organizational specific project I made that I've taken a knife to.

I'm still working to sew back up.

This readme is true to that, and doesn't have much use at the moment.

----------------

### Requirements ###

* [docker-compose](https://docs.docker.com/compose/)

There are other things for osx to user docker-sync now.

Robot will at least try to install most of them for you.

For most things it will install/use homebrew.

If you do not want homebrew on your machine, you need:

* unison
* unison-fsmonitor
* fswatch
* docker-sync

----------------

### Running ###
**
It doesn't matter where you run this from:**
```
#!bash
git clone git@github.com:zak-schlemmer/robot.git robot
cd robot
./install.sh
```
-----------------

**Your site files will be located in:**
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
db ports (allows for mysql GUI client connections on osx)
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

* TO DO

----------------

### Project Arguments ###

* TO DO
* all <- (not recomended, as there are quite a few now)

-----------------

### Commands Using Project Arguements ###

**build out the projects:**

```
#!bash
robot build 
```

