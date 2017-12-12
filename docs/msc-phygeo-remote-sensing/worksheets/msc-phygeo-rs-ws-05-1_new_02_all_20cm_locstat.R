# rs-ws-05-1
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# Compute local statistics

# Set environment --------------------------------------------------------------
if(Sys.info()["sysname"] == "Windows"){
  source("D:/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
} else {
  source("/media/permanent/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
}


# Merge aerial files and write resulting raster to separate file ---------------
aerial_files <- list.files(path_aerial_preprocessed, full.names = TRUE, 
                           pattern = glob2rx("*.tif"))
# muf <- muf_merged(aerial_files, paste0(path_aerial_merged, "ortho_muf.tif"))
muf <- stack(paste0(path_aerial_merged, "ortho_muf.tif"))


# Compute local statistics -----------------------------------------------------
rad <- c(2, 4, 10)

muf_files <- paste0(path_aerial_merged, "ortho_muf.tif")

for(n in muf_files){
  for(r in rad){
    print(paste0("Processing ", n, " ", r))
    otb_local_statistics <- otbLocalStat(x = n, 
                                         output_name = tools::file_path_sans_ext(basename(n)),
                                         path_output = path_aerial_merged,
                                         channel = seq(3),
                                         radius = r,
                                         return_raster = FALSE)
  }
}

