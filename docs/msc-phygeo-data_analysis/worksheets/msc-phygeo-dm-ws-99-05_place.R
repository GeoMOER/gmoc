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
path_vectors <- paste0(path_data, "vectors/")
path_rdata <- paste0(path_data, "rdata/")
path_temp <- paste0(filepath_base, "temp/")


library(raster)
library(rgdal)
library(sp)
library(reshape2)


# Read data files --------------------------------------------------------------
# Pre-cleaned data from da-ws-04-1
lu <- readRDS(paste0(path_rdata, "lu_clean.rds"))
cp <- readRDS(paste0(path_rdata, "cp_clean.rds"))

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

head(vg250_lu,25)
summary(vg250_lu)
length(unique(vg250_lu$DEBKG_ID))

vg250_lu <- vg250_lu[vg250_lu$SN_V1 == "00" & vg250_lu$SN_V2 == "00", ]
length(unique(vg250_lu$DEBKG_ID))

saveRDS(vg250_lu, paste0(path_rdata, "vg250_lu.rds"))

lu_final <- vg250_lu[, c("DEBKG_ID", names(lu)[names(lu)!= "ID"])]
head(lu_final)
saveRDS(lu_final, paste0(path_rdata, "lu_final.rds"))

# Crop
str(vg250)
str(cp)

vg250_cp <- merge(vg250, cp, by.x = "AGS", by.y = "ID")
nrow(vg250_cp)

head(vg250_cp, 20)
summary(vg250_cp)
length(unique(vg250_cp$DEBKG_ID))

vg250_cp <- vg250_cp[vg250_cp$SN_V1 == "00" & vg250_cp$SN_V2 == "00", ]
length(unique(vg250_cp$DEBKG_ID))

saveRDS(vg250_cp, paste0(path_rdata, "vg250_cp.rds"))

cp_final <- vg250_cp[, c("DEBKG_ID", names(cp)[names(cp)!= "ID"])]
head(cp_final)
saveRDS(cp_final, paste0(path_rdata, "cp_final.rds"))

# Combined lu and crop
lu_cp_final <- merge(lu_final, cp_final)

head(lu_cp_final)
summary(lu_cp_final)
length(unique(lu_cp_final$DEBKG_ID))
saveRDS(lu_cp_final, paste0(path_rdata, "lu_cp_final.rds"))


