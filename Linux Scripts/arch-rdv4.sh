#!/bin/bash

rerun_check="${1:-0}"

scriptpath=$(pwd);
script="$scriptpath"
script+="/arch-rdv4.sh"
spaces=$script
script=$(echo $script | sed 's/ /\\ /g')

if [ "$rerun_check" -ne "1" ]; then
    #Update apt
    sudo pacman -Syu git base-devel readline bzip2 lz4 arm-none-eabi-gcc \
    arm-none-eabi-newlib qt5-base bluez python gd usbutils --needed

    #Get and enter repo:
    git clone https://github.com/RfidResearchGroup/proxmark3.git ~/proxmark3
    cd ~/proxmark3
    git pull

    make accessrights

    #log into new instance for permissions to take hold
    sudo -u $USER "$spaces" 1
    exit 0
fi

cd ~/proxmark3

sudo sed -i 's/explicit QFutureInterface<void>(State initialState = NoState)/explicit QFutureInterface(State initialState = NoState)/' /usr/include/qt/QtCore/qfutureinterface.h

#build it
make clean && make -j
#Install if desired
sudo make install

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

#Check Access:
[ -r /dev/ttyACM0 ] && [ -w /dev/ttyACM0 ] && echo ok | grep -i ok
EXIT=$?
if [ "$EXIT" -ne "0" ]; then
    echo "Error making accessrights! Aborting!"
    echo "Is the PM3 plugged in?"
    exit 2
fi

#Flash PM3 if desired
./pm3-flash-all

sleep 3

#start client:
./pm3
exit 0
