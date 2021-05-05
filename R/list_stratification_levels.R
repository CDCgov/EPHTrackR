#' @name list_stratification_levels
#' @title Find stratification levels
#' @description  Some measures on the Tracking Network have a set of "Advanced Options" that allow the user to access data stratified by variables other than geography or temporal period. For instance, data on asthma hospitalizations can be broken down by age and/or gender rather than for the whole population. This function allows the user to list available "Advanced Options" stratification *levels* for specified measures and geographic types. For instance, in the case of the asthma hospitalization data, it would be possible to view the full range of stratifications available, including gender, age, and both gender and age combined.
#' 
#'Because "Advanced Options" may only be available at a particular geographic scale (e.g., age-breakdown of asthma hospitalizations is only available at the state-level), results showing available stratification levels always include the geography type. Therefore, this function is can be used to specify geography types as well as stratifiation levels of interest when using the get_data() function to download data from the Tracking Network Data API.
#' @import dplyr
#' @param measure Specify the measure/s of interest as an ID, name, or shortName. IDs should be unquoted, while name and shortName entries should be quoted strings.
#' @param geo_type An optional argument in which you can specify a geographic type as a quoted string (e.g., "State", "County"). A list of geo_type's associated with each measure can be found in the "geographicType" column in the list_geography_types() output.
#' @param geo_type_ID An optional argument in which you can specify a geographic type ID as an unquoted numeric value (e.g., 1, 2). A list of geo_type_ID's associated with each measure can be found in the "geographicTypeId" column in the list_geography_types() output.
#' @param format Indicate whether the measure argument contains entries formatted as an "ID", "name" or "shortName". The default is "ID".
#' @param smoothing Specify whether to return stratification levels for geographically smoothed versions of a measure (1) or not (0). The default value is 0 since smoothing is not available for most measures. Requesting smoothed data when it is not available will produce an error.
#' @return The output of this function is a list with a separate element for each geography type available  for the specifie measure (e.g., state, county). Each row in the data frames contained as elements in the list shows the a stratification available for the measure.
#' @examples \dontrun{
#' list_stratification_levels(measure=370,format="ID")
#'
#' list_stratification_levels(measure=c(370,423,707),format="ID")
#'
#' list_stratification_levels(measure=c("Number of summertime (May-Sep) heat-related deaths, by year",
#'                                 "Number of extreme heat days","Number of months of drought per year"),
#'                       format="shortName")
#' }
#' @export


### Return Stratification Levels for a Measure and Geographic Type ###
list_stratification_levels<-
  function(measure=NA,
           geo_type=NA,geo_type_ID=NA,
           format="ID",
           smoothing=0){
    
    format<-match.arg(format, choices = c("name","shortName","ID"))
    
    GL_list<-list_geography_types(measure,format)
    
    GL_table<-purrr::map_dfr(GL_list,as.data.frame)
    
    
    if(!any(is.na(geo_type_ID)) | !any(is.na(geo_type))){
      GL_table<-GL_table[which(GL_table$geographicTypeId%in%geo_type_ID |
                                 GL_table$geographicType%in%geo_type),]
      
      if(nrow( GL_table)==0){
        
        stop("The specified geographic type may not be available for this measure or stratification.")
        
      }
      
    }
    
    meas_ID<-GL_table$Measure_ID
    geo_type_ID<-GL_table$geographicTypeId
    
    SL_list<-purrr::map(1:length(meas_ID), function(strlev){
      
      SL<-
        httr::GET(paste0("https://ephtracking.cdc.gov:443/apigateway/api/v1/stratificationlevel/",
                         meas_ID[strlev],"/",geo_type_ID[strlev],"/",smoothing))
      SL_cont<-jsonlite::fromJSON(rawToChar(SL$content))
      SL_cont$Measure_ID<-meas_ID[strlev]
      SL_cont$Measure_Name<-GL_table$Measure_Name[strlev]
      SL_cont$Measure_shortName<-GL_table$Measure_shortName[strlev]
      SL_cont$Geo_Type<-GL_table$geographicType[strlev]
      SL_cont$Geo_Type_ID<-GL_table$geographicTypeId[strlev]
      
      return(SL_cont)
      
    })
    
    return(SL_list)
  }

