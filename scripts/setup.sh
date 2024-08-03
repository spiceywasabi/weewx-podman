#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

apt-get -y install wget gnupg
wget -qO - https://weewx.com/keys.html | sudo gpg --dearmor --output /etc/apt/trusted.gpg.d/weewx.gpg
echo "deb [arch=all] https://weewx.com/apt/python3 buster main" | sudo tee /etc/apt/sources.list.d/weewx.list

apt-get -y update
mkdir -p /etc/weewx
#touch /etc/weewx/weewx.conf
DEBIAN_FRONTEND=noninteractive apt-get -y install weewx  --assume-yes

# Before we begin we must setup logging....

cat <<EOF >> /etc/weewx/weewx.conf

[Logging]
    [[root]]
        handlers = timed_rotate,
    [[handlers]]
        [[[timed_rotate]]]
            level = ERROR
            formatter = verbose
            class = logging.StreamHandler
            stream = ext://sys.stdout

EOF

wanted_extensions_file="wee-wanted-extensions.txt"
if [ -f "${wanted_extensions_file}" ]; then
	wanted_extensions=$(cat "${wanted_extensions_file}"|grep -v "^#"|tr "\n" " ")
	for extension in ${wanted_extensions}; do
		potential_filename=$(basename $(echo "${extension}"|sort|sed -e "s/\/archive.*//g" -e "s/\/releases.*//g"))
		if [ -z "${potential_filename}" ]; then
			potential_filename="extension"
		fi
		filename="/tmp/${potential_filename}.zip"
		echo "wanting to download url ${extension} to destination ${filename}..."
		wget -O "${filename}" "${extension}"
		if [ -f ${filename} ]; then
			weectl extension install -y "${filename}"
			if [ "$?" -ne 0 ]; then
				exit 1
			fi
		else
			echo "error on building, extension unavailable"
			exit 1
		fi
	done
	echo "doing cleanup..."
	# remove what we can, never fail
	rm -fv "/tmp/*.zip" || exit 0
fi
apt-get clean
apt-get autoclean
apt-get autoremove

