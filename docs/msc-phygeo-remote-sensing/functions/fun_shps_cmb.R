# rs-ws-05-2
# MOC - Remote Sensing (T. Nauss, C. Reudenbach)
# 
#' Combine multiple shape files with ground truth data and adjust ids
#' 
#' @description
#' Combine shape files with ground truth data, adjust ids (column "ID") and 
#' write the resulting data set into a new shape file.
#' 
#' @param shp_names A list of filenames that should be combined
#' @param outfile Name of the output file (with extension shp)
#'
#' @return Nothing.
#'
shps_cmb <- function(shp_names, outfile){
  require(car)
  require(rgdal)
  require(sp)
  require(tools)
  
  shift <- 0
  shps <- list()
  for(s in seq(length(shp_names))){
    act_shps <- readOGR(shp_names[s], ogrListLayers(shp_names[s]))
    shps[[s]] <- spChFIDs(act_shps, as.character(seq(nrow(act_shps)) + shift))
    shift <- shift + nrow(act_shps)
  }
  
  # rownames(as(shps[[1]], "data.frame"))
  
  # Remove non-standard columns (if necessary)
  # shps[[1]]@data$merge_id <- NULL
  
  # Combine shapes
  shps_cmb <- do.call("rbind", shps)
  
  # Recode values
  ids_old <- unique(shps_cmb@data$ID)
  ids_new <- seq(length(ids_old))
  ids_repl <- paste(ids_old, ids_new, sep = "=", collapse = ";")
  shps_cmb@data$ID <- recode(shps_cmb@data$ID, ids_repl)
  
  # Write shape file
  writeOGR(shps_cmb, outfile, file_path_sans_ext(basename(outfile)),
           driver = "ESRI Shapefile", overwrite = TRUE)
}

