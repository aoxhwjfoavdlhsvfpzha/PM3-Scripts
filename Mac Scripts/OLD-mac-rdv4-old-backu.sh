#!/bin/bash

rerun_check="${1:-0}"

scriptpath=$(pwd);
script="$scriptpath"
script+="/mac-rdv4.sh"

script=$(echo $script | sed 's/ /\\ /g')

if [ "$rerun_check" -ne "1" ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    brew install readline qt5 pkgconfig coreutils
    brew install RfidResearchGroup/proxmark3/arm-none-eabi-gcc
    brew install recode
    brew install astyle
    brew install gnu-sed
    brew install openssl

    #Get and enter repo:
    git clone https://github.com/RfidResearchGroup/proxmark3.git ~/proxmark3
    cd ~/proxmark3
    git pull

    #Check PM3 Connection:
    lsusb | grep -i proxmark
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
