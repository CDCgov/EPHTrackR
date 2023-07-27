#' @name list_GeographicTypes
#' @title List available geographic types
#' @description  Lists geographic types (e.g., state, county) for specified measure(s). If multiple measures are specified, the results for each are returned as separate list elements.
#' @param measure Specifies the measure of interest as an ID or name. IDs should be unquoted; name entries should be quoted strings. It is highly recommended that you entered IDs rather than names to avoid issues with string matching with special characters, spaces, and capitalization etc.
#' @param simplified_output If TRUE, a simplified output table is returned. If FALSE, the raw output from the Tracking Network Data API is returned. The default is TRUE.
#' @param token An optional argument to submit a Tracking API token acquired from trackingsupport(AT)cdc.gov as a quoted string. It is recommended that you save your token using the tracking_api_token() function so that you don't need to enter your token when you run this function. It will be automatically pulled from you .Renviron file.
#' @return This function returns a list with each element containing a data frame corresponding to a specified measure.
#' @examples \dontrun{
#' list_GeographicTypes(measure=370)
#' 
#' list_GeographicTypes(measure=c(370,423,707))
#' 
#' list_GeographicTypes(measure=c("Number of summertime (May-Sep) heat-related deaths, by year",
#'                            "Number of extreme heat days",
#'                            "Number of months of mild drought or worse per year"))
#'                  
#'                  
#' list_GeographicTypes(measure="Number of summertime (May-Sep) heat-related deaths, by year")
#' }
#' @export


### Print out Geographic Types for a Measure ###

list_GeographicTypes <- function(measure,
                                 simplified_output=T,
                                 token=NULL){
  
  if(!is.null(token) &
     !is.character(token)){ #want the option to specify token as NA and circumvent submitting a token if desired. Need is.character instead of is.na because is.na(NULL) returns an empty vector
    
    warning("By submitting token as NA or in a non-string format, you're requesting that no token be submitted when calling the API. Set token to NULL (default) if you'd like to automatically include your saved token value in API calls.")
    
  }else if (Sys.getenv("TRACKING_API_TOKEN") != "") {
    
    token <- Sys.getenv("TRACKING_API_TOKEN")
    
  }
  
  else if (is.null(token) &
           !is.character(token)) {
    
    warning("Consider obtaining a Tracking API token from trackingsupport@cdc.gov to avoid throttling or other issues with your API calls.")
  }
  

  
  meas_df <- list_measures(token=token)
  
  meas_ID <- unique(meas_df$measureId[
    c(match(measure,meas_df$measureId ),
      match(tolower(measure),tolower(meas_df$measureName)))[
        !is.na(c(match(measure,meas_df$measureId ),
                 match(tolower(measure),tolower(meas_df$measureName))))]])
  


    
    if(length(meas_ID)==0){
      
      stop("You entered an incorrect measure name or measure ID. Entering IDs is recommended, because string matching is error-prone.")
    }
    
    
    

  GL_list <- purrr::map( 1:length(meas_ID), function(geolev){
    
    url <- paste0("https://ephtracking.cdc.gov:443/apigateway/api/v1/geographicTypes/",
                  meas_ID[geolev])
    
    if(!is.null(token) & 
       is.character(token)){
      
      url <- paste0(url,  "?apiToken=", token)
      
    } 
    
    GL <- 
      httr::GET(url)
    
    if(GL$status_code == 404 ||
       length(GL$content)==2){
      stop("The Tracking API may be down or there may be a problem with the parameters you entered. If the problem persists for more than 24 hours, contact trackingsupport(AT)cdc.gov.")
    }

    GL_cont <- jsonlite::fromJSON(rawToChar(GL$content))
    
    GL_cont$measureId <- meas_ID[geolev]
    
    GL_cont <-  
      dplyr::left_join(GL_cont,
                unique(meas_df[c("measureId","measureName")]),
                by="measureId")

    
    if(simplified_output == F){
      
      return(unique(GL_cont))
      
    } else{
      
      
      return(unique(dplyr::select(GL_cont,geographicType,
                             geographicTypeId, 
                             measureId ,
                             measureName,
                             smoothingLevel)))
    }
    
  }
  )
  
  return(GL_list)
}

