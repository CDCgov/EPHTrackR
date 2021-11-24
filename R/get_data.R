#' @name get_data
#' @title Retrieve measure data
#' @description Retrieves data from the Tracking Network Data API for specified measures, geographies, stratifications, and temporal periods. We recommend that you submit only one measure and one stratification level (many geographies and temporal periods may be provided, however). The function will work if multiple measures or stratification levels are submitted, but the resulting object will be a multi-element list from which it might be difficult to distinguish which element applies to a particular stratification level. The output of function calls with a single measure and stratification level is a list with one element containing the relevant data frame.
#' @param measure Specifies the measure of interest as an ID, name, or shortName. IDs should be unquoted; name and shortName entries should be quoted strings.
#' @param strat_level Specifies a stratification level by name or abbreviation. Stratification level specifications always include the geography type. They also may include "Advanced Options" that allow stratification by additional variables (e.g., age, gender). We recommend that this argument always be included in function calls and that only one stratification level be included per call. Including this argument renders the geo_type and geo_type_ID arguments redundant. You can find available stratification levels in the "name" or "abbreviation" columns in the list_stratification_levels() output.
#' @param strat_level_ID Specifies a stratification level by ID. Stratification level specifications always include the geography type. They also may include "Advanced Options" that allow stratification by additional variables (e.g., age, gender). We recommend that this argument always be included in function calls and that only one stratification level be included per call. Including this argument renders the geo_type and geo_type_ID arguments redundant. You can find available stratification levels in the "id" column in the list_stratification_levels() output.
#' @param geo An optional argument in which to specify geographies of interest as a quoted string (e.g., "Alabama", "Colorado"). Currently, this argument only accepts states even for county or sub-county geography specifications in the geo_type, geo_type_ID, and strat_level arguments. When a state-level geo argument is submitted with a sub-state geography specification, all sub-state geographies within the state will be returned. The "parentName" column in the list_geography() output contains a list of available geos. If this argument is NULL, all geographies will be included in the output.
#' @param geo_ID An optional argument in which to specify the FIPS codes of geographies of interest as unquoted numeric values without leading zeros (e.g., 1, 8). Currently, this argument only accepts states even for county or sub-county geography specifications in the geo_type, geo_type_ID, and strat_level arguments. When a state-level geo argument is submitted with a sub-state geography specification, all sub-state geographies within the state will be returned. The "parentGeographicId" column in the list_geography() output contains a list of geo_IDs. If this argument is NULL, all geographies will be included in the output.
#' @param temporal_period An optional argument in which to specify the temporal period(s) of interest with unquoted numeric values (e.g., 2011, 2019). If this argument is NULL, all temporal periods will be included in the output. You can find available temporal periods in the "parentTemporal" column in the list_temporal() output.
#' @param geo_type An optional argument in which you can specify a geographic type as a quoted string (e.g., "State", "County"). The "geographicType" column in the list_geography_types() output contains a list of geo_types associated with each measure.
#' @param geo_type_ID An optional argument in which you can specify a geographic type ID as an unquoted numeric value (e.g., 1, 2). The "geographicTypeId" column in the list_geography_types() output contains a list of geo_types associated with each measure.
#' @param format Indicates whether the measure argument contains entries formatted as an ID, name, or shortName as a quoted string (e.g., "name", "shortName"). The default is ID.
#' @param simplified_output If TRUE, a simplified output table is returned. If FALSE, the raw output from the Tracking Network Data API is returned. The default is TRUE.
#' @param geo_filter A 1 indicates that the geo/geo_ID arguments contain the parent geography type (e.g., states containing counties of interest). When 0, the child geographies should be specified in the geo/geo_ID arguments. Currently, the default value is 1, and this should not be changed because the child geography types cannot yet be used in the geo/geo_ID arguments.
#' @param smoothing Specifies whether to return geographically smoothed measure data (1) or not (0). The default value is 0 because smoothing is not available for most measures. Requesting smoothed data when it is not available will produce an error.
#' @return This function returns a list with each element containing a data frame corresponding to each combination of the specified measures and geographic types/stratification levels. Note that certain data values may be suppressed in accordance with CDC guidelines intended to protect individual privacy.
#' @examples \dontrun{
#' 
#' 
#' data_st <- get_data(measure=99, 
#' strat_level = "ST")
#' 
#' data_ad <- get_data(measure=99, 
#' format="ID",  
#' strat_level = "ST_AG_GN")
#' 
#' data_mo.geo <- get_data(measure=988, 
#' format="ID",  
#' strat_level = "ST_PT",
#' geo_ID = c(4,8,9,12))
#' 
#' 
#' }
#' @export


### Get data for multiple states and years ###
get_data<-
  function(measure=NA,strat_level=NA,
           strat_level_ID=NA,geo=NA,
           geo_ID=NA,temporal_period=NA,
           geo_type=NA,geo_type_ID=NA,
           format="ID",
           smoothing=0, geo_filter=1, 
           simplified_output=T){
    
    format<-match.arg(format, choices = c("ID","name","shortName"))
    
    
    SL_list<-
      list_stratification_levels(measure,
                          geo_type,geo_type_ID,format)
    
    MS_list<-list_stratification_values(measure,
                                   geo_type,geo_type_ID,format)
    temp_list<-list_temporal(measure,
                        geo_type,geo_type_ID,geo,
                        geo_ID,format, simplified_output = FALSE)
    
    
    
    temp_vec_list<-purrr::map(temp_list, function(x){
      
      if(any(!is.na(temporal_period))){
        
        df <- x[which(x$parentTemporal %in% temporal_period),]
        
      } else{
        
        df=x
      }
      
      temp_vec<- rev(
        sort(
          paste0(unique(gsub("[^0-9.-]", "",paste0(df$parentTemporal,df$childTemporal))),
                 collapse = ",")
        )
      )
      
      return(temp_vec)
    })
    
    
    
    
    
    #generating advanced options calls for each measure and geography type
    adv_opt_call_list<-purrr::map(1:length(SL_list), function(y){
      
      # if(any(!is.na(strat_level_ID)) | any(!is.na(strat_level))){
      #   
      # SL_table<-SL_list[[y]][which(SL_list[[y]]$id %in% strat_level_ID |
      #                                SL_list[[y]]$name %in% strat_level |
      #                                SL_list[[y]]$abbreviation %in% strat_level),]
      #   
      # } else{
      #   
      SL_table<-SL_list[[y]]
      #   
      # }
      
      
      adv_opt_call_row <- purrr::map(1:nrow(SL_table),function(i){
        
        if(length(unlist(SL_table[i,"stratificationType"]))>0){
          
          
          stratificationType <- as.list(SL_table[[i,"stratificationType"]][,"columnName"])
          
          
          
          values <- purrr::map(1:length(stratificationType),function(z){
            
            advanced_options <-
              MS_list[[y]][MS_list[[y]]$columnName %in% 
                             stratificationType[[z]],"stratificationItem"][[1]]$localId
            
            return(advanced_options)
          })
          
          
          adv_opt <- Map(c,stratificationType,values)
          
          adv_opt_call <-  purrr::map(adv_opt, function(w){
            
            paste0(w[1], "=", paste0(w[2:length(w)], collapse=","))
            
          })
          
          paste0("?", paste0(adv_opt_call, collapse="&") )
          
        } else{
          
          adv_opt_call_row <- ""
        }
        
        
      })
      
      return(unlist(adv_opt_call_row))
    })
    
    
    #adding each element of the advanced options list as a column in each SL table
    
    SL_list_complete<-purrr::map(1:length(SL_list), function(q){
      
      SL_list[[q]]$Geographic_ID <- rep(temp_list[[q]]$Geographic_ID[1],
                                        nrow(SL_list[[q]]))
      
      SL_list[[q]]$time <- rep(temp_vec_list[[q]],
                               nrow(SL_list[[q]]) )
      
      SL_list[[q]]$adv_opt_call <- adv_opt_call_list[[q]]
      
      return(SL_list[[q]])
      
    })
    
    SL_df_complete <- purrr::map_dfr(SL_list_complete, as.data.frame)
    
    
    if(any(!is.na(strat_level_ID)) | any(!is.na(strat_level))){
      
      SL_df_complete <- SL_df_complete[which(SL_df_complete$id%in%strat_level_ID |
                                               SL_df_complete$name%in%strat_level |
                                               SL_df_complete$abbreviation%in%strat_level),]
      
    }
    
    message("Retrieving data...")
    
    MD_list<-purrr::map(1:nrow(SL_df_complete), function(gch){
      
      MD<-
        httr::GET(paste0("https://ephtracking.cdc.gov:443/apigateway/api/v1/getCoreHolder/",
                         SL_df_complete[gch,]$Measure_ID,"/",
                         SL_df_complete[gch,]$id,"/",geo_filter,
                         "/",SL_df_complete[gch,]$Geographic_ID,"/",
                         SL_df_complete[gch,]$time,"/",smoothing,"/0",
                         SL_df_complete[gch,]$adv_opt_call))
      
      MD_cont<-jsonlite::fromJSON(rawToChar(MD$content))
      
      #removing empty list elements
      MD_cont <- purrr::compact(MD_cont )
      
      MD_cont <- purrr::compact(MD_cont )
      
      data_list_element<-names(unlist(purrr::map(MD_cont,nrow))[which(unlist(purrr::map(MD_cont,nrow))>1)])
      
      #selecting the table results element with actual relevant data.
      #name of element can differ depending on the measure
      ###not totally sure that the third element is always the datas
      MD_cont_tab<-MD_cont[[data_list_element]]
      
      
      
      #adding in stratification names only if lookuplist with the names exists
      if(length(MD_cont$lookupList)>0){
        MD_cont_lookup <- purrr::map(1:length(MD_cont$lookupList), function(v){
          
          df<-data.frame(groupById=v, 
                         stratification= 
                           paste(MD_cont$lookupList[[v]]$itemName,collapse=", "),
                         stringsAsFactors = F)
          
          return(df)
        })
        
        
        MD_cont_lookup_df<-purrr::map_dfr(MD_cont_lookup, 
                                          as.data.frame)
        
        MD_cont_tab$stratification <- 
          MD_cont_lookup_df$stratification[match( MD_cont_tab$groupById,
                                                  MD_cont_lookup_df$groupById)]
      }
      
      #filling in the rest of the output table
      names(MD_cont_tab)[which(names(MD_cont_tab)=="year")]<-"date"
      
      MD_cont_tab$Measure_ID<-SL_df_complete[gch,"Measure_ID"]
      MD_cont_tab$Measure_Name<-SL_df_complete[gch,"Measure_Name"]
      MD_cont_tab$Measure_shortName<-SL_df_complete[gch,"Measure_shortName"]
      MD_cont_tab$Strat_Level_ID<-SL_df_complete[gch,"id"]
      MD_cont_tab$Geo_Type_ID<-SL_df_complete[gch,"Geo_Type_ID"]
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
                                       "rollover" ))))
        
        
      }
      
      
    })
    
    message("Done")
    
    return(MD_list)
    
  }
