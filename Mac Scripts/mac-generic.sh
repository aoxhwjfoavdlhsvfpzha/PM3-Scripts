#!/bin/bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install readline qt5 pkgconfig coreutils
brew install RfidResearchGroup/proxmark3/arm-none-eabi-gcc
brew install recode
brew install astyle
brew install gnu-sed

#Get and enter repo:
git clone https://github.com/RfidResearchGroup/proxmark3.git ~/proxmark3
cd ~/proxmark3
git pull

cd ~/proxmark3

cp Makefile.platform.sample Makefile.platform
gsed -i '0,/PLATFORM=PM3RDV4/{s/PLATFORM=PM3RDV4/#PLATFORM=PM3RDV4/}' Makefile.platform
gsed -i '0,/#PLATFORM=PM3GENERIC/{s/#PLATFORM=PM3GENERIC/PLATFORM=PM3GENERIC/}' Makefile.platform

#build it
make clean && make -j8
#Install if desired
sudo make install

#Check PM3 Connection:
sudo dmesg | grep -i proxmark
EXIT=$?
if [ "$EXIT" -ne "0" ]; then
    echo "Wizard couldn't detect PM3, if it isn't connected it won't be flashed!"
    read -p "Continue? Y/n:" PM3_detect_conf
    if [ "$PM3_detect_conf" == "" ]; then
        PM3_detect_conf="y"
    fi
    if [[ "$PM3_detect_conf" != "y" ]] && [[ "$PM3_detect_conf" != "Y" ]]; then
        exit 1
    fi
fi

#Flash PM3 if desired
./pm3-flash-all

sleep 3

#start client:
./pm3
exit 0
