#! /bin/bash

# Before running this, download Martin Butzin's ocean modelled values of reservoir age and OxCal (unzip the later one directory above this)
# Download the reservoir age files from Pangaea: doi:10.1594/PANGAEA.876733
# Download OxCal: https://c14.arch.ox.ac.uk/oxcal.html

# According to Martin, using the full upper and lower range for the reservoir correction is overly pessimistic, and might give a range
# that is well over 1000 years. Instead, I am assigning a nominal 1-sigma error of 200 years, which probably should be
# appropriate, and still covers the typical range of modelled reservoir ages at the 3-sigma level in the Arctic

# Though I extract the time series for both the 0-100 m and 200-300 m levels, I only use the 200-300 m level data
# for the final delta_R. This can be changed by editing the code in delta_r.f90
# I cross checked the reservoir ages from the model with preindustrial shells collected in various parts of
# the Arctic (see Coulthard et al 2010 doi:10.1016/j.quageo.2010.03.002), and it matches
# better with the modelled 200-300 m range. This is likely because of the way that the modelled values
# incorporate information from sea ice reconstructions, which greatly increases the reservoir age relative
# to the deeper parts of the water column. If the modelled values are accurate, this likely means
# that the near-shore region where the shells grow is getting water from the deeper part
# of the ocean rather than the surface.

source check_files.sh

delta_r_error=200



# TODO make it read this from a file



latitude=0
longitude=0

radiocarbon_age=7185

source extract_time_series.sh


delta_r=$(./delta_r ${radiocarbon_age})


echo ${delta_r} ${delta_r_error}
