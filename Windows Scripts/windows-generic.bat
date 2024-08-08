@echo off
curl -L -o "ProxSpace.tar.xz" "https://siliconbased.us/pm3/install/ProxSpace/ProxSpace_3.11.tar.xz"
tar -xvf "./ProxSpace.tar.xz"
cd ProxSpace
call runme64.bat -c exit
curl -L -o "pm3/ProxSpaceScript.sh" "https://siliconbased.us/pm3/install/scripts/ProxSpaceScript-generic.sh"
./runme64.bat ./ProxSpaceScript.sh
