#' @name list_TemporalItems
#' @title List temporal items
#' @description  List the temporal items (periods) available for specified measures, geography types, and geographic items.
#' @import dplyr
#' @param measure Specifies the measure of interest as an ID or name. IDs should be unquoted; name entries should be quoted strings. It is recommended that only one measure be submitted.
#' @param geo_type An optional argument in which you can specify a geographic type as a quoted string (e.g., "State", "County") or a geographic type ID as an unquoted numeric value (e.g., 1, 2). The "geographicType" and "geographicTypeId" columns in the list_geography_types() output contain a list of potential geo_type entries associated with each measure.
#' @param simplified_output If TRUE, a simplified output table is returned. If FALSE, the raw output from the Tracking Network Data API is returned. The default is FALSE.
#' @param token An optional argument to submit a Tracking API token acquired from trackingsupport(AT)cdc.gov as a quoted string. It is recommended that you save your token using the tracking_api_token() function so that you don't need to enter your token when you run this function. It will be automatically pulled from you .Renviron file.
#' @return This function returns a list with each element containing a data frame corresponding to each combination of the specified measures and geographic types.
#' @examples \dontrun{
#' 
#' 
#' temp <- list_TemporalItems(measure = 99)
#'                           
#'                           
#'                           
#' }
#' @export


list_TemporalItems <- function(measure,
                               geo_type=NA,
                               simplified_output=FALSE,
                               token=NULL){
  
  if(length(measure)>1){
    
    warning("Call may fail because more than one measure has been entered")
  }
  
  
  if(!is.null(token) &
     !is.character(token)){ #want the option to specify token as NA and circumvent submitting a token if desired. Need is.character instead of is.na because is.na(NULL) returns an empty vector
    
    warning("By submitting token as NA or in a non-string format, you're requesting that no token be submitted when calling the API. Set token to NULL (default) if you'd like to automatically include your saved token value in API calls.")
    
  }else if (Sys.getenv("TRACKING_API_TOKEN") != "") {
    
    token <- Sys.getenv("TRACKING_API_TOKEN")
    
  }else if (is.null(token)) {
    
    warning("Consider obtaining a Tracking API token from trackingsupport@cdc.gov to avoid throttling or other issues with your API calls.")
  }
  
  
  geo_list <- list_GeographicItems(measure,
                      geo_type,
                      simplified_output=F,
                      token = token)
  
  
  
  

  temp_list <- purrr::map(1:length(geo_list), function(tp){
    
    #Call requirements
    # ephtracking.cdc.gov/apigateway/api/{version}/temporalItems/{measureID}/{geographicTypeId}/{geographicTypeIdFilter}/
    #   {geographicItemsFilter}[?apiToken]
    measureId <- geo_list[[tp]][1,"measureId"]
    geo_typeID <- geo_list[[tp]][1,"geo_typeID"]
    
    #sometimes the "ALL" entry for the geo type and items filter does not work (not clear why). If ALL fails, trying the call by entering all the geo items.
    
    tryCatch({
      
      url <- paste0("https://ephtracking.cdc.gov/apigateway/api/v1/temporalItems/",
                    measureId,"/",
                    geo_typeID,"/",
                    "ALL","/","ALL")
      
      if(!is.null(token) & 
         !is.na(token)){
        
        url <- paste0(url,  "?apiToken=", token)
        
      } 
      
      temp <-
        httr::GET(url)
      },
      
      error=function(cond) {
        geoitemsfiterID <- ifelse(!is.na(geo_list[[tp]]$childGeographicId[1]),
                             unique(geo_list[[tp]]$childGeographicId),
                             unique(geo_list[[tp]]$parentGeographicId))
        
        url <- paste0("https://ephtracking.cdc.gov/apigateway/api/v1/temporalItems/",
                      measureId,"/",
                      geo_typeID,"/",
                      geo_typeID,"/", #specifying items geo type
                      geoitemsfiterID)
        
        if(!is.null(token) & 
           !is.na(token)){
          
          url <- paste0(url,  "?apiToken=", token)
          
        } 
        
        
        
        temp <-
          httr::GET(url)
             })

    if(temp$status_code == 404 ||
       length(temp$content) == 2){
      stop("The Tracking API may be down or the parameters you entered may be incorrect. If the problem persists for more than 24 hours, contact trackingsupport(AT)cdc.gov.")
    }
   
    
    temp_cont <- jsonlite::fromJSON(rawToChar(temp$content))
    
    temp_cont$measureName <- rep(geo_list[[tp]]$measureName[1], 
                             nrow(temp_cont))
    
    temp_cont$measureId <- rep(geo_list[[tp]]$measureId[1], 
                                nrow(temp_cont))
    
    temp_cont$geo_type <- rep(geo_list[[tp]]$geo_type[1], 
                              nrow(temp_cont))
    
    temp_cont$geo_typeID <- rep(geo_list[[tp]]$geo_typeID[1], 
                                nrow(temp_cont))
  
    
    if(simplified_output == F){
      
      return(temp_cont)
      
    } else{
      
      return(
          
          dplyr::select(temp_cont,
                        parentTemporal,
                        parentTemporalType,
                        temporal,
                        temporalType,
                        geo_type,
                        measureName,
                        measureId)
 
        
    
      )
    }
  })
  
  return(temp_list)
  
}


