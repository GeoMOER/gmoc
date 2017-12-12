# rs-ws-05-1
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# Compute pca

# Set environment --------------------------------------------------------------
if(Sys.info()["sysname"] == "Windows"){
  source("D:/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
} else {
  source("/media/permanent/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
}


# Compute pca ------------------------------------------------------------------
files_muf_rgb <- paste0(path_muf_set1m, "ortho_muf_1m.tif")

files_muf_rgb_idx <- list.files(path_muf_set1m, pattern = glob2rx("*I.tif"),
                           full.names = TRUE)
files_muf_rgb_idx <- c(files_muf_rgb, files_muf_rgb_idx)

pca_data <- pca(stack(files_muf_rgb_idx))
projection(pca_data$map) <- CRS("+init=epsg:25832")
writeRaster(pca_data$map, 
            paste0(path_muf_set1m, "ortho_muf_rgb_idx_", names(pca_data$map), ".tif"), 
            bylayer = TRUE)


# Scale PCA --------------------------------------------------------------------
new_min = 0
new_max = 255

files_muf_rgb_idx_pca <- paste0(path_muf_set1m, "ortho_muf_rgb_idx_PC", seq(7), ".tif")

muf_stack <- stack(files_muf_rgb_idx_pca)
muf_scaled <- lapply(seq(nlayers(muf_stack)), function(i){
  mfx <- getValues(muf_stack[[i]])
  old_min <- min(mfx)
  old_max <- max(mfx)
  
  mfx_scaled <- new_min + (new_max - new_min) * (mfx - old_min) / (old_max - old_min)  
  mfx_scaled <- setValues(muf_stack[[i]], mfx_scaled)
  return(mfx_scaled)
})
muf_scaled <- stack(muf_scaled)

writeRaster(muf_scaled, paste0(path_muf_set1m, "ortho_muf_rgb_idx_pca_scaled.tif"))

