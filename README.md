### Kalieraser v1.1  

### Antiforensics script for security and privacy by Brainfuck & N4d4




#### Install instructions


##### 1 - Install Bleachbit
```bash
apt-get install bleachbit 
```
###### if you don't know how bleachbit work you can read the documentation here: http://bleachbit.sourceforge.net/




##### 2 - Install srm 

###### Secure RM is already present in the program folder, you can check the last version here: http://sourceforge.net/projects/srm/files/1.2.15/

##### Extract and install: 
```bash
tar -zxvf srm-1.2.15.tar.gz

cd srm-1.2.15/

./configure

make

make install
```

##### Copy the executable file in /usr/bin directory:
```bash
cd src/

chmod +x srm

cp srm /usr/bin
```

##### 3 - Start the script  

##### Give permits to .sh file and start cleaner:
```bash
chmod +x kalieraser.sh

./kalieraser.sh 
```

##### I Really say thanks to my friend N4d4 for his precious advice in the bash scripting 
