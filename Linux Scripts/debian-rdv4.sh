#!/bin/bash

rerun_check="${1:-0}"

scriptpath=$(pwd);
script="$scriptpath"
script+="/debian-rdv4.sh"

script=$(echo $script | sed 's/ /\\ /g')

if [ "$rerun_check" -ne "1" ]; then
    #Update apt
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get auto-remove -y
    #Install dependencies
    sudo apt-get install --no-install-recommends git ca-certificates build-essential pkg-config \
    libreadline-dev gcc-arm-none-eabi libnewlib-dev qtbase5-dev \
    libbz2-dev liblz4-dev libbluetooth-dev libpython3-dev libssl-dev libgd-dev

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

    make accessrights

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
