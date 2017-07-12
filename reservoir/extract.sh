#! /bin/bash

# Before running this, download Martin Butzin's ocean modelled values of reservoir age and OxCal (unzip the later one directory above this)
# Download the reservoir age files from Pangaea: doi:10.1594/PANGAEA.876733
# Download OxCal: https://c14.arch.ox.ac.uk/oxcal.html

# According to Martin, using the full upper and lower range for the reservoir correction is overly pessimistic, and might give a range
# that is well over 1000 years. Instead, I am assigning a nominal 1-sigma error of 200 years, which probably should be
# appropriate, and still covers the typical range of modelled reservoir ages at the 3-sigma level in the Arctic

# Though I extract the time series for both the 0-100 m and 200-300 m levels, I only use the 200-300 m level data
# for the final delta_R. This can be changed by editing the code in delta_r.f90
# I cross checked the reservoir ages from the model with preindustrial shells collected in various parts of
# the Arctic (see Coulthard et al 2010 doi:10.1016/j.quageo.2010.03.002), and it matches
# better with the modelled 200-300 m range. This is likely because of the way that the modelled values
# incorporate information from sea ice reconstructions, which greatly increases the reservoir age relative
# to the deeper parts of the water column. If the modelled values are accurate, this likely means
# that the near-shore region where the shells grow is getting water from the deeper part
# of the ocean rather than the surface.

reservoir_error=200

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

# TODO make it read this from a file



latitude=0
longitude=0
longitude360=$(echo ${longitude} | awk '{if ($1 < 0) print 360 + $1; else print $1}')
radiocarbon_age=7185


for range in 0-100 200-300
do

ncfile=MarineReservoirAge_${range}m.nc


extract_max=MRA_max
extract_avg=MRA_avg
extract_min=MRA_min

rm time_series_${range}.txt

for time_count in $( seq 0 100 )
do

time=$(echo "${time_count} * 500" | bc)

grdtrack << END -G${ncfile}?${extract_min}[${time_count}] -T > time_series_temp.txt
${longitude360} ${latitude} ${time}
END

grdtrack time_series_temp.txt -G${ncfile}?${extract_avg}[${time_count}] -T > time_series_temp2.txt

grdtrack time_series_temp2.txt -G${ncfile}?${extract_max}[${time_count}] -T > time_series_temp.txt

cat time_series_temp.txt >> time_series_${range}.txt

done


# the plots were originally just for testing
#plot=plots/time_series_${latitude}N_${longitude}E_${range}.ps

#awk '{print $3, $4}' time_series_${range}.txt | psxy -R0/50000/0/3500 -X4 -Y10 -JX-15/10 -K -P -BWeSn -Bxf5000a10000 -Bx+l"Radiocarbon age" -Byf250a500 -By+l"Reservoir correction" -St0.2 -Gblue  > ${plot}
#awk '{print $3, $5}' time_series_${range}.txt | psxy -R -JX -K -P -O -Ss0.2 -Ggreen >> ${plot}

#awk '{print $3, $6}' time_series_${range}.txt | psxy -R -JX -K -O -P -Si0.2 -Gred >> ${plot}

#psxy << END -R -J -Wthick -O -K >> ${plot}
#50000 ${reservoir_age}
#0 ${reservoir_age}
#END

#pstext << END -R -JX -O -K -P -F+f12p,Helvetica,black,+cTR -D-0.2/-0.2 >> ${plot}
#Measured reservoir age: ${reservoir_age}\261${actual_error}
#END

#pstext << END -R -JX -O -K -P -F+f12p,Helvetica,black,+cTL -D0.2/-0.2 >> ${plot}
#Location: ${latitude}N, ${longitude}E
#END

#pstext << END -R -JX -O  -P -F+f12p,Helvetica,black,+cBR -D-0.2/0.2 >> ${plot}
#Model depth range: ${range} m
#END

done


reservoir_age=$(./delta_r ${radiocarbon_age})


echo ${reservoir_age} ${reservoir_error}
