#' @name measures
#' @title Find Measures
#' @description  Find the measures in specified indicators and/or content areas available on the CDC Tracking API.
#' @param indicator specify the indicators of interest.
#' @param content_area specify the content areas of interest
#' @param format indicate whether the indicator and/or content_area variables are ID, name or shortName
#' @return The measures in the specified indicators and/or content areas on the CDC Tracking API.
#' @examples \dontrun{
#'measures(indicator=67,format="ID")
#'
#'measures(indicator=c(67,173),format = "ID")
#'
#'measures(indicator="Heat-Related Mortality",
#'         format="name")
#'
#'measures(content_area = 25,format="ID")
#'
#'measures(indicator=67,content_area =25,format="ID")
#'
#'measures(indicator="Historical Temperature & Heat Index",content_area ="Drought",format="name")
#'
#'all_measures<-measures()
#' }
#' @export

# library(httr)
# library(jsonlite)
# library(plyr)


### Print out Measures within an Indicator and/or Content Area ###

measures<-function(indicator=NA,content_area=NA,
                   format=c("ID","name","shortName")){
  format<-match.arg(format)
  ind_formatting<-paste0("indicator_",format)
  CA_formatting<-paste0("content_area_",format)
  #load("data/measures_indicators_CAs.RData")
  if(any(is.na(indicator)) & any(is.na(content_area))){
    measures<-
      unique(measures_indicators_CAs[,c("measure_ID","measure_name",
                                        "measure_shortName","indicator_ID",
                                        "indicator_name","indicator_shortName",
                                        "content_area_ID","content_area_name",
                                        "content_area_shortName")])
  }else{
    measures<-
      unique(measures_indicators_CAs
             [which(measures_indicators_CAs[,ind_formatting]%in%indicator |
                      measures_indicators_CAs[,CA_formatting]%in%content_area),
               c("measure_ID","measure_name","measure_shortName","indicator_ID",
                 "indicator_name","indicator_shortName","content_area_ID",
                 "content_area_name","content_area_shortName")])
  }
  measures_sorted<-
    measures[order(measures$measure_ID,
                   measures$indicator_ID,
                   measures$content_area_ID),]
  rownames(measures_sorted)<-1:nrow(measures_sorted)
  measures_sorted
}

