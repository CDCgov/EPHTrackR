#' @name list_measures
#' @title List measures
#' @description  List the measures contained within specified indicator/s and/or content area/s. Measures are the core data product of the Tracking Network.
#' @param indicator Optional argument used to specify the indicator/s of interest as an ID, name, or shortName. IDs should be unquoted, while name and shortName entries should be quoted strings. Available indicators can be identified using list_indicators().
#' @param content_area Optional argument used to specify the content area/s of interest as an ID, name, or shortName. IDs should be unquoted, while name and shortName entries should be quoted strings. Available content areas can be identified using list_content_areas().
#' @param format Indicates whether the measure argument contains entries formatted as an ID, name or shortName as a quoted string (e.g., "name", "shortName"). The default is ID.
#' @return This function returns a data frame containing the measures within the specified indicator/s and/or content area/s.
#' @examples \dontrun{
#' 
#' 
#'list_measures(indicator=67,format="ID")
#'
#'list_measures(indicator=c(67,173),format = "ID")
#'
#'list_measures(indicator="Heat-Related Mortality",
#'         format="name")
#'
#'list_measures(content_area = 25,format="ID")
#'
#'list_measures(indicator=67,content_area =25,format="ID")
#'
#'list_measures(indicator="Historical Temperature & Heat Index",content_area ="Drought",format="name")
#'
#'all_measures<-list_measures()
#'
#'
#' }
#' @export

# library(httr)
# library(jsonlite)
# library(plyr)


### Print out Measures within an Indicator and/or Content Area ###

list_measures<-function(indicator=NA,content_area=NA,
                   format="ID"){
  
  format<-match.arg(format, choices = c("ID","name","shortName"))
  
  ind_formatting<-paste0("indicator_",format)
  CA_formatting<-paste0("content_area_",format)
  #load("data/measures_indicators_CAs.RData")
  if(any(is.na(indicator)) & any(is.na(content_area))){
    measures<-
      unique(EPHTrackR::measures_indicators_CAs[,c("measure_ID","measure_name",
                                        "measure_shortName","indicator_ID",
                                        "indicator_name","indicator_shortName",
                                        "content_area_ID","content_area_name",
                                        "content_area_shortName")])
  }else{
    measures<-
      unique(EPHTrackR::measures_indicators_CAs
             [which(EPHTrackR::measures_indicators_CAs[,ind_formatting]%in%indicator |
                      EPHTrackR::measures_indicators_CAs[,CA_formatting]%in%content_area),
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

