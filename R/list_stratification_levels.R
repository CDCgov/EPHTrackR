#' @name list_stratification_levels
#' @title DEPRECATED -List stratification levels
#' @description 
#' `r lifecycle::badge("deprecated")`
#' 
#' Replaced by new more powerful function, list_StratificationLevels().
#' @keywords internal
#' @import dplyr
#' @param measure Specifies the measure of interest as an ID, name, or shortName. IDs should be unquoted; name and shortName entries should be quoted strings.
#' @param geo_type An optional argument in which you can specify a geographic type as a quoted string (e.g., "State", "County"). The "geographicType" column in the list_geography_types() output contains a list of geo_types associated with each measure.
#' @param geo_type_ID An optional argument in which you can specify a geographic type ID as an unquoted numeric value (e.g., 1, 2). The "geographicTypeId" column in the list_geography_types() output contains a list of geo_types associated with each measure.
#' @param format Indicates whether the measure argument contains entries formatted as an ID, name, or shortName as a quoted string (e.g., "name", "shortName"). The default is ID.
#' @param smoothing Specifies whether to return stratification levels for geographically smoothed versions of a measure (1) or not (0). The default value is 0 because smoothing is not available for most measures. Requesting smoothed data when it is not available will produce an error.
#' @return The output of this function is a list with a separate element for each geography type available for the specified measure (e.g., state, county). Each row in the data frames contained as elements in the list shows a stratification available for the measure.
#' @examples \dontrun{
#' 
#' list_stratification_levels(measure=370,format="ID")
#'
#' list_stratification_levels(measure=c(370,423,707),format="ID")
#'
#' list_stratification_levels(measure=c("Number of summertime (May-Sep) heat-related deaths, by year",
#'                                 "Number of extreme heat days","Number of months of drought per year"),
#'                       format="shortName")
#'                       
#'                       
#' }
#' @export


### Return Stratification Levels for a Measure and Geographic Type ###
list_stratification_levels<-
  function(measure=NA,
           geo_type=NA,geo_type_ID=NA,
           format="ID",
           smoothing=0){
    
    lifecycle::deprecate_warn(when = "1.0.0",
                              what = "list_stratification_levels()",
                              with = "list_StratificationLevels()" )
    
    format<-match.arg(format, choices = c("ID","name","shortName"))
    
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
        httr::GET(paste0("https://ephtracking.cdc.gov/apigateway/api/v1/stratificationlevel/",
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

