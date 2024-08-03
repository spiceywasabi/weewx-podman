#!/bin/bash

set -o errexit
set -o pipefail

if [ -z "${CONFIG_FILE}" ]; then
	export CONF_FILE="/data/weewx.conf"
fi

if [ "$1" = "--version" ]; then
	weewxd --version
	exit 0
elif [ "$1" = "--shell" ]; then
	/bin/sh
	exit $?
elif [ "$1" = "--upgrade" ]; then
	wee_config --upgrade --no-prompt --dist-config weewx.conf "${CONF_FILE}"
	exit $?
elif [ "$1" = "--init" ]; then
	wee_config --intall "${CONF_FILE}"
	exit $?
elif [ "$1" = "--run" ]; then
	# due to the way weewx generates and processes data from remotes
	# we need to ensure the user has set their timezone correctly (esp if migrated)
	if [ -z "$TZ" ]; then 
		echo "timezone not set"
		exit 1
	fi
	
	# set timezone
	#cp "/usr/share/zoneinfo/${TZ}" /etc/localtime && echo "${TZ}" > /etc/timezone
	
	if [ ! -f "${CONF_FILE}" ]; then
		echo "error! no configuration file"
		logger "error, no configuration file"
		exit 1
	fi
	# as a backup for plugins that hard code the config path
	# we put it in the etc directoruy, but use the /data path
	cp -v /data/weewx.conf /etc/weewx/weewx.conf

	/sbin/syslogd -n -S -O - &
	logger "attempting to start"
	weewxd "${CONF_FILE}"
else
	echo "unknown option, try --version, --shell, --init, or --run to container"
fi
