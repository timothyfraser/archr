#' @name dev_package.R
#'
#'

library(devtools)

setwd("C:/Users/tmf77/OneDrive - Cornell University/Documents/rstudio/archr/")
getwd()

unloadNamespace("archr"); remove.packages("archr"); rm(list = ls()); gc()
# Document your functions and data
devtools::document()
# Build packages
devtools::build(pkg = ".", path = getwd(), binary = FALSE, vignettes = FALSE, manual = FALSE)

unloadNamespace("archr");remove.packages("archr")
install.packages("archr_1.0.tar.gz", type = "source")


# archr::get_edges()
