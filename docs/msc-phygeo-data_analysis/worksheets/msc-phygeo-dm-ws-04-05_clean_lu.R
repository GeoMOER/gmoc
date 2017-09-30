# da-ws-04-1
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# Read and clean

# Set path ---------------------------------------------------------------------
if(Sys.info()["sysname"] == "Windows"){
  filepath_base <- "D:/active/moc/msc-phygeo-data-analysis/"
} else {
  filepath_base <- "/media/permanent/active/moc/msc-phygeo-data-analysis/"
}

path_data <- paste0(filepath_base, "data/")
path_csv <- paste0(path_data, "csv/")
path_rdata <- paste0(path_data, "rdata/")
path_scripts <- paste0(filepath_base, "scripts/msc-phygeo-data_management/src/functions/")
path_temp <- paste0(filepath_base, "temp/")


library(reshape2)
source(paste0(path_scripts, "fun_cleaning.R"))

# Pre-clean land use data ------------------------------------------------------
# Read data
lu <- read.table(paste0(path_csv, "AI001_gebiet_flaeche.txt"),
                 skip = 4, header = TRUE, sep = ";", dec = ",",
                 encoding="ANSI")
head(lu)

str(lu)

# New column names
names(lu) <- c("Year", "ID", "Place", "Settlement", "Recreation", 
               "Agriculture", "Forest")

# Numbers as numbers, not characters/factors
for(c in colnames(lu)[4:7]){
  lu[, c][lu[, c] == "."] <- NA  
  lu[, c] <- as.numeric(sub(",", ".", as.character(lu[, c])))
}

summary(lu)

place_df <- split_places_RDG(lu)
head(place_df)

# # Split place into comma separated entries
# place <- strsplit(as.character(lu$Place), ",")
# head(place)
# max(sapply(place, length))
# 
# # Write separate entries to data frame
# place_df <- lapply(place, function(i){
#   p1 <- sub("^\\s+", "", i[1])  # Trim leading white spaces
#   if(length(i) > 2){
#     p2 <- sub("^\\s+", "", i[2])
#     p3 <- sub("^\\s+", "", i[3])
#   } else if (length(i) > 1){
#     p2 <- sub("^\\s+", "", i[2])
#     p3 <- NA
#   } else {
#     p2 <- NA
#     p3 <- NA
#   }
#   data.frame(A = p1,
#              B = p2,
#              C = p3)
# })
# place_df <- do.call("rbind", place_df)
# place_df$ID <- lu$ID 
# place_df$Year <- lu$Year
# head(place_df)
# 
# unique(place_df[, 2])
# unique(place_df[, 3])
# unique(place_df$B[!is.na(place_df$C)])
# 
# # Swap second and third column
# place_df[!is.na(place_df$C),] <- place_df[!is.na(place_df$C), c(1,3,2, 4, 5)]
# 
# unique(lu$Place[is.na(place_df$B)])
# sum(is.na(place_df$B))
# 
# # Take care of "Landkreise"
# for(r in seq(nrow(place_df))){
#   if(is.na(place_df$B[r]) &
#      grepl("kreis", tolower(place_df$A[r]))){
#     place_df$B[r] <- "Landkreis"
#   }
# }
# head(place_df)
# unique(lu$Place[is.na(place_df$B)])
# sum(is.na(place_df$B))
# 
# # Take care of federal states and country
# place_df$B[is.na(place_df$B) & nchar(as.character(place_df$ID) == 2)] <- "Bundesland"
# place_df$B[place_df$ID == "DG"] <- "Land"
# head(place_df)
# sum(is.na(place_df$B))


# Merge back into original data frame
lu_sep <- merge(lu, place_df, by = c("ID", "Year"))
head(lu_sep)
lu_sep[c(1, 50, 600),]

# Remove initial place column and move the new place information further left
lu_clean <- lu_sep[, -3]
names(lu_clean)[(ncol(lu_clean)-2):ncol(lu_clean)] <- c("Place", "Admin_unit", "Admin_misc")
lu_clean <- lu_clean[, c(1:2, 7:9, 3:6)]
head(lu_clean)


saveRDS(lu_clean, file = paste0(path_rdata, "lu_clean.rds"))
summary(lu_clean)
