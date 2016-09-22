#!/bin/bash

# Program: kalieraser.sh
# Version: 2.3.0 - 20/09/2016
# Author: Brainfuck
# Description: This program erase the system's logs and the tools data, 
# the files are wiped with Bleachbit (overwrite method) and 
# Secure RM (7 US DoD compliant passes method)
#
# (for all informations please see the file: README.md)
# Operating System: Kali Linux
# Dependencies: bleachbit, srm (Secure RM)
# http://bleachbit.sourceforge.net
# http://sourceforge.net/projects/srm/

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


# program / version
program="kalieraser"
version="2.3.0"

# define colors
export red=$'\e[0;91m'
export green=$'\e[0;92m'
export white=$'\e[0;97m'
export cyan=$'\e[0;36m'
export endc=$'\e[0m'


# banner
function banner {
printf "${white}
 _____     _ _
|  |  |___| |_|___ ___ ___ ___ ___ ___
|    -| .'| | | -_|  _| .'|_ -| -_|  _|
|__|__|__,|_|_|___|_| |__,|___|___|_|

Antiforensics script for security and privacy

Version: 2.3.0
Author: Brainfuck${endc}\n"
}


# check if the program run as a root
function check_root {
	if [ "$(id -u)" -ne 0 ]; then
		printf "${red}[!] Please run this program as a root!${endc}\n" >&2
		exit 1
	fi
}


# backup function
#################

# backup log files and folders
function backup_data {
	banner
	check_root
	printf "\n${cyan}[ INFO ]${endc} ${green}Backup log files and folders${endc}\n"

	local current_date
	current_date=$(date +%Y-%m-%d)

	# list logs in root and user home directory
	declare -a log_folder=(
	'/nmap_output/' '/.maltego/*BT/var/cache/*' '/.maltego/*BT/var/log/*'
	'/.maltego/*CaseFileCE/var/cache/*' '/.maltego/*CaseFileCE/var/cache/*'
	'./chirp/*.log' '*.mtgrx' '/.recon-ng/*' '*.sprt' '/*-tool-output/'
	'/.zenmap/*' '/.golismero/*' '/.ZAP/session/*' '/.ZAP/*.log/'
	'/paros/session/*' '*skipfish*' '/.sqlmap/output/*' '/.w3af/tmp/*'
	'*conversations*' '*fragments*' '*.properties' '*.data' '*.keystore'
	'*.pot' '.0trace-*' '/TLSSLed*/' '/.wapiti/*' 'fimap.log' 'hydra.restore'
	'/.creepy/*.log/' '.john/sessions/*.log''/.john/*' '/.set/*' '/.msf4/*'
	'/.wireshark/*' '/.faraday/logs/*' '/.armitage/*' '/.weevely/*' '/*history/'
	# /var/log/
	'/var/log/dradis/*' '/var/log/openvas/*.log' '/var/log/openvas/*.gz'
	'/var/log/openvas/*.dump' '/var/log/openvas/*.messages' '/var/log/*log'
	'/var/log/*.1' '/var/log/*.gz' '/var/log/*.old' '/var/log/*.err/'
	'/var/log/messages' 'var/log/mysql/*.log' '/var/log/mysql/*.gz'
	'/var/log/postgresql/*.log' '/var/log/wmtp' '/var/log/*.dat' 
	'/var/log/clamav/*.log');

	# start backup
	IFS=$'\n'
	for username in $(printf "/root/\n$(ls /home/ | sed -e 's_^_/home/_' -e 's_$_/_')"); do
		printf "${cyan}[ INFO ]${endc} ${green}Backup logs data of ${red}$username${endc}\n"
		cd $username
		sleep 2

		IFS=$','
		for files in ${log_folder[@]}; do
			if [ "$(ls -A "$files" 2> /dev/null | wc -l)" -gt 0 ]; then
				# simple backup with "cp" in /tmp/ directory
				cp -R "$files" /tmp/backup-logs-$current_date 2> /dev/null
				printf "${cyan}[+]${endc} ${green}copied:${endc} ${white}$files${endc}\n"
			fi
		done
	done

	# compress backup folder with tar and move backup in /root/backups/ folder
	printf "${cyan}[ INFO ]${endc} ${green}Compress backup with tar, please wait...${endc}\n"
	local tmp_dir
	tmp_dir='/tmp/'
	cd $tmp_dir
	if [ "$?" = "0" ]; then
		tar -czf backup-logs-$current_date.tar.gz backup-logs-$current_date
		# create folder for backups in /root/ home directory
		mkdir -pv /root/backups
		# move backup
		cp backup-logs-$current_date.tar.gz /root/backups
		sleep 5
		rm -R backup-logs-*
		sleep 3
	else
		printf "${red}[ FAILED ] An error occurred, please check your configuration${endc}\n"
		exit 1
	fi

	# encrypt new backup with GnuPG, cipher: AES256
	# gpg -h for more information
	printf "${cyan}[ INFO ]${endc} ${green}Encrypt backup with GnuPG, cipher AES256${endc}\n"
	cd /root/backups
	gpg -ca --cipher-algo AES256 backup-logs-$current_date.tar.gz
	sleep 3

	# remove unnecessary backup files
	printf "${cyan}[ INFO ]${endc} Backup encrypted, remove old backup files${endc}\n"
	rm backup-logs-$current_date.tar.gz
	sleep 3

	printf "${cyan}[ OK ]${endc} ${white}Backup complete:${endc}\n" 
	printf "${cyan}path of backup file:${endc} ${white}/root/backups/backups-logs-$current_date.tar.gz.asc${endc}\n"
	exit 0
}


# secure rm functions 
#####################

# run bleachbit command line interface
function run_bleachbit {
	printf "\n${cyan}[ INFO ]${endc} ${green}Starting bleachbit cleaner${endc}\n"
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

	printf "${cyan}[ OK ]${endc} ${green}Temporary files are deleted${endc}\n"
}


# delete logs with srm
function secure_rm {
	printf "${cyan}[ INFO ]${endc} ${green}Starting secure file deletion with srm, this will take some time...${endc}\n"

	# list logs in root and user home directory
	declare -a log_folder=(
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

	# delete logs
	IFS=$'\n'
	for username in $(printf "/root/\n$(ls /home/ | sed -e 's_^_/home/_' -e 's_$_/_')"); do
		printf "${cyan}[ INFO ]${endc} ${green}Deleting logs of ${red}$username${endc}\n"
		cd $username
		sleep 2

		IFS=$','
		for files in ${log_folder[@]}; do
			if [ "$(ls -A "$files" 2> /dev/null | wc -l)" -gt 0 ]; then
				# execute command "srm -i -D -R <file/folder>"
				# -i, --interactive     prompt before any removal
				# -D, --dod             overwrite with 7 US DoD compliant passes
				# -r, -R, --recursive   remove the contents of directories
				srm -i -D -R "$files" 2> /dev/null
				printf "${cyan}[+]${endc} ${green}deleted:${endc} ${white}$files${endc}\n"
			fi
		done
	done

	# delete dmesg logs
	printf "${green}Delete kernel messages? (dmesg) [Y/n]${endc}"
	read -p "${green}:${endc} " yn
	case $yn in
		[yY]|[y|Y] )
			dmesg -C
			sleep 3
			printf "${cyan}[ OK ]${endc} ${green}dmesg cleared${endc}\n"
			;;
		*)
			;;
	esac

	# it's strange, but bleachbit don't delete root bash history 
	# if you don't run the program from sudo, delete with this command: "history -c"
	printf "${green}Delete root bash history? [Y/n]${endc}"
	read -p "${green}:${endc} " yn
	case $yn in
		[yY]|[y|Y] )
			history -c
			sleep 1
			printf "${cyan}[ OK ]${endc} ${green}bash history deleted${endc}\n"
			;;
		*)
			;;
	esac
}


# emptying the buffers cache (free pagecache, entries and inodes)
function drop_cache {
	printf "${cyan}[ INFO ]${endc} ${green}Drop data from RAM${endc}\n"
	sh -c 'echo 3 >/proc/sys/vm/drop_caches'
	printf "${cyan}[ OK ]${endc} ${green}RAM empty${endc}\n"
	sleep 5
	printf "\033c"

	printf "${cyan}[ OK ]${endc} ${white}All logs and files are securely deleted and your System is clean${endc}\n"
}


# ask for reboot
function system_reboot {
	printf "${green}It's recommended to reboot system, reboot now? [Y/n]${endc}"
	read -p "${green}:${endc} " yn
	case $yn in
		[yY]|[y|Y] )
			reboot
			;;
		*)
		printf "${cyan}[-]${endc} ${green}Exit!${endc}\n"
			exit 0
			;;
	esac
}


# start the program
function start {
	banner
	check_root

	# check if dependencies are installed
	# bleachbit
	command -v bleachbit -h > /dev/null 2>&1 ||
	{ printf >&2 "${red}[!] bleachbit isn't installed, exiting...${endc}\n"; exit 1; }

	# srm 
	command -v srm --help > /dev/null 2>&1 ||
	{ printf >&2 "${red}[!] srm isn't installed, exiting...${endc}\n"; exit 1; }

	run_bleachbit
	secure_rm
	drop_cache
	system_reboot
}


# display program and srm version then exit
function print_version {
	printf "${white}$program $version${endc}\n"
	printf "${white}$(srm -V)${endc}\n"
	exit 0
}


# print help menu'
function help_menu {
	banner
	printf "\n${white}Usage:${endc}\n\n"
	printf "${white}┌─╼${endc} ${red}$USER${endc} ${white}╺─╸${endc} ${red}$(hostname)${endc}\n"
	printf "${white}└───╼${endc} ${green}./%s$program --argument${endc}\n"

	printf "\n${white}Arguments:${endc}\n\n"
	printf "${red}--help${endc}		${green}show this help message and exit${endc}\n"
	printf "${red}--start${endc}  	${green}start the program and delete logs${endc}\n"
	printf "${red}--backup${endc}	${green}backup data and log folders${endc}\n"
	printf "${red}--version${endc}	${green}display program and srm version, then exit${endc}\n\n"
	exit 0
}


# cases user input
case "$1" in
	--start)
		start
		;;
	--backup)
		backup_data
		;;
	--version)
		print_version
		;;
	--help)
		help_menu
		;;
	*)
help_menu
exit 1

esac
