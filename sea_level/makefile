# The compiler
FC = gfortran

FCFLAGS2 = -g -fbacktrace -fbounds-check 
FCFLAGS = -O2 
OBFLAGS = -c

shared_subs.o: shared_subs.f90
	 $(FC) -o shared_subs.o $(OBFLAGS) $(FCFLAGS) shared_subs.f90


relative_plot_param: relative_plot_param.f90 shared_subs.o
	$(FC) -o relative_plot_param $(FCFLAGS) relative_plot_param.f90 shared_subs.o

extract_calc_sea_level: extract_calc_sea_level.f90 shared_subs.o
	$(FC) -o extract_calc_sea_level $(FCFLAGS) extract_calc_sea_level.f90 shared_subs.o


sl_diff_params: sl_diff_params.f90
	$(FC) -o sl_diff_params $(FCFLAGS) sl_diff_params.f90
