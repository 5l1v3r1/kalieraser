#!/bin/bash

# Program: kalieraser.sh
# Version: 2.2 - 29/06/2016
# Dev: Brainfuck
# Description: Antiforensics script for security and privacy
# Operative System: Kali Linux
# Dependencies Bleachbit, Secure RM
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
version="2.2"

# define colors
export green='\033[0;92m'
export red='\033[0;91m'
export white='\033[0;97m'
export cyan='\033[0;96m'
export endc='\e[0m'


# banner
function banner {
cat << "EOF"
 _____     _ _                         
|  |  |___| |_|___ ___ ___ ___ ___ ___ 
|    -| .'| | | -_|  _| .'|_ -| -_|  _|
|__|__|__,|_|_|___|_| |__,|___|___|_|

Version: 2.2
Dev: Brainfuck
EOF
}


# check if the program run as a root
function check_root {
	if [ "$(id -u)" -ne 0 ]; then
		echo -e "$red[!] Please run this program as a root!$endc" >&2
		exit 1
	fi
}


# backup log files and folders 
function backup_data {
	banner
	check_root
	echo -e "\n$cyan[info]$green Backup log files and folders$endc"

	local current_date=`date +%Y-%m-%d`

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

	# start backup  
	IFS=$'\n'
	for username in $(echo -e "/root/\n$(ls /home/ | sed -e 's_^_/home/_' -e 's_$_/_')"); do
		echo -e "$cyan[info]$green Backup logs data of $red$username$endc"
		cd $username
		sleep 2

		IFS=$','
		for files in ${log_folder[@]}; do
			if [ "$(ls -A "$files" 2> /dev/null | wc -l)" -gt 0 ]; then
				# simple backup with "cp" in /tmp/ directory
				cp -R "$files" /tmp/backup-logs-$current_date 2> /dev/null
				echo -e "$cyan[+]$green copied: $white$files$endc"
			fi
		done		
	done
	
	# compress backup folder with tar and move backup in /root/backups/ folder
	echo -e "$cyan[info]$green Compress backup with tar, please wait...$endc"
	local tmp_dir='/tmp/'
	cd $tmp_dir
	if [ "$?" = "0" ]; then
		tar -czf backup-logs-$current_date.tar.gz backup-logs-$current_date
		mkdir -p /root/backups
		mv backup-logs-$current_date.tar.gz /root/backups
		sleep 5
	else
	echo -e "$red[!] An error occurred, please check your configuration$endc"
		exit 1
	fi
	
	# encrypt new backup with GPG, AES256
	# gpg -h for more information 
	echo -e "$cyan[info]$green Encrypt backup with GnuPG, cipher AES256$endc"  
	cd /root/backups
	gpg -ca --cipher-algo AES256 backup-logs-$current_date.tar.gz
	sleep 3

	# remove unnecessary backup files
	echo -e "$cyan[info]$green Backup encrypted, remove old backup files$endc"
	rm backup-logs-$current_date.tar.gz
	rm -R /tmp/backup-logs-*
	sleep 3

	echo -e "$cyan[+]$green Backup complete:$white /root/backups/backup-logs-$current_date.tar.gz.asc"
	exit 0
}


# run bleachbit command line interface
function run_bleachbit {
	echo -e "\n$cyan[info]$green Starting bleachbit cleaner$endc"
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

	echo -e "$cyan[+]$green Temporary files are deleted$endc"
}


# delete logs with srm 
function secure_rm {	
	echo -e "$cyan[info]$green Starting secure file deletion with srm, this will take some time...$endc"
	
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
	for username in $(echo -e "/root/\n$(ls /home/ | sed -e 's_^_/home/_' -e 's_$_/_')"); do
		echo -e "$cyan[info]$green Deleting logs of $red$username$endc"
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
				echo -e "$cyan[+]$green deleted: $white$files$endc"
			fi
		done
	done

	# delete dmesg logs
	echo -e "$green Delete kernel messages? [Y/n]: $endc" 
	read -p "> " yn	
	case $yn in
		[yY]|[y|Y] )
			dmesg -C
			sleep 3
			echo -e "$cyan[+]$green dmesg deleted$endc"
			;;
		*)		
			;;	
	esac

	# bleachbit don't delete "/root/.bash_history" file if you don't run
	# from sudo, delete with "history -c" command
	echo -e "$green Delete root bash history? [Y/n]: $endc" 
	read -p "> " yn	
	case $yn in
		[yY]|[y|Y] )
			history -c
			sleep 1
			echo -e "$cyan[+]$green bash history deleted$endc"
			;;
		*)		
			;;	
	esac
}


# emptying the buffers cache (free pagecache, entries and inodes)
function drop_cache {
	echo -e "$cyan[info]$green Drop data from RAM$endc"
	sh -c 'echo 3 >/proc/sys/vm/drop_caches'
	echo -e "$cyan[+]$green RAM empty$endc"
	sleep 5
	printf "\033c"

	echo -e "$cyan[ ok ]$white All logs and files are securely deleted and your System is clean$endc\n"
}


# ask for reboot
function system_reboot {
	echo -e "$green It is recommended to reboot system, reboot now? [Y/n]: $endc" 
	read -p "> " yn	
	case $yn in
		[yY]|[y|Y] )
			reboot
			;;
		*)
		echo -e "$green Exit!$endc"
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
	{ echo -e "$red[!] bleachbit isn't installed, exiting...$endc"; exit 0; }

	command -v srm --help > /dev/null 2>&1 ||
	{ echo -e "$red[!] srm isn't installed, exiting...$endc"; exit 0; }

	run_bleachbit
	secure_rm
	drop_cache
	system_reboot 
}


# display program and srm version then exit
function print_version {
	echo -e "$white $program $version$endc"
	echo -e "$white $(srm -V)$endc"
	exit 0
}


# print help menu'
function help_menu {
	banner
	echo -e "\n$white Usage:$endc\n"
	echo -e "$white┌─╼ $red$USER$white ╺─╸ $red$(hostname)$endc"
	echo -e "$white└───╼ $green$program <argument>$endc\n"

	echo -e "$white Arguments:$endc\n"
	echo -e "$red help    $green show this help message and exit$endc"
	echo -e "$red start   $green start program and delete logs$endc"
	echo -e "$red backup  $green backup data and log folders$endc"
	echo -e "$red version $green display program and srm version$endc"
	exit 0
}


# cases user input
case "$1" in
	start)
		start
		;;
	backup)
		backup_data
		;;
	version)
		print_version
		;;
	help)
		help_menu
		;;
	*)
help_menu
exit 1

esac
