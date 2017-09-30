# Set path ---------------------------------------------------------------------
if(Sys.info()["sysname"] == "Windows"){
  filepath_base <- "D:/active/moc/msc-phygeo-data-analysis/"
} else {
  filepath_base <- "/media/permanent/active/moc/msc-phygeo-data-analysis/"
}

path_data <- paste0(filepath_base, "data/")
path_csv <- paste0(path_data, "csv/")
path_rdata <- paste0(path_data, "rdata/")
path_temp <- paste0(filepath_base, "temp/")


library(reshape2)

# Read csv file and clean data frame -------------------------------------------
woodhrv <- read.table(paste0(path_csv, "hessen_holzeinschlag_1997-2014_clean.csv"),
                      skip = 0, header = TRUE, sep = ",")
woodhrv


# Summarize --------------------------------------------------------------------
summary(woodhrv)


# Visualize descriptive summary statistics ------------------------------------
boxplot(woodhrv)

head(woodhrv)

t.test(woodhrv$Buche, woodhrv$Fichte)
t.test(woodhrv$Buche, woodhrv$Fichte, var.equal = TRUE)

woodhrv_long <- melt(woodhrv, id.vars = "FWJ")

woodhrv_lm <- lm(value ~ variable, data = woodhrv_long)
summary(woodhrv_lm)


anova(woodhrv_lm)

summary(aov(woodhrv_long$value ~ woodhrv_long$variable))

confint(woodhrv_lm)

woodhrv_check = data.frame(Fitted = fitted(woodhrv_lm),
                       Residuals = resid(woodhrv_lm), Species = woodhrv_long$variable)

ggplot(woodhrv_check, aes(Fitted, Residuals, colour = Species)) + geom_point()



pts = seq(-4.5,4.5,length=100)
dof <- length(pts)-2

plot(pts, dnorm(pts), type = "l")
lines(pts, dt(pts, df = dof), col = "red")
lines(pts, rchisq(pts, df = dof), col = "green")



# dist <- rt(ppoints(length(lu$Settlement)), df = length(lu$Settlement)-2)
# plot(density(dist))
# hist(lu$Settlement[!is.na(lu$Settlement)])
# qqplot(dist, lu$Settlement, main = "Normal")
# > abline(lm(quantile(lu$Settlement, na.rm = TRUE, probs = c(0.25, 0.75)) ~
#               + quantile(dist, probs = c(0.25, 0.75))), col = "red", lwd = 2)
# > plot(pts, dnorm(pts), type = "l")
# > lines(pts, dt(pts, df = dof), col = "red")



t <- replicate(10000,t.test(rnorm(10),rnorm(10))$statistic)
pts = seq(-4.5,4.5,length=100)
plot(pts,dt(pts,df=18),col='red',type='l')
lines(density(t))


yrange <- c(min(woodhrv[,-1], na.rm = TRUE), max(woodhrv[,-1], na.rm = TRUE))
colors <- c("blue", "green", "red")

plot(woodhrv$Buch ~ woodhrv$FWJ, type = "l", col = "blue", ylim = yrange)
lines(woodhrv$Fichte ~ woodhrv$FWJ, col = "green")
lines(woodhrv$Kiefer ~ woodhrv$FWJ, col = "red")


legend("topleft", pch=16, col=c("red", "green"), legend=c("Buche", "Fichte"), bty = "n")


par(mfrow = c(2,2))
plot(woodhrv$Eiche, woodhrv$Buche)
plot(woodhrv$Kiefer, woodhrv$Buche)
plot(woodhrv$Fichte, woodhrv$Buche)
plot(woodhrv$Buntholz, woodhrv$Buche)
par(par_org)




