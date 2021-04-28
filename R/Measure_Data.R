#' @name Measure_Data
#' @title Pull data from API
#' @description  Pull data from CDC Tracking API for multiple measures, geographies, stratifications and years.
#' @import dplyr
#' @param measure specify the measures of interest
#' @param indicator specify the indicators of interest
#' @param content_area specify the content areas of interest
#' @param geo_type specify the geography type of the geo_items entry as a quoted string (e.g. "State", "County").
#' @param geo_type_ID specify the ID of the geography type of the geo_items entry as a numeric value (e.g. 1, 2).
#' @param geo_items specify Geographic items by name or abbreviation.
#' @param geo_items_ID specify Geographic items by ID.
#' @param temporal specify the temporal period(s) of interest with unquoted string.
#' @param strat_level specify stratification level by name or abbreviation.
#' @param strat_level_ID specify stratification level by ID.
#' @param format indicate whether the measure, indicator and/or content_area variables are ID, name or shortName
#' \item{geo_filter}{default is 1. Filter to query based on parent geographic type. This is a crude fix for a problem with the API query and for now don't change.}
#' @param smoothing default is 0. Specify whether data is geographically smoothed(1) or not (0).
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
  function(measure=NA,indicator=NA,content_area=NA,
           geo_type=NA,geo_type_ID=NA,geo_items=NA,
           geo_items_ID=NA,temporal=NA,strat_level=NA,
           strat_level_ID=NA,
           format=c("name","shortName","ID"),
           smoothing=0, geo_filter=1){
  format<-match.arg(format)

  temp_table<-temporal(measure,indicator,content_area,
                       geo_type,geo_type_ID,geo_items,
                       geo_items_ID,format)

  if(!any(is.na(temporal))){
    temp_list<-list()
    for(tp in 1:nrow(temp_table)){
      temp_list[[tp]]<-
        temp_table$Temporal[tp,][which(temp_table$Temporal[tp,]%in%temporal)]
    }
  }else{
    for (tp in 1:nrow(temp_table)){
      temp_list[[tp]]<-temp_table$Temporal[tp,]
    }
    
  }

  for(tpf in 1:nrow(temp_table)){
    temp_table$temp_formatted[tpf]<-
      paste0(temp_list[[tpf]],collapse = ",")
  }

  SL_table<-
    stratificationlevel(measure,indicator,content_area,
                        geo_type,geo_type_ID,format)

  if(!any(is.na(strat_level_ID)) | !any(is.na(strat_level))){
    SL_table<-
      SL_table[which(SL_table$id%in%strat_level_ID |
                       SL_table$name%in%strat_level |
                       SL_table$abbreviation%in%strat_level),]
  }

  suppressMessages(temp_SL_table<-
                     dplyr::full_join(temp_table,SL_table))

  MD_list<-list()

  for(gch in 1:nrow(temp_SL_table)){
    MD<-
      httr::GET(paste0("https://ephtracking.cdc.gov:443/apigateway/api/v1/getCoreHolder/",
                       temp_SL_table$Measure_ID[gch],"/",
                       temp_SL_table$id[gch],"/",geo_filter,
                       "/",temp_SL_table$Geographic_ID[gch],"/",
                       temp_SL_table$temp_formatted[gch],"/",smoothing,"/0"))

    MD_cont<-jsonlite::fromJSON(rawToChar(MD$content))
    MD_list[[gch]]<-MD_cont$tableResult
    MD_list[[gch]]$Measure_ID<-temp_SL_table$Measure_ID[gch]
    MD_list[[gch]]$Measure_Name<-temp_SL_table$Measure_Name[gch]
    MD_list[[gch]]$Measure_shortName<-temp_SL_table$Measure_shortName[gch]
    MD_list[[gch]]$Strat_Level_ID<-temp_SL_table$id[gch]
    MD_list[[gch]]$Geo_Type_ID<-temp_SL_table$Geo_Type_ID[gch]
    MD_list[[gch]]$Geo_Type<-temp_SL_table$Geo_Type[gch]
  }
  MD_df<-purrr::map_dfr(MD_list,as.data.frame)
  MD_df[-which(is.na(MD_df$id)),]
}
