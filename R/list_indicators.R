#' @name list_indicators
#' @title List indicators
#' @description  Lists the indicators contained within the specified content area(s). Indicators are groups of highly related measures.
#' @param content_area Optional argument used to specify the content area(s) of interest as an ID or name. IDs should be unquoted numeric values; name entries should be quoted strings. Use list_content_areas() to identify available content areas.
#' @param token An optional argument to submit a Tracking API token acquired from trackingsupport(AT)cdc.gov as a quoted string. It is recommended that you save your token using the tracking_api_token() function so that you don't need to enter your token when you run this function. It will be automatically pulled from you .Renviron file.
#' @return This function returns a data frame containing all indicator names, shortNames, and IDs contained in the specified content area(s).
#' @examples \dontrun{
#' 
#' #create a comprehensive inventory of all indicators and associated content areas
#' all_indicators<-list_indicators()
#' 
#' list_indicators(25)
#' 
#' list_indicators("Drought")
#' 
#' 
#' 
#' 
#' }
#' @export


### Print out Indicators within a Content Area ###
list_indicators <- function(content_area=NA,
                          token=NULL){
  
  if(!is.null(token) &
     !is.character(token)){ #want the option to specify token as NA and circumvent submitting a token if desired. Need is.character instead of is.na because is.na(NULL) returns an empty vector
    
    warning("By submitting token as NA or in a non-string format, you're requesting that no token be submitted when calling the API. Set token to NULL (default) if you'd like to automatically include your saved token value in API calls.")
    
  }else if (Sys.getenv("TRACKING_API_TOKEN") != "") {
    
    token <- Sys.getenv("TRACKING_API_TOKEN")
    
  }else if (is.null(token)) {
    
    warning("Consider obtaining a Tracking API token from trackingsupport@cdc.gov to avoid throttling or other issues with your API calls.")
  }
  

  
  inds <- list_measures()
  
  if(any(is.na(content_area))){
    
    
    inds_sub <- inds[c("contentAreaId" ,
                       "contentAreaName",
                       "indicatorId",
                       "indicatorName")]
  }else{
    
    inds_sub <- inds[which(inds$contentAreaId %in% content_area |
                             tolower(inds$contentAreaName) %in% 
                             tolower(content_area)),]
    
    inds_sub <- inds_sub[c("contentAreaId" ,
                       "contentAreaName",
                       "indicatorId",
                       "indicatorName")]
  }
      
  inds_sub <- unique(inds_sub)
  
  inds_sub <- inds_sub[order(
    as.numeric(inds_sub$contentAreaId),
    as.numeric(inds_sub$indicatorId)),]
  
  rownames(inds_sub) <- 1:nrow(inds_sub)
  
 return(inds_sub)
  
}


