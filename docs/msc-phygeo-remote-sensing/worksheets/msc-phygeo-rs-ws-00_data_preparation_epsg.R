# rs-ws-00-0
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# Set projection and extent to originally supplied dataset

# Set environment --------------------------------------------------------------
if(Sys.info()["sysname"] == "Windows"){
  source("D:/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
} else {
  source("/media/permanent/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
}

# Assign correct EPSG ----------------------------------------------------------
aerial_files <- list.files(paste0(path_muf_set1m, "epsg/"), full.names = TRUE, 
                           pattern = glob2rx("*.tif"))

for(name in aerial_files){
  act <- stack(name)
  projection(act) <- CRS("+init=epsg:25832")
  writeRaster(act, filename = paste0(path_muf_set1m, basename(name)))
}

