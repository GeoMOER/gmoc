# da-ws-05-1
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# Linear regression

# Set path ---------------------------------------------------------------------
if(Sys.info()["sysname"] == "Windows"){
  filepath_base <- "C:/Users/tnauss/permanent/edu/gmoc_data/msc-phygeo-data-analysis/"
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

lu <- lu[complete.cases(lu[, 6:9]),]

plot(lu$Settlement, lu$Recreation)
lmod <- lm(lu$Recreation ~ lu$Settlement)

summary(lmod)
abline(lmod, col = "red")
  
par_org <- par()
par(mfrow = c(2,2))
plot(lmod)
par(par_org)

# Leave one out cross-validation
cv <- lapply(seq(nrow(lu)), function(i){
  train <- lu[-i,]
  test <- lu[i,]
  lmod <- lm(Recreation ~ Settlement, data = train)
  pred <- predict(lmod, newdata = test)
  obsv <- test$Recreation
  data.frame(pred = pred,
             obsv = obsv,
             model_r_squared = summary(lmod)$r.squared)
})
cv <- do.call("rbind", cv)

ss_obsrv <- sum((cv$obsv - mean(cv$obsv))**2)
ss_model <- sum((cv$pred - mean(cv$obsv))**2)
ss_resid <- sum((cv$obsv - cv$pred)**2)

mss_obsrv <- ss_obsrv / (length(cv$obsv) - 1)
mss_model <- ss_model / 1
mss_resid <- ss_resid / (length(cv$obsv) - 2)

mss_model / mss_resid
anova(lmod)

ss_model / ss_obsrv
summary(lmod)
summary(cv$model_r_squared)

# Leave many out
range <- nrow(lu)
nbr <- nrow(lu) * 0.2

cv_sample <- lapply(seq(100), function(i){
  set.seed(i)
  smpl <- sample(range, nbr)
  train <- lu[smpl,]
  test <- lu[-smpl, ]
  lmod <- lm(Recreation ~ Settlement, data = train)
  pred <- predict(lmod, newdata = data.frame(Settlement = test$Settlement))
  obsv <- test$Recreation
  ind <- test$Settlement
  resid <- obsv-pred
  ss_obsrv <- sum((obsv - mean(obsv))**2)
  ss_model <- sum((pred - mean(obsv))**2)
  ss_resid <- sum((obsv - pred)**2)
  mss_obsrv <- ss_obsrv / (length(obsv) - 1)
  mss_model <- ss_model / 1
  mss_resid <- ss_resid / (length(obsv) - 2)
  
  data.frame(pred = pred,
             obsv = obsv,
             ind = ind,
             resid = resid,
             ss_obsrv = ss_obsrv,
             ss_model = ss_model,
             ss_resid = ss_resid,
             mss_obsrv = mss_obsrv,
             mss_model = mss_model,
             mss_resid = mss_resid,
             r_squared = ss_model / ss_obsrv
  )
})
cv_sample <- do.call("rbind", cv_sample)

ss_obsrv <- sum((cv_sample$obsv - mean(cv_sample$obsv))**2)
ss_model <- sum((cv_sample$pred - mean(cv_sample$obsv))**2)
ss_resid <- sum((cv_sample$obsv - cv_sample$pred)**2)

mss_obsrv <- ss_obsrv / (length(cv_sample$obsv) - 1)
mss_model <- ss_model / 1
mss_resid <- ss_resid / (length(cv_sample$obsv) - 2)

anova(lmod)

r_squared <- ss_model / ss_obsrv
summary(cv_sample$r_squared)
summary(lmod)

plot(cv_sample$ind, cv_sample$resid)


# Wood -------------------------------------------------------------------------
woodhrv <- read.table(paste0(path_csv, "hessen_holzeinschlag_1997-2014_clean.csv"),
                      skip = 0, header = TRUE, sep = ",")
woodhrv

lmod <- lm(Buche ~ Eiche, woodhrv)
summary(lmod)

par_org <- par()
par(mfrow = c(2,2))
plot(lmod)
par(par_org)

# Leave one out cross-validation
cv <- lapply(seq(nrow(woodhrv)), function(i){
  train <- woodhrv[-i,]
  test <- woodhrv[i,]
  lmod <- lm(Buche ~ Eiche, data = train)
  pred <- predict(lmod, newdata = data.frame(Eiche = test$Eiche))
  obsv <- test$Buche
  data.frame(pred = pred,
             obsv = obsv,
             model_r_squared = summary(lmod)$r.squared)
})
cv <- do.call("rbind", cv)

ss_obsrv <- sum((cv$obsv - mean(cv$obsv))**2)
ss_model <- sum((cv$pred - mean(cv$obsv))**2)
ss_resid <- sum((cv$obsv - cv$pred)**2)

mss_obsrv <- ss_obsrv / (length(cv$obsv) - 1)
mss_model <- ss_model / 1
mss_resid <- ss_resid / (length(cv$obsv) - 2)

mss_model / mss_resid
anova(lmod)

ss_model / ss_obsrv
summary(lmod)
summary(cv$model_r_squared)



