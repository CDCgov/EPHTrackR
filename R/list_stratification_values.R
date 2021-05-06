#' @name list_stratification_values
#' @title List stratification values
#' @description Some measures on the Tracking Network have a set of "Advanced Options" that allow the user to access data stratified by variables other than geography or temporal period. For instance, data on asthma hospitalizations can be broken down further by age and/or gender. This function allows the user to list available "Advanced Options" stratification values for specified measures and geographic types. For instance, in the case of the asthma hospitalization data, it would be possible to view the potential gender (e.g., Male, Female), and age (e.g. 0-4, >=65) values that are available.
#' 
#' 
#' The user should not need this function to retrieve data from the Tracking Network Data API because the get_data() function calls it internally. It can however, be used as a reference to view available stratification values.
#' @import dplyr
#' @param measure Specify the measure/s of interest as an ID, name, or shortName. IDs should be unquoted, while name and shortName entries should be quoted strings.
#' @param geo_type An optional argument in which you can specify a geographic type as a quoted string (e.g., "State", "County"). A list of geo_type's associated with each measure can be found in the "geographicType" column in the list_geography_types() output.
#' @param geo_type_ID An optional argument in which you can specify a geographic type ID as an unquoted numeric value (e.g., 1, 2). A list of geo_type_ID's associated with each measure can be found in the "geographicTypeId" column in the list_geography_types() output.
#' @param format Indicates whether the measure argument contains entries formatted as an ID, name or shortName as a quoted string (e.g., "name", "shortName"). The default is ID.
#' @param smoothing Specify whether to return stratification values for geographically smoothed versions of a measure (1) or not (0). The default value is 0 since smoothing is not available for most measures.
#' @return This function returns a list with each element containing a data frame corresponding with all combinations of specified measures and geographic types. Within each row of the data frame is a nested data frame containing the stratification values. If the specified measure and associated geography type do not have any "Advanced Options" stratifications, the returned list element will be empty.
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
