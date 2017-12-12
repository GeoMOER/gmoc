# rs-ws-05-1
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# Compute spectral indices

# Set environment --------------------------------------------------------------
if(Sys.info()["sysname"] == "Windows"){
  source("D:/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
} else {
  source("/media/permanent/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
}


# Compute spectral indices -----------------------------------------------------
muf <- stack(paste0(path_muf_set1m, "ortho_muf_1m.tif"))

idx <- rgbIndices(muf, rgbi = c("GLI", "NGRDI", "TGI", "VVI"))
projection(idx) <- CRS("+init=epsg:25832")
writeRaster(idx, paste0(path_muf_set1m, "ortho_muf_", names(idx), ".tif"), 
                        bylayer = TRUE)
# idx <- stack(paste0(path_muf_set1m, "ortho_muf_", c("GLI", "NGRDI", "TGI", "VVI"), ".tif"))


