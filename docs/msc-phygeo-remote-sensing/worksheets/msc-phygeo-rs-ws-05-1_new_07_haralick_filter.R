# rs-ws-05-1
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# Scaling

# Set environment --------------------------------------------------------------
if(Sys.info()["sysname"] == "Windows"){
  source("D:/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
} else {
  source("/media/permanent/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
}


# Compute haralick textures ----------------------------------------------------
ortho_muf_rgb_idx_pca_scaled <- paste0(path_muf_set1m_sample_segm, "ortho_muf_rgb_idx_pca_scaled.tif")


minv <- minValue(raster(ortho_muf_rgb_idx_pca_scaled[[1]]))
maxv <- maxValue(raster(ortho_muf_rgb_idx_pca_scaled[[1]]))

windows <- c(3, 9, 15, 21)
for(win in windows){
  oth <- otbTexturesHaralick(x=ortho_muf_rgb_idx_pca_scaled[[1]], 
                             output_name = "ortho_muf_rgb_idx_pca_scaled_haralick_",
                             path_output = path_muf_set1m, 
                             return_raster = FALSE, 
                             parameters.xyrad=list(c(win, win)),
                             parameters.xyoff=list(c(1,1)),
                             parameters.minmax=c(minv, maxv),
                             parameters.nbbin = 8,
                             texture="all",
                             channel = 1)
  
}
