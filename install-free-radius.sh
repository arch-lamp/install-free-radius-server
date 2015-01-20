#!/usr/bin/env bash

#
# Date: 23 December, 2014
# Author: Aman Hanjrah and Peeyush Budhia
# URI: http://techlinux.net and http://phpnmysql.com
# License: GNU GPL v2.0
# Description: The script is used for the installation of free-radius server.
#

main() {
	clear
	echo -e "|------------------------|"
	echo -e "|Installing FreeRadius...|"
	echo -e "|------------------------|"
	prerequisites
	installFreeRadius
	sleep 1
	restartMySQL
	databaseOprations
	sleep 1
	changeConfiguration
	sleep 1
	startFreeRadius
	echo -e "|-----------------------------------------------------|"
	echo -e "|Installation of FreeRadius is completed successfully.|"
	echo -e "|-----------------------------------------------------|"
	echo -e "Press enter to return to main menu."
	read
	sh master-install.sh
	exit 0

}

prerequisites() {
	txtBold=`tput bold`
	txtNormal=`tput sgr0`
	sh install-repo.sh
	sleep 1
	chkWhich
	sleep 1
	chkMySQL
}

chkMySQL() {
	CHECK_MYSQL=`which mysql`
	if [[ `echo $?` -eq 1 ]]; then
		echo -e "MySQL is not installed on the server. Please install it first and re-run the script again to install freeradius.\n--------------------"
		echo -e "Press enter to return to main menu."
		read
		sh master-install.sh
		exit 0
	fi
}

chkWhich() {
	CHECK_WHICH=`rpm -qa | grep which`
	if [[ ! -n "$CHECK_WHICH" ]]; then
		yum -y install which >> /dev/null
	fi
}

installFreeRadius() {
	CHECK_FREERADIUS=`rpm -qa | grep freeradius`
	if [[ -n "$CHECK_FREERADIUS" ]]; then
		echo -e "FreeRadius is already installed on the server.\n--------------------"
		echo -e "Press enter to return to main menu."
		read
		sh master-install.sh
		exit 0
	else
		yum -y install freeradius freeradius-mysql freeradius-utils >> /dev/null
		unset CHECK_FREERADIUS
		CHECK_FREERADIUS=`rpm -qa | grep freeradius`
		if [[ ! -n "$CHECK_FREERADIUS" ]]; then
			echo -e "Error while installing FreeRadius.\n--------------------"
			echo -e "Press enter to return to main menu."
			read
			sh master-install.sh
			exit 0
		fi
	fi
}
	

askDBuser() {
	echo -e "Enter database username that you want to associate with freeradius database.\n--------------------"
	unset DB_USER
	read -e DB_USER
	if [[ -z "$DB_USER" ]]; 
		then
			echo -e "${txtBold}Please enter the username.${txtNormal}"
			askDBuser
	fi

	if [[ "$DB_USER" == "root" ]]; then
		echo -e "${txtBold}For security reasons root user is not allowed. Please choose different user.${txtNormal}"
		askDBuser
	fi
}

askDBpassword() {
	echo -e "Enter the password for the user above.\n--------------------"
	unset DB_PASS
	read -e DB_PASS
	if [[ -z "$DB_PASS" ]]; 
		then
			echo -e "${txtBold}Please enter the password.${txtNormal}"
			askDBpassword
	fi	
}

askDBname() {
	echo -e "Enter the database name you want to create for freeradius.\n--------------------"
	unset DB_NAME
	read -e DB_NAME
	if [[ -z "$DB_NAME" ]]; 
		then
			echo -e "${txtBold}Please enter the database name.${txtNormal}"
			askDBname
	fi	
}

askDBrootPass() {
	echo -e "Enter password of database root user.\n--------------------"
	unset DB_ROOT_PASS
	read -e DB_ROOT_PASS
	if [[ -z "$DB_ROOT_PASS" ]]; 
		then
			echo -e "${txtBold}Please enter the root password.${txtNormal}"
			askDBrootPass
	fi	
}

databaseOprations() {
	askDBname
	askDBuser
	askDBpassword
	askDBrootPass

	`which mysql` -u root -p"$DB_ROOT_PASS" -e "CREATE DATABASE $DB_NAME"
	`which mysql` -u root -p"$DB_ROOT_PASS" -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS'"

	echo -e "Creating database for freeradius server...\n--------------------"
	mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < /etc/raddb/sql/mysql/schema.sql
	mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < /etc/raddb/sql/mysql/nas.sql
	echo -e "Database for freeradius created successfully.\n--------------------"
}

changeConfiguration() {

	echo -e "Changing configuration files...\n--------------------"
	# Changing configuration in /etc/raddb/sql.conf
	sed -i "s/#port = 3306/port = 3306/g" /etc/raddb/sql.conf
	sed -i "s/login = \"radius\"/login = \""$DB_USER"\"/g" /etc/raddb/sql.conf
	sed -i "s/password = \"radpass\"/password = \""$DB_PASS"\"/g" /etc/raddb/sql.conf
	sed -i "s/radius_db = \"radius\"/radius_db = \""$DB_NAME"\"/g" /etc/raddb/sql.conf

	sed -i "s/#readclients = yes/readclients = yes/g" /etc/raddb/sql.conf

	# Changing configuration in /etc/raddb/radiusd.conf
	sed -i "s/#\t\$INCLUDE sql.conf/\t\$INCLUDE sql.conf/g" /etc/raddb/radiusd.conf

	# Changing configuration in /etc/raddb/sites-available/default
	sed -i "s/#\tsql/\tsql/g" /etc/raddb/sites-available/default

	# Changing configuration in /etc/raddb/sites-available/inner-tunnel
	sed -i "s/#\tsql/\tsql/g" /etc/raddb/sites-available/inner-tunnel
	echo -e "Configuration changed successfully.\n--------------------"
}

startFreeRadius() {
	service radiusd start >> /dev/null
}

restartMySQL() {
	service mysqld restart >> /dev/null
}

main
