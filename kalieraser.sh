#!/bin/bash

# Program: kalieraser.sh
# Version: 2.4.0
# Operating System: Kali Linux 2016.2
#
# Description: 
# 
# This program wipe out system's logs and the tools data,
# of Kali Linux OS, files are wiped with Bleachbit (overwrite method) and 
# Secure RM (7 US DoD compliant passes method)
# (for all informations please see the file: README.md)
#
# Dependencies: bleachbit, srm (Secure RM)
# http://bleachbit.sourceforge.net
# http://sourceforge.net/projects/srm/
#
# Copyright (C) 2015, 2016 Brainfuck

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


# program name / version
program="kalieraser"
version="2.4.0"

# define colors
export red=$'\e[0;91m'
export green=$'\e[0;92m'
export white=$'\e[0;97m'
export cyan=$'\e[0;36m'
export endc=$'\e[0m'

# global arrays
# *************
# list logs in /var/log/* directories
declare -a SYSTEM_LOG=(
'/var/log/*.log' '/var/log/*log' '/var/log/*.1' '/var/log/*.old' 
'/var/log/*.gz' '/var/log/apache2/*.log' '/var/log/chkrootkit/*.log' 
'/var/log/clamav/*.log' '/var/log/couchdb/*.log' '/var/log/dradis/*.log' 
'/var/log/exim4/*log' '/var/log/exim4/*.1' '/var/log/gdm3/*.log'
'/var/log/inetsim/*.log' '/var/log/mysql/*.log' '/var/log/ntpstats/*.log'
'/var/log/postgresql/*.log' '/var/log/samba/*.log' '/var/log/speech-dispatcher'
'/var/log/stunnel14/*.log' '/var/log/unattended-upgrades/*.log');

# list tools data in root and users home directory
declare -a TOOL_DATA=(
'/nmap_output/' '/.maltego/*BT/var/cache/*' '/.maltego/*BT/var/log/*'
'/.maltego/*CaseFileCE/var/cache/*' '/.maltego/*CaseFileCE/var/cache/*'
'./chirp/*.log' '*.mtgrx' '/.recon-ng/*' '*.sprt' '/*-tool-output/'
'/.zenmap/*' '/.golismero/*' '/.ZAP/session/*' '/.ZAP/*.log/'
'/paros/session/*' '*skipfish*' '/.sqlmap/output/*' '/.w3af/tmp/*'
'*conversations*' '*fragments*' '*.properties' '*.data' '*.keystore'
'*.pot' '.0trace-*' '/TLSSLed*/' '/.wapiti/*' 'fimap.log' 'hydra.restore'
'/.creepy/*.log/' '.john/sessions/*.log''/.john/*' '/.set/*' '/.msf4/*'
'/.wireshark/*' '/.faraday/logs/*' '/.armitage/*' '/.weevely/*' '/*history/');


# banner, thanks to: http://patorjk.com/
banner () {
printf "${white}
 _       _ _                         
| |_ ___| |_|___ ___ ___ ___ ___ ___ 
| '_| .'| | | -_|  _| .'|_ -| -_|  _|
|_,_|__,|_|_|___|_| |__,|___|___|_|  

    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+    
    |A|n|t|i|-|F|o|r|e|n|s|i|c|s|
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+   

Version: $version
Author: Brainfuck${endc}\n"
}


# check if the program run as a root
check_root () {
	if [[ "$(id -u)" -ne 0 ]]; then
		printf "${red}%s${endc}\n"  "[!] Please run this program as a root!" >&2
		exit 1
	fi
}


# display program and srm version then exit
print_version () {
	printf "${white}%s${endc}\n" "$program $version"
	printf "${white}%s${endc}\n\n" "$(srm -V)"
	printf "${white}%s${endc}\n" "Author: Brainfuck"
	printf "${white}%s${endc}\n" "https://github.com/BrainfuckSec"
	printf "${white}%s${endc}\n" "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>"
	printf "${white}%s${endc}\n" "This is free software: you are free to change and redistribute it."
	printf "${white}%s${endc}\n" "There is NO WARRANTY, to the extent permitted by law."
	exit 0
}


# backup function:
# ****************
# backup log files and folders
backup_data () {
	banner
	check_root
	printf "\n${cyan}%s${endc} ${green}%s${endc}\n" "[ info ]" "Backup log files and folders"

	local current_date
	current_date="$(date +%Y-%m-%d)"

	# create backup folders
	mkdir -pv /tmp/backup-logs-$current_date/var_log
	mkdir -pv /tmp/backup-logs-$current_date/tools_data_root
	sleep 3
	
	# backup root stuff
	printf "${cyan}%s${endc} ${green}%s${endc} ${red}%s${endc}\n" "[ info ]" "Backup files of:" "/root"

	cd /

	IFS=$' '
	for files in ${SYSTEM_LOG[@]}; do
		if [ "$(ls -A "$files" 2> /dev/null | wc -l)" -gt 0 ]; then
			# simple backup with "cp" in /tmp/ directory
			cp -R "$files" /tmp/backup-logs-$current_date/var_log 2> /dev/null
			printf "${cyan}%s${endc} ${green}%s${endc} ${white}%s${endc}\n" "+" "copy:" "$files"
		fi
	done

	IFS=$' '
	for files in ${TOOL_DATA[@]}; do
		if [ "$(ls -A "$files" 2> /dev/null | wc -l)" -gt 0 ]; then
			# simple backup with "cp" in /tmp/ directory
			cp -R "$files" /tmp/backup-logs-$current_date/tools_data_root 2> /dev/null
			printf "${cyan}%s${endc} ${green}%s${endc} ${white}%s${endc}\n" "+" "copy:" "$files"
		fi
	done


	# backup users stuff
	# create backup directory of current user
	mkdir -pv /tmp/backup-logs-$current_date/tools_data_$username
	
	IFS=$'\n'
	for username in $(echo -e "$(ls /home/ | sed -e 's_^_/home/_' -e 's_$_/_')"); do
		printf "${cyan}%s${endc} ${green}%s${endc} ${white}%s${endc}\n" "[ info ]" "Backup files of:" "$username"

		cd $username

		IFS=$' '
		for files in ${TOOL_DATA[@]}; do
			if [ "$(ls -A "$files" 2> /dev/null | wc -l)" -gt 0 ]; then
				# simple backup with "cp" in /tmp/ directory
				cp -R "$files" /tmp/backup-logs-$current_date/tools_data_$username 2> /dev/null
				printf "${cyan}%s${endc} ${green}%s${endc} ${white}%s${endc}\n" "+" "copy:" "$files"
			fi
		done
	done

	# cd to directory --> /tmp, 
	# compress backup folder with tar,
	printf "${cyan}%s${endc} ${green}%s${endc}\n" "[ info ]" "Compress backup with tar, please wait..."
	local tmp_dir
	tmp_dir='/tmp/'
	
	if ! cd $tmp_dir; then
		printf "${red}%s${endc}\n" "[ failed ] An error occurred, please check your configuration"
		exit 1
	fi
	
	tar -czf backup-logs-$current_date.tar.gz backup-logs-$current_date
	
	# create folder for place new backups in /root/ directory
	mkdir -pv /root/backups
	# move backup
	cp -vf backup-logs-$current_date.tar.gz /root/backups
	sleep 5
	
	printf "${cyan}%s${endc} ${green}%s${endc}" "[ info ]" "Remove unnecessary backup files from /tmp directory"
	# execute command "srm -D -R -v <file/folder>"
	# -D, --dod             overwrite with 7 US DoD compliant passes
	# -r, -R, --recursive   remove the contents of directories
	# -v, --verbose         explain what is being done
	srm -D -R backup-logs-*
	printf "${green}%s${endc}\n" " ... Done"
	sleep 3

	# cd to directory --> /root/backups
	# encrypt new backup with GnuPG, cipher: AES256
	# gpg -h for more information
	printf "${cyan}%s${endc} ${green}%s${endc}\n" "[ info ]" "Encrypt backup with GnuPG, cipher AES256"
	cd /root/backups
	gpg -ca --cipher-algo AES256 backup-logs-$current_date.tar.gz
	sleep 3

	# delete unnecessary backup files from /root/backups directory
	# execute command "srm -D -R -v <file/folder>"
	printf "${cyan}%s${endc} ${green}%s${endc}" "[ info ]" "Backup encrypted, remove unnecessary backup files from /root directory"
	srm -D backup-logs-$current_date.tar.gz
	printf "${green}%s${endc}\n" " ... Done"
	sleep 3

	printf "${cyan}%s${endc} ${white}%s${endc}\n" "[ OK ]" "Backup complete:" 
	printf "${cyan}%s${endc} ${white}%s${endc}\n" "path of backup file:" "/root/backups/backups-logs-$current_date.tar.gz.asc"
	exit 0
}


# securely wipe out function (1):
# run bleachbit command line interface
run_bleachbit () {
	printf "\n${cyan}%s${endc} ${green}%s${endc}\n" "[ info ]" "Starting bleachbit cleaner"
	printf "${cyan}%s${endc} ${green}%s${endc}\n" "[ info ]" "if the output give errors, don't worry,"
	printf "${green}%s${endc}\n" "bleachbit simply list the applications not installed :)"
	sleep 5

	bleachbit --overwrite --clean apt.autoremove apt.clean apt.package_lists \
	\ bash.history chromium.cache chromium.cookies chromium.current_session \
	\ chromium.dom chromium.form_history chromium.history chromium.passwords \
	\ chromium.search_engines chromium.vacuum elinks.history filezilla.mru \
	\ firefox.cache firefox.cookies firefox.crash_reports firefox.dom \
	\ firefox.download_history firefox.forms firefox.passwords \
	\ firefox.session_restore firefox.site_preferences firefox.url_history \
	\ firefox.vacuum flash.cache flash.cookies gedit.recent_documents gimp.tmp \
	\ grome.run gnome.search_history google_chrome.cache google_chrome.cookies \
	\ google_chrome.dom google_chrome.form_history google_chrome.history \
	\ google_chrome.passwords google_chrome.search_engines google_chrome.session \ 
	\ google_chrome.vacuum google_earth.temporary_files google_toolbar.search_history \
	\ java.cache kde.cache kde.recent_documents kde.tmp libreoffice.cache \
	\ libreoffice.history liferea.cache liferea.cookies liferea.vacuum \
	\ links2.history nautilus.history openofficeorg.cache \
	\ openofficeorg.recent_documents opera.cache opera.cookies opera.current_session \
	\ opera.dom opera.download_history opera.passwords opera.search_history \
	\ opera.url_history pidgin.cache pidgin.logs rhythmbox.cache rhythmbox.history \
	\ screenlets.logs skype.chat_logs skype.installers sqlite3.history system.cache \
	\ system.clipboard system.desktop_entry system.localizations \
	\ system.recent_documents system.rotated_logs system.tmp system.trash \
	\ thumbnails.cache thunderbird.cache thunderbird.cookies thunderbird.passwords \
	\ thunderbird.vacuum transmission.blocklists transmission.history \ 
	\ transmission.torrents vim.history vlc.mru wine.tmp x11.debug_logs xchat.logs
	sleep 1
	# real terminal clear 
	printf "\033c"

	printf "${cyan}%s${endc} ${green}%s${endc}\n" "[ OK ]" "Temporary files deleted"
}


# securely wipe out function (2):
# wipe logs with srm
run_securerm () {
	printf "${cyan}%s${endc} ${green}%s${endc}\n" "[ info ]" "Starting secure file deletion with srm, this will take some time..."

	# delete root stuff
	printf "${cyan}%s${endc} ${green}%s${endc} ${red}%s${endc}\n" "[ info ]" "Deleting logs of:" "/root"

	cd /

	IFS=$' '
	for files in ${SYSTEM_LOG[@]}; do
		if [ "$(ls -A "$files" 2> /dev/null | wc -l)" -gt 0 ]; then
			# execute command "srm -i -D -R <file/folder>"
			# -i, --interactive     prompt before any removal
			# -D, --dod             overwrite with 7 US DoD compliant passes
			# -r, -R, --recursive   remove the contents of directories
			srm -i -D -R "$files" 2> /dev/null
		fi
	done

	IFS=$' '
	for files in ${TOOL_DATA[@]}; do
		if [ "$(ls -A "$files" 2> /dev/null | wc -l)" -gt 0 ]; then
			# execute command "srm -i -D -R <file/folder>"
			# -i, --interactive     prompt before any removal
			# -D, --dod             overwrite with 7 US DoD compliant passes
			# -r, -R, --recursive   remove the contents of directories
			srm -i -D -R "$files" 2> /dev/null
		fi
	done

	# delete users stuff
	IFS=$'\n'
	for username in $(echo -e "$(ls /home/ | sed -e 's_^_/home/_' -e 's_$_/_')"); do
		printf "${cyan}%s${endc} ${green}%s${endc} ${white}%s${endc}\n" "[ info ]" "Deletings log of:" "$username"

		cd $username

		IFS=$' '
		for files in ${TOOL_DATA[@]}; do
			if [ "$(ls -A "$files" 2> /dev/null | wc -l)" -gt 0 ]; then
				# execute command "srm -i -D -R <file/folder>"
				# -i, --interactive     prompt before any removal
				# -D, --dod             overwrite with 7 US DoD compliant passes
				# -r, -R, --recursive   remove the contents of directories
				srm -i -D -R "$files" 2> /dev/null
			fi
		done
	done

	# if one application don't recreate log files, the application may not work correctly
	# empties the contents of this files with "truncate -s 0 <filename>"
	# https://unix.stackexchange.com/questions/88808/empty-the-contents-of-a-file
	# http://man7.org/linux/man-pages/man1/truncate.1.html
	printf "${cyan}%s${endc} ${green}%s${endc}\n" "[ info ]" "Empties critical log files with 'truncate' command"
	declare -a truncate_file=(
	'/var/log/apt/history.log' '/var/log/apt/term.log' '/var/log/debug'
	'/var/log/fsck/checkfs' '/var/log/fsck/checkroot' '/var/log/wtmp');

	for files in ${truncate_file[@]}; do
		truncate -s 0 "$files" 2> /dev/null
	done
	printf "${cyan}%s${endc} ${green}%s${endc}\n" "-" "critical log files empty"

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
drop_cache () {
	printf "${cyan}%s${endc} ${green}%s${endc}\n" "[ info ]" "Drop data from RAM"
	sh -c 'echo 3 >/proc/sys/vm/drop_caches'
	printf "${cyan}%s${endc} ${green}%s${endc}\n" "-" "RAM empty"
	sleep 5
	printf "\033c"

	printf "${cyan}%s${endc} ${white}%s${endc}\n" "[ OK ]" "All logs and files are securely deleted and your System is clean"
}


# ask for reboot
system_reboot () {
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


# start program
start_program () {
	banner
	check_root

	# check if dependencies are installed
	# bleachbit, srm
	command -v bleachbit -h > /dev/null 2>&1 ||
	{ printf >&2 "\n${red}%s${endc}\n" "[!] bleachbit isn't installed, exiting..."; exit 1; }

	command -v srm --help > /dev/null 2>&1 ||
	{ printf >&2 "\n${red}%s${endc}\n" "[!] srm isn't installed, exiting..."; exit 1; }

	run_bleachbit
	run_securerm
	drop_cache
	system_reboot
}


# print help menu'
help_menu () {
	banner
	
	printf "\n${white}%s${endc}\n" "Usage:"
	printf "${white}%s${endc}\n\n"     "******"
	printf "${white}%s${endc}${red}%s${endc}${white}%s${endc}${red}%s${endc}\n" "┌─" "[$USER]" "@" "[$(hostname)]"
	printf "${white}%s${endc}${red}%s${endc} ${green}%s${endc}\n" "└─" "▶" "./$program --argument"

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
		start_program
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
