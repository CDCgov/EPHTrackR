#' @name list_GeographicItems
#' @title List available geographies
#' @description  Lists available geographies (e.g., Fulton County, Georgia) for specified measures and geographic types. If multiple measures or geography types are submitted, the results for each combination of these two inputs will be returned as a separate list element in the output.
#' @import dplyr
#' @param measure Specifies the measure of interest as an ID, name, or shortName. IDs should be unquoted; name and shortName entries should be quoted strings.
#' @param geo_type An optional argument in which you can specify a geographic type as a quoted string (e.g., "State", "County"). The "geographicType" column in the list_geography_types() output contains a list of potential geo_type entries associated with each measure.
#' @param geo_typeID An optional argument in which you can specify a geographic type ID as an unquoted numeric value (e.g., 1, 2). The "geographicTypeId" column in the list_geography_types() output contains a list of potential geo_typeID entries associated with each measure.
#' @param format Indicates whether the measure argument contains entries formatted as an ID, name, or shortName as a quoted string (e.g., "name", "shortName"). The default is "ID".
#' @param simplified_output If TRUE, a simplified output table is returned. If FALSE, the raw output from the Tracking Network Data API is returned. The default is TRUE.
#' @param rollup Submitting a value of 1 returns only parent geographies (e.g., for a county-level measure, the states containing the relevant counties will be returned). A value of 0 returns the child geographies (e.g., for a county-level measure, all counties where there is data will be returned). This argument does nothing if the focal geography type is already a state or tribal area (highest level geographic type). The default is 0.
#' @return This function returns a list with each element containing a data frame corresponding to each combination of the specified measures and geographic types.
#' @examples\dontrun{
#' geo1_id<-list_GeographicItems(measure=370,format="ID")
#' 
#' geo2_name<-
#'   list_GeographicItems(measure=c("Number of summertime (May-Sep) heat-related deaths, by year"),
#'             format="name")
#' }
#' @export


### Print out geographic items for a Measure ID, Geographic Type and Geographic Rollup (rollup forces a view of all the parent geographic items) ###

list_GeographicItems<-function(measure=NA,
                    geo_type=NA,
                    geo_typeID=NA,
                    format="ID",
                    simplified_output = TRUE,
                    rollup=0){
  
  format<-match.arg(format, 
                    choices = c("ID","name","shortName"))
  

  GL_list <- list_GeographicTypes(measure,
                            format,
                            simplified_output=F)
  
  GL_table <- unique(purrr::map_dfr(GL_list,as.data.frame))
  

  #subsetting geography list to only those specified only if geographies are specified
  if(!any(is.na(geo_typeID)) | !any(is.na(geo_type))){
    GL_table<-
      GL_table[which(GL_table$geographicTypeId%in%geo_typeID |
                       GL_table$geographicType%in%geo_type),]
  }

  meas_ID<-GL_table$Measure_ID
  geo_typeID<-GL_table$geographicTypeId


  geo_list <- purrr::map(1:length(meas_ID), 
                       function(gg){
                         geo <- httr::GET(paste0(
                           "https://ephtracking.cdc.gov:443/apigateway/api/v1/geographicItems/",
                                               meas_ID[gg],"/",geo_typeID[gg],"/",rollup))
                         
                         geo_cont <- jsonlite::fromJSON(rawToChar(geo$content))
                         
                         geo_cont$Measure_ID<-meas_ID[gg]
                         
                         geo_cont$Measure_Name<-GL_table$Measure_Name[gg]
                         
                         geo_cont$Measure_shortName<-GL_table$Measure_shortName[gg]
                         
                         geo_cont$geo_type<-GL_table$geographicType[gg]
                         geo_cont$geo_typeID<-GL_table$geographicTypeId[gg]
                         
                         if(simplified_output == F){
                           
                           return(geo_cont)
                          
                         } else{
                           
                           return(dplyr::select(geo_cont,
                                                parentGeographicId,
                                                parentName,
                                                childGeographicId,
                                                childName,
                                                Measure_ID,
                                                Measure_Name,
                                                geo_type,
                                                geo_typeID))
                           
                         }
                         
                         
                       }
                       )
  
  return(geo_list)
  

}


