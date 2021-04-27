#' @name temporal
#' @title Find temporal periods available.
#' @description  Find temporal periods on CDC Tracking API for multiple measures and geographies.
#' @import dplyr
#' @param measure specify the measures of interest
#' @param indicator specify the indicators of interest
#' @param content_area specify the content areas of interest
#' @param geo_type specify the Geographic type.
#' @param geo_type_ID specify the Geographic type ID.
#' @param geo_items specify Geographic items by name or abbreviation.
#' @param geo_items_ID specify Geographic items by ID.
#' @param format indicate whether the measure, indicator and/or content_area variables are ID, name or shortName
#' @param geo_filter default is 1. Filter to only retrieve filtered geographic type. Most of the time should equal 1.
#' @return The years for specified measures and geographies on the CDC Tracking API.
#' @examples \dontrun{
#' temp2_shortName<-temporal(content_area = "DR",
#'                           geo_items_ID = c(4,32,35),
#'                           format="shortName")
#' }
#' @export


temporal<-function(measure=NA,indicator=NA,content_area=NA,
                   geo_type=NA,geo_type_ID=NA,geo_items=NA,
                   geo_items_ID=NA,format=c("name","shortName","ID"),
                   geo_filter=1){
  format<-match.arg(format)

  geo_table<-geography(measure,indicator,content_area,
                       geo_type,geo_type_ID,format)

  if(!any(is.na(geo_items_ID)) | !any(is.na(geo_items))){
    geo_table<-
      geo_table[which(geo_table$parentGeographicId%in%geo_items_ID |
                        geo_table$parentName%in%geo_items |
                        geo_table$parentAbbreviation%in%geo_items),]
  }

  geo_table2<-
    unique(geo_table[,c("parentGeographicId","parentName",
                        "Measure_ID","Geo_Type_ID","Measure_Name","Geo_Type")])

  #geo_id_table<-aggregate(id~Measure_ID+Geo_Type_ID,geo_table2,paste0,collapse=",")
  geo_parentid_table<-
    aggregate(parentGeographicId~Measure_ID+Geo_Type_ID,
              geo_table2,paste0,collapse=",")
  
  geo_ordered_table<-
    aggregate(parentName~Measure_Name+Geo_Type+Measure_ID+
                Geo_Type_ID,geo_table2,paste0,collapse=",")


  temp_list<-list()

  for(tp in 1:nrow(geo_parentid_table)){
    temp<-
      httr::GET(paste0("https://ephtracking.cdc.gov:443/apigateway/api/v1/temporal/",
                       geo_parentid_table$Measure_ID[tp],"/",
                       geo_parentid_table$Geo_Type_ID[tp],"/",
                       geo_filter,"/",geo_parentid_table$parentGeographicId[tp]))
    temp_list[[tp]]<-jsonlite::fromJSON(rawToChar(temp$content))
    temp_list[[tp]]$Measure<-geo_ordered_table$Measure[tp]
    temp_list[[tp]]$Measure_ID<-geo_parentid_table$Measure_ID[tp]
    temp_list[[tp]]$Geo_Type<-geo_ordered_table$Geo_Type[tp]
    temp_list[[tp]]$Geo_Type_ID<-geo_parentid_table$Geo_Type_ID[tp]
    temp_list[[tp]]$Geographic_ID<-geo_parentid_table$parentGeographicId[tp]
  }
  output<-purrr::map_dfr(temp_list,as.data.frame)
  names(output)[which(names(output)%in%c("parentTemporal","parentTemporalDisplay"))]<-
    c("Temporal","TemporalDisplay")
  output_agg1<-aggregate(Temporal~Measure_ID+Geo_Type_ID+Geographic_ID,output,c)
  output_agg2<-aggregate(TemporalDisplay~Measure_ID+Geo_Type_ID+Geographic_ID,output,c)
  suppressMessages(dplyr::full_join(output_agg1,output_agg2))
}


