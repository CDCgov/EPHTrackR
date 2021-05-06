#' @name list_geographies
#' @title List available geographies for specified measures
#' @description  List available geographies (e.g., Fulton County, Georgia) for specified measures and geographic types. If multiple measures or geography types are submitted, the results for each combination of these two inputs will be returned as a separate list element in the output.
#' @import dplyr
#' @param measure Specify the measure/s of interest as an ID, name, or shortName. IDs should be unquoted, while name and shortName entries should be quoted strings.
#' @param geo_type An optional argument in which you can specify a geographic type as a quoted string (e.g., "State", "County"). A list of geo_type's associated with each measure can be found in the "geographicType" column in the list_geography_types() output.
#' @param geo_type_ID An optional argument in which you can specify a geographic type ID as an unquoted numeric value (e.g., 1, 2). A list of geo_type_ID's associated with each measure can be found in the "geographicTypeId" column in the list_geography_types() output.
#' @param format Indicates whether the measure argument contains entries formatted as an ID, name or shortName as a quoted string (e.g., "name", "shortName"). The default is ID.
#' @param simplified_output If TRUE, a simplified output table is returned. If FALSE, the raw output from the Tracking Network Data API is returned. The default is TRUE.
#' @param rollup It is unlikely you'll need to change this from the default value of 0. Submitting a value of 1 results in returning only parent geographies (e.g. states instead of all county-level geographies). This argument does nothing if the focal geography type is already a state. 
#' @return This function returns a list with each element containing a data frame corresponding with each combination of the specified measures and geographic types.
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
                    format="ID",
                    simplified_output = TRUE,
                    rollup=0){
  
  format<-match.arg(format, 
                    choices = c("ID","name","shortName"))
  

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


