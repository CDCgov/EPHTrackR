#' @name Measure_Data
#' @title Pull data from API
#' @description  Pull data from CDC Tracking API for multiple measures, geographies, stratifications and years.
#' @import dplyr
#' @param measure specify the measures of interest
#' @param geo_type specify the geography type of the geo_items entry as a quoted string (e.g. "State", "County").
#' @param geo_type_ID specify the ID of the geography type of the geo_items entry as a numeric value (e.g. 1, 2).
#' @param geo_items specify Geographic items by name or abbreviation.
#' @param geo_items_ID specify Geographic items by ID.
#' @param temporal_period specify the temporal period(s) of interest with unquoted string.
#' @param strat_level specify stratification level by name or abbreviation.
#' @param strat_level_ID specify stratification level by ID.
#' @param format indicate whether the measure, indicator and/or content_area variables are ID, name or shortName
#' @param geo_filter default is 1. Filter to query based on parent geographic type. This is a crude fix for a problem with the API query and for now don't change.
#' @param smoothing default is 0. Request geographically smoothed data. If smoothed data is requested, but is not available the function will produce an error.
#' @return The specified data from the CDC Tracking API.
#' @examples \dontrun{
#' dat1_id<-
#'   Measure_Data(measure=370,content_area = 25,
#'                geo_type_ID = c(1,2),geo_items_ID = c(4,32,35),
#'                temporal = c(2015,2016),strat_level = c("State","ST_CT"),
#'                format = "ID")
#' dat2_shortName<-
#'   Measure_Data(measure="Number of summertime (May-Sep) heat-related deaths, by year",
#'                indicator="Historical Drought",geo_type_ID = c(1,2),
#'                geo_items_ID = c(4,32,35),temporal=2015:2016,
#'                strat_level_ID = 1:2,format="shortName")
#' dat3_name<-
#'   Measure_Data(measure="Number of summertime (May-Sep) heat-related deaths, by year",
#'                content_area = "Drought",geo_items_ID = c(4,32,35),format="name")
#' }
#' @export


### Get data for multiple states and years ###

Measure_Data<-
  function(measure=NA,
           geo_type=NA,geo_type_ID=NA,geo_items=NA,
           geo_items_ID=NA,temporal_period=NA,strat_level=NA,
           strat_level_ID=NA,
           format=c("name","shortName","ID"),
           smoothing=0, geo_filter=1){
    
    format<-match.arg(format)
    
    
    SL_list<-
      stratificationlevel(measure,
                          geo_type,geo_type_ID,format)
    
    MS_list<-measurestratification(measure,
                                   geo_type,geo_type_ID,format)
    temp_list<-temporal(measure,
                        geo_type,geo_type_ID,geo_items,
                        geo_items_ID,format, simplified_output = FALSE)
    
    
    
    temp_vec_list<-purrr::map(temp_list, function(x){
      
      if(any(!is.na(temporal_period))){
        
        df <- x[which(x$parentTemporal %in% temporal_period),]
        
      } else{
        
        df=x
      }
      
      temp_vec<- rev(
        sort(
          as.numeric(
            paste0(df$parentTemporal,
                   collapse = ",")
          )
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
    
    
    MD_list<-purrr::map(1:nrow(SL_df_complete), function(gch){
      
      MD<-
        httr::GET(paste0("https://ephtracking.cdc.gov:443/apigateway/api/v1/getCoreHolder/",
                         SL_df_complete[gch,]$Measure_ID,"/",
                         SL_df_complete[gch,]$id,"/",geo_filter,
                         "/",SL_df_complete[gch,]$Geographic_ID,"/",
                         SL_df_complete[gch,]$time,"/",smoothing,"/0",
                         SL_df_complete[gch,]$adv_opt_call))
      
      MD_cont<-jsonlite::fromJSON(rawToChar(MD$content))
      MD_cont<-MD_cont$tableResult
      MD_cont$Measure_ID<-SL_df_complete[gch,"Measure_ID"]
      MD_cont$Measure_Name<-SL_df_complete[gch,"Measure_Name"]
      MD_cont$Measure_shortName<-SL_df_complete[gch,"Measure_shortName"]
      MD_cont$Strat_Level_ID<-SL_df_complete[gch,"id"]
      MD_cont$Geo_Type_ID<-SL_df_complete[gch,"Geo_Type_ID"]
      MD_cont$Geo_Type<-SL_df_complete[gch,"Geo_Type"]
      MD_cont<-MD_cont[which(!is.na(MD_cont$id)),]
      return(MD_cont)
      
      
    })
    
  }

