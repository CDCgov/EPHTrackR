#' @name temporal
#' @title Find temporal periods available.
#' @description  Find temporal periods on CDC Tracking API for multiple measures and geographies.
#' @import dplyr
#' @param measure specify the measures of interest
#' @param geo_type specify the Geographic type.
#' @param geo_type_ID specify the Geographic type ID.
#' @param geo_items specify Geographic items by name or abbreviation.
#' @param geo_items_ID specify Geographic items by ID.
#' @param format indicate whether the measure, indicator and/or content_area variables are ID, name or shortName
#'@param simplified_output logical. Determines whether output table is simplified with only relevant columns (TRUE) or the raw output from the Tracking Network API (FALSE)
#' @param geo_filter default is 1. Filter query based on parent geographic type. This is a crude fix for a problem with the API query and for now don't change
#' @return The years for specified measures and geographies on the CDC Tracking API.
#' @examples \dontrun{
#' temp2_shortName<-temporal(content_area = "DR",
#'                           geo_items_ID = c(4,32,35),
#'                           format="shortName")
#' }
#' @export


temporal<-function(measure=NA,
                   geo_type=NA,geo_type_ID=NA,geo_items=NA,
                   geo_items_ID=NA,format=c("name","shortName","ID"),
                   simplified_output=TRUE,
                   geo_filter=1){
  format<-match.arg(format)
  

  
  
  geo_list<-geography(measure,
                      geo_type,geo_type_ID,format, 
                      simplified_output=F)
  
  geo_table<-purrr::map_dfr(geo_list,as.data.frame)
  
  
  if(!any(is.na(geo_items_ID)) | !any(is.na(geo_items))){
    geo_table<-
      geo_table[which(geo_table$parentGeographicId%in%geo_items_ID |
                        geo_table$parentName%in%geo_items |
                        geo_table$parentAbbreviation%in%geo_items),]
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


