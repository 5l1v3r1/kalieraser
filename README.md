### Kalieraser v2.0 

##### Written by: Brainfuck
##### Version: 2.0 - 19/02/2016
##### Antiforensics script for security and privacy
##### Operative System: Kali Linux 
##### Descr: This tool erase all the system's logs and data of tools in the list, these files are wiped with Bleachbit (overwrite method) and Secure RM (7 US DoD compliant passes method).




#### Instructions


##### 1 - Install Bleachbit
```
apt-get install bleachbit 
```



##### 2 - Install srm 

##### Secure RM is already present in the program folder, you can check the latest version here: http://sourceforge.net/projects/srm/files/, anyway when the new version of srm are released, the git repository will be updated.


##### Extract and install: 
```
tar -zxvf srm-1.2.15.tar.gz

cd srm-1.2.15/

./configure

make

make install
```

##### Copy the executable file in /usr/bin directory:
```
cd src/

chmod +x srm

cp srm /usr/bin
```



##### 3 - Start the script  

##### Chmod and start cleaner:
```
chmod +x kalieraser.sh

./kalieraser.sh start 
```

##### Print list of supported tools 
```
./kalieraser.sh list 
```



#### Note for the users:

##### [!] Please make sure you don't need the logs before run the script, this is not a "magic security tool" and does not absolutely guarantee that data on the drive cannot be recovered, but it goes a long way in making it difficult.

#####  I could not test some tools because it was impossible for me (i.e. the cisco tools).


##### References:

######  Bleachbit documentation: http://bleachbit.sourceforge.net/

######  Secure RM documentation: http://srm.sourceforge.net/

######  About secure wiping of media: http://www.destructdata.com/dod-standard/, https://en.wikipedia.org/wiki/Data_erasure

