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

# Pre-clean crop data ----------------------------------------------------------
# Read data
cp <- read.table(paste0(path_csv, "115-46-4_feldfruechte.txt"),
                 skip = 6, header = TRUE, sep = ";", dec = ",", 
                 fill = TRUE, encoding="ANSI")
head(cp)

str(cp)

# New column names
names(cp) <- c("Year", "ID", "Place", "Winter_wheat", "Rye", "Winter_barley",
               "Spring_barley", "Oat", "Triticale", "Potatos", "Suggar_beets",
               "Rapeseed", "Silage_maize")

# Cut off tail
tail(cp)
cp <- cp[1:8925,]

# Numbers as numbers, not characters/factors
for(c in colnames(cp)[4:13]){
  cp[, c][cp[, c] == "." | 
            cp[, c] == "-" | 
            cp[, c] == "," | 
            cp[, c] == "/"] <- NA
  cp[, c] <- as.numeric(sub(",", ".", as.character(cp[, c])))
}

summary(cp)

# Split place into comma separated entries
place <- strsplit(as.character(cp$Place), ",")
head(place)
max(sapply(place, length))

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
place_df$ID <- cp$ID 
place_df$Year <- cp$Year
head(place_df)

unique(place_df[, 2])
unique(place_df[, 3])
unique(place_df$B[!is.na(place_df$C)])

# Swap second and third column
place_df[!is.na(place_df$C),] <- place_df[!is.na(place_df$C), c(1,3,2, 4, 5)]

unique(cp$Place[is.na(place_df$B)])
sum(is.na(place_df$B))

# Take care of "Landkreise"
for(r in seq(nrow(place_df))){
  if(is.na(place_df$B[r]) &
     grepl("kreis", tolower(place_df$A[r]))){
    place_df$B[r] <- "Landkreis"
  }
}
head(place_df)
unique(cp$Place[is.na(place_df$B)])
sum(is.na(place_df$B))

# Take care of federal states and country
place_df$B[is.na(place_df$B) & nchar(as.character(place_df$ID) == 2)] <- "Bundesland"
place_df$B[place_df$ID == "DG"] <- "Land"
head(place_df)
sum(is.na(place_df$B))


# Merge back into original data frame
cp_sep <- merge(cp, place_df, by = c("ID", "Year"))
head(cp_sep)
cp_sep[c(1, 50, 600),]

# Remove initial place column and move the new place information further left
cp_clean <- cp_sep[, -3]
names(cp_clean)[(ncol(cp_clean)-2):ncol(cp_clean)] <- c("Place", "Admin_unit", "Admin_misc")
cp_clean <- cp_clean[, c(1:2, 13:15, 3:12)]
head(cp_clean)

saveRDS(cp_clean, file = paste0(path_rdata, "cp_clean.rds"))


