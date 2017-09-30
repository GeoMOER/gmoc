# da-ws-05-1
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# Linear regression

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


# Read data files --------------------------------------------------------------
# Pre-cleaned data from da-ws-04-1
lu <- readRDS(paste0(path_rdata, "lu_clean.rds"))

plot(lu$Settlement, lu$Recreation)
lmod <- lm(lu$Recreation ~ lu$Settlement)

summary(lmod)
abline(lmod, col = "red")
  
par_org <- par()
par(mfrow = c(2,2))
plot(lmod)
par(par_org)


plot(lmod$fitted.values, lmod$residuals)
plot(lmod$model$`lu$Settlement`, lmod$residuals)

plot(lu$Settlement, sqrt(lu$Recreation))
lmod_sqrt <- lm(sqrt(lu$Recreation) ~ lu$Settlement)

summary(lmod_sqrt)
abline(lmod_sqrt, col = "red")

par_org <- par()
par(mfrow = c(2,2))
plot(lmod_sqrt)
par(par_org)
  
shapiro.test(lmod$residuals)
shapiro.test(lmod_sqrt$residuals)
