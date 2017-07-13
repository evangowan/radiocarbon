#! /bin/bash

# the input file is a tab delimited file!
input_file="radiocarbon_list.txt"

if [ ! -e "radiocarbon_statistics" ]
then
	make radiocarbon_statistics
fi

rm age_parameters

cat -T ${input_file} | while read radiocarbon_list
do


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

#	description=$(awk --field-separator '\t' '{print $12}' temp)

#	location=$(awk --field-separator '\t' '{print $13}' temp)

	age_output=$(./radiocarbon_statistics $sample_code)

	if [ "${sample_code}" = "LAB_ID" ]
	then

		echo $sample_code $latitude $longitude median_age mode_age one_sigma_lower one_sigma_higher two_sigma_lower two_sigma_higher >> age_parameters

	else

		echo $sample_code $latitude $longitude $age_output >> age_parameters

	fi

done
