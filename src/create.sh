#!/bin/bash

###################################
#        ROBOT DEVELOPMENT        #
#  create project from template   #
#        by: Zak Schlemmer        #
###################################


# check if --dir arg provided
if [ "$1" == "--dir" ]; then
    if [ "$2" == "" ]; then
        echo "" && echo "When using '--dir' please provide the existing directory in the form:"
        echo "" && echo "robot create --dir /path/to/my/existing/project"
        echo "" && exit
    fi
    # extract the project directory from the path
    remove=`dirname ${2%/}`
    project_name=`echo ${2%/} | sed "s@${remove}/@@g"`

else
    # check if a name was provided
    if [ "$1" == "" ]; then
        # take in a project name
        echo "" && echo "What would you like to use as a project name?"
        echo "" && echo -n "(You will want to keep it short and simple): "
        read project_name && echo ""
    else
        project_name="$1"
    fi
fi


# project name error catch
for existing in `ls -p /etc/robot/projects/* | grep / | grep -v :| tr '\n' ' '`
do
    # check for duplicate project name
    if [ "${existing}" == "${project_name}/" ]; then
        echo "" && echo "A project named $project_name appears to already exist."
        echo "" && echo "Please either remove the existing project by that name, or choose another name."
        echo "" && exit
    fi
    # check for unix user
    if [ `whoami` == "${project_name}" ]; then
        echo "" && echo "A project cannot currently use the same name as your unix user."
        echo "" && exit
    fi
done

# check for underscore character and tell them stuff
if ! [ `echo $project_name | grep -c "_"` == "0" ]; then
    echo ""
    echo "I see you included an underscore character in your project name." && echo ""
    echo "That character is used in robot to represent subprojects in the form: <project>_<subproject>" && echo ""
    echo "I recommend you replace this character with a period or dash to achive the same human readable symbolism." && echo ""
    exit
fi

# when using --dir flag, default to "Empty" (for now)
if [ "$1" == "--dir" ]; then
    template_select_option="0"
else
    # some sort of option of the template to use
    echo ""
    echo "Please pick a base template to use:" && echo ""
    echo "       ( 0 ) Empty                 2 container (web/db)"
    echo "       ( 1 ) drupal 7.54           2 container (web/db)"
    echo "       ( 2 ) drupal 8.3.1          2 container (web/db)"
    echo "       ( 3 ) wordpress             2 container (web/db)"
    echo ""
    echo -n "Numbered Choice: "
    read template_select_option && echo ""
fi

# select php 5.6 or 7
echo ""
echo "Please select the php version you would like to use:" && echo ""
echo "       ( 1 ) 5.6"
echo "       ( 2 ) 7.0"
echo ""
echo -n "Numbered Choice: "
read php_select_option && echo ""

# when using --dir flag, offer to include a db dump in build
if [ "$1" == "--dir" ]; then
    echo ""
    echo "Would you like to include a database dump file in the build?"
    echo -n "Enter 'y' or 'n': "
    read use_db_dump && echo ""
fi
if [ "$use_db_dump" == "y" ]; then
    echo ""
    echo "Please enter the the path to the database dump file to include in the build."
    echo -n "Path to file: "
    read -e db_file_path && echo ""
fi

# when using --dir flag, offer drush or wp-cli addition
if [ "$1" == "--dir" ]; then
    echo ""
    echo "Would you like any additional tools for this project?:" && echo ""
    echo "       ( 0 ) none"
    echo "       ( 1 ) drush            (drupal)"
    echo "       ( 2 ) wp-cli           (wordpress)"
    echo ""
    echo -n "Numbered Choice: "
    read tool_select_option && echo ""
fi


# make all the things for the new project, using the name provided
project_path=/etc/robot/projects/custom/$project_name
mkdir -p $project_path


# create project from template
case $template_select_option in


    #####################
    # empty 2 container #
    #####################
    0 )
        # copy everything from templates
        cp -rf /etc/robot/template/robot-system/empty-2-container/* $project_path/
        # check user php selection
        case $php_select_option in
            1 )
                # php5.6
                cp -rf /etc/robot/template/robot-system/apache2 $project_path/
                ;;
            2 )
                # php7.0
                cp -rf /etc/robot/template/robot-system/apache2-php7 $project_path/apache2
                ;;
            esac
        ;;

    ###############
    # drupal 7.54 #
    ###############
    1 )
        # copy everything from templates
        cp -rf /etc/robot/template/robot-system/drupal7/* $project_path/
        # check user php selection
        case $php_select_option in
            1 )
                # php5.6
                cp -rf /etc/robot/template/robot-system/apache2 $project_path/
                ;;
            2 )
                # php7.0
                cp -rf /etc/robot/template/robot-system/apache2-php7 $project_path/apache2
                ;;
            esac
        ;;

    ################
    # drupal 8.2.7 #
    ################
    2 )
        # copy everything from templates
        cp -rf /etc/robot/template/robot-system/drupal8/* $project_path/
        # check user php selection
        case $php_select_option in
            1 )
                # php5.6
                cp -rf /etc/robot/template/robot-system/apache2 $project_path/
                ;;
            2 )
                # php7.0
                cp -rf /etc/robot/template/robot-system/apache2-php7 $project_path/apache2
                ;;
            esac
        ;;


    #############
    # wordpress #
    #############
    3 )
        # copy everything from templates
        cp -rf /etc/robot/template/robot-system/wordpress/* $project_path/
        # check user php selection
        case $php_select_option in
            1 )
                # php5.6
                cp -rf /etc/robot/template/robot-system/apache2 $project_path/
                ;;
            2 )
                # php7.0
                cp -rf /etc/robot/template/robot-system/apache2-php7 $project_path/apache2
                ;;
            esac
        ;;

    esac



# do everything else not option specific
cp -rf /etc/robot/template/robot-system/mysql $project_path/
cp -rf /etc/robot/template/robot-system/docker-sync $project_path/
# replace the word template in stuff
sed -i -e "s/template/${project_name}/g" \
    $project_path/docker-compose.yml \
    $project_path/apache2/Dockerfile \
    $project_path/mysql/Dockerfile \
    $project_path/apache2/template.apache2.vhost.conf \
    $project_path/docker-sync/docker-sync.yml \
    $project_path/osx-docker-compose.yml
# project specific file names
mv $project_path/apache2/template.apache2.ports.conf $project_path/apache2/$project_name.apache2.ports.conf
mv $project_path/apache2/template.apache2.vhost.conf $project_path/apache2/$project_name.apache2.vhost.conf
# install per project type
if [ $template_select_option == 0 ]; then
    mv $project_path/empty.install.sh $project_path/$project_name.install.sh
elif [ $template_select_option == 1 ] || [ $template_select_option == 2 ]; then
    mv $project_path/drupal.install.sh $project_path/$project_name.install.sh
elif [ $template_select_option == 3 ]; then
    mv $project_path/wordpress.install.sh $project_path/$project_name.install.sh
fi

# set custom file location
if [ "$1" == "--dir" ]; then
    # use db dump file in build
    if [ "$use_db_dump" == "y" ]; then
        db_file_full_path=${db_file_path/\~/$HOME}
        cp "${db_file_full_path}" $project_path/mysql/${project_name}.sql
        sed -i -e "s@#remove me#@@g" $project_path/$project_name.install.sh
    fi
    # add extra tools
    if [ "$tool_select_option" == "1" ]; then
        sed -i -e "s@#remove me drush#@@g" $project_path/$project_name.install.sh
    elif [ "$tool_select_option" == "2" ]; then
        sed -i -e "s@#remove me wp#@@g" $project_path/$project_name.install.sh
    fi
    # do the rest of the replacements
    sed -i -e "s@~/robot.dev@$remove@g" \
        $project_path/docker-compose.yml \
        $project_path/apache2/Dockerfile \
        $project_path/osx-docker-compose.yml \
        $project_path/apache2/$project_name.apache2.ports.conf \
        $project_path/apache2/$project_name.apache2.vhost.conf \
        $project_path/docker-sync/docker-sync.yml
fi

# find next available apache2 port
for ((i=81;i<=181;i++)); do
    if [ `cat /etc/robot/projects/*/*/apache2/*.apache2.ports.conf | grep Listen | tr -d 'Listen ' | grep -c $i` == "0" ]; then
        apache_port=$i
        break
    fi
done
# find next available mysql port
for ((i=3301;i<=3401;i++)); do
    if [ `cat /etc/robot/projects/*/*/mysql/default.my.cnf | grep port | tr -d 'port = ' | grep -c $i` == "0" ]; then
        mysql_port=$i
        break
    fi
done
# find next available IP
for ((i=2;i<=254;i++)); do
    if [ `grep -rh "ipv4_address: 172.72.72" /etc/robot/projects/*/*/docker-compose.yml | sed  's/        ipv4_address: //' | grep -c "172.72.72.${i}"` == "0" ]; then
        next_ip=$i
        break
    fi
done
# set apache port
sed -i -e "s/8080/${apache_port}/g" $project_path/apache2/$project_name.apache2.ports.conf \
    $project_path/apache2/$project_name.apache2.vhost.conf
# set mysql port
sed -i -e "s/9999/${mysql_port}/g" $project_path/mysql/default.my.cnf \
    $project_path/$project_name.install.sh \
    $project_path/docker-compose.yml \
    $project_path/osx-docker-compose.yml
# set ip
sed -i -e "s/333/${next_ip}/g" $project_path/docker-compose.yml $project_path/osx-docker-compose.yml
apache2_next_ip=$((next_ip+1))
sed -i -e "s/444/${apache2_next_ip}/g" $project_path/docker-compose.yml $project_path/osx-docker-compose.yml
# update local /etc/hosts
export project_name=$project_name
echo "I will update your local /etc/hosts file for you." && echo ""
if [ `uname -s` == "Darwin" ]; then
    sudo -E bash -c 'echo "10.254.254.254 ${project_name}.robot" >> /etc/hosts'
else
    sudo -E bash -c 'echo "172.72.72.254 ${project_name}.robot" >> /etc/hosts'
fi
# update nginx
sed -i -e "s/} # the end of all the things//" /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf
cat /etc/robot/projects/robot-system/robot-nginx/nginx.server.template.conf >> /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf
sed -i -e "s/template/${project_name}/g" /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf
sed -i -e "s/8080/${apache_port}/g" /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf
echo "      - '${project_name}.robot:172.72.72.${apache2_next_ip}'" >> /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml
docker-compose -p robot -f /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml build
docker-compose -p robot -f /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml up -d

# cleanup for poor work on OSX sed's
find $project_path/ -name "*-e" | xargs rm -rf
