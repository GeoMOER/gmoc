# rs-ws-02-2
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# Clip aerial images to aoi extent.

# Set environment --------------------------------------------------------------
if(Sys.info()["sysname"] == "Windows"){
  source("D:/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
} else {
  source("/media/permanent/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
}

# Clip eastern aerial files to LAS extent and write raster to separate file ----
aerial_files <- list.files(path_aerial_geomoc, full.names = TRUE, 
                           pattern = glob2rx("*.tif"))

aoi <- readOGR(paste0(path_vectors, "muf_aoi.shp"), layer = "muf_aoi")

for(name in aerial_files){
  crp <- crop(stack(name), extent(aoi), snap = "near")
  projection(crp) <- CRS("+init=epsg:25832")
  writeRaster(crp, filename = 
                paste0(paste0(path_aerial_croped, basename(name))))
}

