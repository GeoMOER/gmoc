# rs-ws-08-2
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# Predict LCC using gpm

# Set environment --------------------------------------------------------------
if(Sys.info()["sysname"] == "Windows"){
  source("D:/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
} else {
  source("/media/permanent/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
}


# Prepare gpm data set used for remote sensing prediction study ----------------
set_run <- "smpl"

if(set_run == "large"){
  obsv <- readRDS(file = paste0(path_lcc_training_areas, "muf_lc_ta_cmb_cc.rds"))
  obsv <- obsv[which(obsv$ID %in% names(table(obsv$ID)[table(obsv$ID) > 1000])),]
  p_val <- 0.005
} else if(set_run == "smpl"){
  obsv <- readRDS(file = paste0(path_lcc_training_areas, "muf_lc_ta_smpl_cc.rds"))
  obsv <- obsv[which(obsv$ID %in% names(table(obsv$ID)[table(obsv$ID) > 100])),]
  p_val <- 0.65
}

obsv <- obsv[, c(which("ID" == colnames(obsv)),
                             which("ortho_muf_1m.tif" == colnames(obsv)),
                             which("ortho_muf_NGRDI_glcm_mean_w3.tif" == colnames(obsv)),
                             which("ortho_muf_NGRDI_glcm_mean_w21.tif" == colnames(obsv)))]

obsv <- obsv[complete.cases(obsv),]
obsv <- obsv[!is.infinite(obsv$ortho_muf_NGRDI_glcm_mean_w3.tif),]
obsv <- obsv[!is.infinite(obsv$ortho_muf_NGRDI_glcm_mean_w21.tif),]

obsv$ID <- as.factor(obsv$ID)

col_selector <- which(names(obsv) == "ID")
col_meta <- NULL
col_lc <- which(names(obsv) == "ID")
col_precitors <- seq(which(names(obsv) == "ortho_muf_1m.tif"),
                   which(names(obsv) == "ortho_muf_NGRDI_glcm_mean_w21.tif"))
    
meta <- createGPMMeta(obsv, type = "input",
                      selector = col_selector, 
                      response = col_lc, 
                      predictor = col_precitors, 
                      meta = col_meta)

obsv <- gpm(obsv, meta, scale = FALSE)



# Clean predictor variables ----------------------------------------------------
# if(compute){
#   cprj <- c("wgs", "arc")
#   obsv_gpm <- lapply(cprj, function(prj){
#     obsv <- obsv_gpm[[prj]]
#     obsv <- cleanPredictors(x = obsv, nzv = TRUE, 
#                             highcor = TRUE, cutoff = 0.90)
#     return(obsv)
#   })
#   names(obsv_gpm) <- cprj
#   saveRDS(obsv_gpm, file = paste0(path_results, "gls_obsv_gpm_cleanPredictors.rds"))
# } else {
#   obsv_gpm <- readRDS(file = paste0(path_results, "gls_obsv_gpm_cleanPredictors.rds"))
# }


# Compile model training and evaluation dataset --------------------------------
obsv <- resamplingsByVariable(x = obsv,
                              use_selector = FALSE,
                              resample = 5)
    
# Split resamples into training and testing samples
obsv <- splitMultResp(x = obsv, 
                      p = p_val, 
                      use_selector = FALSE)


# Train and build model --------------------------------------------------------
models <- trainModel(x = obsv,
                     n_var = NULL, 
                     mthd = "rf",
                     mode = "rfe",
                     seed_nbr = 11, 
                     cv_nbr = 5,
                     var_selection = "indv", 
                     filepath_tmp = NULL)

if(set_run == "large"){
  saveRDS(models, file = paste0(path_muf_set1m_sample_test_01, "gpm_poly_large.rds"))
} else if(set_run == "smpl"){
  saveRDS(models, file = paste0(path_muf_set1m_sample_test_01, "gpm_poly_smpl.rds"))
}

gpm_poly_large <- readRDS(file = paste0(path_muf_set1m_sample_test_01, "gpm_poly_large.rds"))
gpm_poly_large@model$rf_rfe[[1]][[1]]$model
tstat_gpm_poly_large <- compContTests(gpm_poly_large@model$rf_rfe, mean = FALSE)

gpm_poly_smpl <- readRDS(file = paste0(path_muf_set1m_sample_test_01, "gpm_poly_smpl.rds"))
gpm_poly_smpl@model$rf_rfe[[1]][[1]]$model
tstat_gpm_poly_smpl <- compContTests(gpm_poly_smpl@model$rf_rfe, mean = FALSE)


# Predict lcc ------------------------------------------------------------------
library(randomForest)
muf_data <- stack(paste0(path_muf_set1m_sample_non_segm, "ortho_muf_1m.tif"),
                  paste0(path_muf_set1m_sample_non_segm, "ortho_muf_NGRDI_glcm_mean_w3.tif"),
                  paste0(path_muf_set1m_sample_non_segm, "ortho_muf_NGRDI_glcm_mean_w21.tif"))

ortho_muf_1m.tif <- getValues(muf_data[[1]])
ortho_muf_NGRDI_glcm_mean_w3.tif <- getValues(muf_data[[4]])
ortho_muf_NGRDI_glcm_mean_w21.tif <- getValues(muf_data[[5]])

# Remove NAs
new_data <- data.frame(ortho_muf_1m.tif, ortho_muf_NGRDI_glcm_mean_w3.tif, ortho_muf_NGRDI_glcm_mean_w21.tif)
new_data$ortho_muf_NGRDI_glcm_mean_w3.tif[is.na(new_data$ortho_muf_NGRDI_glcm_mean_w3.tif)] <- 0
new_data$ortho_muf_NGRDI_glcm_mean_w21.tif[is.na(new_data$ortho_muf_NGRDI_glcm_mean_w21.tif)] <- 0


# Predict land-cover using model based on large polygons
gpm_poly_large_lcc <- predict(gpm_poly_large@model$rf_rfe[[1]][[1]]$model$fit, newdata = new_data,
                              na.action = na.pass)
gpm_poly_large_lcc_raster <- setValues(muf_data[[1]], as.numeric(as.character(gpm_poly_large_lcc)))
writeRaster(gpm_poly_large_lcc_raster,
            file = paste0(path_muf_set1m_sample_test_01, "gpm_poly_large_lcc_raster.tif"))


# Predict land-cover using model based on small polygons
gpm_poly_smpl_lcc <- predict(gpm_poly_smpl@model$rf_rfe[[1]][[1]]$model$fit, newdata = new_data,
                              na.action = na.pass)
gpm_poly_smpl_lcc_raster <- setValues(muf_data[[1]], as.numeric(as.character(gpm_poly_smpl_lcc)))
writeRaster(gpm_poly_smpl_lcc_raster,
            file = paste0(path_muf_set1m_sample_test_01, "gpm_poly_smpl_lcc_raster.tif"))
