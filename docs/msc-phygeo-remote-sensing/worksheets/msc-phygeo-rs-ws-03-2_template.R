# rs-ws-03-1
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# Check radiometric image alignment

# Set environment --------------------------------------------------------------
if(Sys.info()["sysname"] == "Windows"){
  source("D:/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
} else {
  source("/media/permanent/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
}


# Get filepath of aerial tiles -------------------------------------------------
# ...

# To use the function, just call it
neighbours <- ngb_aerials(...)

#...

# Save intermediate results which form the basis for the descriptive analysis  -
# This example assumes that the results are stored in the variable "results".
saveRDS(results, file = paste0(path_rdata, "rs-ws-03-2.rds"))

results <- readRDS(paste0(path_rdata, "rs-ws-03-2.RDS"))