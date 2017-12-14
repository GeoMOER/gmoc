# rs-ws-03-2
# MOC - Remote Sensing (T. Nauss, C. Reudenbach)
# 
#' Compute Kappa based on contingency table
#' 
#' @description
#' Compute Kappa index.
#'
#' @param ctable Contingency table
#'
#' @return Kappa index.
#'
compKappa <- function(ctable){
  ctable <- ctable/sum(ctable)
  categories <- nrow(ctable)
  
  # Fraction of agreement
  pagrm <- 0
  for(i in seq(categories)){
    pagrm <- pagrm + ctable[i,i]
  }
  
  # Expected fraction of agreement subject to the observed distribution
  pexpct <- 0
  for(i in seq(categories)){
    pexpct <- pexpct + sum(ctable[i,]) * sum(ctable[,i])
  }
  
  # Kappa index
  kappa <- (pagrm - pexpct)/(1 - pexpct)
  
  return(kappa)
}