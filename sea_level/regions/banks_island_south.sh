#! /bin/bash


###############################################################
# parameters for the regional map plots
###############################################################

# corners of the main plot with the locations of the data
bottom_long=-126.752551
bottom_lat=70.174922
top_long=-116.70809
top_lat=73.573244


# location of the square used to show the region on the inset map. Should be in the middle of the above coordinates.
center_long=-123.24433
center_lat=71.834919


# location of where the scale bar is plotted. Takes some trial and error to get it in the right spot.
scale_bar_lat=70.64
scale_bar_long=-126.25
# this is the latitude where it measures the width of the scale bar. Remember, the width will change depending on latitude!
scale_bar_reference_lat=55
# width is in km
scale_bar_width=50


# shift in cm where the insert map should go. Takes some trial and error.
x_corner=7.47
y_corner=2.1

###############################################################
# parameters for the relative sea level plot
###############################################################

# x-axis range
# for best results, use a multiple of 1000 years
max_time=14000
min_time=0

# y-axis range
# for best results, use a multiple of 20 m
max_elevation=40
min_elevation=-40
