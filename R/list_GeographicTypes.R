#' @name list_GeographicTypes
#' @title List available geographic types
#' @description  Lists geographic types (e.g., state, county) for specified measure(s). If multiple measures are specified, the results for each are returned as separate list elements.
#' @param measure Specifies the measure of interest as an ID, name, or shortName. IDs should be unquoted; name and shortName entries should be quoted strings.
#' @param format Indicates whether the measure argument contains entries formatted as an ID, name, or shortName as a quoted string (e.g., "name", "shortName"). The default is ID.
#' @param simplified_output If TRUE, a simplified output table is returned. If FALSE, the raw output from the Tracking Network Data API is returned. The default is TRUE.
#' @return This function returns a list with each element containing a data frame corresponding to a specified measure.
#' @examples \dontrun{
#' list_GeographicTypes(measure=370,format="ID")
#' 
#' list_GeographicTypess(measure=c(370,423,707),format="ID")
#' 
#' list_GeographicTypes(measure=c("Number of summertime (May-Sep) heat-related deaths, by year",
#'                            "Number of extreme heat days",
#'                            "Number of months of mild drought or worse per year"),
#'                  format="name")
#'                  
#' list_GeographicTypes(measure=c("Number of summertime (May-Sep) heat-related deaths, by year",
#'                            "Number of extreme heat days","Number of months of drought per year"),
#'                  format="shortName")
#'                  
#' list_GeographicTypes(measure="Number of summertime (May-Sep) heat-related deaths, by year" ,
#' format="name")
#' }
#' @export


### Print out Geographic Types for a Measure ###

list_GeographicTypes <- function(measure=NA,
                           format="ID",
                          simplified_output=T){
  format <- match.arg(format, 
                    choices = c("ID","name","shortName"))
  
  meas_formatting <- paste0("measure_",format)
  ind_formatting <- paste0("indicator_",format)
  CA_formatting <- paste0("content_area_",format)

  #load("data/measures_indicators_CAs.RData")
  if(any(is.na(measure))){
    meas_ID <- unique(EPHTrackR::measures_indicators_CAs$measure_ID)
  }else{
    meas_ID <- 
      unique(EPHTrackR::measures_indicators_CAs$measure_ID
             [which(EPHTrackR::measures_indicators_CAs[,meas_formatting]%in%measure )])
  }

  GL_list <- purrr::map( 1:length(meas_ID), function(geolev){
    GL <- 
      httr::GET(paste0("https://ephtracking.cdc.gov:443/apigateway/api/v1/geographicTypes/",
                 meas_ID[geolev]))

    GL_cont <- jsonlite::fromJSON(rawToChar(GL$content))
    GL_cont$Measure_ID <- meas_ID[geolev]
    GL_cont$Measure_Name <- 
      unique(EPHTrackR::measures_indicators_CAs$measure_name
             [which(EPHTrackR::measures_indicators_CAs$measure_ID==meas_ID[geolev])])

    GL_cont$Measure_shortName <- 
      unique(EPHTrackR::measures_indicators_CAs$measure_shortName
             [which(EPHTrackR::measures_indicators_CAs$measure_ID==meas_ID[geolev])])
    
    if(simplified_output == F){
      
      return(unique(GL_cont))
      
    } else{
      
      
      return(unique(dplyr::select(GL_cont,geographicType,
                             geographicTypeId, 
                             Measure_ID ,
                             Measure_Name,
                             smoothingLevel)))
    }
    
  }
  )
  
  return(GL_list)
}

