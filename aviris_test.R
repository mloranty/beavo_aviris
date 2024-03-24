#########################################
#
# script to manipulate aviris ng data
# for beavo project
#
# MML 23 March 2024
#########################################

# clear workspace
rm(list = ls())

# load required packages
library(terra)

# set working directory to aviris repo in project directory
setwd("/Users/mloranty/Library/CloudStorage/GoogleDrive-mloranty@colgate.edu/My Drive/Documents/research/NASA_BEAVo/aviris")

# list files 
fl <- list.files(path = "AV320230717t211528_L2A_OE_main_50b461f8/", 
                 full.names = T)

# read the reflectance file (fourth file in my directory) using the rast function
avr <- rast(fl[4])


# look at the names for each channel/band in the file
names(avr)
# I received the following warning message
# Warning message:
# [rast] the data in this file are rotated. Use 'rectify' to fix that
# this has to do with how the data are GDAL converts data from map to pixel coordinates
# I'm a little fuzzy on what this means, but rectify seems to do the trick

# rectify 
#   note this will take a long time given the high number of bands and file size
#   this might go faster if you write the output to a new file, but for now we'll do a couple of bands
#   I tried to rectify the whole image, and then wasn't able to read the file again

# we'll use bands close to 531nm and 570nm and then calculate Photochemical Reflectance Index
# use double brackets to index a specific layer in a SpatRaster
# here avr[[20]] is the 20th band, or channel 19, etc. 
# note these will be written as tmeporary files
p531 <- rectify(avr[[20]])
p570 <- rectify(avr[[25]])

# calculate photochemical reflectance index
# it's a simple band ratio, related to photosynthetic pigments
# see John Gamon's work for more info

# first compare Geometry to confirm that raster align
compareGeom(p531,p570)

# they align so  we can use normal mathematical operators to make the calculation
pri <- ((p531-p570)/(p531+p570))

# make a quick plot to have a look at the image
# range controls the range of the legend
plot(pri,
     range = c(-0.15,0.15),
     col = topo.colors(50))

# write the pri layer to file so that we can use it later
# not you'd want to use the original filename, and perhaps append pri to that
# I'm just being a little lazy here
writeRaster(pri,"pri_test.tif")


