#' @name list_content_areas
#' @title List all content areas 
#' @description  Lists the content areas available on the CDC Tracking Network. Content areas are the highest level of categorization on the CDC Tracking Network.
#' @param token An optional argument to submit a Tracking API token acquired from trackingsupport(AT)cdc.gov as a quoted string. It is recommended that you save your token using the tracking_api_token() function so that you don't need to enter your token when you run this function. It will be automatically pulled from you .Renviron file.
#' @return This function returns a data frame containing all content area names, shortNames, and IDs.
#' @examples\dontrun{
#' 
#' #return a comprehensive inventory of all content areas
#' list_content_areas()
#' }
#' @export


### Print out Content Areas ###

list_content_areas <- function(token=NULL){
  
  if(!is.null(token) &
     !is.character(token)){ #want the option to specify token as NA and circumvent submitting a token if desired. Need is.character instead of is.na because is.na(NULL) returns an empty vector
    
    warning("By submitting token as NA or in a non-string format, you're requesting that no token be submitted when calling the API. Set token to NULL (default) if you'd like to automatically include your saved token value in API calls.")
    
  }else if (Sys.getenv("TRACKING_API_TOKEN") != "") {
    
    token <- Sys.getenv("TRACKING_API_TOKEN")
    
  }else if (is.null(token)) {
    
    warning("Consider obtaining a Tracking API token from trackingsupport@cdc.gov to avoid throttling or other issues with your API calls.")
  }
  
  
  url <- "https://ephtracking.cdc.gov:443/apigateway/api/v1/contentareas/json"
  
  if(!is.null(token) & 
     is.character(token)){
    
    url <- paste0(url,  "?apiToken=", token)
    
  } 
  
  CAs_raw <-
    httr::GET(url)
  
  if(CAs_raw$status_code == 404 ||
     length(CAs_raw$content)==2){
    stop("The Tracking API may be down. If the problem persists for more than 24 hours, contact trackingsupport(AT)cdc.gov.")
  }
  
  CAs <- jsonlite::fromJSON(rawToChar(CAs_raw$content))
  
  CAs <- CAs[1:2]
  
  names(CAs)<-c("contentAreaId","contentAreaName")
  
  CAs <- unique(CAs)
  
  CAs_sorted<-CAs[order(as.numeric(CAs$contentAreaId)),]
  
  rownames(CAs_sorted)<-1:nrow(CAs_sorted)
  
  CAs_sorted
}

