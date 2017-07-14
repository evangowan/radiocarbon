program relative_plot_param

	! outputs calibrated age ranges at 2-sigma and elevation ranges including elevation error for each radiocarbon date

	use shared_subs
	implicit none

	! input files
	character(len=80), parameter :: minimum_file = "minimum.txt"
	character(len=80), parameter :: maximum_file = "maximum.txt"
	character(len=80), parameter :: bounded_file = "bounded.txt"
	character(len=80), parameter :: age_parameters_file = "age_parameters"
	integer, parameter :: minimum_unit = 10, maximum_unit=20, bounded_unit = 30, age_parameters_unit=40

	! output files

	character(len=80), parameter :: minimum_plot_file = "minimum_plot.txt"
	character(len=80), parameter :: maximum_plot_file = "maximum_plot.txt"
	character(len=80), parameter :: bounded_plot_file = "bounded_plot.txt"
	integer, parameter :: minimum_plot_unit = 50, maximum_plot_unit=60, bounded_plot_unit = 70



	integer :: number_minimum, number_maximum, number_bounded, number_age_parameters

	integer :: istat, counter
	double precision :: latitude, longitude, median_age, mode_age, one_sigma_lower, one_sigma_higher
	double precision :: two_sigma_lower, two_sigma_higher
	double precision, dimension(:), allocatable :: two_sigma_higher_array, two_sigma_lower_array

	double precision :: maximum_elevation, minimum_elevation, maximum_error, minimum_error, bounded_elevation, bounded_error

	! output parameters
	double precision :: average_age, age_error
	logical :: success

	character(len=80) :: dummy, lab_id
	character(len=80), dimension(:), allocatable :: lab_id_array

	! find number of dates in the age_parameters file
	open(unit=age_parameters_unit, file=age_parameters_file, form="formatted", access="sequential", status="old")
	number_age_parameters = number_entries(age_parameters_unit) - 1 ! ignore header


	! allocate storage for the age parameters

	allocate(lab_id_array(number_age_parameters), two_sigma_higher_array(number_age_parameters),&
	  two_sigma_lower_array(number_age_parameters))

	! read in the age parameters
	read(age_parameters_unit,*, iostat=istat) dummy ! skip header
	

	do counter = 1, number_age_parameters

		read(age_parameters_unit,*, iostat=istat) lab_id, latitude, longitude, median_age, mode_age,  &
		  one_sigma_lower, one_sigma_higher, two_sigma_higher, two_sigma_lower
		if(istat /= 0 ) THEN
			write(6,*) "there is a bug somewhere, you should check relative_plot_param.f90"
			write(6,*) "marker: 1"
			stop
		endif
		
		lab_id_array(counter) = lab_id
		two_sigma_higher_array(counter) = two_sigma_higher
	 	two_sigma_lower_array(counter) = two_sigma_lower
		

	end do

	close(unit=age_parameters_unit)

	!!!!!!!!!!!!!!!!!!!!!!!
	! maximum constraints !
	!!!!!!!!!!!!!!!!!!!!!!!

	! find number of maximum constraints
	open(unit=maximum_unit, file=maximum_file, form="formatted", access="sequential", status="old")
	number_maximum = number_entries(maximum_unit)


	! if there are maximum constraints, search for them

	if(number_maximum > 0) THEN

		open(unit=maximum_plot_unit, file=maximum_plot_file, form="formatted", access="sequential", status="replace")	

		do counter = 1, number_maximum, 1

			read(maximum_unit,*, iostat=istat) lab_id, maximum_elevation, maximum_error
			if(istat /= 0 ) THEN
				write(6,*) "there is a bug somewhere, you should check relative_plot_param.f90"
				write(6,*) "marker: 2"
				stop
			endif

			call search_date(lab_id_array, two_sigma_lower_array, two_sigma_higher_array, number_age_parameters, lab_id, &
			 average_age, age_error, success)

			if(success) THEN

				write(maximum_plot_unit,*) average_age, maximum_elevation, age_error, maximum_error

			else

				write(6,*) "could not find lab_id: ", lab_id

			end if

		end do

		close(unit=maximum_plot_unit)
	end if

	close(unit=maximum_unit)


	!!!!!!!!!!!!!!!!!!!!!!!
	! minimum constraints !
	!!!!!!!!!!!!!!!!!!!!!!!

	! find number of minimum constraints

	open(unit=minimum_unit, file=minimum_file, form="formatted", access="sequential", status="old")
	number_minimum = number_entries(minimum_unit)


	! if there are minimum constraints, search for them

	if(number_minimum > 0) THEN

		open(unit=minimum_plot_unit, file=minimum_plot_file, form="formatted", access="sequential", status="replace")	

		do counter = 1, number_minimum, 1

			read(minimum_unit,*, iostat=istat) lab_id, minimum_elevation, minimum_error
			if(istat /= 0 ) THEN
				write(6,*) "there is a bug somewhere, you should check relative_plot_param.f90"
				write(6,*) "marker: 3"
				stop
			endif

			call search_date(lab_id_array, two_sigma_lower_array, two_sigma_higher_array, number_age_parameters, lab_id, &
			 average_age, age_error, success)

			if(success) THEN

				write(minimum_plot_unit,*) average_age, minimum_elevation, age_error, minimum_error

			else

				write(6,*) "could not find lab_id: ", lab_id

			end if

		end do

		close(unit=minimum_plot_unit)
	end if

	close(unit=minimum_unit)


	!!!!!!!!!!!!!!!!!!!!!!!
	! bounded constraints !
	!!!!!!!!!!!!!!!!!!!!!!!



	! find number of bounded constraints

	open(unit=bounded_unit, file=bounded_file, form="formatted", access="sequential", status="old")
	number_bounded = number_entries(bounded_unit)


	! if there are minimum constraints, search for them

	if(number_bounded > 0) THEN

		open(unit=bounded_plot_unit, file=bounded_plot_file, form="formatted", access="sequential", status="replace")	

		do counter = 1, number_bounded, 1

			read(bounded_unit,*, iostat=istat) lab_id, minimum_elevation, maximum_elevation, minimum_error, maximum_error
			if(istat /= 0 ) THEN
				write(6,*) "there is a bug somewhere, you should check relative_plot_param.f90"
				write(6,*) "marker: 4"
				stop
			endif

			call search_date(lab_id_array, two_sigma_lower_array, two_sigma_higher_array, number_age_parameters, lab_id, &
			 average_age, age_error, success)

			if(success) THEN

				bounded_elevation = (maximum_elevation - minimum_elevation) / 2.
				bounded_error = sqrt((bounded_elevation - minimum_elevation)**2 + maximum_error**2 + minimum_error**2)

				write(bounded_plot_unit,*) average_age, minimum_elevation, age_error, bounded_error

			else

				write(6,*) "could not find lab_id: ", lab_id

			end if

		end do

		close(unit=bounded_plot_unit)
	end if

	close(unit=bounded_unit)





	

end program relative_plot_param
