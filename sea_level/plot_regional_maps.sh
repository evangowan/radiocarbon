#! /bin/bash


if [ ! -e "plots" ]
then
	mkdir plots
fi

folder_regions="plots/regional_maps"

if [ ! -e "${folder_regions}" ]
then
	mkdir ${folder_regions}
fi




sea_level_file="data/sea_level_indicators.txt"



# For Lambert azimuthal projection. These parameters cover the entire range of places where North American ice sheets covered

center_longitude=-94
center_latitude=60
width=10 # in cm


xshift=5
yshift=8

# corners for the inset map
small_west_latitude=25
small_west_longitude=-135
small_east_latitude=58
small_east_longitude=3



for regions in $(cat region_list)
do

	source regions/${regions}.sh

	plot=${folder_regions}/plot_${regions}.ps

	plot2=${folder_sl}/plot_${regions}_data.ps





#	psbasemap  -Ba:/a:wens --MAP_TICK_LENGTH_PRIMARY=-.0c -V -P -K  > $plot
	pscoast -X${xshift} -Y${yshift} -R${bottom_long}/${bottom_lat}/${top_long}/${top_lat}r -JA${center_longitude}/${center_latitude}/${width}c   -Df   -P -A100 -Wthinner -Slightgrey -K > ${plot}



	awk -F'\t' -v regions=${regions} '{if ($1 == regions && $5 != "" && $6 == "" ) {print $4, $3}}' ${sea_level_file} >  data_to_plot.txt

	psxy data_to_plot.txt  -Gblue  -P -K -O -J -R -St0.35 -Wblack >> ${plot}


	awk -F'\t'  -v regions=${regions} '{if ($1 == regions && $5 == "" && $6 != "" ) {print $4, $3}}' ${sea_level_file} >  data_to_plot.txt

	psxy data_to_plot.txt  -Gred  -P -K -O -J -R -Si0.35 -Wblack >> ${plot}


	awk -F'\t' -v regions=${regions} '{if ($1 == regions && $5 != "" && $6 != "" ) {print $4, $3}}' ${sea_level_file} >  data_to_plot.txt

	psxy data_to_plot.txt  -Ggreen  -P -K -O -J -R -Sc0.35 -Wblack >> ${plot}


	psbasemap  -R${bottom_long}/${bottom_lat}/${top_long}/${top_lat}r -JA${center_longitude}/${center_latitude}/${width}c -Bafg  --MAP_TICK_LENGTH_PRIMARY=-.0c -P -K -O  -Lf${scale_bar_long}/${scale_bar_lat}/${scale_bar_reference_lat}/${scale_bar_width}k+l"km"+jr -F+gwhite --FONT_ANNOT_PRIMARY=10p --FONT_ANNOT_SECONDARY=10p --FONT_LABEL=10p >> ${plot}



#	psbasemap  -V -P -O -K     >> ${plot}
#-Ba:/a:wens+gwhite
	pscoast -X${x_corner} -Y${y_corner} -R${small_west_longitude}/${small_west_latitude}/${small_east_longitude}/${small_east_latitude}r -JA${center_longitude}/${center_latitude}/2.5c   -K -O -Dl -Na -Slightgrey -P -A5000 -Wthinner  --MAP_FRAME_PEN=1p --MAP_TICK_LENGTH_PRIMARY=-.0c -Bwens+gwhite  -B20p >> $plot #  -B20p is needed or else no map outline is drawn 

	psxy << end -Gyellow   -P -K -O -J -R -Ss0.35 -Wblack    >> ${plot}
${center_long} ${center_lat}
end

	xshift_now=${xshift}
	yshift_now=$( echo "${yshift} - 6.6" | bc )

	psxy << END -Xf${xshift_now} -Yf${yshift_now} -R0/10/0/1 -JX10c -P -K -O -Gblue -St0.35 -Wblack  >> ${plot}
1 0.5
END

	psxy << END  -R -JX -P -K -O -Gred -Si0.35 -Wblack  >> ${plot}
4 0.5
END

	psxy << END  -R -JX -P -K -O -Ggreen -Sc0.35 -Wblack  >> ${plot}
7 0.5
END


	pstext << END -R -JX -P  -O -F+f12p,Helvetica -F+jLM -F+a0  >> ${plot}
1.5 0.5 minimum
4.5 0.5 maximum
7.5 0.5 bounded
END

done
