#' @name stratificationlevel
#' @title Find stratification levels
#' @description  Find stratification levels for specified measures and geographic types available on the CDC Tracking API.
#' @import dplyr
#' @param measure specify the measures of interest
#' @param indicator specify the indicators of interest
#' @param content_area specify the content areas of interest
#' @param geo_type specify the Geographic type.
#' @param geo_type_ID specify the Geographic type ID.
#' @param format indicate whether the measure, indicator and/or content_area variables are ID, name or shortName
#' @param smoothing default is 0. Specify whether data is geographically smoothed(1) or not (0).
#' @return The stratification levels for the specified measures and stratification levels on the CDC Tracking API.
#' @examples \dontrun{
# measurestratification(measure=370,format="ID")
# measurestratification(measure=c(370,423,707),format="ID")
# measurestratification(measure=c("Number of summertime (May-Sep) heat-related deaths, by year",
#                                 "Number of extreme heat days","Number of months of mild drought or worse per year"),
#                       format="name")
# measurestratification(measure=c("Number of summertime (May-Sep) heat-related deaths, by year",
#                                 "Number of extreme heat days","Number of months of drought per year"),
#                       format="shortName")
# measurestratification(content_area = 25,format="ID")
# measurestratification(indicator="Historical Heat Days",
#                       content_area ="DR",format="shortName")
# measurestratification(indicator="Historical Heat Days",
#                       content_area ="DR",geo_type = "County",
#                       format="shortName")
# measurestratification(indicator="Historical Heat Days",
#                       content_area ="DR",geo_type_ID = 7,
#                       format="shortName")
# measurestratification(measure="Number of summertime (May-Sep) heat-related deaths, by year",
#                       indicator="Historical Extreme Heat Days and Events",
#                       content_area ="Drought",format="name")
#' }
#' @export

# library(httr)
# library(jsonlite)
# library(plyr)



### Return Stratification Levels for a Measure and Geographic Type ###

stratificationlevel<-
  function(measure=NA,indicator=NA,content_area=NA,
           geo_type=NA,geo_type_ID=NA,
           format=c("name","shortName","ID"),smoothing=0){
  format<-match.arg(format)

  GL_table<-geographicLevels(measure,indicator,content_area,format)

  if(!any(is.na(geo_type_ID)) | !any(is.na(geo_type))){
    GL_table<-GL_table[which(GL_table$geographicTypeId%in%geo_type_ID |
                               GL_table$geographicType%in%geo_type),]
  }

  meas_ID<-GL_table$Measure_ID
  geo_type_ID<-GL_table$geographicTypeId

  SL_list<-list()

  for(strlev in 1:length(meas_ID)){
    SL<-
      httr::GET(paste0("https://ephtracking.cdc.gov:443/apigateway/api/v1/stratificationlevel/",
                       meas_ID[strlev],"/",geo_type_ID[strlev],"/",smoothing))
    SL_list[[strlev]]<-jsonlite::fromJSON(rawToChar(SL$content))
    SL_list[[strlev]]$Measure_ID<-meas_ID[strlev]
    SL_list[[strlev]]$Measure_Name<-GL_table$Measure_Name[strlev]
    SL_list[[strlev]]$Measure_shortName<-GL_table$Measure_shortName[strlev]
    SL_list[[strlev]]$Geo_Type<-GL_table$geographicType[strlev]
    SL_list[[strlev]]$Geo_Type_ID<-GL_table$geographicTypeId[strlev]
  }
  purrr::map_dfr(SL_list,as.data.frame)
}

