# da-06
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# Images for slides
# 
# The code used for this visualization has been posted by Todos Logos on 
# Rbloggers
# https://www.r-bloggers.com/how-to-plot-points-regression-line-and-residuals/

library(calibrate)

independentendent <- anscombe$x1
dependent <- anscombe$y1

plot(independentendent, dependent)
for(i in seq(length(independentendent))){
  abline(lm(dependent[-i] ~ independentendent[-i]), col = "red")
}

dev.copy(jpeg,
         'D:/active/moc/msc-phygeo-data-analysis/scripts/msc-phygeo-data_management/src/slides/cross_validation.jpg', quality = 100)
dev.off()
