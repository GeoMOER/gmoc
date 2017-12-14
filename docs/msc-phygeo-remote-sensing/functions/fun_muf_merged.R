# rs-ws-05-1
# MOC - Remote Sensing (T. Nauss, C. Reudenbach)
# 
#' Merge raster stacks
#' 
#' @description
#' Create a single raster stack from the individual raster tiles
#'
#' @param aerial_files A list of all filenames that should be considered
#' @param outfile Path and name of the output file
#' 
#' @return Stack of merged raster tiles
#'
#'
muf_merged<-function(aerial_files, outfile){
  
  require(raster)
  
  m <- merge(stack(aerial_files[1]),stack(aerial_files[2]))
  for(i in seq(3,length(aerial_files))){
    m <- merge(m, stack(aerial_files[i]))
  }
  writeRaster(m, outfile)
  return(m)
}