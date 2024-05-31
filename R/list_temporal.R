#' @name list_temporal
#' @title DEPRECATED - List temporal periods
#' @description 
#' `r lifecycle::badge("deprecated")`
#' 
#' 
#' Replaced by new more powerful function, list_TemporalItems().
#' @keywords internal
#' @import dplyr
#' @param measure Specifies the measure of interest as an ID, name, or shortName. IDs should be unquoted; name and shortName entries should be quoted strings.
#' @param geo_type An optional argument in which you can specify a geographic type as a quoted string (e.g., "State", "County"). The "geographicType" column in the list_geography_types() output contains a list of geo_types associated with each measure.
#' @param geo_type_ID An optional argument in which you can specify a geographic type ID as an unquoted numeric value (e.g., 1, 2). The "geographicTypeId" column in the list_geography_types() output contains a list of geo_types associated with each measure.
#' @param geo An optional argument in which to specify geographies of interest as a quoted string (e.g., "Alabama", "Colorado"). Currently, this argument only accepts states even for county or sub-county geography specifications in the geo_type, geo_type_ID, and strat_level arguments. When a state-level geo argument is submitted with a sub-state geography specification, all sub-state geographies within the state will be returned. The "parentName" column in the list_geography() output contains a list of available geos. If this argument is NULL, all geographies will be included in the output.
#' @param geo_ID An optional argument in which to specify the FIPS codes of geographies of interest as unquoted numeric values without leading zeros (e.g., 1, 8). Currently, this argument only accepts states even for county or sub-county geography specifications in the geo_type, geo_type_ID, and strat_level arguments. When a state-level geo argument is submitted with a sub-state geography specification, all sub-state geographies within the state will be returned. The "parentGeographicId" column in the list_geography() output contains a list of geo_IDs. If this argument is NULL, all geographies will be included in the output.
#' @param format Indicates whether the measure argument contains entries formatted as an ID, name, or shortName as a quoted string (e.g., "name", "shortName"). The default is ID.
#' @param simplified_output If TRUE, a simplified output table is returned. If FALSE, the raw output from the Tracking Network Data API is returned. The default is TRUE.
#' @param geo_filter A 1 indicates that the geo/geo_ID arguments contain the parent geography type (e.g., states containing counties of interest). When 0, the child geographies should be specified in the geo/geo_ID arguments. Currently, the default value is 1, and this should not be changed because the child geography types cannot yet be used in the geo/geo_ID arguments.
#' @return This function returns a list with each element containing a data frame corresponding to each combination of the specified measures and geographic types.
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
  
  lifecycle::deprecate_warn(when = "1.0.0",
                            what = "list_temporal()",
                            with = "list_TemporalItems()" )
  
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
      httr::GET(paste0("https://ephtracking.cdc.gov/apigateway/api/v1/temporal/",
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
                           childTemporal,
                           childTemporalType,
                           Geo_Type,
                           Measure_ID,
                           Measure))
    }
    
    
  })
  
  
  return(temp_list)
  
}


