#!/bin/bash

# Program: kalieraser.sh
# Version: 2.3.2 
# Author: Brainfuck
# Description: This program erase the system's logs and the tools data, 
# the files are wiped with Bleachbit (overwrite method) and 
# Secure RM (7 US DoD compliant passes method)
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
version="2.3.2"

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

Version: $version
Author: Brainfuck${endc}\n"
}


# check if the program run as a root
function check_root {
	if [ "$(id -u)" -ne 0 ]; then
		printf "${red}%s${endc}\n"  "[!] Please run this program as a root!" >&2
		exit 1
	fi
}


# backup function
#################

# backup log files and folders
function backup_data {
	banner
	check_root
	printf "\n${cyan}%s${endc} ${green}%s${endc}\n" "[ info ]" "Backup log files and folders"

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
		printf "${cyan}%s${endc} ${green}%s${endc} ${red}%s${endc}\n" "[ info ]" "Backup logs data of" "$username"
		cd $username
		sleep 2

		IFS=$','
		for files in ${log_folder[@]}; do
			if [ "$(ls -A "$files" 2> /dev/null | wc -l)" -gt 0 ]; then
				# simple backup with "cp" in /tmp/ directory
				cp -R "$files" /tmp/backup-logs-$current_date 2> /dev/null
				printf "${cyan}%s${endc} ${green}%s${endc} ${white}%s${endc}\n" "+" "copied:" "$files"
			fi
		done
	done

	# cd /tmp, compress backup folder with tar,
	printf "${cyan}%s${endc} ${green}%s${endc}\n" "[ info ]" "Compress backup with tar, please wait..."
	local tmp_dir
	tmp_dir='/tmp/'
	
	cd $tmp_dir
	if [ "$?" = "0" ]; then
		tar -czf backup-logs-$current_date.tar.gz backup-logs-$current_date
		# create folder for backups in /root/ directory
		mkdir -pv /root/backups
		# move backup
		cp -vf backup-logs-$current_date.tar.gz /root/backups
		sleep 5
		rm -Rv backup-logs-*
		sleep 3
	else
		printf "${red}%s${endc}\n" "[ failed ] An error occurred, please check your configuration"
		exit 1
	fi

	# encrypt new backup with GnuPG, cipher: AES256
	# gpg -h for more information
	printf "${cyan}%s${endc} ${green}%s${endc}\n" "[ info ]" "Encrypt backup with GnuPG, cipher AES256"
	cd /root/backups
	gpg -ca --cipher-algo AES256 backup-logs-$current_date.tar.gz
	sleep 3

	# remove unnecessary backup files
	printf "${cyan}%s${endc} ${green}%s${endc}\n" "[ info ]" "Backup encrypted, remove old backup files"
	rm -v backup-logs-$current_date.tar.gz
	sleep 3

	printf "${cyan}%s${endc} ${white}%s${endc}\n" "[ ok ]" "Backup complete:" 
	printf "${cyan}%s${endc} ${white}%s${endc}\n" "path of backup file:" "/root/backups/backups-logs-$current_date.tar.gz.asc"
	exit 0
}


# securely delete functions 
###########################

# run bleachbit command line interface
function run_bleachbit {
	printf "\n${cyan}%s${endc} ${green}%s${endc}\n" "[ info ]" "Starting bleachbit cleaner"
	sleep 1

	# if the output give errors, don't worry, bleachbit simply warning
	# if the application in this list are not installed :)
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
	# real terminal clear 
	printf "\033c"

	printf "${cyan}%s${endc} ${green}%s${endc}\n" "[ ok ]" "Temporary files deleted"
}


# delete logs with srm
function secure_rm {
	printf "${cyan}%s${endc} ${green}%s${endc}\n" "[ info ]" "Starting secure file deletion with srm, this will take some time..."

	# list logs in root and user home directories
	# when you start one tool, this tool can create a folder, or, often a hidden folder
	# with logs and configuration files, this array collect this files and folders
	# then pass it to next function.
	declare -a log_folder=(
	# files in /home/ 
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
		printf "${cyan}%s${endc} ${green}%s${endc} ${red}%s${endc}\n" "[ info ]" "Deleting logs of" "$username"
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
			printf "${cyan}%s${endc} ${green}%s${endc}\n" "-" "dmesg cleared"
			;;
		*)
			;;
	esac

	# it's strange, but if you don't run bleachbit from sudo, 
	# the program don't delete root bash history, delete with this function
	# simply executing the command: "history -c"
	printf "${green}Delete root bash history? [Y/n]${endc}"
	read -p "${green}:${endc} " yn
	case $yn in
		[yY]|[y|Y] )
			history -c
			sleep 1
			printf "${cyan}%s${endc} ${green}%s${endc}\n" "-" "bash history deleted"
			;;
		*)
			;;
	esac
}


# emptying the buffers cache (free pagecache, entries and inodes)
# in other words, drop data from RAM
function drop_cache {
	printf "${cyan}%s${endc} ${green}%s${endc}\n" "[ info ]" "Drop data from RAM"
	sh -c 'echo 3 >/proc/sys/vm/drop_caches'
	printf "${cyan}%s${endc} ${green}%s${endc}\n" "-" "RAM empty"
	sleep 5
	printf "\033c"

	printf "${cyan}%s${endc} ${white}%s${endc}\n" "[ ok ]" "All logs and files are securely deleted and your System is clean"
}


# ask for reboot
function system_reboot {
	printf "${green}%s${endc}" "It's recommended to reboot system, reboot now? [Y/n]"
	read -p "${green}:${endc} " yn
	case $yn in
		[yY]|[y|Y] )
			reboot
			;;
		*)
		printf "${cyan}%s${endc} ${green}%s${endc}\n" "[-]" "Exit!"
			exit 0
			;;
	esac
}


# start the program
###################
function start {
	banner
	check_root

	# check if dependencies are installed
	# bleachbit, srm
	command -v bleachbit -h > /dev/null 2>&1 ||
	{ printf >&2 "\n${red}%s${endc}\n" "[!] bleachbit isn't installed, exiting..."; exit 1; }

	command -v srm --help > /dev/null 2>&1 ||
	{ printf >&2 "\n${red}%s${endc}\n" "[!] srm isn't installed, exiting..."; exit 1; }

	run_bleachbit
	secure_rm
	drop_cache
	system_reboot
}


# display program and srm version then exit
function print_version {
	printf "${white}%s${endc}\n" "$program $version"
	printf "${white}%s${endc}\n" "$(srm -V)"
	exit 0
}


# print help menu'
function help_menu {
	banner
	
	printf "\n${white}%s${endc}\n\n" "Usage:"
	printf "${white}%s${endc}${red}%s${endc}${white}%s${endc}${red}%s${endc}\n" "┌─" "$USER" "@" "$(hostname)"
	printf "${white}%s${endc}${red}%s${endc} ${green}%s${endc}\n" "└─" "➤" "./$program --argument"

	printf "\n${white}%s${endc}\n\n" "Arguments:"
	printf "${green}%s${endc}\n" "--help      show this help message and exit"
	printf "${green}%s${endc}\n" "--start     start the program and delete logs"
	printf "${green}%s${endc}\n" "--backup    backup data and log folders"
	printf "${green}%s${endc}\n" "--version   display program and srm version, then exit"
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
