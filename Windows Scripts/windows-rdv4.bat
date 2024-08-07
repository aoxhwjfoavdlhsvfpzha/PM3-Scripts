@echo off
curl -LO "https://github.com/Gator96100/ProxSpace/releases/download/v3.11/ProxSpace.7z"
tar -xvf "./ProxSpace.7z"
cd ProxSpace
call runme64.bat -c exit
curl -L -o "/pm3/ProxSpaceScript.sh" "https://siliconbased.us/pm3/install/scripts/ProxSpaceScript-rdv4.sh"
./runme64.bat ./ProxSpaceScript.sh
