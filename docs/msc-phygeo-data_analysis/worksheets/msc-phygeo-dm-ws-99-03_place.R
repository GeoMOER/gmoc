# da-ws-04-2
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# Separate and merge

# Set path ---------------------------------------------------------------------
if(Sys.info()["sysname"] == "Windows"){
  filepath_base <- "D:/active/moc/msc-phygeo-data-analysis/"
} else {
  filepath_base <- "/media/permanent/active/moc/msc-phygeo-data-analysis/"
}

path_data <- paste0(filepath_base, "data/")
path_csv <- paste0(path_data, "csv/")
path_bkg <- paste0(path_data, "bkg/")
path_rdata <- paste0(path_data, "rdata/")
path_temp <- paste0(filepath_base, "temp/")


library(rgdal)
library(sp)
library(reshape2)


# Read data file ---------------------------------------------------------------
# Pre-cleaned data from da-ws-04-1
lu <- readRDS(paste0(path_rdata, "lu.rds"))
cp <- readRDS(paste0(path_rdata, "cp.rds"))

# Geo information
vg250 <- read.table(paste0(path_bkg, "vg250_0101.utm32s.shape.ebenen/vg250_ebenen/struktur_und_attribute_vg250.csv"),
                           header = TRUE, sep = ";", dec = ".", fill = TRUE,
                           encoding="ANSI")


# Merge land use and crop information with geo information ---------------------
# Land use
str(vg250)
str(lu)

vg250_lu <- merge(vg250, lu, by.x = "AGS", by.y = "ID")
nrow(vg250_lu)

head((vg250_lu))
summary(vg250_lu)
length(unique(vg250_lu$AGS))

# Crop
str(vg250)
str(cp)

vg250_cp <- merge(vg250, cp, by.x = "AGS", by.y = "ID")
nrow(vg250_cp)

head(vg250_cp, 20)
summary(vg250_cp)
length(unique(vg250_cp$AGS))

# Combined lu and crop
vg250_lu_cp <- merge(vg250_lu, vg250_cp)

summary(vg250_lu_cp)
length(unique(vg250_lu_cp$AGS))




# Clean place information ------------------------------------------------------
# Separate place name and place type and remove any kind of white space 
place <- strsplit(as.character(lu$Place), ",")
max(sapply(place, length))

place_df <- lapply(place, function(i){
  p1 <- sub("^\\s+", "", i[1])  # Trim leading white spaces
  if(length(i) > 2){
    p2 <- gsub(" ", "", i[2], fixed = TRUE)
    p3 <- gsub(" ", "", i[3], fixed = TRUE)
  } else if (length(i) > 1){
    p2 <- gsub(" ", "", i[2], fixed = TRUE)
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
place_df$ID <- lu$ID
place_df$Year <- lu$Year

unique(place_df[, 2])
unique(place_df[, 3])

place_df[!is.na(place_df$C),] # C does not contain additional information to B

# Make list dictionary which maps OBA codes to contents of place
str(gn250)
levels(gn250$OBA)

gn250_categories <- list(
  KreisfreieStadt = "AX_Ortslage",
  Landeshauptstadt = "AX_Ortslage",
  Hansestadt = "AX_Ortslage",
  Stadt = "AX_Ortslage",
  krsfr.Stadt = "AX_Ortslage",
  krfr.Stadt = "AX_Ortslage",
  Universitätsstadt = "AX_Ortslage",
  Landkreis = "AX_KreisRegion",
  Kreis = "AX_KreisRegion",
  Stat.Region = "AX_KreisRegion",
  Regionalverband = "AX_KreisRegion",
  Regierungsbezirk = "AX_Regierungsbezirk",
  AX_Gemeinde = NULL, AX_Nationalstaat = NULL, AX_Bundesland = NULL)

# Map content of separate place information to OBD codes
place_clean <- lapply(seq(nrow(place_df)), function(i){
  pt <- gn250_categories[[place_df$B[i]]]
  if(is.null(pt)){
    pt <- NA
  }
  data.frame(place_name = place_df$A[i],
             place_type = pt,
             ID = place_df$ID[i],
             Year = place_df$Year[i])
})
place_clean <- do.call("rbind", place_clean)
place_clean$ID <- as.character(place_clean$ID)

# Take care of remaining NAs in place type by merging "Kreise" first
place_clean[is.na(place_clean$place_type), ]
sum(is.na(place_clean$place_type))

for(r in seq(nrow(place_clean))){
  if(is.na(place_clean$place_type[r]) &
     grepl("kreis", tolower(place_clean$place_name[r]))){
    place_clean$place_type[r] <- "AX_KreisRegion"
  }
}

sum(is.na(place_clean$place_type))
place_clean[is.na(place_clean$place_type), ]

# Take care of remaining NAs in place type by merging "Bundesländer" second
unique(place_clean[is.na(place_clean$place_type) &
              nchar(place_clean$id) < 3, ])

place_clean$place_type[is.na(place_clean$place_type) &
                         place_clean$place_name == "Hamburg"] <- "AX_Ortslage"
place_clean$place_type[is.na(place_clean$place_type) &
                         place_clean$place_name == "Bremen"] <- "AX_Ortslage"
place_clean$place_type[is.na(place_clean$place_type) &
                         place_clean$place_name == "Berlin"] <- "AX_Ortslage"
place_clean$place_type[is.na(place_clean$place_type) &
                         nchar(place_clean$id) < 3] <- "AX_Bundesland"

sum(is.na(place_clean$place_type))
place_clean[is.na(place_clean$place_type), ]

# Take care of remaining NAs in place type by merging some mixed rest
unique(place_clean[(is.na(place_clean$place_type)),])

place_clean$place_type[
  is.na(place_clean$place_type) &
    place_clean$place_name == 
    "StädteregionAachen(einschl.StadtAachen)"] <- "AX_KreisRegion"
place_clean$place_type[is.na(place_clean$place_type)] <- "AX_Ortslage"

sum(is.na(place_clean$place_type))

# Merge separated place information with original data frame and remove original
# place information
lu_clean <- merge(lu, place_clean, by = c("ID", "Year"))
head(lu_clean, 25)

lu_clean$Place <- NULL


# Merge land cover data with geo information -----------------------------------
str(lu_clean)
str(gn250)

lu_clean$place_name <- as.character(lu_clean$place_name)
gn250$OBA <- as.character(gn250$OBA)
gn250$NAME <- as.character(gn250$NAME)

lu_clean$NNID <- NA
lu_clean$Commune <- NA
lu_clean$Municipality <- NA
lu_clean$UTMRE <- NA
lu_clean$UTMHO <- NA
lu_clean$BOX_UTM <- NA

for(i in seq(nrow(lu_clean))){
  if(i %% 100 == 0) print(i)
  m <- gn250[(gn250$OBA == lu_clean$place_type[i] & 
           gn250$NAME == lu_clean$place_name[i]),]
  if(nrow(m) > 0){
    lu_clean$NNID[i] <- m$X.U.FEFF.NNID
    lu_clean$Commune[i] <- m$GEMEINDE
    lu_clean$Municipality[i] <- m$KREIS
    lu_clean$UTMRE[i] <- m$UTMRE
    lu_clean$UTMHO[i] <- m$UTMHO
    lu_clean$BOX_UTM[i] <- m$BOX_UTM
  }
}

unique(lu_clean$place_name[is.na(lu_clean$NNID)])




gn250[(gn250$OBA == "AX_KreisRegion" & gn250$NAME == "Ilm-Kreis"),]
