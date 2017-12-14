# # Filter function # #
#
# Input: path to rasterstack with indices, path for output files, prefix for output data
#        statistics (see glcm package), window (see glcm package)
#
# Output: rasterstacks for each layers of the input stack,
#         rds data.frame with band order of the stack
#
# stucture example of stack with two window sizes and three statistics: 
# (statistic[1] window[1])
# (statistic[1] window[2])
# (statistic[2] window[1])
# (statistic[2] window[2])
# (statistic[3] window[1])
# (statistic[3] window[2])
#
# # # #

filter <- function(filepath, targetpath = dirname(filepath),
                   prefix = "file_", window = c(21,29,33),
                   statistics = c("homogeneity", "contrast", "correlation", "mean")){
  
  library(glcm)
  library(raster)
  
  # read indice tif and rds file
  stack <- stack(filepath)
  indices <- readRDS(paste0(substr(filepath,1,nchar(filepath)-3),"rds"))
  
  # get number of layers from stack
  n_indices <- nlayers(stack)
  
  
  #Gesamtergebnis der Schleifen:
  #Ein Listeneintrag enth?lt ein Stack mit allen Windowsizes f?r jede Statistik f?r einen Index.
  
  
  # first lapply-loop: iterate layer of inputstack
  all_indices <- lapply(1:n_indices, function(i){
    # load one layer
    r <- stack[[i]]
    # second lapply-loop: iterate statistics
    filter_different_windowsize <- lapply(statistics, function(s){
      # third lapply-loop: iterate window sizes
      filter_same_windowsize <- lapply(window, function(w){
        
        glcm(r, statistics = s, window = c(w,w))
        
      })
      stack(filter_same_windowsize)
    })
    stack(filter_different_windowsize)
  })
  
  # create tifs and meta files
  stacknames <- indices$Index
  for(j in 1:n_indices){
    writeRaster(all_indices[[j]], paste0(targetpath, "/",prefix, stacknames[j],".tif"))
    saveRDS(data.frame(Layer = seq(1,nlayers(all_indices[[j]])),
                       Filter = rep(statistics, each = length(window)),
                       Window = rep(window, length(statistics))), 
            paste0(targetpath, "/",prefix, stacknames[j],".rds"))
  }
  
}