#! /bin/bash


input_file="radiocarbon_list.txt"
output_folder=priors

mkdir $output_folder

rm test_file.txt

# using this bash script, you take in a csv file (this will be tab delimited), and output everything needed to do the calibration using OxCal
# The CSV file will be in the format:

# Sample Code, latitude, longitude, age (yr BP), error (1 sigma), correction type, correction amount, correction error, calibration curve, material dated, reference

# for correction type, use:
# 0 - no correction
# 1 - marine
# 2 - terrestrial correction


#
# For the calibration curve setting, select "marine" for marine samples, and "terrestrial" for terrestrial samples
#
# Arctic region reservoir corrections used in the sample file are from Coulthard et al. 2010
counter=0
rm run.oxcal *.prior
cat -T ${input_file} | while read radiocarbon_list
do
	counter=$(echo $counter + 1 | bc)
	echo "Analysis: " $counter

	echo ${radiocarbon_list} | sed 's/\^I/\t/g'  > temp
	
	sample_code=$(awk --field-separator '\t' '{print $1}' temp)
	echo $sample_code

	latitude=$(awk --field-separator '\t' '{print $2}' temp)
#	echo $latitude

	longitude=$(awk --field-separator '\t' '{print $3}' temp)
#	echo $longitude

	age=$(awk --field-separator '\t' '{print $4}' temp)
#	echo $age

	error_val=$(awk --field-separator '\t' '{print $5}' temp)
#	echo $error_val

	correction_type=$(awk --field-separator '\t' '{print $6}' temp)
#	echo $correction_type

	correction_amount=$(awk --field-separator '\t' '{print $7}' temp)
#	echo $correction_amount

	correction_error=$(awk --field-separator '\t' '{print $8}' temp)
#	echo $correction_error

	cal_curve=$(awk --field-separator '\t' '{print $9}' temp)
#	echo $cal_curve

# the material dated and reference field is not actually used for anything.

	material=$(awk --field-separator '\t' '{print $10}' temp)
#	echo $material

	reference=$(awk --field-separator '\t' '{print $11}' temp)
#	echo $reference

	# next, generate the file to be read into OxCal

	if [ "${cal_curve}" = "marine" ] || [  "${cal_curve}" = "marine_bulk" ]
	then
		cal_line="Curve(\"Marine13\",\"../bin/marine13.14c\");"
	else
		cal_line="Curve(\"IntCal13\",\"../bin/intcal13.14c\");"
	fi

	if  [ "${correction_type}" = "1" ] || [ "${correction_type}" = "3" ]
	then
		delta_r="Delta_R(\"correction\", ${correction_amount}, ${correction_error});"
	else
		delta_r=""
	fi

# if you want to add a terrestrial correction
#	if  [ "${correction_type}" = "2" ]
#	then

#		age=$(echo $age - ${correction_amount} | bc)
#		error_val=$(echo "sqrt($error_val^2 + ${correction_error}^2)" | bc )

#	fi

	cat << END > run.oxcal
 Plot()
 {
	$cal_line
  	${delta_r}
  	R_Date("${sample_code}", $age, $error_val);

 };
END

echo ${sample_code} $age $error_val ${cal_curve} >> test_file.txt
cat run.oxcal >> test_file.txt


	../OxCal/bin/OxCalLinux run.oxcal
	
	perl parse_javascript.pl run.js

	if [ -e ${sample_code}.prior ] 
	then
		echo "successful run"
	else
		echo "did not work"
	fi

	mv ${sample_code}.prior $output_folder

done
#rm temp
