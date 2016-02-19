#!/bin/bash

##############################################################
#							       							   						           	  
#  Script: kalieraser.sh                                       
#  							       							   						           	
#  Version: 2.0 - 19/02/2016						           
# 															   
#  Dev: Brainfuck               		                   	           
#  							       							   						           	
#  Descr: Antiforensics script for security and privacy 
#  
#  Operative System: Kali Linux       
#     							                               					  		   	
#  Dependencies: Bleachbit > http://bleachbit.sourceforge.net/					  
#                                                                  
#  Secure RM > http://sourceforge.net/projects/srm/ 	       											          
#                                                              
##############################################################


# Define Colors
export GREEN='\033[1;92m'
export RED='\033[1;91m'
export WHITE='\033[1;97m'
export CYAN='\033[1;96m'
export RESETCOLOR='\033[1;00m'


# banner
function banner {
cat << "EOF"
   __ __     ___                         
  / //_/__ _/ (_)__ _______ ____ ___ ____
 / ,< / _ `/ / / -_) __/ _ `(_-</ -_) __/
/_/|_|\_,_/_/_/\__/_/  \_,_/___/\__/_/     	
								
Version: 2.0
Dev: Brainfuck  
EOF
}


# checkroot
function checkroot {
	if [ "$(id -u)" -ne 0 ]; 
	then
		echo -e "\n$RED[!] Please run this script as a root!$RESETCOLOR\n" >&2
		exit 1
	fi
}


# bleachbit command line interface 
function runbleachbit {
	echo -e "\n$CYAN[info] $GREEN Starting Bleachbit cleaner$RESETCOLOR\n"
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
	clear
	
	echo -e ""
	echo -e "$CYAN[+]$GREEN Temporary files are deleted$RESETCOLOR"
}


# delete logs with srm 
function securerm {
	# array for tools and logs folders 
	declare -a logfolder=('/nmap_output/' '/.maltego/*BT/var/cache/*' 
	'/.maltego/*BT/var/log/*' '/.maltego/*CaseFileCE/var/cache/*' 
	'/.maltego/*CaseFileCE/var/cache/*' '*.mtgrx' '/.recon-ng/*' '*.sprt' 
	'/*-tool-output/' '/.zenmap/*' '/.golismero/*' '/.ZAP/session/*' '/.ZAP/*.log/' 
	'/paros/session/*' '*skipfish*' '/.sqlmap/output/*' '/.w3af/tmp/*' '*conversations*' 
	'*fragments*' '*.properties' '*.data' '*.keystore' '*.pot' '.0trace-*' '/TLSSLed*/' 
	'/.wapiti/*' 'fimap.log' 'hydra.restore' '/.creepy/*.log/' '.john/sessions/*.log'
	'/.john/*' '/.set/*' '/.msf4/*' '/.wireshark/*' '/.faraday/logs/*' '/.armitage/*'
	'/.weevely/*' '/var/log/dradis/*' '/var/log/openvas/*.log' '/var/log/openvas/*.gz' 
	'/var/log/openvas/*.dump' '/var/log/openvas/*.messages' '/var/log/*log' 
	'/var/log/*.1' '/var/log/*.gz' '/var/log/*.old' '/var/log/*.err/' 
	'/var/log/messages' 'var/log/mysql/*.log' '/var/log/mysql/*.gz' 
	'/var/log/postgresql/*.log' '/var/log/wmtp' '/var/log/*.dat');
	 
	echo -e "\n$CYAN[info] $GREEN Starting secure file deletion with srm, this will take some time $RESETCOLOR\n"
	sleep 2
	
	# root and user logs 
	IFS=$'\n'
	for username in `echo -e "/root/\n$(ls /home/ | sed -e 's_^_/home/_' -e 's_$_/_')"`; 
	do
		echo -e "$CYAN[info] $GREEN Deleting logs of $WHITE$username $RESETCOLOR\n"
		cd $username
		sleep 2
		
		IFS=$','
		for i in ${logfolder[@]}; 
		do
			if [ "$(ls -A "$i" 2>/dev/null | wc -l)" -gt 0 ]; 
			then
				# command srm -D --dod --> overwrite with 7 US DoD compliant passes
				srm -D -R "$i" 2>/dev/null
				echo -e "$CYAN[+] $GREEN deleted: $WHITE $i $RESETCOLOR"
			fi
		done
	done
}


# delete the last crumbs on system  
function lastcrumbs {
	# bleachbit don't remove root bash_history if you don't run command from sudo
	# deleting for you with this function 
	echo -e ""
	echo -e "$CYAN[info] $GREEN Deleting dmesg and bash_history $RESETCOLOR\n"	
	dmesg -C
	history -c
	
	# drop data from RAM 
	echo -e "$CYAN[info] $GREEN Drop data from RAM $RESETCOLOR"
	echo 3 > /proc/sys/vm/drop_caches
	sleep 3
	clear
	
	echo -e "$CYAN[ ok ] $WHITE All the logs are secure deleted and System is clean$RESETCOLOR\n"			
}


# print list of supported tools
function list {
	declare -a tools=('0trace' 'armitage' 'burpsuite' 'casefile' 'creepy' 'dradis'
	'faraday' 'fimap' 'golismero''hashcat' 'hydra' 'hydra-gtk' 'lynis' 'maltego'
	'metasploit' 'nmap' 'openvas' 'owasp-zap' 'p0f' 'paros''recon-ng' 'se-toolkit' 
	'skipfish' 'sparta' 'sqlmap' 'ssldump' 'tlssled' 'unicornscan' 'uniscan' 
	'uniscan-gui' 'w3af' 'wapiti' 'webscarab' 'weevely' 'wireshark' 'zenmap')
	
	banner
	echo -e "\n$WHITE List of supported tools $RESETCOLOR\n"
	printf '%s\n' "${tools[@]}" | more
	exit 1 
}


# reboot system
function systemreboot {
	echo -e "\n$GREEN Stay safe and reboot system now? [Y/n]: $RESETCOLOR" 
	read -e yno 
	case $yno in
		[yY]|[y|Y] )
			reboot
			;;
		*)
		echo -e "\n$GREEN Exit ! $RESETCOLOR"
			exit 1
			;;				
	esac
}


# start as main function
function start {
	banner 
	checkroot
	
	# check if dependencies are installed
	command -v bleachbit > /dev/null 2>&1 || 
	{ echo -e "\n$RED [!] bleachbit isn't installed, exiting...$RESETCOLOR"; exit 0; }
	command -v srm --help >/dev/null 2>&1 || 
	{ echo -e "\n$RED [!] srm isn't installed, exiting...$RESETCOLOR"; exit 0; }
	
	runbleachbit
	securerm 
	lastcrumbs
	systemreboot 
}


# simple start and list options 
case "$1" in
	start)
		start
	;;
	list)
		list
	;;
   *)	

# usage 
banner 
echo -e "\n$WHITE Usage:

╭─[$RED$USER$WHITE]─[$RED`hostname`$WHITE]
╰──> $GREEN""./kalieraser.sh $WHITE[$GREEN""start$WHITE | $GREEN""list$WHITE""]

$WHITE start$GREEN --> Start the program 

$WHITE list$GREEN  --> List the supported tools 

$RESETCOLOR" >&2
exit 1
;;
esac
