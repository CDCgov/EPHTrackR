#' @name geography_types
#' @title Find geographic levels
#' @description  Find geographic levels for specified measures available on the Tracking Network API. If multiple measures are specified, the results for each are returned as separate list elements.
#' @import dplyr
#' @param measure specify the measures of interest
#' @param format indicate whether the listed measure(s) is an ID, name or shortName
#' @param simplified_output logical. Determines whether output table is simplified with only relevant columns (TRUE) or the raw output from the Tracking Network API (FALSE)
#' @return The geographic levels for the specified measures on the CDC Tracking API.
#' @examples \dontrun{
#' geography_types(measure=370,format="ID")
#' geography_types(measure=c(370,423,707),format="ID")
#' geography_types(measure=c("Number of summertime (May-Sep) heat-related deaths, by year",
#'                            "Number of extreme heat days",
#'                            "Number of months of mild drought or worse per year"),
#'                  format="name")
#' geography_types(measure=c("Number of summertime (May-Sep) heat-related deaths, by year",
#'                            "Number of extreme heat days","Number of months of drought per year"),
#'                  format="shortName")
#' geography_types(measure="Number of summertime (May-Sep) heat-related deaths, by year" ,
#' format="name")
#' }
#' @export


### Print out Geographic Levels for a Measure ###

geography_types<-function(measure=NA,
                           format=c("ID","name","shortName"),
                          simplified_output=T){
  format<-match.arg(format)
  meas_formatting<-paste0("measure_",format)
  ind_formatting<-paste0("indicator_",format)
  CA_formatting<-paste0("content_area_",format)

  #load("data/measures_indicators_CAs.RData")
  if(any(is.na(measure))){
    meas_ID<-unique(measures_indicators_CAs$measure_ID)
  }else{
    meas_ID<-
      unique(measures_indicators_CAs$measure_ID
             [which(measures_indicators_CAs[,meas_formatting]%in%measure )])
  }

  GL_list<-purrr::map( 1:length(meas_ID), function(geolev){
    GL<-
      httr::GET(paste0("https://ephtracking.cdc.gov:443/apigateway/api/v1/geographicLevels/",
                 meas_ID[geolev]))

    GL_cont<-jsonlite::fromJSON(rawToChar(GL$content))
    GL_cont$Measure_ID<-meas_ID[geolev]
    GL_cont$Measure_Name<-
      unique(measures_indicators_CAs$measure_name
             [which(measures_indicators_CAs$measure_ID==meas_ID[geolev])])

    GL_cont$Measure_shortName<-
      unique(measures_indicators_CAs$measure_shortName
             [which(measures_indicators_CAs$measure_ID==meas_ID[geolev])])
    
    if(simplified_output == F){
      
      return(unique(GL_cont))
      
    } else{
      
      
      return(unique(dplyr::select(GL_cont,geographicType,
                             geographicTypeId, 
                             Measure_ID ,
                             Measure_Name ,
                             Measure_shortName)))
      
    }
    
  }
  )
  
  return(GL_list)
}

