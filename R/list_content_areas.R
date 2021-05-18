#' @name list_content_areas
#' @title List all content areas 
#' @description  Lists the content areas available on the CDC Tracking Network. Content areas are the highest level of categorization on the CDC Tracking Network.
#' @return This function returns a data frame containing all content area names, shortNames, and IDs.
#' @examples\dontrun{
#' list_content_areas()
#' }
#' @export


### Print out Content Areas ###

list_content_areas<-function(){
  #measures_indicators_CAs<-
  #load("data/measures_indicators_CAs.RData")
  CAs<-unique(EPHTrackR::measures_indicators_CAs[,c("content_area_ID","content_area_name","content_area_shortName")])
  CAs_sorted<-CAs[order(CAs$content_area_ID),]
  rownames(CAs_sorted)<-1:nrow(CAs_sorted)
  CAs_sorted
}

