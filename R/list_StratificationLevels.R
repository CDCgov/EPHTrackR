#' @name list_StratificationLevels
#' @title List stratification levels
#' @description  Some measures on the Tracking Network have a set of "Advanced Options" that allow the user to access data stratified by variables other than geography or temporal period. For instance, data on asthma hospitalizations can be broken down further by age and/or gender. This function allows the user to list available "Advanced Options" stratification levels for specified measures and geographic types. For instance, in the case of the asthma hospitalization data, it would be possible to view the full range of stratification levels available, including gender, age, and both gender and age combined.
#' 
#' 
#'Because "Advanced Options" may only be available at a particular geographic type (e.g., an age-breakdown of asthma hospitalizations is only available at the state-level), results showing available stratification levels always include the geographic type. Therefore, this function can be used to identify geographic types and stratification levels of interest.
#' @import dplyr
#' @param measure Specifies the measure of interest as an ID or name. IDs should be unquoted; name entries should be quoted strings.
#' @param geo_type An optional argument in which you can specify a geographic type as a quoted string (e.g., "State", "County") or a geographic type ID as an unquoted numeric value (e.g., 1, 2). The "geographicType" and "geographicTypeId" columns in the list_geography_types() output contain a list of potential geo_type entries associated with each measure.
#' @param smoothing Specifies whether to return stratification levels for geographically smoothed versions of a measure (1) or not (0). The default value is 0 because smoothing is not available for most measures. Requesting smoothed data when it is not available will produce an error.
#' @param token An optional argument to submit a Tracking API token acquired from trackingsupport(AT)cdc.gov as a quoted string. It is recommended that you save your token using the tracking_api_token() function so that you don't need to enter your token when you run this function. It will be automatically pulled from you .Renviron file.
#' @return The output of this function is a list with data frame elements for each measure submitted. The data frames contain a row for each stratification level. 
#' @examples \dontrun{
#' 
#' list_StratificationLevels(measure=370)
#'
#' list_StratificationLevels(measure=c(370,423,707))
#'
#' list_StratificationLevels(measure=c("Number of summertime (May-Sep) heat-related deaths, by year",
#'                                 "Number of extreme heat days","Number of months of drought per year"))
#'                       
#'                       
#' }
#' @export


### Return Stratification Levels for a Measure and Geographic Type ###
list_StratificationLevels <-
  function(measure,
           geo_type=NA,
           smoothing=0,
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
                                    token=token)
    
    
    SL_list <- purrr::map(1:length(GL_list),function(measstrat){
      
      GL_list_sub <- GL_list[[measstrat]]
      
      #subsetting geography type list if a particular geo type is requested
      if(any(!is.na(geo_type))){
        
        GL_list_sub <-  
          GL_list_sub[which(GL_list_sub$geographicTypeId %in% geo_type |
                              tolower(GL_list_sub$geographicType) %in% 
                              gsub(" ", "", tolower(geo_type))),]
        
        if(nrow(GL_list_sub)==0){
          
          stop("The specified geographic type may not be available for this measure.")
          
        }
      }
      

      
      #using this to return a list or nested list of strats for each geography type
      API_results <- 
        purrr::map(1:nrow(GL_list_sub),function(i){
          
          #Required arguments
          #ephtracking.cdc.gov/apigateway/api/{version}/stratificationlevel/
          # {measureId}/{geographicTypeId}/{isSmoothed}[?apiToken]
          
          url <- paste0("https://ephtracking.cdc.gov:443/apigateway/api/v1/stratificationlevel/",
                        GL_list_sub$measureId[i],"/",
                        GL_list_sub$geographicTypeId[i],"/",
                        smoothing)
          
          if(!is.null(token) & 
             !is.na(token)){
            
            url <- paste0(url,  "?apiToken=", token)
            
          } 
          

          MS <-
            httr::GET(url)
          
          
          if(MS$status_code == 404 ||
             length(MS$content) == 2){
            stop("The Tracking API may be down or the parameters you entered may be incorrect. If the problem persists for more than 24 hours, contact trackingsupport(AT)cdc.gov.")
          }
          
      
            MS_cont <- jsonlite::fromJSON(rawToChar(MS$content))
            MS_cont$measureId <-  GL_list_sub$measureId[i]
            MS_cont$measureName <- GL_list_sub$measureName[i]
            MS_cont$Geo_Type <- GL_list_sub$geographicType[i]
            MS_cont$geo_typeID <- GL_list_sub$geographicTypeId[i]
            
            names(MS_cont)[which(names(MS_cont)=="id")] <- "stratificationLevelId"
            names(MS_cont)[which(names(MS_cont)=="name")] <- "stratificationLevelName"
            names(MS_cont)[which(names(MS_cont)=="abbreviation")] <- "stratificationLevelAbbreviation"
            
            return(MS_cont)
  
          
        })
      
      #binding together the separate data frames for each geography type
      API_results <- dplyr::bind_rows( API_results)
      
      
      
    })
    
    
    return(SL_list)
  }


