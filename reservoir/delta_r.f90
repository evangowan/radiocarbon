program delta_r

! Written by Evan Gowan
! evangowan@gmail.com

! determines the delta_r value based on Martin Butzin's ocean modelled values and the INTCAl13 and Marine13 curves
! Download files from Pangaea: doi:10.1594/PANGAEA.876733

! Must run extract.sh first to produce the time series for the point


! only uses the 200-300 m dataset for now, since there is a large dump in the near surface dataset at about 12000 yr BP

	implicit none
	character(len=50), parameter :: intcal="intcal13.14c"
	character(len=50), parameter :: marine="marine13.14c"
	character(len=50), parameter :: upper_layer = "time_series_0-100.txt"
	character(len=50), parameter :: lower_layer = "time_series_200-300.txt"
	integer, parameter :: intcal_unit=10, marine_unit=11, upper_layer_unit=12, lower_layer_unit=13
	integer, parameter :: header_length = 11

	character(len=5) :: radiocarbon_input, dummy

	integer, parameter :: intcal_dim = 5141, marine_dim = 4801

	double precision, dimension(intcal_dim) :: intcal_cal_yr, intcal_rad_yr, intcal_error
	double precision, dimension(marine_dim) :: marine_rad_yr, marine_cal_yr, marine_error

	integer :: radiocarbon_age, counter, istat
	integer :: cal_yr, rad_yr, error
	real :: delta_14, sigma_pm

	double precision :: slope, intercept

	integer, parameter :: model_spacing = 500, point_filter = 5
	integer, parameter :: model_dim = 50000 / model_spacing + 1
	integer :: filter_low_i, filter_high_i
	double precision, dimension(model_dim) :: lower, upper, filter_lower, filter_upper
	double precision :: longitude, latitude, min_val, avg_val, max_val
	double precision :: atmospheric_age, calendar_age, marine_age, intcal_out_error, marine_out_error


	call getarg(1,radiocarbon_input)
	read(radiocarbon_input,*) radiocarbon_age



! first must find the equivalent terrestrial radiocarbon age from Martin's analysis

	open(unit=upper_layer_unit,file=upper_layer,form="formatted",access="sequential",status="old")
	open(unit=lower_layer_unit,file=lower_layer,form="formatted",access="sequential",status="old")

	do counter = 1, model_dim

		read(upper_layer_unit,*) longitude, latitude, rad_yr, min_val, avg_val, max_val
		upper(counter) = avg_val

		read(lower_layer_unit,*) longitude, latitude, rad_yr, min_val, avg_val, max_val
		lower(counter) = avg_val

	end do

	close(unit=upper_layer_unit)
	close(unit=lower_layer_unit)

	! adding a filter to these data, because there is a pretty harsh jump between the tree-ring record and marine-only record interface in the model


	do counter = 1, model_dim


		filter_low_i = counter - point_filter / 2
		filter_high_i = counter + point_filter / 2

		if(filter_low_i < 1) THEN
			filter_low_i = 1
		endif
		if(filter_high_i > model_dim) THEN
			filter_high_i = model_dim
		endif
		
		filter_lower(counter) = sum(lower(filter_low_i:filter_high_i)) / dble(filter_high_i - filter_low_i + 1)
		filter_upper(counter) = sum(upper(filter_low_i:filter_high_i)) / dble(filter_high_i - filter_low_i + 1)



	end do


	! now add the radiocarbon age and the reservoir age to get the apparent age
	do counter = 1, model_dim

		filter_lower(counter) = filter_lower(counter) + dble((counter-1) * model_spacing)
		filter_upper(counter) = filter_upper(counter) + dble((counter-1) * model_spacing)

	end do

	! with the apparent ages calculated, we can now find the corresponding atmospheric radiocarbon age of the input radiocarbon date

	! for the moment I am only using the 200-300 m dataset, as in the Arctic there is a huge leap in the reservoir age at 12000 yr BP,
	! which is caused by the fact that there is no reference atmospheric concentration before the tree ring chronologies, and
	! due to assumptions on sea ice concentration. There is far less of a jump in the lower range dataset, and it actually
	! corresponds better to the reservoir ages determined from live collected shells found in Coulthard et al 2010
	if(radiocarbon_age <= filter_lower(1)) THEN
		atmospheric_age = 0.
	else ! search through the filtered dataset

		search_model: do counter = 2, model_dim

			if(radiocarbon_age > filter_lower(counter-1) .and. radiocarbon_age <= filter_lower(counter)) THEN

				atmospheric_age = find_point_on_line(filter_lower(counter), dble((counter-1)*model_spacing), &
				  filter_lower(counter-1), dble((counter-2)*model_spacing), dble(radiocarbon_age))

!				write(6,*) "check search_model"
!				write(6,*) filter_lower(counter-1), dble((counter-2)*model_spacing)
!				write(6,*) dble(radiocarbon_age), atmospheric_age
!				write(6,*) filter_lower(counter), dble((counter-1)*model_spacing)
				exit search_model

			endif


		end do search_model
	end if



! open the marine and intcal curves and read them in

	open(unit=intcal_unit,file=intcal,form="formatted",access="sequential",status="old")
	open(unit=marine_unit,file=marine,form="formatted",access="sequential",status="old")

	do counter = 1, header_length
		read(intcal_unit,*) dummy

		read(marine_unit,*) dummy

	end do


	! intcal
	read_intcal: do counter = 1, intcal_dim

		read(intcal_unit,*, iostat=istat) cal_yr, rad_yr, error, delta_14, sigma_pm
		if(istat /= 0) THEN
			write(6,*) "error reading intcal"
			stop
		endif	

		intcal_cal_yr(counter) = cal_yr
		intcal_rad_yr(counter) = rad_yr
		intcal_error(counter) = error

	end do read_intcal

	! marine
	read_marine: do counter = 1, marine_dim

		read(marine_unit,*, iostat=istat) cal_yr, rad_yr, error, delta_14, sigma_pm
		if(istat /= 0) THEN
			write(6,*) "error reading marine"
			stop
		endif	

		marine_cal_yr(counter) = cal_yr
		marine_rad_yr(counter) = rad_yr
		marine_error(counter) = error

	end do read_marine

	close(intcal_unit)
	close(marine_unit)

! find the calibrated age from the Intcal curve

	search_intcal: do counter = 1, intcal_dim

		if(atmospheric_age <= intcal_rad_yr(counter-1) .and. atmospheric_age >= intcal_rad_yr(counter)) THEN ! intcal has descending ages

			calendar_age = find_point_on_line(intcal_rad_yr(counter-1), intcal_cal_yr(counter-1), intcal_rad_yr(counter), &
			  intcal_cal_yr(counter), atmospheric_age)

			intcal_out_error = find_point_on_line(intcal_rad_yr(counter-1), intcal_error(counter-1), intcal_rad_yr(counter), &
			  intcal_error(counter), atmospheric_age)

!			write(6,*) "check search_intcal"

!			write(6,*) intcal_rad_yr(counter-1), intcal_cal_yr(counter-1), intcal_error(counter-1)
!			write(6,*) atmospheric_age, calendar_age, intcal_out_error
!			write(6,*) intcal_rad_yr(counter), intcal_cal_yr(counter), intcal_error(counter)
			exit search_intcal

		endif

		if(counter == intcal_dim) THEN
			write(6,*) "failed"
			stop
		endif


	end do search_intcal



! then find the marine radiocarbon age from the Marine curve


	search_marine: do counter = 1, marine_dim

		if(calendar_age <= marine_cal_yr(counter-1) .and. calendar_age >= marine_cal_yr(counter)) THEN ! marine has descending ages

			marine_age = find_point_on_line(marine_cal_yr(counter-1), marine_rad_yr(counter-1), marine_cal_yr(counter), &
			  marine_rad_yr(counter), calendar_age)

			marine_out_error = find_point_on_line(marine_rad_yr(counter-1), marine_error(counter-1), marine_rad_yr(counter), &
			  marine_error(counter), marine_age)



!			write(6,*) "check search_marine"

!			write(6,*) marine_cal_yr(counter-1), marine_rad_yr(counter-1), marine_error(counter-1)
!			write(6,*) calendar_age, marine_age, marine_out_error
!			write(6,*) marine_rad_yr(counter-1), marine_cal_yr(counter), marine_error(counter)
			exit search_marine

		endif

		if(counter == marine_dim) THEN
			write(6,*) "failed"
			stop
		endif


	end do search_marine

! finally subtract the input radiocarbon age from the Marine curve


!	write(6,*) "delta R"

	write(6,*) radiocarbon_age - nint(marine_age)



contains

double precision function find_point_on_line(x1, y1, x2, y2, intermediate_x)

	double precision, intent(in) :: x1, y1, x2, y2, intermediate_x

	double precision :: slope, interecept

	slope = (y2 - y1) / (x2 - x1)
	intercept = y2 - slope * x2

	find_point_on_line = intermediate_x * slope + intercept

end function find_point_on_line

end program delta_r
