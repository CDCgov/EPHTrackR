############################################################
##  Sending a welcome message   ##
############################################################

.onAttach <- function(libname, pkgname) {

  packageStartupMessage("Welcome to the CDC Environmental Public Health Tracking Network! This package provides an R interface to the Tracking Network Data API. To easily visualize our data products, please visit https://ephtracking.cdc.gov/DataExplorer/.")
  
}
