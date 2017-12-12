# rs-ws-05-2
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# Merging training areas

# Set environment --------------------------------------------------------------
if(Sys.info()["sysname"] == "Windows"){
  source("D:/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
} else {
  source("/media/permanent/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
}


# Merge shape files ------------------------------------------------------------
# Read names of shape files
shp_names <- list.files(path_muf_set1m_lcc_ta, 
                        pattern = glob2rx("*.shp"), full.names = TRUE)
shp_names <- shp_names[c(-3, -4)]

shps_cmb(shp_names = shp_names, 
         outfile = paste0(path_muf_set1m_lcc_ta, "muf_training.shp"))

shp_final <- readOGR(paste0(path_muf_set1m_lcc_ta, "muf_training.shp"),
                     "muf_training")
projection(shp_final) <- CRS("+init=epsg:25832")
muf <- raster(paste0(path_muf_set1m, "ortho_muf_1m.tif"))
shp_final <- crop(shp_final, extent(muf))

writeOGR(shp_final, paste0(path_muf_set1m_lcc_ta, "muf_training.shp"),
         "muf_training", overwrite = TRUE, driver = "ESRI Shapefile")

