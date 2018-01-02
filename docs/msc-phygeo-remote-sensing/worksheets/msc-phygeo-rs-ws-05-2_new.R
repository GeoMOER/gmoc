# rs-ws-05-2
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# Merging training areas

# Set environment --------------------------------------------------------------
if(Sys.info()["sysname"] == "Windows"){
  source("C:/Users/tnauss/permanent/edu/gmoc/docs/msc-phygeo-remote-sensing/functions/set_environment.R")
} else {
  source("/media/permanent/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
}


# Merge shape files ------------------------------------------------------------
# Read names of shape files
# Version 2016
shp_names <- list.files(path_muf_set1m_lcc_ta, 
                        pattern = glob2rx("*.shp"), full.names = TRUE)
shp_names <- shp_names[c(-3, -4)]

shps_cmb(shp_names = shp_names, 
         outfile = paste0(path_muf_set1m_lcc_ta, "muf_training_2017.shp"))

shp_final <- readOGR(paste0(path_muf_set1m_lcc_ta, "muf_training.shp"),
                     "muf_training")
projection(shp_final) <- CRS("+init=epsg:25832")
muf <- raster(paste0(path_muf_set1m, "ortho_muf_1m.tif"))
shp_final <- crop(shp_final, extent(muf))

writeOGR(shp_final, paste0(path_muf_set1m_lcc_ta, "muf_training.shp"),
         "muf_training", overwrite = TRUE, driver = "ESRI Shapefile")

# Version 2017
shp_names <- list.files(path_muf_set1m_lcc_ta_2017, 
                        pattern = glob2rx("*.shp"), full.names = TRUE)

shps = lapply(shp_names, function(f){
  shp = readOGR(f, ogrListLayers(f))
  shp@data$LN = as.numeric(as.character(shp@data$LN))
  return(shp)
})
shps = do.call("rbind", shps)
shps = spTransform(shps, CRS("+init=epsg:25832"))
plot(shps)

shps$LN_New = -1

old_vals = sort(unique(shps$LN))
i = 20
for(i in seq(length(unique(shps$LN)))){
  ov = old_vals[i]
  shps@data$LN_New[shps@data$LN == ov] = i
}
shps@data$LN_New

# shps@data$LN_New = as.character(shps@data$LN_New)
summary(shps)
outfile = paste0(path_muf_set1m_lcc_ta_2017, "muf_training_2017.shp")
writeOGR(shps, outfile, file_path_sans_ext(basename(outfile)),
         driver = "ESRI Shapefile", overwrite = TRUE)


