############################################################
##  Suggesting to update inventory   ##
############################################################

.onAttach <- function(libname, pkgname) {

  packageStartupMessage("Run `update_inventory()` to update the stored list of content areas, indicators, and measures.")
  
}
