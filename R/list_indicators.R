#' @name list_indicators
#' @title List indicators
#' @description  Lists the indicators contained within the specified content area(s). Indicators are groups of highly related measures.
#' @param content_area Optional argument used to specify the content area(s) of interest as an ID, name, or shortName. IDs should be unquoted; name and shortName entries should be quoted strings. Use list_content_areas() to identify available content areas.
#' @param format Indicates whether the measure argument contains entries formatted as an ID, name, or shortName as a quoted string (e.g., "name", "shortName"). The default is ID.
#' @return This function returns a data frame containing all indicator names, shortNames, and IDs contained in the specified content area(s).
#' @examples \dontrun{
#' 
#' 
#' list_indicators(25,"ID")
#' 
#' list_indicators("Drought","name")
#' 
#' list_indicators("DR","shortName")
#' 
#' all_indicators<-list_indicators()
#' 
#' 
#' }
#' @export


### Print out Indicators within a Content Area ###
list_indicators<-function(content_area=NA,
                     format="ID"){
  
  format<-match.arg(format, choices = c("ID","name","shortName"))
  
  formatting<-paste0("content_area_",format)
  #load("data/measures_indicators_CAs.RData")
  if(any(is.na(content_area))){
    indicators<-
      unique(EPHTrackR::measures_indicators_CAs
             [,c("indicator_ID","indicator_name",
                 "indicator_shortName","content_area_ID",
                 "content_area_name","content_area_shortName")])
  }else{
    indicators<-
      unique(EPHTrackR::measures_indicators_CAs
             [which(EPHTrackR::measures_indicators_CAs[,formatting]%in%content_area),
               c("indicator_ID","indicator_name","indicator_shortName",
                 "content_area_ID","content_area_name","content_area_shortName")])
  }
  indicators_sorted<-
    indicators[order(indicators$indicator_ID,indicators$content_area_ID),]
  rownames(indicators_sorted)<-1:nrow(indicators_sorted)
  indicators_sorted
}


