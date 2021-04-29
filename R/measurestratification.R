#' @name measurestratification
#' @title Find stratification
#' @description  Find stratification for specified measures and geographic types available on the CDC Tracking API.
#' @import dplyr
#' @param measure specify the measures of interest
#' @param geo_type specify the Geographic type.
#' @param geo_type_ID specify the Geographic type ID.
#' @param format indicate whether the measure is listed as an ID, name or shortName
#' @param smoothing default is 0. Specify whether data is geographically smoothed(1) or not (0).
#' @return The stratification for the specified measures and geographic levels on the CDC Tracking API.
#' @examples \dontrun{
# measurestratification(measure=370,format="ID")
# measurestratification(measure=c(370,423,707),format="ID")
# measurestratification(measure=c("Number of summertime (May-Sep) heat-related deaths, by year",
#                                 "Number of extreme heat days","Number of months of mild drought or worse per year"),
#                       format="name")
# measurestratification(measure=c("Number of summertime (May-Sep) heat-related deaths, by year",
#                                 "Number of extreme heat days","Number of months of drought per year"),
#                       format="shortName")
#' }
#' @export



### Print out Stratifications for a Measure and Geographic Type ###

measurestratification<-
  function(measure=NA,
           geo_type=NA,geo_type_ID=NA,
           format=c("name","shortName","ID"),
           smoothing=0){
    format<-match.arg(format)
    
    
    GL_list<-geography_types(measure,format)
    
    GL_table<-purrr::map_dfr(GL_list,as.data.frame)
    
    
    if(!any(is.na(geo_type_ID)) | !any(is.na(geo_type))){
      GL_table<-
        GL_table[which(GL_table$geographicTypeId%in%geo_type_ID |
                         GL_table$geographicType%in%geo_type),]
    }
    
    meas_ID<-GL_table$Measure_ID
    geo_type_ID<-GL_table$geographicTypeId
    
    MS_list<-purrr::map(1:length(meas_ID),function(measstrat){
      
      MS<-
        httr::GET(paste0("https://ephtracking.cdc.gov:443/apigateway/api/v1/measurestratification/",
                         meas_ID[measstrat],"/",
                         geo_type_ID[measstrat],"/",smoothing))
      
      if(length(MS$content) >2){
        MS_cont<-jsonlite::fromJSON(rawToChar(MS$content))
        MS_cont$Measure_ID<-meas_ID[measstrat]
        MS_cont$Measure_Name<-GL_table$Measure_Name[measstrat]
        MS_cont$Measure_shortName<-GL_table$Measure_shortName[measstrat]
        MS_cont$Geo_Type<-GL_table$geographicType[measstrat]
        MS_cont$Geo_Type_ID<-GL_table$geographicTypeId[measstrat]
        
        return(MS_cont)
        
      } else{
        
        return(list())
        
      }
      
      
      
    })
    
    return(MS_list)
  }
