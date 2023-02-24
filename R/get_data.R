#' @name get_data
#' @title Retrieve measure data
#' @description Retrieves data from the Tracking Network Data API for specified measures, geographies, stratifications, and temporal items. We recommend that you submit only one measure and one stratification level (many geographies and temporal periods may be provided, however). The function may work if multiple measures or stratification levels are submitted, but the resulting object will be a multi-element list from which it might be difficult to distinguish which element applies to a particular stratification level. The output of function calls with a single measure and stratification level is a list with one element containing the relevant data frame.
#' @param measure Specifies the measure of interest as an ID or name. IDs should be unquoted; name entries should be quoted strings.
#' @param strat_level An optional argument that specifies a stratification level by abbreviation as a quoted string (e.g., "ST_CT"), name as an quoted string (e.g., "State x County") or ID and an unquoted numeric value (e.g., 2). Stratification level specifications always include the geography type. They also may include "Advanced Options" that allow stratification by additional variables (e.g., age, gender). We recommend that this argument always be included in your get_data() calls and that only one stratification level be included per call. Including this argument renders the geo_type argument redundant. You can find available stratification levels in the "stratificationLevelAbbreviation", "stratificationLevelName", and "stratificationLevelId" columns in the list_StratificationLevels() output.
#' @param geo_type An optional argument in which you can specify a geographic type as a quoted string (e.g., "State", "County") or a geographic type ID as an unquoted numeric value (e.g., 1, 2). The "geographicType" and "geographicTypeId" columns in the list_geography_types() output contain a list of potential geo_type entries associated with each measure. The requested geo_type represents the geographic type of the retrieved data, which is not necessarily the same as geographic type of the geoItems argument. Do not use this argument if you have already specified a strat_level.
#' @param geoItems An optional argument that specifies geographic items as a vector of quoted strings (e.g., "Alabama", "Colorado", "Alameda, CA") or full FIPS codes as unquoted numeric values without leading zeros (e.g., 1, 8, 6001). You can request either the lowest level geographic items you would like included in the returned dataset (e.g., specify a county or census tract) or a state (i.e., parent geographic item) that contains the lowest level geographic items you would like returned in the data (e.g., specify a state to retrieve data for all counties or census tracts within that state). The "parentName","parentGeographicId", "childName, and "childGeographicId"  columns in the list_GeographicItems() output contains a list of available geoItems. To request a specific county by name, it is best to include the state/territory abbreviation after a comma in a quoted string (e.g., "Cumberland, PA", "Ingham, MI", "Middlesex, MA") and to omit words like county. It is safer to use FIPS codes rather than names to ensure that you retrieve the appropriate county. You can also mix items of different geographic types (e.g., state, county). If this argument is NULL, all geographies will be included in the output table.
#' @param temporalItems An optional argument to specify the temporal items(s) of interest as a vector of unquoted numeric values (e.g., 2011, 2019). If this argument is not entered, all available temporal items for the supplied measure and geographic constraints will be included in the output. You can find available temporal items in the "temporal" and "parentTemporal" columns in the list_TemporalItems() output.
#' #' @param stratItems An optional argument to specify specific stratification(s) of interest as vector of a quoted strings (e.g., c("RaceEthnicityId=1,2","GenderId=1")). This function allows you to return data from a subset of strata (e.g., return data for only males). This argument only applies to measure/geography combinations that have advanced stratification options, which can be determined by whether values are returned in the  stratificationItem column in the output of the list_StratificationTypes() function. Appropriate stratification(s) can be identified using the list_StratificationTypes() function output and combining the "type" of stratification derived from the columnName column (e.g., "GenderId") and the the ID for the stata/stratum of interest.  The IDs of the stata/stratum can be found in the list(s) contained within the stratificationItem column of the list_StratificationTypes() function output. The localId column within this nested list contains IDs that can be submitted in this argument. .
#' @param smoothing Specifies whether to return geographically smoothed measure data (1) or not (0). The default value is 0 because smoothing is not available for most measures. Requesting smoothed data when it is not available will produce an error.
#' @param simplified_output If TRUE, a simplified output table is returned. If FALSE, the raw output from the Tracking Network Data API is returned. The default is TRUE.
#' @param token An optional argument to submit a Tracking API token acquired from trackingsupport(AT)cdc.gov as a quoted string. It is recommended that you save your token using the tracking_api_token() function so that you don't need to enter your token when you run this function. It will be automatically pulled from you .Renviron file.
#' @return This function returns a list with each element containing a data frame corresponding to each combination of the specified measures and geographic types/stratification levels. Note that certain data values may be suppressed in accordance with CDC guidelines intended to protect individual privacy.
#' 
#' @examples \dontrun{
#' 
#' 
#' data_st <- get_data(measure=99, 
#' strat_level = "ST")
#' 
#' #return a subset of gender and age stratification items
#' data_ad <- get_data(measure=99,   
#' strat_level = "ST_AG_GN",
#' temporalItems = 2005,
#' stratItems = c("GenderId=1","AgeBandId=3"))
#' 
#' data_mo.geo <- get_data(measure=988,  
#' strat_level = "ST_PT",
#' geoItems = c(4,8,9,12))
#' 
#' 
#' }
#' @export


### Get data for multiple states and years ###
get_data<-
  function(measure,
           strat_level=NA,
           geo_type=NA,
           geoItems=NA,
           temporalItems=NA,
           stratItems=NA,
           smoothing=0,
           token = NULL,
           simplified_output=T){
    
    if(!is.null(token) &
       !is.character(token)){ #want the option to specify token as NA and circumvent submitting a token if desired. Need is.character instead of is.na because is.na(NULL) returns an empty vector
      
      warning("By submitting token as NA or in a non-string format, you're requesting that no token be submitted when calling the API. Set token to NULL (default) if you'd like to automatically include your saved token value in API calls.")
      
    }else if (Sys.getenv("TRACKING_API_TOKEN") != "") {
      
      token <- Sys.getenv("TRACKING_API_TOKEN")
      
    }else if (is.null(token)) {
      
      warning("Consider obtaining a Tracking API token from trackingsupport@cdc.gov to avoid throttling or other issues with your API calls.")
    }
    
    
    

     
     #the retrieved geography is determined by the strat level. The other geographic entries just specify the scale that you'd like to submit the request as
     SL_list <-
       list_StratificationLevels(measure,
                                 geo_type,
                                 smoothing,
                                 token=token)
     
     
     #subsetting the SL list if any SL's are specified
     if(all(!is.na( strat_level))){ 
       
       
       strat_indx <- 
         which(SL_list[[x]]$stratificationLevelId %in% strat_level |
                 tolower(SL_list[[x]]$stratificationLevelAbbreviation) %in% 
                 gsub(" ","",tolower(strat_level)) |
                 gsub(" ","",tolower(SL_list[[x]]$stratificationLevelName)) %in% 
                 gsub(" ","",tolower(strat_level)))
       
       if(length(strat_indx)==0){
         
         stop(paste0("The strat_level you requested (",strat_level, ") does not exist for the measure/geography requested. Use the list_stratificationLevels() function to identify appropriate strat_level entries for this measure/geography.")) 
         
       }else{
         
         SL_list <- 
           lapply(1:length(SL_list),
                  FUN = function(x){
                    SL_sub <- 
                      SL_list[[x]][strat_indx ,]
                    
                    return(SL_sub)
                    
                  })
         
       }
       
       
       
     }
    
#building out the the sl data frame to include specific geographic or temporal items selected
     
     GEO_TEMP_SL_list <-
       lapply(1:length(SL_list),
              FUN = function(y){
                                  
                                  
       
    #initializing some columns that will be filled later
                                  
                                 
                                  
       SL_list[[y]]$temporal_items <-NA
       SL_list[[y]]$temporal_items_type <-NA
       SL_list[[y]]$Geographic_ID <- NA
       SL_list[[y]]$geographicTypeId <- NA
       SL_list[[y]]$advanced_strat_call <- NA
       
       #print(y)
       for (j in 1:nrow(SL_list[[y]])){
         
         message(paste0("Building API call for ",
                      "measure: ",
                      SL_list[[y]]$measureId[j],
                      " with stratification: ",
                      SL_list[[y]]$stratificationLevelName[j],
                      "."
                      )) 
         
         SL_measure <- SL_list[[y]]$measureId[j]
         SL_geotype <- SL_list[[y]]$geo_typeID[j]
         
         ######################
         #retrieving all temporal items for measure
         temp_list <- 
           list_TemporalItems(SL_measure,
                              SL_geotype, 
                              simplified_output = FALSE,
                              token=token)
         
         temp_df <- temp_list[[1]]
         
         if(any(!is.na(temporalItems))){
           
           temp_df_sub <- temp_df[which(temp_df$temporal %in% temporalItems |
                                          temp_df$parentTemporal),]
           
           if(nrow(temp_df_sub)==0){ 
             stop("Requested temporalItems could not be found for measure/geography requested.")
           }
           
           
           temp_output <- temp_df_sub
           
         } else{
           
           temp_output <- temp_df
         }
         
         temp_vec <- rev(
           sort(
             # paste0(unique(gsub("[^0-9.-]", "",paste0(df$parentTemporal,df$temporal))),
             #         collapse = ",")
             # df$temporal
             
             paste0(unique(paste0(temp_output$temporal)),
                    collapse = ",")
           )
         )
         
         #adding temporal items call to SL data frame
         SL_list[[y]]$temporal_items[j] <- temp_vec
         
         SL_list[[y]]$temporal_items_type[j] <- temp_output$temporalTypeId[1]
         
         
         
         ##################
         #retrieving all geographic items for measure
         geo_list <- 
           list_GeographicItems(SL_measure,
                                SL_geotype,
                                simplified_output = FALSE,
                                token=token)
         
         
         geo_df <- geo_list[[1]]
         
         if(any(!is.na(geoItems))){
           
           #creating a county/state name column in case someone requests a county
           geo_df$county_state_name <- 
             tolower(paste0(geo_df$childName,",",
                            geo_df$parentAbbreviation ))
           
           #matching geo items entries to either ids or names. removing spaces and case from name entries.
           geo_df_sub <- geo_df[which(tolower(geo_df$parentName) %in% gsub(" ","",tolower(geoItems)) |
                                       tolower(geo_df$county_state_name) %in% gsub(" ","",tolower(geoItems)) |
                                       tolower(geo_df$childName) %in% gsub(" ","",tolower(geoItems)) |
                                        tolower(geo_df$parentAbbreviation) %in% gsub(" ","",tolower(geoItems)) |
                                       geo_df$parentGeographicId %in% geoItems |
                                       geo_df$childGeographicId %in% geoItems),]
           
           if(nrow(geo_df_sub)==0){ 
             stop("Requested geoItems could not be found for measure/geography requested.")
             }
           
           geo_output <- geo_df_sub
           
         } else{
           
           geo_output <- geo_df
         }
         
         geo_vec <- 
           paste0(unique(paste0(geo_output$id)),
                    collapse = ",")
         
         SL_list[[y]]$Geographic_ID[j] <- geo_vec
         
         SL_list[[y]]$geographicTypeId[j] <- geo_output$geo_typeID[1]
         
         
        
         ##################
         #Making sure that any requested advanced options are available in the stratification
         
         
         #if a strat item is required for the stratification level, identify what is needed
         if((length(SL_list[[y]]$stratificationType[[j]]) > 0)){
           
          
             MS_list <-
             list_StratificationTypes(SL_measure,
                                      SL_geotype,
                                      token=token)
           
           ms_df <- MS_list[[1]]
           
           #determining which stratification types are needed for the particular stratification level
           SL_strat_types <- SL_list[[y]]$stratificationType[[j]]$columnName
           
           #subsetting to just relevant strat types
           ms_df <- ms_df[which(ms_df$columnName %in% SL_strat_types),]
           
           
           adv_cal_vec <- c()
           
           strat_col_name <- c()
           
           strat_vals <-list()
           
           for(k in 1:nrow(ms_df)){
             
             #saving strat col names and values for future use
             strat_col_name[k] <- ms_df$columnName[k]
            
             strat_vals[[k]] <- ms_df[[7]][[k]]$localId                              
                                                   
      
             adv_cal_vec[k] <- paste0(strat_col_name[k], "=",
                                      paste0(strat_vals[[k]], 
                                             collapse=","))
             
             
             
             
           }
           
         } 
         
         #if no stratItems were specified, fill in all stratItems available
         if(any(is.na(stratItems)) & 
            (length(SL_list[[y]]$stratificationType[[j]]) > 0)){
           
           SL_list[[y]]$advanced_strat_call[j] <- paste0(adv_cal_vec, collapse="&")
           
           
         } 
         
         
         #if stratItems were specified, then make sure they apply to this particular stratification level and fill them in the dataframe instead of including all the stratItems available as above
         if(all(!is.na(stratItems)) &
            (length(SL_list[[y]]$stratificationType[[j]]) > 0)){ 
           
           initial_split <- strsplit(x = stratItems,
                                     split = c("&"))
           
          submitted_items <- lapply(1:length(initial_split),
                                    function(r){
                                      unlist(strsplit(initial_split[[r]],
                                               split = "="))})
           
          
           all_items <- strsplit(x = adv_cal_vec,
                                 split = "=")
           
           
             for(t in 1:length(submitted_items)){
               

               #checking whether the stratification category requested is appropriate and checking whether the requested values for that category actually make sense.
               #this if statement is messy, but need to check whether the column name is specified before you can check whether
               if(!(submitted_items[[t]][1] %in% strat_col_name) || #the double || ensures the rest of the if statement is only assessed if it passes the first one 
                  any(!(as.numeric(strsplit(submitted_items[[t]][2], split=",")[[1]]) %in% 
                          strat_vals[[which(strat_col_name %in% submitted_items[[t]][1])]] ))){ 
                 
                 warning("One of the stratItems you submitted could not be found in the data requested. Function will return all available stratifications types (" ,paste0(adv_cal_vec, collapse = "&") ,") for the requested stratification level (",SL_list[[y]]$stratificationLevelName[j],") .")
                 
                 SL_list[[y]]$advanced_strat_call[j] <- 
                   paste0(adv_cal_vec, collapse="&")
                 
                 #print(t)
                 break #breaking the loop if the condition is met that one of the requested stratifications is incorrect
                 
               }
               
               
             }
           
           
           #if nothing has been filled for the stratitems at this point, then we should fill it in with what the user submitted because this means that the submission passed all various checks
           if(is.na(SL_list[[y]]$advanced_strat_call[j])){
             
             SL_list[[y]]$advanced_strat_call[j] <- paste0(stratItems, collapse="&")
           }
           
         }
         
        
         
         
         
       
       }
       
       
       return(SL_list[[y]])
       
       
     })
       
    
    
    
  
     
    SL_df_complete <- purrr::map_dfr(GEO_TEMP_SL_list, as.data.frame)
     
    message("Retrieving data...")
    

    MD_list<-purrr::map(1:nrow(SL_df_complete), function(gch){
      #print(gch)
      
      # POST Format
      # URL:
      #   ephtracking.cdc.gov/apigateway/api/{version}/getCoreHolder/{measureId}/{stratificationLevelId}/{isSmoothed}/
      #   {getFullCoreHolder}[?stratificationLevelLocalIds][?apiToken]
      # Header:
      #   Accept: application/json
      # Body:
      #   {
      #     "geographicTypeIdFilter" : "string", "geographicItemsFilter" : "string", "temporalTypeIdFilter" : "string", "temporalItemsFilter" : "string" "embedId": "string"
      #   }
      
      
      POSTbody_args <- list(geographicTypeIdFilter = as.character(SL_df_complete[gch,]$geographicTypeId), 
                            geographicItemsFilter = SL_df_complete[gch,]$Geographic_ID, 
                            temporalTypeIdFilter= as.character(SL_df_complete[gch,]$temporal_items_type), 
                            temporalItemsFilter = SL_df_complete[gch,]$temporal_items)
      
      
      
      #use this call if advanced strata are required
      if(!is.na(SL_df_complete[gch,]$advanced_strat_call) ){
        
        
        
        url <- paste0("https://ephtracking.cdc.gov:443/apigateway/api/v1/getCoreHolder/",
                        SL_df_complete[gch,]$measureId,"/",
                        SL_df_complete[gch,]$stratificationLevelId,"/", #stratification level id
                        smoothing, "/",
                        0, "?",SL_df_complete[gch,]$advanced_strat_call) #don't need full core holder
          
          
        if(!is.null(token) & 
           !is.na(token)){
          
          url <- paste0(url,  "&apiToken=", token)
          
        } 
        
    
        
      }else{
        
        url  <- paste0("https://ephtracking.cdc.gov:443/apigateway/api/v1/getCoreHolder/",
                       SL_df_complete[gch,]$measureId,"/",
                       SL_df_complete[gch,]$stratificationLevelId,"/", #stratification level id
                       smoothing, "/",
                       0)#don't need full core holder
        
        
        if(!is.null(token) & 
           !is.na(token)){
          
          url <- paste0(url,  "?apiToken=", token)
          
        } 
        
      }
      
      MD <-
        httr::POST(
          url = url, 
          config = httr::add_headers("Accept: application/json"),
          body = POSTbody_args,
          encode="json"
          #,httr::verbose()
          )


      if(MD$status_code == 404 ||
         length(MD$content) == 2){
        stop("The Tracking API may be down. If the problem persists for more than 24 hours, contact trackingsupport(AT)cdc.gov.")
      }


      
      
      MD_cont <- jsonlite::fromJSON(rawToChar(MD$content))
      
      #removing empty list elements
      MD_cont <- purrr::compact(MD_cont )
      
      MD_cont <- purrr::compact(MD_cont )
      
      data_list_element <- if("tableResult"  %in% names(MD_cont)){
        "tableResult"
        
      }else{names(unlist(purrr::map(MD_cont,nrow))[which(unlist(purrr::map(MD_cont,nrow))>=1)])}
        
        
      
      #selecting the table results element with actual relevant data.
      #name of element can differ depending on the measure
      ###not totally sure that the third element is always the data
      MD_cont_tab <- MD_cont[[data_list_element]]
      
      
      
      #adding in stratification names only if lookuplist with the names exists
      if(length(MD_cont$lookupList)>0){
        MD_cont_lookup <- purrr::map(1:length(MD_cont$lookupList), function(v){
          
          
          df <- data.frame(groupById=v, 
                         full_stratification= 
                           paste(MD_cont$lookupList[[v]]$itemName,collapse=", "),
                         stringsAsFactors = F)
          
          for(u in 1:nrow(MD_cont$lookupList[[v]])){
            
            df <-  dplyr::mutate(df, 
                          !!MD_cont$lookupList[[v]]$name[u] := 
                            MD_cont$lookupList[[v]]$itemName[u]
                            )
            
          }
          
          return(df)
        })
        
        
        MD_cont_lookup_df <- purrr::map_dfr(MD_cont_lookup, 
                                          as.data.frame)
        
        #adding columns for entering stratification advanced options. length could change depending on number of stratifications
        MD_cont_tab[(length(MD_cont_tab)+1):
                      (length(MD_cont_tab)+(length(MD_cont_lookup_df)-1))] <-
          MD_cont_lookup_df[2:length(MD_cont_lookup_df)][match( MD_cont_tab$groupById,
                                                  MD_cont_lookup_df$groupById),]
        
        # MD_cont_tab$full_stratification <- 
        #   MD_cont_lookup_df$full_stratification[match( MD_cont_tab$groupById,
        #                                                MD_cont_lookup_df$groupById)]
        
        
        
      }
      
      #filling in the rest of the output table
      names(MD_cont_tab)[which(names(MD_cont_tab)=="year")]<-"date"
      
      MD_cont_tab$measureId<-SL_df_complete[gch,"measureId"]
      MD_cont_tab$measureName<-SL_df_complete[gch,"measureName"]
      MD_cont_tab$strat_levelID<-SL_df_complete[gch,"id"]
      MD_cont_tab$geo_typeID<-SL_df_complete[gch,"geo_typeID"]
      MD_cont_tab$Geo_Type<-SL_df_complete[gch,"Geo_Type"]
      
      
      MD_cont_tab<-MD_cont_tab[which(!is.na(MD_cont_tab$id)),]
      
      
      if(simplified_output==FALSE){
        
        return(MD_cont_tab)
        
      } else{
        
        return(dplyr::select(MD_cont_tab,
                             -any_of(c("id",
                                       "displayValue",
                                       "groupById",
                                       "geographicTypeId",
                                       "calculationType",
                                       "noDataId",
                                       "hatchingId",
                                       "hatching",
                                       "noDataBreakGroup",
                                       "categoryId",
                                       "category",
                                       "categoryName",
                                       "titleconfidenceIntervalLowName",
                                       "confidenceIntervalHighName",
                                       "standardErrorDisplay",
                                       "secondaryValueDisplay",
                                       "confidenceIntervalDisplay",
                                       "rollover"
                                       ))))
        
        
      }
      
      
    })
    
    message("Done")
    
    return(MD_list)
    
  }
