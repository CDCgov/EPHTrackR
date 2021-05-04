#' @name list_geographies
#' @title Identify geographies for specified measures
#' @description  Identify available geographies (e.g., Fulton County, Georgia) for specified measures and geographic types. If multiple measures or geography types are submitted, the results for each one will be returned as a separate list element in the output object.
#' @import dplyr
#' @param measure specify the measures of interest
#' @param geo_type specify the Geographic type.
#' @param geo_type_ID specify the Geographic type ID.
#' @param format indicate whether the measure, indicator and/or content_area variables are ID, name or shortName
#' @param simplified_output logical. Determines whether output table is simplified with only relevant columns (TRUE) or the raw output from the Tracking Network API (FALSE)
#' @param rollup default is 0. Changing this value to 1 results in returning only parent geographies (e.g. states containing all county-level geographies). It makes no difference if the focal geography is already state. It is unlikely you'll need to change this from the default. 
#' @return The geographies for the specified measures on the CDC Tracking API.
#' @examples\dontrun{
#' geo1_id<-list_geographies(measure=370,format="ID")
#' 
#' geo2_name<-
#'   list_geographies(measure=c("Number of summertime (May-Sep) heat-related deaths, by year"),
#'             format="name")
#' }
#' @export


### Print out Geographies for a Measure ID, Geographic Type and Geographic Rollup ###

list_geographies<-function(measure=NA,
                    geo_type=NA,
                    geo_type_ID=NA,
                    format=c("name","shortName","ID"),
                    simplified_output = TRUE,
                    rollup=0){
  format<-match.arg(format)
  

  GL_list <- list_geography_types(measure,
                            format,
                            simplified_output=F)
  
  GL_table <- unique(purrr::map_dfr(GL_list,as.data.frame))
  

  #subsetting geography list to only those specified only if geographies are specified
  if(!any(is.na(geo_type_ID)) | !any(is.na(geo_type))){
    GL_table<-
      GL_table[which(GL_table$geographicTypeId%in%geo_type_ID |
                       GL_table$geographicType%in%geo_type),]
  }

  meas_ID<-GL_table$Measure_ID
  geo_type_ID<-GL_table$geographicTypeId


  geo_list <- purrr::map(1:length(meas_ID), 
                       function(gg){
                         geo<-httr::GET(paste0("https://ephtracking.cdc.gov:443/apigateway/api/v1/geography/",
                                               meas_ID[gg],"/",geo_type_ID[gg],"/",rollup))
                         geo_cont<-jsonlite::fromJSON(rawToChar(geo$content))
                         geo_cont$Measure_ID<-meas_ID[gg]
                         geo_cont$Measure_Name<-GL_table$Measure_Name[gg]
                         geo_cont$Measure_shortName<-GL_table$Measure_shortName[gg]
                         geo_cont$Geo_Type<-GL_table$geographicType[gg]
                         geo_cont$Geo_Type_ID<-GL_table$geographicTypeId[gg]
                         
                         if(simplified_output == F){
                           
                           return(geo_cont)
                          
                         } else{
                           
                           return(dplyr::select(geo_cont,
                                                parentGeographicId,
                                                parentName,
                                                parentAbbreviation,
                                                childGeographicId,
                                                childName,
                                                childAbbreviation,
                                                Measure_ID,
                                                Measure_Name,
                                                Measure_shortName,
                                                Geo_Type,
                                                Geo_Type_ID))
                           
                         }
                         
                         
                       }
                       )
  
  return(geo_list)
  

}


