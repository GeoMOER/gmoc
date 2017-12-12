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
shp_names <- shp_names[-grep("muf", basename(shp_names))]

# Put shapes in a list and adjust geometry ids
shift <- 0
shps <- list()
for(s in seq(length(shp_names))){
  act_shps <- readOGR(shp_names[s], ogrListLayers(shp_names[s]))
  shps[[s]] <- spChFIDs(act_shps, as.character(seq(nrow(act_shps)) + shift))
  shift <- shift + nrow(act_shps)
}

# rownames(as(shps[[1]], "data.frame"))

# Remove non-standard columns (if necessary)
shps[[1]]@data$merge_id <- NULL

# Combine shapes
shps_cmb <- do.call("rbind", shps)

# Recode values
ids_old <- unique(shps_cmb@data$ID)
ids_repl <- paste(ids_old, ids_new, sep = "=", collapse = ";")
shps_cmb@data$ID <- recode(shps_cmb@data$ID, ids_repl)

# Write shape file
writeOGR(shps_cmb, paste0(path_muf_set1m_lcc_ta, "muf_lc_ta_poly_large"),
         "muf_lc_ta_poly_large", driver = "ESRI Shapefile", overwrite = TRUE)

