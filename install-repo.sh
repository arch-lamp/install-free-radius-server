#!/usr/bin/env bash

#
# Date: 19 November, 2014
# Author: Aman Hanjrah and Peeyush Budhia
# URI: http://techlinux.net and http://phpnmysql.com
# License: GNU GPL v2.0
# Description: The script is used for the installation of required repos (epel and remi) according to the system's architecture and OS version.
#

installRepos() {
	ARCHITECTURE=`uname -m`
	OS_VERSION=`cat /etc/redhat-release | cut -d" " -f3 | cut -c1`
	CHK_EPEL=`rpm -qa | grep epel-release`
	CHK_REMI=`rpm -qa | grep remi-release`

	if [[ ! -n "$CHK_EPEL" || ! -n "$CHK_REMI" ]]; 
		then
			cd /tmp
			curl -O -f http://dl.fedoraproject.org/pub/epel/$OS_VERSION/$ARCHITECTURE/epel-release-$OS_VERSION-[0-9].noarch.rpm >> /tmp/epel.log 2>&1
			curl -O -f http://rpms.famillecollet.com/enterprise/remi-release-6.rpm >> /tmp/remi.log 2>&1
			rpm -Uh /tmp/epel-release* >> /tmp/epel.log 2>&1
			rpm -Uh /tmp/remi-release* >> /tmp/remi.log 2>&1

			rm -rf /tmp/epel-release* /tmp/remi-release*
			cd - >> /dev/null
	fi
}

installRepos
