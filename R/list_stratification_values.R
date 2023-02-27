#' @name list_stratification_values
#' @title DEPRECATED - List stratification values
#' @description 
#' `r lifecycle::badge("deprecated")`
#' 
#' 
#' Replaced by new more power function, list_StratificationTypes().
#' @keywords internal
#' @import dplyr
#' @param measure Specifies the measure of interest as an ID, name, or shortName. IDs should be unquoted; name and shortName entries should be quoted strings.
#' @param geo_type An optional argument in which you can specify a geographic type as a quoted string (e.g., "State", "County"). The "geographicType" column in the list_geography_types() output contains a list of geo_types associated with each measure.
#' @param geo_type_ID An optional argument in which you can specify a geographic type ID as an unquoted numeric value (e.g., 1, 2). The "geographicTypeId" column in the list_geography_types() output contains a list of geo_types associated with each measure.
#' @param format Indicates whether the measure argument contains entries formatted as an ID, name, or shortName as a quoted string (e.g., "name", "shortName"). The default is ID.
#' @param smoothing Specifies whether to return stratification values for geographically smoothed versions of a measure (1) or not (0). The default value is 0 because smoothing is not available for most measures.
#' @return This function returns a list with each element containing a data frame corresponding to all combinations of specified measures and geographic types. Within each row of the data frame is a nested data frame containing the stratification values. If the specified measure and associated geography type do not have any "Advanced Options" stratifications, the returned list element will be empty.
#' @examples \dontrun{
#' 
#' 
# list_stratification_values(measure=370,format="ID")

# list_stratification_values(measure=c(370,423,707),format="ID")

# list_stratification_values(measure=c("Number of summertime (May-Sep) heat-related deaths, by year",
#                                 "Number of extreme heat days","Number of months of mild drought or worse per year"),
#                       format="name")

# list_stratification_values(measure=c("Number of summertime (May-Sep) heat-related deaths, by year",
#                                 "Number of extreme heat days","Number of months of drought per year"),
#                       format="shortName")


#' }
#' @export



### Print out Stratifications for a Measure and Geographic Type ###

list_stratification_values <-
  function(measure=NA,
           geo_type=NA,geo_type_ID=NA,
           format="ID",
           smoothing=0){
    
    lifecycle::deprecate_warn(when = "1.0.0",
                              what = "list_stratification_values()",
                              with = "list_StratificationTypes()" )
    
    format<-match.arg(format, choices = c("name","shortName","ID"))
    
    
    GL_list<-list_geography_types(measure,format)
    
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
