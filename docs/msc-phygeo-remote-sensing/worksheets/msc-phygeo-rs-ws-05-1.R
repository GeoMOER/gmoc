# rs-ws-05-1
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# Scaling

# Set environment --------------------------------------------------------------
if(Sys.info()["sysname"] == "Windows"){
  source("D:/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
} else {
  source("/media/permanent/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
}

# Merge ------------------------------------------------------------------------
# Read aerial files from different directories and create consistent list
aerial_files <- list.files(path_aerial_preprocessed, full.names = TRUE, 
                           pattern = glob2rx("*.tif"))
muf_merged <- merge(stack(aerial_files[[1]]), stack(aerial_files[[2]]))
for(i in seq(3, length(aerial_files))){
  muf_merged <- merge(muf_merged, stack(aerial_files[[i]]))
}
projection(muf_merged) <- CRS("+init=epsg:25832")
writeRaster(muf_merged, paste0(path_aerial_merged, "ortho_muf.tif"))


# indices
ngb_idx(infile = paste0(path_aerial_merged, "ortho_muf.tif"),
        outfile = paste0(path_aerial_merged, "ortho_muf_indices.tif"))

# filter
filter(infile = paste0(path_aerial_merged, "ortho_muf.tif"), 
       targetpath = path_aerial_merged,
       prefix = "aerial_", window = c(21,29,33),
       statistics = c("homogeneity", "contrast", "correlation", "mean"))


