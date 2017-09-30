# da-ws-04-1
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# 
#' Split the information on places in the Regional Database Germany
#' 
#' @description
#' Split the information on places in the Regional Database Germany into name
#' and type.
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

split_places_RDG <- function(ds){
  
  # Split place into comma separated entries
  place <- strsplit(as.character(ds$Place), ",")
  #   head(place)
  #   max(sapply(place, length))
  
  # Write separate entries to data frame
  place_df <- lapply(place, function(i){
    p1 <- sub("^\\s+", "", i[1])  # Trim leading white spaces
    if(length(i) > 2){
      p2 <- sub("^\\s+", "", i[2])
      p3 <- sub("^\\s+", "", i[3])
    } else if (length(i) > 1){
      p2 <- sub("^\\s+", "", i[2])
      p3 <- NA
    } else {
      p2 <- NA
      p3 <- NA
    }
    data.frame(A = p1,
               B = p2,
               C = p3)
  })
  place_df <- do.call("rbind", place_df)
  place_df$ID <- ds$ID 
  place_df$Year <- ds$Year
  # head(place_df)
  
  #   unique(place_df[, 2])
  #   unique(place_df[, 3])
  #   unique(place_df$B[!is.na(place_df$C)])
  
  # Swap second and third column
  place_df[!is.na(place_df$C),] <- place_df[!is.na(place_df$C), c(1,3,2, 4, 5)]
  
  #   unique(ds$Place[is.na(place_df$B)])
  #   sum(is.na(place_df$B))
  
  # Take care of "Landkreise"
  for(r in seq(nrow(place_df))){
    if(is.na(place_df$B[r]) &
       grepl("kreis", tolower(place_df$A[r]))){
      place_df$B[r] <- "Landkreis"
    }
  }
  #   head(place_df)
  #   unique(ds$Place[is.na(place_df$B)])
  #   sum(is.na(place_df$B))
  
  # Take care of federal states and country
  place_df$B[is.na(place_df$B) & nchar(as.character(place_df$ID) == 2)] <- "Bundesland"
  place_df$B[place_df$ID == "DG"] <- "Land"
  #   head(place_df)
  #   sum(is.na(place_df$B))
  return(place_df)  
  
}