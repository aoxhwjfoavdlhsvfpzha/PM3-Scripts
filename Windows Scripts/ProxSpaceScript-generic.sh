ls | grep -i touched
EXIT=$?
sleep .5
if [ "$EXIT" -ne "0" ]; then
	touch touched
	exit
fi
rm touched

git clone https://github.com/RfidResearchGroup/proxmark3.git

cd proxmark3

git pull

cp Makefile.platform.sample Makefile.platform
sed -i '0,/PLATFORM=PM3RDV4/{s/PLATFORM=PM3RDV4/#PLATFORM=PM3RDV4/}' Makefile.platform
sed -i '0,/#PLATFORM=PM3GENERIC/{s/#PLATFORM=PM3GENERIC/PLATFORM=PM3GENERIC/}' Makefile.platform

make clean && make -j

./pm3-flash-all

sleep 3

./pm3
