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

make clean && make -j

./pm3-flash-all

sleep 3

./pm3
