#r=stack()
#for z in zeile {
#for s in spalte {
# if d[z,s]=255{
# r[z,s]=r2[z,s]
#dateinamen
#einlesen(stack)
#overlay
#projektion
#auslesen
#use overlay part in raster
library(sp)
library(raster)
library(rgdal)



x=stack("C:/Users/tnauss/permanent/edu/msc-ui/data/aerial/org/476000_5630000_1.tif")
y=stack("C:/Users/tnauss/permanent/edu/msc-ui/data/aerial/org/476000_5630000.tif")
new=overlay(x,y, fun=min)
new            

x1=stack("C:/master-prog/data/aerial/aerial_croped/raster5_crop.tif")            
y1=stack("C:/master-prog/data/aerial/aerial_croped/raster6_crop.tif")
new_2=overlay(x1,y1,fun=min)
writeRaster(new, "C:/master-prog/data/aerial/aerial_croped/raster3_overl.tif")
