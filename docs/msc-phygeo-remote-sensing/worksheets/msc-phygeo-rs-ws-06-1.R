# rs-ws-05-2
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# Remove nas

# Set environment --------------------------------------------------------------
if(Sys.info()["sysname"] == "Windows"){
  source("D:/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
} else {
  source("/media/permanent/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
}

test_files <- list.files(path_muf_set1m_sample_test_01, pattern = glob2rx("*.tif"),
                         full.names = TRUE)

act_file <- test_files[[5]]

r <- raster(act_file)
d <- getValues(r)
summary(d)
d[is.na(d)] <- 0
r <- setValues(r, d)
projection(r) <- CRS("+init=epsg:25832")
writeRaster(r, paste0(dirname(act_file), "/",
                      substr(basename(act_file), 1, nchar(basename(act_file))-4),
                      "_non-na.tif"), 
            overwrite = TRUE)

# dmin <- min(d, na.rm = TRUE)
# dmax <- max(d, na.rm = TRUE)
# d_new <- (d - dmin) * (255 - 0) / (dmax - dmin) + 0
# summary(d_new)
# r <- setValues(r, d)
# projection(r) <- CRS("+init=epsg:25832")
# writeRaster(r, paste0(path_aerial_aggregated, 
#                       "geonode_muf_merged_001m_redness_index_mean_21_scaled.tif"),
#             overwrite = TRUE)


files <- list.files(path_aerial_aggregated, pattern = glob2rx("*index.tif"),
                    full.names = TRUE)
for(f in files){
  r <- raster(f)
  d <- getValues(r)
  d[is.na(d)] <- 0
  r <- setValues(r, d)
  projection(r) <- CRS("+init=epsg:25832")
  of <- paste0(substr(f, 1, nchar(f)-4), "_nona.tif")
  writeRaster(r, of, overwrite = TRUE)
}