#' @name list_TemporalItems
#' @title List temporal items
#' @description  List the temporal items (periods) available for specified measures, geography types, and geographic items.
#' @import dplyr
#' @param measure Specifies the measure of interest as an ID, name, or shortName. IDs should be unquoted; name and shortName entries should be quoted strings. It is recommended that only one measure be submitted.
#' @param geo_type An optional argument in which you can specify a geographic type as a quoted string (e.g., "State", "County"). The "geographicType" column in the list_geography_types() output contains a list of potential geo_type entries associated with each measure.
#' @param geo_typeID An optional argument in which you can specify a geographic type ID as an unquoted numeric value (e.g., 1, 2). The "geographicTypeId" column in the list_geography_types() output contains a list of potential geo_typeID entries associated with each measure.
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


list_TemporalItems <- function(measure,
                               geo_type=NA,
                               geo_typeID=NA,
                               format="ID",
                               simplified_output=TRUE){
  
  if(length(measure)>1){
    
    warning("Call may fail because more than one measure has been entered")
  }
  
  if(missing(measure)){
    
    stop("Nothing has been entered in the measure argument.")
  }
  
  
  format<-match.arg(format, choices = c("ID","name","shortName"))
  
  
  geo_list <- list_GeographicItems(measure,
                      geo_type,
                      geo_typeID,
                      format, 
                      simplified_output=F)
  
  
  
  

  temp_list<-purrr::map(1:length(geo_list), function(tp){
    
    #Call requirements
    # ephtracking.cdc.gov/apigateway/api/{version}/temporalItems/{measureID}/{geographicTypeId}/{geographicTypeIdFilter}/
    #   {geographicItemsFilter}[?apiToken]
    Measure_ID <- geo_list[[tp]][1,"Measure_ID"]
    geo_typeID <- geo_list[[tp]][1,"geo_typeID"]
    
    #sometimes the "ALL" entry for the geo type and items filter does not work (not clear why). If ALL fails, trying the call by entering all the geo items.
    
    tryCatch({
      
      temp <-
        httr::GET(paste0("https://ephtracking.cdc.gov/apigateway/api/v1/temporalItems/",
                         Measure_ID,"/",
                         geo_typeID,"/",
                         "ALL","/","ALL"))
      },
      
      error=function(cond) {
        geoitemsfiterID <- ifelse(!is.na(geo_list[[tp]]$childGeographicId[1]),
                             unique(geo_list[[tp]]$childGeographicId),
                             unique(geo_list[[tp]]$parentGeographicId))
        
        temp <-
          httr::GET(paste0("https://ephtracking.cdc.gov/apigateway/api/v1/temporalItems/",
                           Measure_ID,"/",
                           geo_typeID,"/",
                           geo_typeID,"/",
                           geoitemsfiterID))
             })

      
   
    
    temp_cont <- jsonlite::fromJSON(rawToChar(temp$content))
    
    temp_cont$Measure <- rep(geo_list[[tp]]$Measure_Name[1], 
                             nrow(temp_cont))
    
    temp_cont$Measure_ID <- rep(geo_list[[tp]]$Measure_ID[1], 
                                nrow(temp_cont))
    
    temp_cont$geo_type <- rep(geo_list[[tp]]$geo_type[1], 
                              nrow(temp_cont))
    
    temp_cont$geo_typeID <- rep(geo_list[[tp]]$geo_typeID[1], 
                                nrow(temp_cont))
  
    
    if(simplified_output == F){
      
      return(temp_cont)
      
    } else{
      
      return(
          
          dplyr::select(temp_cont,
                        parentTemporal,
                        parentTemporalType,
                        temporal,
                        temporalType,
                        geo_type,
                        geo_typeID,
                        Measure,
                        Measure_ID)
 
        
    
      )
    }
  })
  
  return(temp_list)
  
}


