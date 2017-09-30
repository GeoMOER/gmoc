# Read wood harvest from csv file, clean data frame and write it to new csv file
# MOC - Data analysis

# Set path ---------------------------------------------------------------------
if(Sys.info()["sysname"] == "Windows"){
  filepath_base <- "D:/active/moc/msc-phygeo-data_management/"
} else {
  filepath_base <- "/media/permanent/active/moc/msc-phygeo-data_management/"
}

path_data <- paste0(filepath_base, "data/")
path_csv <- paste0(path_data, "csv/")
path_rdata <- paste0(path_data, "rdata/")
path_temp <- paste0(filepath_base, "temp/")


# Read csv file and clean data frame -------------------------------------------
woodhrv <- read.table(paste0(path_csv, "hessen_holzeinschlag_1997-2014.csv"),
                      skip = 4, header = TRUE, sep = ";")
woodhrv

# Adjust row numbers
woodhrv <- woodhrv[1:nrow(woodhrv)-1, ]

# Convert 0 to NA for column "Buntholz"
woodhrv$Buntholz[woodhrv$Buntholz == 0] <- NA

# Write cleaned data to csv file -----------------------------------------------
write.table(woodhrv, 
            file = paste0(path_csv, "hessen_holzeinschlag_1997-2014_clean.csv"),
            sep = ",", row.names = FALSE)
