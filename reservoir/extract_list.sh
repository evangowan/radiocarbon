# /bin/bash


# similar to extract.sh, but uses the information from radiocarbon_list.txt
# see the calibrate folder for an example file

# this script will create a new list file with the appropriate delta_r value (output to radiocarbon_list_delta_r.txt). This can
#  be taken back into the calibrate folder for calibration.

source check_files.sh


# if you have made a different file, replace it here
input_file=radiocarbon_list.txt


output_file=radiocarbon_list_delta_r.txt
rm ${output_file}

if [ ! -e ${input_file} ]
then
	cp ../calibrate/${input_file} .
fi


counter=0

cat -T ${input_file} | while read radiocarbon_list
do

	counter=$(echo "${counter} + 1" | bc)

	echo ${radiocarbon_list} | sed 's/\^I/\t/g'  > temp
	
	sample_code=$(awk --field-separator '\t' '{print $1}' temp)

	latitude=$(awk --field-separator '\t' '{print $2}' temp)

	longitude=$(awk --field-separator '\t' '{print $3}' temp)

	radiocarbon_age=$(awk --field-separator '\t' '{print $4}' temp)

	error_val=$(awk --field-separator '\t' '{print $5}' temp)

	correction_type=$(awk --field-separator '\t' '{print $6}' temp)

	delta_r=$(awk --field-separator '\t' '{print $7}' temp)

	delta_r_error=$(awk --field-separator '\t' '{print $8}' temp)

	cal_curve=$(awk --field-separator '\t' '{print $9}' temp)

	material=$(awk --field-separator '\t' '{print $10}' temp)

	reference=$(awk --field-separator '\t' '{print $11}' temp)


	if [  "${correction_type}" = "1" ]
	then

		echo "calculating for: ${sample_code}"

		source extract_time_series.sh

		delta_r=$(./delta_r ${radiocarbon_age})
		delta_r_error=200

	fi

	echo -e "${sample_code}\t${latitude}\t${longitude}\t${radiocarbon_age}\t${error_val}\t${correction_type}\t${delta_r}\t${delta_r_error}\t${cal_curve}\t${material}\t${reference}" >> ${output_file}


done
