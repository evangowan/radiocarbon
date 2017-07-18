#! /bin/bash


###############################################################
# parameters for the regional map plots
###############################################################

# corners of the main plot with the locations of the data
bottom_long=-99
bottom_lat=69.5
top_long=-88.8
top_lat=72.1


# location of the square used to show the region on the inset map. Should be in the middle of the above coordinates.
center_long=-94.603642
center_lat=70.823009


# location of where the scale bar is plotted. Takes some trial and error to get it in the right spot.
scale_bar_lat=69.9
scale_bar_long=-97.9
# this is the latitude where it measures the width of the scale bar. Remember, the width will change depending on latitude!
scale_bar_reference_lat=55
# width is in km
scale_bar_width=50


# shift in cm where the insert map should go. Takes some trial and error.
x_corner=7.5
y_corner=5.75

###############################################################
# parameters for the relative sea level plot
###############################################################

# x-axis range
# for best results, use a multiple of 1000 years
max_time=12000
min_time=0

# y-axis range
# for best results, use a multiple of 20 m
max_elevation=240
min_elevation=-20
