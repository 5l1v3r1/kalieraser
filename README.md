## Kalieraser v2.4.0
 
#### Anti-Forensics for security and privacy
#### Operating System: Kali Linux 2016.2
#### Description: This program wipe out system's logs and the tools data of Kali Linux OS. Files are wiped with Bleachbit (overwrite method) and Secure RM (7 US DoD compliant passes method).


**What is Bleachbit ?**
BleachBit is a free and open-source disk space cleaner, privacy manager, and computer system optimize, for more information, please read the official website: https://www.bleachbit.org/


**What is srm (Secure RM)?**
srm is a secure replacement for rm. Unlike the standard rm, it overwrites the data in the target files before unlinking them, for more information, please read the Manual Page: http://srm.sourceforge.net/srm.html 


### Configuration

#### Install dependencies:

**Install Bleachbit**
```bash
sudo apt-get update 
sudo apt-get install -y bleachbit 
```

**Install srm** 
```bash
tar -zxvf srm-1.2.15.tar.gz

cd srm-1.2.15/

./configure

make

sudo make install
```

Now, the executable of srm is installed in /usr/local/bin directory, for invoke it alone, type:
```bash
srm --help
```




### Start program

#### Give permission to executable from root:
```bash
chmod +x kalieraser.sh
```


#### Use --help argument or run the program without arguments for help menu':
```bash
./kalieraser.sh --help
```


#### Use --backup argument for backup your files before wiping if you want:
```bash
./kalieraser.sh --backup
```


#### Start program with --start argument for wipe out:
```bash
./kalieraser --start 
```


#### Note:
[ ! ] This is not a "magic security tool" and does not absolutely guarantee that data on the drive cannot be recovered, but it goes a long way in making it difficult.

[ ! ] The program procedure is irreversible, before start wiping, you can use the "backup" function.

[ ! ] This program is for Kali Linux OS only, do not use it in other operating systems.

I could not insert some tools in list because it was impossible for me to test all (i.e. the cisco tools and others), but you can see updates for new implementations or fork/pull request this repository.


#### About secure wiping of media: 

http://www.destructdata.com/dod-standard/

https://en.wikipedia.org/wiki/Data_erasure

https://en.wikipedia.org/wiki/Data_remanence
