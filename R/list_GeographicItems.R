#' @name list_GeographicItems
#' @title List available geographies
#' @description  Lists available geographies (e.g., Fulton County, Georgia) for specified measures and geographic types. If multiple measures or geography types are submitted, the results for each combination of these two inputs will be returned as a separate list element in the output.
#' @import dplyr
#' @param measure Specifies the measure of interest as an ID or name. IDs should be unquoted; name entries should be quoted strings.
#' @param geo_type An optional argument in which you can specify a geographic type as a quoted string (e.g., "State", "County") or a geographic type ID as an unquoted numeric value (e.g., 1, 2). The "geographicType" and "geographicTypeId" columns in the list_geography_types() output contain a list of potential geo_type entries associated with each measure.
#' @param simplified_output If TRUE, a simplified output table is returned. If FALSE, the raw output from the Tracking Network Data API is returned. The default is TRUE.
#' @param rollup Submitting a value of 1 returns only parent geographies (e.g., for a county-level measure, the states containing the relevant counties will be returned). A value of 0 returns the child geographies (e.g., for a county-level measure, all counties where there is data will be returned). This argument does nothing if the focal geography type is already a state or tribal area (highest level geographic type). The default is 0.
#' @param token An optional argument to submit a Tracking API token acquired from trackingsupport(AT)cdc.gov as a quoted string. It is recommended that you save your token using the tracking_api_token() function so that you don't need to enter your token when you run this function. It will be automatically pulled from you .Renviron file.
#' @return This function returns a list with each element containing a data frame corresponding to each combination of the specified measures and geographic types.
#' @examples\dontrun{
#' 
#' geo1_id<-list_GeographicItems(measure=370)
#' 
#' geo2_name<-
#'   list_GeographicItems(measure=c("Number of summertime (May-Sep) heat-related deaths, by year"))
#' }
#' @export


### Print out geographic items for a Measure ID, Geographic Type and Geographic Rollup (rollup forces a view of all the parent geographic items) ###

list_GeographicItems <- function(measure=NA,
                    geo_type=NA,
                    simplified_output = TRUE,
                    rollup=0,
                    token=NULL){
  
  
  if(!is.null(token) &
     !is.character(token)){ #want the option to specify token as NA and circumvent submitting a token if desired. Need is.character instead of is.na because is.na(NULL) returns an empty vector
    
    warning("By submitting token as NA or in a non-string format, you're requesting that no token be submitted when calling the API. Set token to NULL (default) if you'd like to automatically include your saved token value in API calls.")
    
  }else if (Sys.getenv("TRACKING_API_TOKEN") != "") {
    
    token <- Sys.getenv("TRACKING_API_TOKEN")
    
  }else if (is.null(token)) {
    
    warning("Consider obtaining a Tracking API token from trackingsupport@cdc.gov to avoid throttling or other issues with your API calls.")
  }
  
  

  GL_list <- list_GeographicTypes(measure,
                            simplified_output=F)
  
  GL_table <- unique(purrr::map_dfr(GL_list,as.data.frame))
  

  #subsetting geography list to only those specified only if geographies are specified
  if(any(!is.na(geo_type))){
    GL_table <-
      GL_table[which(GL_table$geographicTypeId %in% geo_type |
                       tolower(GL_table$geographicType) %in% 
                       gsub(" ","",tolower(geo_type))),]
  }

  meas_ID <- GL_table$measureId
  geo_typeID <- GL_table$geographicTypeId


  geo_list <- purrr::map(1:length(meas_ID), 
                       function(gg){
                         
                         url <- paste0(
                           "https://ephtracking.cdc.gov:443/apigateway/api/v1/geographicItems/",
                           meas_ID[gg],"/",geo_typeID[gg],"/",rollup)
                         
                         if(!is.null(token) & 
                            is.character(token)){
                           
                           url <- paste0(url,  "?apiToken=", token)
                           
                         } 
                         
                         
                         geo <- httr::GET(url)
                         
                         if(geo$status_code == 404 ||
                            length(geo$content)==2){
                           stop("The Tracking API may be down or the parameters you entered may be incorrect. If the problem persists for more than 24 hours, contact trackingsupport(AT)cdc.gov.")
                         }
                         
                         geo_cont <- jsonlite::fromJSON(rawToChar(geo$content))
                         
                         geo_cont$measureId <- meas_ID[gg]
                         
                         geo_cont$measureName<-GL_table$measureName[gg]
                         
                         geo_cont$geo_type<-GL_table$geographicType[gg]
                         geo_cont$geo_typeID<-GL_table$geographicTypeId[gg]
                         
                         if(simplified_output == F){
                           
                           return(geo_cont)
                          
                         } else{
                           
                           return(dplyr::select(geo_cont,
                                                parentGeographicId,
                                                parentName,
                                                childGeographicId,
                                                childName,
                                                measureId,
                                                measureName,
                                                geo_type,
                                                geo_typeID))
                           
                         }
                         
                         
                       }
                       )
  
  return(geo_list)
  

}


