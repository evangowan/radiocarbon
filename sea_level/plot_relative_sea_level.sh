#! /bin/bash

# copy the radiocarbon_statistics file here

cp -f ../calibrate/age_parameters .

if [ ! -e "plots" ]
then
	mkdir plots
fi

folder_sl="plots/relative_sea_level"

if [ ! -e "${folder_sl}" ]
then
	mkdir ${folder_sl}
fi

sea_level_file="data/sea_level_indicators.txt"





# axis parameters common to all plots
xtext="Age (cal yr BP)"
xtickint=2000
xsubtickint=1000

ytext="Elevation (m)"
ytickint=40
ysubtickint=20

xshift=5
yshift=8


# common parameters for the dimensions of the plot. By doing it this way, the scale on each plot will be the same throughout.

# x-axis width parameters - it will be ${plot_width} cm if the axis is set to ${relative_time}
plot_width=15
relative_time=16000

# y-axis height parameters - it will be ${plot_height} cm if the axis is set to ${relative_elevation}
plot_height=15
relative_elevation=280

for regions in $(cat region_list)
do

	source regions/${regions}.sh

	# create input files for finding the ranges

	awk -F'\t' -v regions=${regions} '{if ($1 == regions && $5 != "" && $6 == "" ) {print $2, $5, $7}}' ${sea_level_file} >  minimum.txt
	awk -F'\t'  -v regions=${regions} '{if ($1 == regions && $5 == "" && $6 != "" ) {print $2, $6, $8}}' ${sea_level_file} >  maximum.txt
	awk -F'\t' -v regions=${regions} '{if ($1 == regions && $5 != "" && $6 != "" ) {print $2, $5, $6, $7, $8}}' ${sea_level_file} >  bounded.txt

	rm minimum_plot.txt maximum_plot.txt bounded_plot.txt

	./relative_plot_param

	plot=${folder_sl}/plot_${regions}_data.ps


	x_width=$( echo "scale=3; ${max_time} / ${relative_time} * ${plot_width}" | bc )
	y_width=$( echo "scale=3; (${max_elevation}-(${min_elevation})) / ${relative_elevation} * ${plot_height}" | bc )


	psbasemap -X${xshift} -Y${yshift} -R${min_time}/${max_time}/${min_elevation}/${max_elevation} -JX-${x_width}/${y_width} -Ba"${xtickint}"f"${xsubtickint}":"${xtext}":/a"${ytickint}"f"${ysubtickint}":"${ytext}":WSne  -P -K --FONT_ANNOT_PRIMARY=16p --FONT_ANNOT_SECONDARY=12p --FONT_LABEL=18p > ${plot}





	if [ -e "maximum_plot.txt" ]
	then
		psxy maximum_plot.txt -Exy -Gred  -P -K -O -JX -R -Si0.3 -Wblack >> ${plot}
	fi

	if [ -e "minimum_plot.txt" ]
	then
		psxy minimum_plot.txt -Exy -Gblue  -P -K -O -JX -R -St0.3 -Wblack >> ${plot}
	fi

	if [ -e "bounded_plot.txt" ]
	then
		psxy bounded_plot.txt -Exy -Ggreen  -P  -O -JX -R -Sc0.3 -Wblack >> ${plot}
	fi


	xshift_now=$( echo "${xshift} + 1.5" | bc )
	yshift_now=$( echo "${yshift} - 7.1" | bc )

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
