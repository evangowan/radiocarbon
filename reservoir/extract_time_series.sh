#! /bin/bash

# assumes that the latitude, longitude and radiocarbon_age values are taken from the script that sources this file

longitude360=$(echo ${longitude} | awk '{if ($1 < 0) print 360 + $1; else print $1}')

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
