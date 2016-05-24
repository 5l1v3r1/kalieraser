### Kalieraser 

##### Written by: Brainfuck
##### Version: 2.1 - 23/05/2016
##### Antiforensics script for security and privacy
##### Operative System: Kali Linux 
##### Description: This program erase all system's logs and data of kali tools, the files are wiped with Bleachbit (overwrite method) and Secure RM (7 US DoD compliant passes method).




#### Instructions


##### 1 - Install Bleachbit
```
apt-get install bleachbit 
```



##### 2 - Install srm 

##### Secure RM is already present in the program folder, but if you are paranoid you can install srm from here: http://sourceforge.net/projects/srm/files/. The version of srm in this repository is the latest and when the new version are released the git repository will be updated.


##### Extract and install: 
```
tar -zxvf srm-1.2.15.tar.gz

cd srm-1.2.15/

./configure

make

sudo make install
```

##### Copy the executable file in /usr/bin directory:
```
cd src/

sudo chmod +x srm

sudo cp srm /usr/bin
```


##### 3 - Start the script from root  

##### Chmod and start cleaner:
```
chmod +x kalieraser.sh

./kalieraser.sh start 
```


##### Print help menu 
```
./kalieraser.sh help
```


#### Note for the users:

##### [!] This is not a "magic security tool" and does not absolutely guarantee that data on the drive cannot be recovered, but it goes a long way in making it difficult.

#####  I could not insert some tools in the list because it was impossible for me to test all (i.e. the cisco tools and more).


##### References:

######  Bleachbit documentation: http://bleachbit.sourceforge.net/

######  Secure RM documentation: http://srm.sourceforge.net/

######  About secure wiping of media: http://www.destructdata.com/dod-standard/, https://en.wikipedia.org/wiki/Data_erasure

