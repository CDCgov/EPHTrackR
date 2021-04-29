#' @name stratificationlevel
#' @title Find stratification levels
#' @description  Find stratification levels for specified measures and geographic types available on the CDC Tracking API.
#' @import dplyr
#' @param measure specify the measures of interest
#' @param geo_type specify the Geographic type.
#' @param geo_type_ID specify the Geographic type ID.
#' @param format indicate whether the measure, indicator and/or content_area variables are ID, name or shortName
#' @param smoothing default is 0. Specify whether data is geographically smoothed(1) or not (0).
#' @return The stratification levels for the specified measures and stratification levels on the CDC Tracking API.
#' @examples \dontrun{
#' stratificationlevel(measure=370,format="ID")
#'
#' stratificationlevel(measure=c(370,423,707),format="ID")
#'
#' stratificationlevel(measure=c("Number of summertime (May-Sep) heat-related deaths, by year",
#'                                 "Number of extreme heat days","Number of months of drought per year"),
#'                       format="shortName")
#' }
#' @export

# library(httr)
# library(jsonlite)
# library(plyr)



### Return Stratification Levels for a Measure and Geographic Type ###

stratificationlevel<-
  function(measure=NA,
           geo_type=NA,geo_type_ID=NA,
           format=c("name","shortName","ID"),smoothing=0){
  format<-match.arg(format)

  GL_list<-geography_types(measure,format)
  
  GL_table<-purrr::map_dfr(GL_list,as.data.frame)
  
  
  if(!any(is.na(geo_type_ID)) | !any(is.na(geo_type))){
    GL_table<-GL_table[which(GL_table$geographicTypeId%in%geo_type_ID |
                               GL_table$geographicType%in%geo_type),]
  }
  
  meas_ID<-GL_table$Measure_ID
  geo_type_ID<-GL_table$geographicTypeId
  
  SL_list<-purrr::map(1:length(meas_ID), function(strlev){
    
    SL<-
      httr::GET(paste0("https://ephtracking.cdc.gov:443/apigateway/api/v1/stratificationlevel/",
                       meas_ID[strlev],"/",geo_type_ID[strlev],"/",smoothing))
    SL_cont<-jsonlite::fromJSON(rawToChar(SL$content))
    SL_cont$Measure_ID<-meas_ID[strlev]
    SL_cont$Measure_Name<-GL_table$Measure_Name[strlev]
    SL_cont$Measure_shortName<-GL_table$Measure_shortName[strlev]
    SL_cont$Geo_Type<-GL_table$geographicType[strlev]
    SL_cont$Geo_Type_ID<-GL_table$geographicTypeId[strlev]
    
    return(SL_cont)
    
  })
  
  return(SL_list)
}

