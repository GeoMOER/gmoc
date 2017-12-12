# rs-ws-05-1
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# Resample to 1 m

# Set environment --------------------------------------------------------------
if(Sys.info()["sysname"] == "Windows"){
  source("D:/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
} else {
  source("/media/permanent/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
}

# Crop lidar data --------------------------------------------------------------
lidar_files <- c(paste0(path_lidar_rasters, "lidar_dem_01m.tif"), 
                 paste0(path_lidar_rasters, "lidar_dsm_01m.tif"))

aoi <- readOGR(paste0(path_vectors, "muf_aoi.shp"), layer = "muf_aoi")

for(name in lidar_files){
  crp <- crop(stack(name), extent(aoi), snap = "near")
  projection(crp) <- CRS("+init=epsg:25832")
  writeRaster(crp, filename = paste0(path_muf_set1m_lidar, basename(name)))
}


# Resample aerial to LiDAR geometry --------------------------------------------
lidar_template <- raster(paste0(path_muf_set1m_lidar, "lidar_dem_01m.tif"))

aerial_files <- list.files(path_aerial_preprocessed, full.names = TRUE, 
                           pattern = glob2rx("*.tif"))
muf_merged <- merge(stack(aerial_files[[1]]), stack(aerial_files[[2]]))
for(i in seq(3, length(aerial_files))){
  muf_merged <- merge(muf_merged, stack(aerial_files[[i]]))
}
projection(muf_merged) <- CRS("+init=epsg:25832")
writeRaster(muf_merged, paste0(path_aerial_merged, "ortho_muf.tif"))

# muf_merged <- stack(paste0(path_aerial_merged, "ortho_muf.tif"))
muf_res <- resample(muf_merged, lidar_template, method="bilinear")
projection(muf_res) <- CRS("+init=epsg:25832")
writeRaster(muf_res, filename = paste0(path_muf_set1m, "ortho_muf_1m.tif"))


