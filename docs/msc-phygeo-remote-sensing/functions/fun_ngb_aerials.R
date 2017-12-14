# rs-ws-03-2
# MOC - Remote Sensing (T. Nauss, C. Reudenbach)
# 
#' Get names of neighbouring aerial image tiles
#' 
#' @description
#' Create filenames of neighbouring aerial files following the naming convention
#' of the Hessiche Landesvermessungsamt (i.e. easting_northing.tif).
#'
#' @param aerial_files A list of all filenames that should be considered
#' @param step The widht/height of the individual tile in m
#'
#' @return List of vectors containing the names of each neighbouring file for 
#' each file in aerial_files. The names of the individual list entries are the 
#' names of the central file. Each list entry contains a vector of length four 
#' which gives the neighbouring filenamesn in the order north-east-south-west.
#' If one or more of these files do not exist within aerial_files, NA is 
#' returned for that position.
#'
ngb_aerials <- function(aerial_files, step = 2000){
  require(tools)
  ngb_files <- lapply(basename(aerial_files), function(act_file){
    
    # Get names without path to compare names although path might be different
    act_ext <- file_ext(act_file)
    fnames <- basename(aerial_files)
    
    # Get x and y coordinates of actual file from filename
    act_file_x <- as.numeric(substr(act_file, 7, 12))
    act_file_y <- as.numeric(substr(act_file, 14, 20))
    
    # Set neighbours starting from north with clockwise rotation (N, E, S, W)
    pot_ngb <- c(paste0("ortho_", act_file_x, "_", act_file_y + step, ".", act_ext),
                 paste0("ortho_", act_file_x + step, "_", act_file_y, ".", act_ext),
                 paste0("ortho_", act_file_x, "_", act_file_y - step, ".", act_ext),
                 paste0("ortho_", act_file_x - step, "_", act_file_y, ".", act_ext))
    
    # Check if neighburs exist and create vector with full filepath
    act_ngb <- sapply(pot_ngb, function(f){
      pos <- grep(f, fnames)
      if(length(pos) > 0){
        return(aerial_files[pos])
      } else {
        return(NA)
      }
    })
    return(act_ngb)
  })

  names(ngb_files) <- aerial_files
  return(ngb_files)

}