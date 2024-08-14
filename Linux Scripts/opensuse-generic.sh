#!/bin/bash

rerun_check="${1:-0}"

scriptpath=$(pwd);
script="$scriptpath"
script+="/opensuse-generic.sh"

script=$(echo $script | sed 's/ /\\ /g')

if [ "$rerun_check" -ne "1" ]; then
    #Update apt
    sudo zypper install git patterns-devel-base-devel_basis gcc-c++ \
    readline-devel libbz2-devel liblz4-devel cross-arm-none-gcc12 \
    cross-arm-none-newlib-devel python3-devel libqt5-qtbase-devel \
    libopenssl-devel gd-devel

    #Get and enter repo:
    git clone https://github.com/RfidResearchGroup/proxmark3.git ~/proxmark3
    cd ~/proxmark3
    git pull

    #Check PM3 Connection:
    lsusb | grep -i proxmark
    EXIT=$?
    if [ "$EXIT" -ne "0" ]; then
        echo "Wizard couldn't detect PM3, if it isn't connected the script will fail!"
        read -p "Continue? Y/n:" PM3_detect_conf
        if [ "$PM3_detect_conf" == "" ]; then
            PM3_detect_conf="y"
        fi
        if [[ "$PM3_detect_conf" != "y" ]] && [[ "$PM3_detect_conf" != "Y" ]]; then
            exit 1
        fi
    fi

    alias "adduser"=useradd

    #make accessrights
    sudo groupadd bluetooth
    sudo groupadd dialout
    sudo usermod -aG bluetooth "$USER"
    sudo usermod -aG dialout "$USER"

    #log into new instance for permissions to take hold
    sudo -u $USER "$script" 1
    exit 0
fi

cd ~/proxmark3


[ -r /dev/ttyACM0 ] && [ -w /dev/ttyACM0 ] && echo ok | grep -i ok
EXIT=$?
if [ "$EXIT" -ne "0" ]; then
    echo "Error making accessrights! Aborting!"
    echo "Is the PM3 plugged in?"
    exit 2
fi

cp Makefile.platform.sample Makefile.platform
sed -i '0,/PLATFORM=PM3RDV4/{s/PLATFORM=PM3RDV4/#PLATFORM=PM3RDV4/}' Makefile.platform
sed -i '0,/#PLATFORM=PM3GENERIC/{s/#PLATFORM=PM3GENERIC/PLATFORM=PM3GENERIC/}' Makefile.platform

#build it
make clean && make -j
#Install if desired
sudo make install

#Flash PM3 if desired
./pm3-flash-all

sleep 3

#start client:
./pm3
exit 0
