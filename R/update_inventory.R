#' @name update_inventory
#' @title Update inventory of content areas, indicators, and measures
#' @description  
#' `r lifecycle::badge("deprecated")`
#' 
#' This function was deprecated because automatic inventory updates were incorporated directly within the list_measures() function in version 1.0.0.
#' @keywords internal
#' @examples \dontrun{
#' 
#' 
#' update_inventory()
#' 
#' 
#' }
#' @export


update_inventory<-function(){
  
  lifecycle::deprecate_stop(when = "1.0.0",
                            what = "update_inventory()",
                            details ="This function was deprecated because automatic inventory updates were incorporated directly within the list_measures() function." )
  
  
  
  message("Downloading inventory...")
  
  CAs_raw <-
    httr::GET("https://ephtracking.cdc.gov/apigateway/api/v1/contentareas/json")
  CAs<-jsonlite::fromJSON(rawToChar(CAs_raw$content))
  CA_id<-CAs$id
  
  
  ### Indicators ###
  
  inds_list<-list()
  for(ind in 1:length(CA_id)){
    inds <- httr::GET(paste0("https://ephtracking.cdc.gov/apigateway/api/v1/indicators/",CA_id[ind]))
    inds_list[[ind]] <- jsonlite::fromJSON(rawToChar(inds$content))
    inds_list[[ind]]$Content_Area <- CA_id[ind]
  }
  
  Inds<-purrr::map_dfr(inds_list,as.data.frame)
  ind_id<-Inds$id
  
  
  ### Measures ###
  
  meas_list<-list()
  for(mezr in 1:length(ind_id)){
    meas<-
      httr::GET(paste0("https://ephtracking.cdc.gov/apigateway/api/v1/measures/",
                       ind_id[mezr]))
    meas_list[[mezr]]<-jsonlite::fromJSON(rawToChar(meas$content))
    meas_list[[mezr]]$Indicator<-ind_id[mezr]
  }
  
  Meas<-purrr::map_dfr(meas_list,as.data.frame)
  
  
  
  ### Combine data for Content Areas, Indicators and Measures ###
  
  names(CAs)<-c("content_area_ID","content_area_name","content_area_shortName")
  names(Inds)<-
    c("indicator_ID","indicator_name","indicator_shortName",
      "externalURL","externalURLText","content_area_ID")
  suppressMessages(Inds_CAs<-dplyr::left_join(Inds,CAs))
  
  names(Meas)<-c("measure_ID","measure_name",
                 "measure_shortName","URL","URLText","indicator_ID")
  
  suppressMessages(Meas_Inds_CAs<-dplyr::left_join(Meas,Inds_CAs))
  Meas_Inds_CAs_unique<-unique(Meas_Inds_CAs)
  Meas_Inds_CAs_unique$measure_ID<-as.numeric(Meas_Inds_CAs_unique$measure_ID)
  Meas_Inds_CAs_unique$indicator_ID<-as.numeric(Meas_Inds_CAs_unique$indicator_ID)
  Meas_Inds_CAs_unique$content_area_ID<-as.numeric(Meas_Inds_CAs_unique$content_area_ID)
  Meas_Inds_CAs_clean<-
    Meas_Inds_CAs_unique[,c("measure_ID","measure_name","measure_shortName",
                            "indicator_ID","indicator_name","indicator_shortName",
                            "content_area_ID","content_area_name","content_area_shortName")]
  
  measures_indicators_CAs<-
    Meas_Inds_CAs_clean[order(Meas_Inds_CAs_clean$measure_ID,
                              Meas_Inds_CAs_clean$indicator_ID,
                              Meas_Inds_CAs_clean$content_area_ID),]
  
  assign("measures_indicators_CAs", 
         measures_indicators_CAs, 
         envir = .GlobalEnv)
  
  save(measures_indicators_CAs,
       file=paste(file.path(system.file(package="EPHTrackR"), 
                            "data/measures_indicators_CAs.RData")))
  
  message("Done")

}
