#!/bin/bash

# Program: kalieraser.sh
# Version: 2.1 - 23/05/2016
# Dev: Brainfuck
# Description: Antiforensics script for security and privacy
# Operative System: Kali Linux 
# Dependencies: Bleachbit > http://bleachbit.sourceforge.net
# Secure RM > http://sourceforge.net/projects/srm/
#
# GNU GENERAL PUBLIC LICENSE
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# define colors
export green='\033[1;92m'
export red='\033[1;91m'
export white='\033[1;97m'
export cyan='\033[1;96m'
export RESETCOLOR='\033[1;00m'

# banner
function banner {
cat << "EOF"
 _____     _ _                         
|  |  |___| |_|___ ___ ___ ___ ___ ___ 
|    -| .'| | | -_|  _| .'|_ -| -_|  _|
|__|__|__,|_|_|___|_| |__,|___|___|_|

Version: 2.1
Dev: Brainfuck
EOF
}


# check if root run the script 
function check_root {
	if [ "$(id -u)" -ne 0 ]; then
		echo -e "\n$red[!] Please run this script as a root!$RESETCOLOR\n" >&2
		exit 1
	fi
}


# run bleachbit command line interface
function run_bleachbit {
	echo -e "\n$cyan[info]$green Starting bleachbit cleaner$RESETCOLOR\n"
	sleep 1

	bleachbit --overwrite --clean apt.autoremove apt.clean bash.history \ 
	\ chromium.cache chromium.cookies chromium.dom chromium.form_history \
	\ chromium.history chromium.passwords chromium.vacuum elinks.history \
	\ firefox.cache firefox.cookies firefox.dom firefox.crash_reports firefox.dom \ 
	\ firefox.download_history firefox.forms firefox.passwords \ 
	\ firefox.session_restore firefox.site_preferences firefox.url_history \ 
	\ firefox.vacuum flash.cache flash.cookies gedit.recent_documents gimp.tmp \
	\ gnome.search_history google_chrome.cache google_chrome.cookies \
	\ google_chrome.dom google_chrome.form_history google_chrome.history \
	\ google_chrome.passwords google_chrome.session google_chrome.vacuum \
	\ google_earth.temporary_files google_toolbar.search_history java.cache \
	\ kde.cache kde.recent_documents kde.tmp libreoffice.cache libreoffice.history \
	\ liferea.cache liferea.cookies liferea.vacuum links2.history nautilus.history \
	\ openofficeorg.cache openofficeorg.recent_documents opera.cache opera.cookies \
	\ opera.current_session opera.dom opera.download_history opera.passwords \
	\ opera.search_history opera.url_history pidgin.cache pidgin.logs \ 
	\ screenlets.logs skype.chat_logs sqlite3.history system.cache \
	\ system.clipboard system.desktop_entry system.localizations \ 
	\ system.recent_documents system.rotated_logs system.tmp system.trash \
	\ thumbnails.cache thunderbird.cache thunderbird.cookies thunderbird.passwords \
	\ thunderbird.vacuum vim.history vlc.mru wine.tmp x11.debug_logs xchat.logs 
	sleep 1
	printf "\033c"

	echo -e "\n$cyan[+]$green Temporary files are deleted$RESETCOLOR"
}


# delete logs with srm 
function secure_rm {	
	echo -e "\n$cyan[info]$green Starting secure file deletion with srm, this will take some time...$RESETCOLOR"
	
	# array for tools and logs folders
	declare -a log_folder=(
	# root and user Home directory
	'/nmap_output/' '/.maltego/*BT/var/cache/*' '/.maltego/*BT/var/log/*' 
	'/.maltego/*CaseFileCE/var/cache/*' '/.maltego/*CaseFileCE/var/cache/*'
	'./chirp/*.log' '*.mtgrx' '/.recon-ng/*' '*.sprt' '/*-tool-output/' 
	'/.zenmap/*' '/.golismero/*' '/.ZAP/session/*' '/.ZAP/*.log/' 
	'/paros/session/*' '*skipfish*' '/.sqlmap/output/*' '/.w3af/tmp/*' 
	'*conversations*' '*fragments*' '*.properties' '*.data' '*.keystore' 
	'*.pot' '.0trace-*' '/TLSSLed*/' '/.wapiti/*' 'fimap.log' 'hydra.restore' 
	'/.creepy/*.log/' '.john/sessions/*.log''/.john/*' '/.set/*' '/.msf4/*' 
	'/.wireshark/*' '/.faraday/logs/*' '/.armitage/*' '/.weevely/*' 
	# /var/log/
	'/var/log/dradis/*' '/var/log/openvas/*.log' '/var/log/openvas/*.gz' 
	'/var/log/openvas/*.dump' '/var/log/openvas/*.messages' '/var/log/*log' 
	'/var/log/*.1' '/var/log/*.gz' '/var/log/*.old' '/var/log/*.err/' 
	'/var/log/messages' 'var/log/mysql/*.log' '/var/log/mysql/*.gz' 
	'/var/log/postgresql/*.log' '/var/log/wmtp' '/var/log/*.dat');

	# root and user logs
	IFS=$'\n'
	for username in $(echo -e "/root/\n$(ls /home/ | sed -e 's_^_/home/_' -e 's_$_/_')"); do
		echo -e "\n$cyan[info]$green Deleting logs of $red$username$RESETCOLOR"
		cd $username
		sleep 2

		IFS=$','
		for i in ${log_folder[@]}; do
			if [ "$(ls -A "$i" 2> /dev/null | wc -l)" -gt 0 ]; then
				# execute command "srm -i -D -R <file/folder>"
				# -i, --interactive     prompt before any removal
				# -D, --dod             overwrite with 7 US DoD compliant passes
				# -r, -R, --recursive   remove the contents of directories
				srm -i -D -R "$i" 2> /dev/null
				echo -e "$cyan[+]$green deleted: $white $i $RESETCOLOR"
			fi
		done
	done

	# delete dmesg logs
	echo -e "\n$green Delete kernel messages? [Y/n]:$RESETCOLOR"
	read -e yno
	case $yno in
		[yY]|[y|Y] )
			dmesg -C
			sleep 3
			echo -e "$cyan[+]$green dmesg deleted$RESETCOLOR\n"
			;;
		*)		
			;;	
	esac
}


# emptying the buffers cache (free pagecache, dentries and inodes)
function drop_cache {
	echo -e "$cyan[info]$green Drop data from RAM$RESETCOLOR\n"
	sh -c 'echo 3 >/proc/sys/vm/drop_caches'
	echo -e "$cyan[+]$green RAM empty$RESETCOLOR"
	sleep 5
	printf "\033c"

	echo -e "$cyan[ ok ]$white All logs and files are securely deleted and your System is clean$RESETCOLOR\n"
}


# ask for reboot
function system_reboot {
	echo -e "\n$green It is recommended to reboot system, reboot now? [Y/n]:$RESETCOLOR"
	read -e yno
	case $yno in
		[yY]|[y|Y] )
			reboot
			;;
		*)
		echo -e "\n$green Exit!$RESETCOLOR"
			exit 0
			;;
	esac
}


# start program 
function start {
	banner
	check_root

	# check if dependencies are installed 
	command -v bleachbit -h > /dev/null 2>&1 ||
	{ echo -e "\n$red[!] bleachbit isn't installed, exiting...$RESETCOLOR"; exit 0; }

	command -v srm --help > /dev/null 2>&1 ||
	{ echo -e "\n$red[!] srm isn't installed, exiting...$RESETCOLOR"; exit 0; }

	run_bleachbit
	secure_rm
	drop_cache
	system_reboot 
}


# print help menu'
function help_menu {
	banner 
	echo -e "\n$white Usage:

┌─╼ $red$USER$white ╺─╸ $red$(hostname)$white
└───╼ $green""./kalieraser.sh $white[ $green""start$white | $green""help $white""]

$white start$red -$green Start the program 

$white help$red -$green Show this help message and exit 
$RESETCOLOR" >&2
	exit 1

	echo -e $RESETCOLOR

	exit 0
}


# menu options 
case "$1" in
	start)
		start
		;;
	help)
		help_menu
		;;
    *)
help_menu
;;
esac

exit 0
