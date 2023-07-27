#' @name list_measures
#' @title List available measures
#' @description  Lists the measures contained within specified indicator(s) and/or content area(s). Measures are the core data product of the Tracking Network.
#' @param indicator Optional argument used to specify the indicator(s) of interest as an ID or name. IDs should be unquoted; name entries should be quoted strings. Use list_indicators() to identify available indicators.
#' @param content_area Optional argument used to specify the content area(s) of interest as an ID or name. IDs should be unquoted; name entries should be quoted strings. Use list_content_areas() to identify available content areas.
#' @param token Optional argument to submit a Tracking API token acquired from trackingsupport(AT)cdc.gov as a quoted string. It is recommended that you save your token using the tracking_api_token() function so that you don't need to enter your token when you run this function. It will be automatically pulled from you .Renviron file.
#' @return This function returns a data frame containing the measures within the specified indicator(s) and/or content area(s).
#' @examples \dontrun{
#' 
#'#create a comprehensive inventory of all measures and their associated indicators and content areas
#'full_inventory <- list_measures()
#'
#'list_measures(indicator=67)
#'
#'list_measures(indicator=c(67,173))
#'
#'list_measures(indicator="Heat-Related Mortality")
#'
#'list_measures(content_area = 25)
#'
#'list_measures(indicator=67,content_area =25)
#'
#'list_measures(indicator="Historical Temperature & Heat Index",content_area ="Drought")
#'
#'
#'
#' }
#' @export

# library(httr)
# library(jsonlite)
# library(plyr)


### Print out Measures within an Indicator and/or Content Area ###

list_measures <- function(indicator=NA,
                        content_area=NA,
                        token=NULL){
  
  
  if(!is.null(token) &
     !is.character(token)){ #want the option to specify token as NA and circumvent submitting a token if desired. Need is.character instead of is.na because is.na(NULL) returns an empty vector
    
    warning("By submitting token as NA or in a non-string format, you're requesting that no token be submitted when calling the API. Set token to NULL (default) if you'd like to automatically include your saved token value in API calls.")
    
  }else if (Sys.getenv("TRACKING_API_TOKEN") != "") {
    
    token <- Sys.getenv("TRACKING_API_TOKEN")
    
  }else if (is.null(token) &
            !is.character(token)) {
    
    warning("Consider obtaining a Tracking API token from trackingsupport@cdc.gov to avoid throttling or other issues with your API calls.")
  }
  
  
  
  measures_url <- "https://ephtracking.cdc.gov:443/apigateway/api/v1/measuresearch"
  
  
  if(!is.null(token) & 
     is.character(token)){
    
    measures_url <- 
      paste0( measures_url,  
              "?apiToken=", 
              token)
    
  } 
  
  meas <- httr::GET(measures_url)
  
  if(meas$status_code == 404 ||
     length(meas$content)==2){
    Sys.sleep(10)
    
    meas <-
      httr::GET(measures_url)
    
    if(meas$status_code == 404 ||
       length(meas$content)==2){
      
      stop("The Tracking API may be down or overloaded. If the problem persists for more than 24 hours, contact trackingsupport(AT)cdc.gov.")
    }
  }
  
  
  meas_cont <- jsonlite::fromJSON(rawToChar(meas$content))
  
  
  if(!is.null(meas_cont$message)){
    
    stop(meas_cont$message)
  }
  
  if(any(is.na(indicator)) & 
     any(is.na(content_area))){
    
    
    Meas <- meas_cont
    
    
    
  } else{
    
    Meas <- meas_cont[which(meas_cont$indicatorId %in% indicator |
                            tolower(meas_cont$indicatorName) %in% tolower(indicator) |
                             meas_cont$contentAreaId %in% content_area |
                             tolower(meas_cont$contentAreaName) %in% tolower(content_area)),]
    
    if(nrow(Meas)==0){
      
      stop("The specified indicator or content_area could not be found. No measures returned.")
    }
  
    
    
    
  }
  
  Meas <- unique(Meas)
  
  Meas <- Meas[order(
    as.numeric(Meas$contentAreaId),
    as.numeric(Meas$indicatorId),
    as.numeric(Meas$measureId)),]
  
  rownames(Meas) <- 1:nrow(Meas)
  

  Encoding(Meas$measureName) <- "UTF-8"
  Encoding(Meas$contentAreaName) <- "UTF-8"
  Encoding(Meas$indicatorName) <- "UTF-8"
  
  # names(Meas) <- c("content_Area_ID", "contentAreaName" , "indicatorId"  , 
  #                  "indicatorName" , "Measure_ID" , "Measure_Name",
  #                  "indicatorStatusId", "contentAreaStatusId","keywords")
 
  return(Meas)
}

