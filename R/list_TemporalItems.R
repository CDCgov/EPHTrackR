#' @name list_TemporalItems
#' @title List temporal items
#' @description  List the temporal items (periods) available for specified measures, geography types, and geographic items.
#' @import dplyr
#' @param measure Specifies the measure of interest as an ID, name, or shortName. IDs should be unquoted; name and shortName entries should be quoted strings.
#' @param geo_type An optional argument in which you can specify a geographic type as a quoted string (e.g., "State", "County"). The "geographicType" column in the list_geography_types() output contains a list of potential geo_type entries associated with each measure.
#' @param geo_typeID An optional argument in which you can specify a geographic type ID as an unquoted numeric value (e.g., 1, 2). The "geographicTypeId" column in the list_geography_types() output contains a list of potential geo_typeID entries associated with each measure.
#' @param geoItems An optional argument that specifies geographic items as a quoted string (e.g., "Alabama", "Colorado"). You can request either the lowest level geographic items you would like included in the returned dataset (e.g., specify a county or census tract name) or a state (i.e., parent geographic item) that contains the lowest level geographic items you would like returned in the data (e.g., specify a state to retrieve data for all counties or census tracts within that state). The "parentName" and "childName" columns in the list_GeographicItems() output contains a list of available geoItems. Note that if you include an entry in this argument, you MUST include a corresponding entry in the geoItems_type or geoItems_typeID arguments. If this argument is NULL, all geographies will be included in the output table.
#' @param geoItems_ID An optional argument that specifies the FIPS codes of geographies of interest as unquoted numeric values without leading zeros (e.g., 1, 8). You can request either the lowest level geographic item IDs you would like included in the returned dataset (e.g., specify a county or census tract FIPS) or a state (i.e., parent geographic item) that contains the lower level geographic items you would like returned in the data (e.g., specify a state FIPS to retrieve data for all counties or census tracts within that state). The "parentGeographicId" and "childGeographicId" columns in the list_GeographicItems() output contains a list of available geoItem_ID that can be entered. Note that if you include an entry in this argument, you MUST include a corresponding entry in the geoItems_type or geoItems_typeID arguments. If this argument is NULL, all geographies will be included in the output table. 
#' @param geoItems_type An optional argument that specifies the geographic type of any entries in the geoItems or geoItems_ID arguments as a quoted string (e.g., "State", "County"). The "geographicType" column in the list_GeographicTypes() output contains a list of appropriate geoItems_type. 
#' @param geoItems_typeID An optional argument that specifies the geographic type ID of any entries in the geoItems or geoItems_ID arguments as an unquoted numeric value (e.g., 1, 2). The "geographicTypeId" column in the list_GeographicTypes() output contains a list of appropriate geoItems_typeID.
#' @param format Indicates whether the measure argument contains entries formatted as an ID, name, or shortName as a quoted string (e.g., "name", "shortName"). The default is ID.
#' @param simplified_output If TRUE, a simplified output table is returned. If FALSE, the raw output from the Tracking Network Data API is returned. The default is TRUE.
#' @param geo_items_filter A 1 indicates that the geo_items/geo_items_ID arguments contain the parent geography type (e.g., states containing counties of interest). When 0, the child geographies should be specified in the geo_items/geo_items_ID arguments. Currently, the default value is 1, and this should not be changed because the child geography types cannot yet be used in the geo_items/geo_items_ID arguments.
#' @return This function returns a list with each element containing a data frame corresponding to each combination of the specified measures and geographic types.
#' @examples \dontrun{
#' 
#' 
#' temp <- list_TemporalItems(measure = 99,
#'                           format="ID")
#'                           
#'                           
#'                           
#' }
#' @export


list_TemporalItems <- function(measure=NA,
                               geo_type=NA,
                               geo_typeID=NA,
                               geoItems=NA,
                               geoItems_ID=NA,
                               geoItems_type=NA,
                               geoItems_typeID=NA,
                               format="ID",
                               simplified_output=TRUE){
  
  format<-match.arg(format, choices = c("ID","name","shortName"))
  
  
  geo_list <- list_GeographicItems(measure,
                      geo_type,
                      geo_typeID,
                      format, 
                      simplified_output=F)
  
  geo_table<-purrr::map_dfr(geo_list,
                            as.data.frame)
  
  #if a items type is selected that is always a parent (tribal, national and state), then search parent columns for selections
  if(any(!is.na(geoItems_ID),!is.na(geoItems)) &
     any(geoItems_typeID %in% c(1,14) | 
     tolower(geoItems_type) %in% tolower(c("Tribal Boundaries",
                            "State","National")))){
    
    geo_table<-
      geo_table[which(geo_table$parentGeographicId %in% geoItems_ID|
                        tolower(geo_table$parentName) %in% tolower(geo_items) |
                        tolower(geo_table$parentAbbreviation) %in% tolower(geo_items)),]
    
    
  }
  
  #if an item type is selected that is always a child (county, census tract), then search child columns for selections
  if(any(!is.na(geoItems_ID),!is.na(geoItems)) &
     !any((geoItems_typeID %in% c(1,14)) | 
        tolower(geoItems_type) %in% tolower(c("Tribal Boundaries",
                                               "State","National")))){
    
    geo_table <-
      geo_table[which(geo_table$childGeographicId %in% geoItems_ID|
                        tolower(geo_table$childName) %in% tolower(geo_items)),]
    
    
  }
  
  

  
  geo_table2<-
    unique(geo_table[,c("parentGeographicId","parentName",
                        "Measure_ID","geo_typeID","Measure_Name","geo_type")])
  
  geo_parentid_table <-
    aggregate(parentGeographicId~Measure_ID+geo_typeID,
              geo_table2,paste0,collapse=",")
  
  geo_ordered_table <-
    aggregate(parentName~Measure_Name+geo_type+Measure_ID+
                geo_typeID,geo_table2,paste0,collapse=",")
  
  num_geographies_measures <- unique()
  
  temp_list<-purrr::map(1:nrow(geo_parentid_table), function(tp){
    
    if(any(!is.na(geoItems_ID),!is.na(geoItems)) &
       any(geoItems_typeID %in% c(1,14) | 
           tolower(geoItems_type) %in% tolower(c("Tribal Boundaries",
                                                 "State","National")))){
      
      temp<-
        httr::GET(paste0("https://ephtracking.cdc.gov:443/apigateway/api/v1/temporalItems/",
                         geo_parentid_table$Measure_ID[tp],"/",
                         geo_parentid_table$geo_typeID[tp],"/",
                         geo_table$geo_typeID,"/",unique(geo_table$parentGeographicId)))
      
    }

   
    
     temp_cont<-jsonlite::fromJSON(rawToChar(temp$content))
    temp_cont$Measure<-geo_ordered_table$Measure_Name[tp]
    temp_cont$Measure_ID<-geo_parentid_table$Measure_ID[tp]
    temp_cont$geo_type<-geo_ordered_table$geo_type[tp]
    temp_cont$geo_typeID<-geo_parentid_table$geo_typeID[tp]
    temp_cont$Geographic_ID<-geo_parentid_table$parentGeographicId[tp]
    
    if(simplified_output == F){
      
      return(temp_cont)
      
    } else{
      
      return(
        #including child columns only for measures that have child temporal type
        if( any("temporal" %in% names(temp_cont))){
          
          dplyr::select(temp_cont,
                        parentTemporal,
                        parentTemporalType,
                        temporal,
                        temporalType,
                        geo_type,
                        Measure_ID,
                        Measure)
        } else(dplyr::select(temp_cont,
                             parentTemporal,
                             parentTemporalType,
                             geo_type,
                             Measure_ID,
                             Measure))
        
    
      )
    }
  })
  
  return(temp_list)
  
}


