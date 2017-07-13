program radiocarbon_statistics

! this program reads in a prior file from a given sample name, and outputs
! median age, mode age, 1-sigma limits (low, up), 2-sigma limits (low, up)

	implicit none

	character(len=12), parameter :: sample_directory = "priors/"
	character(len=80) :: radiocarbon_name, radiocarbon_file

	real :: median_age, mode_age, one_sigma_upper, one_sigma_lower, two_sigma_upper, two_sigma_lower, maximum_probability
	real :: last_age, last_probability, current_age, current_probability, total_probability, one_sigma_low_val
	real :: one_sigma_high_val, two_sigma_low_val, two_sigma_high_val

	integer :: istat

	real, parameter :: zero_age = 1950.5
	real, parameter :: time_interval = 5.
	
	integer, parameter :: radio_unit=10

	one_sigma_low_val = .31731 / 2.
	one_sigma_high_val = 1. - one_sigma_low_val

	two_sigma_low_val = .0455 / 2.
	two_sigma_high_val = 1. - two_sigma_low_val

!	write(6,*) one_sigma_low_val, one_sigma_high_val, two_sigma_low_val, two_sigma_high_val

	call getarg(1,radiocarbon_name)

	radiocarbon_file = trim(adjustl(sample_directory)) // trim(adjustl(radiocarbon_name)) // ".prior"

	open(unit=radio_unit, file=radiocarbon_file, access="sequential", form="formatted", status="old")

	
	read(radio_unit,*) current_age, current_probability


	current_age = zero_age - current_age
	current_probability = current_probability * time_interval

	mode_age = current_age
	maximum_probability = current_probability
	total_probability = current_probability

	last_age = current_age
	last_probability = current_probability


	read_radiocarbon_file: do

		read(radio_unit,*, iostat=istat) current_age, current_probability
		if(istat /=0) THEN
			exit read_radiocarbon_file
		endif

		current_age = zero_age - current_age
		current_probability  = current_probability * time_interval
		
		total_probability = total_probability + current_probability

	!	write(6,*) total_probability, one_sigma_low_val, one_sigma_high_val

		if(total_probability >= one_sigma_low_val .and. last_probability < one_sigma_low_val) THEN
			one_sigma_lower = calc_intermediate_value(last_probability, total_probability, one_sigma_low_val) + last_age
		endif

		if(total_probability >= one_sigma_high_val .and. last_probability < one_sigma_high_val) THEN
			one_sigma_upper = calc_intermediate_value(last_probability, total_probability, one_sigma_high_val) + last_age
		endif

		if(total_probability >= two_sigma_low_val .and. last_probability < two_sigma_low_val) THEN
			two_sigma_lower = calc_intermediate_value(last_probability, total_probability, two_sigma_low_val) + last_age
		endif

		if(total_probability >= two_sigma_high_val .and. last_probability < two_sigma_high_val) THEN
			two_sigma_upper = calc_intermediate_value(last_probability, total_probability, two_sigma_high_val) + last_age
		endif

		if(total_probability >= 0.5 .and. last_probability < 0.5) THEN
			median_age = calc_intermediate_value(last_probability, total_probability, 0.5) + last_age
		endif

		if (current_probability > maximum_probability) THEN
			maximum_probability = current_probability
			mode_age = current_age
		endif

		last_age = current_age
		last_probability = total_probability

	end do read_radiocarbon_file

	close(unit=radio_unit)

	! write out results, to the nearest year

	write(6,'(I5,1X,I5,1X,I5,1X,I5,1X,I5,1X,I5,1X)') nint(median_age), nint(mode_age), nint(one_sigma_lower),  &
		nint(one_sigma_upper), nint(two_sigma_lower), nint(two_sigma_upper)


	
contains

real function calc_intermediate_value(lower_prob, higher_prob, expected_prob)

	! returns an age that should be added to the lower age

	implicit none

	real, intent(in) :: lower_prob, higher_prob, expected_prob
	real, parameter :: time_interval = 5.

	real :: slope, intercept
	
	slope = (higher_prob - lower_prob) / time_interval



	calc_intermediate_value = (expected_prob - lower_prob) / slope

!	write(6,*) calc_intermediate_value, higher_prob, lower_prob, expected_prob


end function calc_intermediate_value

end program radiocarbon_statistics
