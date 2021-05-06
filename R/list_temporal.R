#' @name list_temporal
#' @title List temporal periods
#' @description  List the temporal periods available for specified measures, geography types, and geographies.
#' @import dplyr
#' @param measure Specify the measure/s of interest as an ID, name, or shortName. IDs should be unquoted, while name and shortName entries should be quoted strings.
#' @param geo_type An optional argument in which you can specify a geographic type as a quoted string (e.g., "State", "County"). A list of geo_type's associated with each measure can be found in the "geographicType" column in the list_geography_types() output.
#' @param geo_type_ID An optional argument in which you can specify a geographic type ID as an unquoted numeric value (e.g., 1, 2). A list of geo_type_ID's associated with each measure can be found in the "geographicTypeId" column in the list_geography_types() output.
#' @param geo An optional argument in which you can specify geographies of interest as a quoted string (e.g., "Alabama", "Colorado"). At this time, this argument only accepts states even for county or sub-county geography specifications in the geo_type, geo_type_ID, and strat_level arguments. When a state-level geo argument is submitted with a sub-state geography specification, all sub-state geographies within the state will be returned. Available geo's can be found in the "parentName" column in the list_geography() output. If this argument is NULL, all geographies will be included in the output.
#' @param geo_ID An optional argument in which you can specify the FIPS codes of geographies of interest as unquoted numeric values without leading zeros (e.g., 1, 8). At this time, this argument only accepts states even for county or sub-county geography specifications in the geo_type, geo_type_ID, and strat_level arguments. When a state-level geo argument is submitted with a sub-state geography specification, all sub-state geographies within the state will be returned. Available geo_ID's can be found in the "parentGeographicId" column in the list_geography() output. If this argument is NULL, all geographies will be included in the output.
#' @param format Indicates whether the measure argument contains entries formatted as an ID, name or shortName as a quoted string (e.g., "name", "shortName"). The default is ID.
#' @param simplified_output If TRUE, a simplified output table is returned. If FALSE, the raw output from the Tracking Network Data API is returned. The default is TRUE.
#' @param geo_filter A 1 indicates that the geo/geo_ID arguments contain the parent geography type (e.g., states containing counties of interest). When 0, the child geographies should be specified in the geo/geo_ID arguments. At this time the default value is 1 and this should not be changed, because the child geography types cannot yet be used in the geo/geo_ID arguments.
#' @return This function returns a list with each element containing a data frame corresponding with each combination of the specified measures and geographic types.
#' @examples \dontrun{
#' 
#' 
#' temp <- list_temporal(measure = 99,
#'                           format="ID")
#'                           
#'                           
#'                           
#' }
#' @export


list_temporal <- function(measure=NA,
                   geo_type=NA,geo_type_ID=NA,geo=NA,
                   geo_ID=NA,format="ID",
                   simplified_output=TRUE,
                   geo_filter=1){
  
  format<-match.arg(format, choices = c("ID","name","shortName"))
  
  
  geo_list<-list_geographies(measure,
                      geo_type,geo_type_ID,format, 
                      simplified_output=F)
  
  geo_table<-purrr::map_dfr(geo_list,as.data.frame)
  
  
  if(!any(is.na(geo_ID)) | !any(is.na(geo))){
    geo_table<-
      geo_table[which(geo_table$parentGeographicId%in%geo_ID |
                        geo_table$parentName%in%geo |
                        geo_table$parentAbbreviation%in%geo),]
  }
  
  geo_table2<-
    unique(geo_table[,c("parentGeographicId","parentName",
                        "Measure_ID","Geo_Type_ID","Measure_Name","Geo_Type")])
  
  geo_parentid_table<-
    aggregate(parentGeographicId~Measure_ID+Geo_Type_ID,
              geo_table2,paste0,collapse=",")
  
  geo_ordered_table<-
    aggregate(parentName~Measure_Name+Geo_Type+Measure_ID+
                Geo_Type_ID,geo_table2,paste0,collapse=",")
  
  
  temp_list<-purrr::map(1:nrow(geo_parentid_table), function(tp){
    
    temp<-
      httr::GET(paste0("https://ephtracking.cdc.gov:443/apigateway/api/v1/temporal/",
                       geo_parentid_table$Measure_ID[tp],"/",
                       geo_parentid_table$Geo_Type_ID[tp],"/",
                       geo_filter,"/",geo_parentid_table$parentGeographicId[tp]))
    temp_cont<-jsonlite::fromJSON(rawToChar(temp$content))
    temp_cont$Measure<-geo_ordered_table$Measure_Name[tp]
    temp_cont$Measure_ID<-geo_parentid_table$Measure_ID[tp]
    temp_cont$Geo_Type<-geo_ordered_table$Geo_Type[tp]
    temp_cont$Geo_Type_ID<-geo_parentid_table$Geo_Type_ID[tp]
    temp_cont$Geographic_ID<-geo_parentid_table$parentGeographicId[tp]
    
    if(simplified_output == F){
      
      return(temp_cont)
      
    } else{
      
      return(dplyr::select(temp_cont,
                           parentTemporal,
                           parentTemporalType,
                           Geo_Type,
                           Measure_ID,
                           Measure))
    }
    
    
  })
  
  
  return(temp_list)
  
}


