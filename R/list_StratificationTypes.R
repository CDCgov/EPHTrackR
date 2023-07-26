#' @name list_StratificationTypes
#' @title List stratification values
#' @description Some measures on the Tracking Network have a set of "Advanced Options" that allow the user to access data stratified by variables other than geography or temporal period. For instance, data on asthma hospitalizations can be broken down further by age and/or gender. This function allows the user to list available "Advanced Options" stratification values for specified measures and geographic types. For instance, in the case of the asthma hospitalization data, it would be possible to view the potential gender (e.g., Male, Female), and age (e.g., 0–4 years, >=65 years) values that are available.
#' 
#' 
#' The user should not need this function to retrieve data from the Tracking Network Data API because the get_data() function calls it internally. It can, however, be used as a reference to view available stratification values or to identify specific stratification items to request.
#' @import dplyr
#' @param measure Specifies the measure of interest as an ID or name. IDs should be unquoted; name entries should be quoted strings.
#' @param geo_type An optional argument in which you can specify a geographic type as a quoted string (e.g., "State", "County") or a geographic type ID as an unquoted numeric value (e.g., 1, 2). The "geographicType" and "geographicTypeId" columns in the list_geography_types() output contain a list of potential geo_type entries associated with each measure.
#' @param smoothing Specifies whether to return stratification values for geographically smoothed versions of a measure (1) or not (0). The default value is 0 because smoothing is not available for most measures.
#' @param token An optional argument to submit a Tracking API token acquired from trackingsupport(AT)cdc.gov as a quoted string. It is recommended that you save your token using the tracking_api_token() function so that you don't need to enter your token when you run this function. It will be automatically pulled from you .Renviron file.
#' @return This function returns a list with each element containing a data frame corresponding to all combinations of specified measures and geographic types. Within each row of the data frame is a nested data frame containing the stratification values. If the specified measure and associated geographic type do not have any "Advanced Options" stratification types, the returned list element will be empty.
#' @examples \dontrun{
#' 
#' 
#' list_StratificationTypes(measure=370)
#' 
#' list_StratificationTypes(measure=c(370,423,707))
#'  
#' list_StratificationTypes(measure=c("Number of summertime (May-Sep) heat-related deaths, by year",
#'   "Number of extreme heat days","Number of months of mild drought or worse per year"))
#'   
#' list_StratificationTypes(measure=c("Number of summertime (May-Sep) heat-related deaths, by year",
#                                 "Number of extreme heat days","Number of months of drought per year"))


#' }
#' @export



### Print out Stratification Types for a Measure and Geographic Type ###

#I wonder if this should be called strat items instead. differences between types and levels is confusing...

list_StratificationTypes <-
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
    
    
    MS_list <- purrr::map(1:length(GL_list),function(measstrat){
      
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
          # ephtracking.cdc.gov/apigateway/api/{version}/stratificationTypes/{measureId}/{geographicTypeId}/
          #   {isSmoothed}[?apiToken]
          
          url <- paste0("https://ephtracking.cdc.gov:443/apigateway/api/v1/stratificationTypes/",
                        GL_list_sub$measureId[i],"/",
                        GL_list_sub$geographicTypeId[i],"/",smoothing)
          
          if(!is.null(token) & 
             is.character(token)){
            
            url <- paste0(url,  "?apiToken=", token)
            
          }  
          
          MS <-
            httr::GET(url)
          
          if(MS$status_code == 404){
            
            stop("The Tracking API may be down or the parameters you entered may be incorrect. If the problem persists for more than 24 hours, contact trackingsupport(AT)cdc.gov.")
            
          }
          
          
          if(length(MS$content) >2){
            MS_cont <- jsonlite::fromJSON(rawToChar(MS$content))
            MS_cont$measureId <-  GL_list_sub$measureId[i]
            MS_cont$measureName <- GL_list_sub$measureName[i]
            MS_cont$Geo_Type <- GL_list_sub$geographicType[i]
            MS_cont$geo_typeID <- GL_list_sub$geographicTypeId[i]
            
            return(MS_cont)
            
          } else{
            
            warning(paste0("A measure (or measure/geography type combination) you requested (MeasureID: ",
                           GL_list_sub$measureId[i],
                           ", geo_typeID: "
                           ,GL_list_sub$geographicTypeId[i] ,
                           ") does not appear to have a stratification type, likely because it doesn't have any Advanced Options. The results returned may not contain all the information you expected. If you're sure the requested measure/goe_type combination has a stratification type, the Tracking API may be down. If the problem persists for more than 24 hours, contact trackingsupport(AT)cdc.gov."))
            
            
            return(data.frame(measureId = GL_list_sub$measureId[i],
                                   geo_typeID = GL_list_sub$geographicTypeId[i],
                                   stratificationItem = "No stratification items found"))
          }
          
        })
      
      #unnesting the list if there's only one advanced option to display 
      if(length(API_results)==1){
        
        
        return(API_results[[1]])
        
      } else{ return(API_results)}
     
      
      
    })
    
    
    return(MS_list)
  }
