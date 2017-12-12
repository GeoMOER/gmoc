# rs-ws-03-1
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# Check radiometric image alignment

# Set environment --------------------------------------------------------------
if(Sys.info()["sysname"] == "Windows"){
  source("D:/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
} else {
  source("/media/permanent/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
}


# Read aerial files from different directories and create consistent list ------
aerial_files <- list.files(path_aerial_preprocessed, full.names = TRUE, 
                           pattern = glob2rx("*.tif"))


# Extract border data of aerial files ------------------------------------------
ngbs <- ngb_aerials(aerial_files)


ngbs_values <- lapply(seq(length(ngbs)), function(i){
  
  act_file <- names(ngbs)[i]
  ngb_files <- ngbs[[i]]
  
  act_stack <- stack(act_file)
  
  if(is.na(ngb_files[1])){
    nb <- NA
  } else {
    nb <- data.frame(act_stack[1:2, ],
                     stack(ngb_files[1])[9999:10000, ])
  }
  
  if(is.na(ngb_files[2])){
    eb <- NA
  } else {
    eb <- data.frame(act_stack[, 9999:10000],
                     stack(ngb_files[2])[, 1:2])
  }
 
  if(is.na(ngb_files[3])){
    sb <- NA
  } else {
    sb <- data.frame(act_stack[9999:10000, ],
                     stack(ngb_files[3])[1:2, ])
  }
  
  if(is.na(ngb_files[4])){
    wb <- NA
  } else {
    wb <- data.frame(act_stack[, 1:2],
                     stack(ngb_files[4])[, 9999:10000])
  }
  
  act_ngb <- list(NORTH = nb,
                  EAST = eb,
                  SOUTH = sb,
                  WEST = wb)
  return(act_ngb)
})

saveRDS(ngbs_values, paste0(path_rdata, "ngbs_values.rds"))

s1s3v_div <- ngbs_values[[6]]$WEST$ortho_478000_5632000.1 - ngbs_values[[6]]$WEST$ortho_476000_5632000.1

summary(s1s3v_div)
hist(s1s3v_div)
