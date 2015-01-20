#!/usr/bin/env bash

#
# Date: 23 December, 2014
# Author: Aman Hanjrah and Peeyush Budhia
# URI: http://techlinux.net and http://phpnmysql.com
# License: GNU GPL v2.0
# Description: The script is used for the installation of free-radius and for adding new client for free-radius server.
#

main() {
	clear
	echo -e "-----------------------------------------------"
	echo -e "Press the numbers for their corresponding tasks"
	echo -e "1. Install FreeRadius Server"
	echo -e "2. Exit"
	echo -e "-----------------------------------------------"
	prerequisites
	processRequest
}

prerequisites() {
	txtBold=`tput bold`
	txtNormal=`tput sgr0`
}

takeUserInput() {
	unset "USERINPUT"
	read -e USERINPUT
	if [[ -z "$USERINPUT" ]]; 
		then
			echo -e "${txtBold}Please choose at least one option...\n${txtNormal}"
			takeUserInput
	fi
}

processRequest() {
	takeUserInput
	case "$USERINPUT" in
		1)
			sh install-free-radius.sh
		;;

		2)
			clear
			echo -e "For other technical stuff please visit the following sites:\nhttp://phpnmysql.com\nhttp://techlinux.net"
			exit 0
		;;

		*)
			echo -e "${txtBold}Invalid input supplied...\nPlease choose the correct option.${txtNormal}"
			installServers
	esac
}

main
