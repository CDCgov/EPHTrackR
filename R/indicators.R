#' @name indicators
#' @title Find Indicators
#' @description  Find the indicators in specified content areas available on the CDC Tracking API.
#' @param content_area specify the content areas of interest
#' @param format indicate whether the content_area variable is an ID, name or shortName
#' @return The indicators in the specified content areas on the CDC Tracking API.
#' @examples
#' indicators(25,"ID")
#' indicators("Drought","name")
#' indicators("DR","shortName")
#'
#' indicators(c(15,25),"ID")
#' indicators(c("Climate Change","Drought"),"name")
#' indicators(c("CC","DR"),"shortName")
#' all_indicators<-indicators()
#' @export


### Print out Indicators within a Content Area ###
indicators<-function(content_area=NA,
                     format=c("ID","name","shortName")){
  format<-match.arg(format)
  formatting<-paste0("content_area_",format)
  #load("data/measures_indicators_CAs.RData")
  if(any(is.na(content_area))){
    indicators<-
      unique(measures_indicators_CAs
             [,c("indicator_ID","indicator_name",
                 "indicator_shortName","content_area_ID",
                 "content_area_name","content_area_shortName")])
  }else{
    indicators<-
      unique(measures_indicators_CAs
             [which(measures_indicators_CAs[,formatting]%in%content_area),
               c("indicator_ID","indicator_name","indicator_shortName",
                 "content_area_ID","content_area_name","content_area_shortName")])
  }
  indicators_sorted<-
    indicators[order(indicators$indicator_ID,indicators$content_area_ID),]
  rownames(indicators_sorted)<-1:nrow(indicators_sorted)
  indicators_sorted
}


