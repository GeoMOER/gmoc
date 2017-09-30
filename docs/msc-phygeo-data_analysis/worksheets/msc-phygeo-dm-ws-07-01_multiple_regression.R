# da-ws-07-1
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# Multiple linear regression, forward feature selection

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
cp <- readRDS(paste0(path_rdata, "cp_clean.rds"))

# dm-ws-07-1
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# Multiple linear regression, forward feature selection
# Forward feature selection function -------------------------------------------
forward_feature_selection <- function(data, dep, vars, selected_vars = NULL){
  
  fwd_fs <- lapply(seq(length(vars)), function(v){
    if(is.null(selected_vars)){
      formula <- paste(dep, " ~ ", paste(vars[v], collapse=" + "))
    } else {
      formula <- paste(dep, " ~ ", paste(c(selected_vars, vars[v]), collapse=" + "))
    }
    
    lmod <- lm(formula, data = data)
    results <- data.frame(Variable = vars[v],
                          Adj_R_sqrd = round(summary(lmod)$adj.r.squared, 4),
                          AIC = round(AIC(lmod), 4))
    return(results)
  })
  fwd_fs <- do.call("rbind", fwd_fs)
  
  if(!is.null(selected_vars)){
    formula <- paste(dep, " ~ ", paste(selected_vars, collapse=" + "))
    lmod <- lm(formula, data = data)
    results_selected <- data.frame(Variable = paste0("all: ", 
                                                     paste(selected_vars, 
                                                           collapse=", ")),
                                   Adj_R_sqrd = round(summary(lmod)$adj.r.squared, 4),
                                   AIC = round(AIC(lmod), 4))
  } else {
    results_selected <- data.frame(Variable = paste0("all: ", 
                                                     paste(selected_vars, 
                                                           collapse=", ")),
                                   Adj_R_sqrd = 0,
                                   AIC = 1E10)
  }
  
  # best_var <- as.character(fwd_fs$Variable[which(fwd_fs$AIC == min(fwd_fs$AIC))])
  # min_AIC <- min(fwd_fs$AIC)
  # fwd_fs <- rbind(results_selected, fwd_fs)
  # return(list(best_var, min_AIC, fwd_fs))
  
  best_var <- as.character(fwd_fs$Variable[which(fwd_fs$Adj_R_sqrd == max(fwd_fs$Adj_R_sqrd))])
  max_adj_r_sqrd <- max(fwd_fs$Adj_R_sqrd)
  fwd_fs <- rbind(results_selected, fwd_fs)
  return(list(best_var, max_adj_r_sqrd, fwd_fs))
}


# Multiple linear model --------------------------------------------------------
dep <- "Winter_wheat"
next_vars <- names(cp)[-c(1:5, which(names(cp) == dep))]
selected_vars <- NULL

run <- forward_feature_selection(data = cp, dep = dep, vars = next_vars)

while(run[[2]] >= run[[3]]$Adj_R_sqrd[1]){
  selected_vars <- c(selected_vars, run[[1]])
  next_vars <- next_vars[-which(next_vars == run[[1]])]
  run <- forward_feature_selection(data = cp, dep = dep, 
                                   vars = next_vars, 
                                   selected_vars = selected_vars)
}
run







run = TRUE
while(act_run[[3]]$AIC[1] >= act_run[[2]] & run == TRUE){
  next_vars <- next_vars[-which(next_vars == act_run[[1]])]
  selected_vars = c(selected_vars, act_run[[1]])
  if(length(next_vars) > 0){
    act_run <- forward_feature_selection(data = cp, dep = dep, vars = next_vars,
                                         selected_vars = selected_vars)
  } else {
    run <- FALSE
  }
}
act_run



dep <- "Winter_wheat"
next_vars <- names(cp)[-c(1:5, which(names(cp) == dep))]
selected_vars <- NULL

act_run <- forward_feature_selection(data = cp, dep = dep, vars = next_vars)

run = TRUE
while(act_run[[3]]$Adj_R_sqrd[1] <= act_run[[2]] & run == TRUE){
  next_vars <- next_vars[-which(next_vars == act_run[[1]])]
  selected_vars = c(selected_vars, act_run[[1]])
  if(length(next_vars) > 0){
    act_run <- forward_feature_selection(data = cp, dep = dep, vars = next_vars,
                                         selected_vars = selected_vars)
  } else {
    run <- FALSE
  }
}
act_run
