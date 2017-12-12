library(rgdal)
library(raster)

path <- "D:/active/moc/msc-phygeo-remote-sensing-2016/data/lidar_rasters/"

files <- list.files(path, pattern = glob2rx("*.tif"), full.names = TRUE)

# temp <- raster(files[1])
# files <- files[-1]

for(i in seq(files)){
  r <- raster(files[i])
  projection(r)
  # projection(r) <- projection(temp)
  projection(r) <- CRS("+init=epsg:25832")
  writeRaster(r, paste0(path, "done/", basename(files[i])))
}
i = 1


raster("D:/active/moc/msc-phygeo-remote-sensing-2016/data/lidar_rasters/done/lidar_dsm_01m_epsg.tif")
