# The compiler
FC = gfortran

FCFLAGS2 = -g -fbacktrace -fbounds-check 
FCFLAGS = -O2 
OBFLAGS = -c

shared_subs.o: shared_subs.f90
	 $(FC) -o shared_subs.o $(OBFLAGS) $(FCFLAGS) shared_subs.f90


relative_plot_param: relative_plot_param.f90 shared_subs.o
	$(FC) -o relative_plot_param $(FCFLAGS) relative_plot_param.f90 shared_subs.o


