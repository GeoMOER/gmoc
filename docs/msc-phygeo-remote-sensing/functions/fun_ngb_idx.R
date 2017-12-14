library(tools)



green_leaf_idx<-function(x, r=1, g=2, b=3){
  require(raster)
  (2*x[[g]]-x[[r]]-x[[b]])/(2*x[[g]]+x[[r]]+x[[b]])
}

intensity_index <- function(x,r=1,g=2,b=3){
  require(raster)
  intensity <- (1/30.5)/(x[[r]] +x[[g]] +x[[b]])
} 


redness_index<- function (x, r=1, g=2){
  index<-(x[[r]]-x[[g]])/(x[[r]]+x[[g]])
  return(index)
}

vvi <- function(x,r=1, g=2, b=3){
  (1-abs((x[[r]]-40)/(x[[r]]+40)))*
    (1- abs((x[[g]]-60)/(x[[g]]+60)))*
    (1-abs((b-10)/(b+10)))}


rgb_shape_index <- function(x, r=1, g=2, b=3){2*(x[[r]]-x[[g]]-x[[b]])/(x[[g]]-x[[b]])}


# outfile <-paste0(pd_rs_aerial_final,"/muf_rgb_indx.tif")
# 
# infile<-stack(paste0(pd_rs_aerial_merged, "muff_merged.tif"))





ngb_idx<-function(infile, outfile){
  require(tools)
  require(raster)
  
  x<-stack(infile)
  
  g<-green_leaf_idx(x)
  
  int<-intensity_index(x)
  
  red<-redness_index(x)
  
  v<- vvi(x)
  
  rshp<- rgb_shape_index(x)
  
  stck<-stack(g, int, red, v, rshp)
  
  writeRaster(stck, filename=outfile,  format="GTiff", bylayer = TRUE)
  
  Index <- c("green_leaf_index", "intensity_index","redness_index", "visible_vegetation_index", "rgb_shape_index")
  
  Layer <- c(1:5)
  
  rds_cont <- data.frame(Layer, Index)
  
  saveRDS(rds_cont, file=paste0(file_path_sans_ext(outfile),".rds"))
}

