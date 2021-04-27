#' @name geography
#' @title Find geography
#' @description  Find geography for specified measures and geographic types available on the CDC Tracking API.
#' @import dplyr
#' @param measure specify the measures of interest
#' @param indicator specify the indicators of interest
#' @param content_area specify the content areas of interest
#' @param geo_type specify the Geographic type.
#' @param geo_type_ID specify the Geographic type ID.
#' @param rollup default is 0. Specify whether geographic rollup(1) or not (0).
#' @param format indicate whether the measure, indicator and/or content_area variables are ID, name or shortName
#' @return The geographies for the specified measures on the CDC Tracking API.
#' @examples\dontrun{
#' geo1_id<-geography(measure=370,format="ID")
#' 
#' geo2_id<-geography(measure=c(370,423,707),
#'                    format="ID")
#' geo2_name<-
#'   geography(measure=c("Number of summertime (May-Sep) heat-related deaths, by year",
#'                       "Number of extreme heat days","Number of months of mild drought or worse per year"),
#'             format="name")
#' geo2_shortName<-
#'   geography(measure=c("Number of summertime (May-Sep) heat-related deaths, by year",
#'                       "Number of extreme heat days","Number of months of drought per year"),
#'             format="shortName")
#' geo3_id<-geography(content_area = 25,format="ID")
#' geo4_shortName<-
#'   geography(indicator="Historical Heat Days",
#'             content_area ="DR",format="shortName")
#' geo5_shortName<-
#'   geography(indicator="Historical Heat Days",
#'             content_area ="DR",geo_type = "County" ,
#'             format="shortName")
#' geo6_shortName<-
#'   geography(indicator="Historical Heat Days",
#'             content_area ="DR",geo_type_ID = 7,
#'             format="shortName")
#' geo7_name<-
#'   geography(measure="Number of summertime (May-Sep) heat-related deaths, by year" ,
#'             indicator="Historical Extreme Heat Days and Events",
#'             content_area ="Drought",format="name")
#' }
#' @export

#library(httr)
#library(jsonlite)
#library(plyr)


### Print out Geographies for a Measure ID, Geographic Type and Geographic Rollup ###

geography<-function(measure=NA,indicator=NA,
                    content_area=NA,geo_type=NA,
                    geo_type_ID=NA,
                    format=c("name","shortName","ID"),rollup=0){
  format<-match.arg(format)

  GL_table<-geographicLevels(measure,indicator,
                             content_area,format)

  if(!any(is.na(geo_type_ID)) | !any(is.na(geo_type))){
    GL_table<-
      GL_table[which(GL_table$geographicTypeId%in%geo_type_ID |
                       GL_table$geographicType%in%geo_type),]
  }

  meas_ID<-GL_table$Measure_ID
  geo_type_ID<-GL_table$geographicTypeId

  geo_list<-list()

  for(gg in 1:length(meas_ID)){
    geo<-httr::GET(paste0("https://ephtracking.cdc.gov:443/apigateway/api/v1/geography/",
                          meas_ID[gg],"/",geo_type_ID[gg],"/",rollup))
    geo_list[[gg]]<-jsonlite::fromJSON(rawToChar(geo$content))
    geo_list[[gg]]$Measure_ID<-meas_ID[gg]
    geo_list[[gg]]$Measure_Name<-GL_table$Measure_Name[gg]
    geo_list[[gg]]$Measure_shortName<-GL_table$Measure_shortName[gg]
    geo_list[[gg]]$Geo_Type<-GL_table$geographicType[gg]
    geo_list[[gg]]$Geo_Type_ID<-GL_table$geographicTypeId[gg]
  }
  purrr::map_dfr(geo_list,as.data.frame)
}


