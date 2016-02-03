#!/bin/bash

##############################################################
#							       							   						           	  
#  Script: kalieraser.sh                                       
#  							       							   						           	
#  Version: 1.1 [11-8-2015] 						           
# 															   
#  Dev: Brainfuck - N4d4              		                   	           
#  							       							   						           	
#  Descr: Antiforensics Script for Debian Kali Linux           
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


function init_bleachbit {
	# Make sure only root can run this script
	if [ $(id -u) -ne 0 ]; then
	echo -e "\n$GREEN[$RED!$GREEN] $RED What are you doing? This script must be run as root$RESETCOLOR\n" >&2
	exit 1
	fi
	
	# Check dependencies
	command -v bleachbit >/dev/null 2>&1 || { echo -e "\n$GREEN[$RED!$GREEN]$RED Bleachbit isn't installed$RESETCOLOR"; exit 0; }
	command -v srm >/dev/null 2>&1 || { echo -e "\n$GREEN[$RED!$GREEN]$RED srm isn't installed$RESETCOLOR"; exit 0; }
	
cat << "EOF"	
   __ __     ___                         
  / //_/__ _/ (_)__ _______ ____ ___ ____
 / ,< / _ `/ / / -_) __/ _ `(_-</ -_) __/
/_/|_|\_,_/_/_/\__/_/  \_,_/___/\__/_/     	
										  V1.1       
EOF
													
	echo -e ""
	echo -e "$CYAN[info]$GREEN Starting Bleachbit cleaner$RESETCOLOR\n"
	sleep 2
	
	# bleachbit command line interface 
	bleachbit -c apt.autoclean apt.autoremove apt.clean bash.history chromium.cache \
	\ chromium.cookies chromium.current_session chromium.dom chromium.form_history \
	\ chromium.history chromium.vacuum firefox.cache firefox.cookies firefox.dom \
	\ firefox.download_history firefox.forms firefox.passwords firefox.session_restore \
	\ firefox.site_preferences firefox.url_history firefox.vacuum flash.cache flash.cookies \
	\ gedit.recent_documents gimp.tmp gnome.run gnome.search_history java.cache \
	\ libreoffice.cache libreoffice.history nautilus.history system.cache system.clipboard \
	\ system.desktop_entry system.free_disk_space system.localizations system.memory \
	\ system.recent_documents system.tmp system.trash vlc.history wine.tmp xchat.logs 2>/dev/null
	sleep 1
	
	clear 
	
	echo -e "$CYAN[*]$GREEN Done, Please Wait...$RESETCOLOR\n"
	sleep 2
	
}

init_bleachbit


function securerm {
	
	# Directory list -- you can insert here your own folder 
	declare -a evil_Path=('hydra.restore','/.inguma/*','/.ginguma/*','/.john/*','/.maltego/*',
	'/.mitmproxy/*','/.recon-ng/*','/.set/*','/.msf4/*','/.sqlmap/output/*','/.w3af/*',
	'/.wireshark/*','/.ZAP/session/*','/.zenmap/*','/usr/share/vega/workspace/*','/var/log/*log',
	'/var/log/*.1','/var/log/*.gz','/var/log/*.old','/var/log/*.err/','/var/log/dradis/*',
	'/var/log/messages','var/log/mysql/*.log','/var/log/mysql/*.gz','/var/log/openvas/*.log',
	'/var/log/openvas/*.gz','/var/log/openvas/*.dump','/var/log/openvas/*.messages',
	'/var/log/postgresql/*.log','/var/log/wmtp',);

	echo -e "$CYAN[info]$GREEN Starting secure file deletion with srm$RESETCOLOR\n"
    sleep 2	
    
    
    # Delete root and users logs 
    IFS=$'\n'
	for username in `echo -e "/root/\n$(ls /home/ | sed -e 's_^_/home/_' -e 's_$_/_')"`;do 
		echo -e "$CYAN[*]$GREEN Deleting users logs $RED$username $RESETCOLOR\n";
		cd $username
		sleep 2

		IFS=$','
		for i in ${evil_Path[@]}; do
			if [ "$(ls -A "$i" 2>/dev/null | wc -l)" -gt 0 ]; then
				# command srm -D --dod --> overwrite with 7 US DoD compliant passes				
				srm -D -R "$i" 2>/dev/null
				echo -e "$CYAN[*]$GREEN Logs Deleted $i $RESETCOLOR";
			fi
		done	    
	done
	
	# dmesg and root bash_history
	dmesg -C
	history -c

	# Drop data from RAM Memory  
	echo 3 > /proc/sys/vm/drop_caches 
	
	clear
	
	echo -e "$CYAN[ ok ]$GREEN All the logs are secure deleted and System is clean$RESETCOLOR\n"
}

securerm 

echo -e "\n$GREEN Stay safe and Reboot system now? [Y/n]: $RESETCOLOR" 
read -e yno 
case $yno in
	[yY]|[y|Y] )
		reboot
		;;
	*)
		exit 1
		;;
esac
