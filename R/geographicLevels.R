#' @name geographicLevels
#' @title Find geographic levels
#' @description  Find geographic levels for specified measures available on the CDC Tracking API.
#' @import dplyr
#' @param measure specify the measures of interest
#' @param indicator specify the indicators of interest
#' @param content_area specify the content areas of interest
#' @param format indicate whether the measure, indicator and/or content_area variables are ID, name or shortName
#' @return The geographic levels for the specified measures on the CDC Tracking API.
#' @examples \dontrun{
# geographicLevels(measure=370,format="ID")
# geographicLevels(measure=c(370,423,707),format="ID")
# geographicLevels(measure=c("Number of summertime (May-Sep) heat-related deaths, by year",
#                            "Number of extreme heat days",
#                            "Number of months of mild drought or worse per year"),
#                  format="name")
# geographicLevels(measure=c("Number of summertime (May-Sep) heat-related deaths, by year",
#                            "Number of extreme heat days","Number of months of drought per year"),
#                  format="shortName")
# geographicLevels(content_area = 25,format="ID")
# geographicLevels(indicator="Historical Heat Days",
#                  content_area ="DR",format="shortName")
# geographicLevels(measure="Number of summertime (May-Sep) heat-related deaths, by year" ,
#                  indicator="Historical Extreme Heat Days and Events",
#                  content_area ="Drought",format="name")
#' }
#' @export

#library(httr)
#library(jsonlite)
#library(plyr)


### Print out Geographic Levels for a Measure ###

geographicLevels<-function(measure=NA,indicator=NA,
                           content_area=NA,
                           format=c("ID","name","shortName")){
  format<-match.arg(format)
  meas_formatting<-paste0("measure_",format)
  ind_formatting<-paste0("indicator_",format)
  CA_formatting<-paste0("content_area_",format)

  #load("data/measures_indicators_CAs.RData")
  if(any(is.na(measure)) & any(is.na(indicator)) &
     any(is.na(content_area))){
    meas_ID<-unique(measures_indicators_CAs$measure_ID)
  }else{
    meas_ID<-
      unique(measures_indicators_CAs$measure_ID
             [which(measures_indicators_CAs[,meas_formatting]%in%measure |
                      measures_indicators_CAs[,ind_formatting]%in%indicator |
                      measures_indicators_CAs[,CA_formatting]%in%content_area )])
  }

  GL_list<-list()
  for(geolev in 1:length(meas_ID)){
    GL<-
      httr::GET(paste0("https://ephtracking.cdc.gov:443/apigateway/api/v1/geographicLevels/",
                 meas_ID[geolev]))

    GL_list[[geolev]]<-jsonlite::fromJSON(rawToChar(GL$content))
    GL_list[[geolev]]$Measure_ID<-meas_ID[geolev]
    GL_list[[geolev]]$Measure_Name<-
      unique(measures_indicators_CAs$measure_name
             [which(measures_indicators_CAs$measure_ID==meas_ID[geolev])])

    GL_list[[geolev]]$Measure_shortName<-
      unique(measures_indicators_CAs$measure_shortName
             [which(measures_indicators_CAs$measure_ID==meas_ID[geolev])])
  }
  unique(purrr::map_dfr(GL_list,as.data.frame))
}

