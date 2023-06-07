#' @name list_geography_types
#' @title DEPRECATED - List available geography types
#' @description  
#' `r lifecycle::badge("deprecated")`
#' 
#' 
#' Replaced by new more powerful function, list_GeographicTypes().
#' @keywords internal
#' @param measure Specifies the measure of interest as an ID, name, or shortName. IDs should be unquoted; name and shortName entries should be quoted strings.
#' @param format Indicates whether the measure argument contains entries formatted as an ID, name, or shortName as a quoted string (e.g., "name", "shortName"). The default is ID.
#' @param simplified_output If TRUE, a simplified output table is returned. If FALSE, the raw output from the Tracking Network Data API is returned. The default is TRUE.
#' @return This function returns a list with each element containing a data frame corresponding to a specified measure.
#' @examples \dontrun{
#' list_geography_types(measure=370,format="ID")
#' 
#' list_geography_types(measure=c(370,423,707),format="ID")
#' 
#' list_geography_types(measure=c("Number of summertime (May-Sep) heat-related deaths, by year",
#'                            "Number of extreme heat days",
#'                            "Number of months of mild drought or worse per year"),
#'                  format="name")
#'                  
#' list_geography_types(measure=c("Number of summertime (May-Sep) heat-related deaths, by year",
#'                            "Number of extreme heat days","Number of months of drought per year"),
#'                  format="shortName")
#'                  
#' list_geography_types(measure="Number of summertime (May-Sep) heat-related deaths, by year" ,
#' format="name")
#' }
#' @export


### Print out Geographic Levels for a Measure ###

list_geography_types<-function(measure=NA,
                           format="ID",
                          simplified_output=T){
  
  lifecycle::deprecate_warn(when = "1.0.0",
                            what = "list_geography_types()",
                            with = "list_GeographicTypes()" )
  
  format<-match.arg(format, 
                    choices = c("ID","name","shortName"))
  
  meas_formatting<-paste0("measure_",format)
  ind_formatting<-paste0("indicator_",format)
  CA_formatting<-paste0("content_area_",format)

  #load("data/measures_indicators_CAs.RData")
  if(any(is.na(measure))){
    meas_ID<-unique(EPHTrackR::measures_indicators_CAs$measure_ID)
  }else{
    meas_ID<-
      unique(EPHTrackR::measures_indicators_CAs$measure_ID
             [which(EPHTrackR::measures_indicators_CAs[,meas_formatting]%in%measure )])
  }

  GL_list<-purrr::map(1:length(meas_ID), function(geolev){
    GL<-
      httr::GET(paste0("https://ephtracking.cdc.gov:443/apigateway/api/v1/geographicLevels/",
                 meas_ID[geolev]))

    GL_cont<-jsonlite::fromJSON(rawToChar(GL$content))
    GL_cont$Measure_ID<-meas_ID[geolev]
    GL_cont$Measure_Name<-
      unique(EPHTrackR::measures_indicators_CAs$measure_name
             [which(EPHTrackR::measures_indicators_CAs$measure_ID==meas_ID[geolev])])

    GL_cont$Measure_shortName<-
      unique(EPHTrackR::measures_indicators_CAs$measure_shortName
             [which(EPHTrackR::measures_indicators_CAs$measure_ID==meas_ID[geolev])])
    
    if(simplified_output == F){
      
      return(unique(GL_cont))
      
    } else{
      
      
      return(unique(dplyr::select(GL_cont,geographicType,
                             geographicTypeId, 
                             Measure_ID ,
                             Measure_Name ,
                             Measure_shortName)))
      
    }
    
  }
  )
  
  return(GL_list)
}

