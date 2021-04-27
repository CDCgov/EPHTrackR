#' @name content_areas
#' @title Print Content Areas
#' @description  Print the content areas available on the CDC Tracking API.
#' @return The content areas on the CDC Tracking API.
#' @examples\dontrun{
#' content_areas()
#' }
#' @export


### Print out Content Areas ###

content_areas<-function(){
  #measures_indicators_CAs<-
  #load("data/measures_indicators_CAs.RData")
  CAs<-unique(measures_indicators_CAs[,c("content_area_ID","content_area_name","content_area_shortName")])
  CAs_sorted<-CAs[order(CAs$content_area_ID),]
  rownames(CAs_sorted)<-1:nrow(CAs_sorted)
  CAs_sorted
}

