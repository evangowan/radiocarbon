#! /bin/bash

for range in 0-100 200-300
do
	ncfile=MarineReservoirAge_${range}m.nc

	if [ ! -e "${ncfile}" ]
	then

		echo "You must download the marine reservoir age files before running this script!"
		echo "missing: ${ncfile}"
		exit 0
	fi

done

if [ ! -e "marine13.14c" ]
then

	cp ../OxCal/bin/marine13.14c .
fi

if [ ! -e "intcal13.14c" ]
then

	cp ../OxCal/bin/intcal13.14c .
fi

if [ ! -e "plots" ]
then
	mkdir plots
fi


if [ ! -e "delta_r" ]
then
	make delta_r
fi
