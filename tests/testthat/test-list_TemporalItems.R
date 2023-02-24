####Testing scenario 1. Simple annual county-level measure with only measure entry####
measure = 296
geo_type=NA
geo_typeID=NA
format="ID"
simplified_output=TRUE


test1 <- list_TemporalItems(measure)

str(test1)

View(test1[[1]])

######################################################################

####Testing scenario 2. Simple annual county-level measure with measure entry and geo_type####
measure = 296
geo_type="County"
geo_typeID=NA
format="ID"
simplified_output=TRUE


test2 <- list_TemporalItems(measure,
                            geo_type)

str(test2)

View(test2[[1]])

######################################################################

####Testing scenario 3. Simple annual county-level measure with measure entry and geo_typeID####
measure = 296
geo_type=NA
geo_typeID=2
  format="ID"
simplified_output=TRUE


test3 <- list_TemporalItems(measure,
                            geo_typeID=geo_typeID)

str(test3)

View(test3[[1]])

#measure = 1204

######################################################################


####Testing scenario 4. Measure with only one county selectable in data explorer####
measure=357 
geo_type=NA
geo_typeID=NA
format="ID"
simplified_output=TRUE


test4 <- list_TemporalItems(measure)

str(test4)

View(test4[[1]])



######################################################################


####Testing scenario 5. Includes tract and tribal and has multiple geographies####
measure=876 
geo_type=NA
geo_typeID=NA
format="ID"
simplified_output=TRUE


test5 <- list_TemporalItems(measure)

str(test5)

View(test5[[1]])
View(test5[[2]])
View(test5[[3]])


######################################################################


####Testing scenario 6. Includes a daily measure####
measure=1204
geo_type=NA
geo_typeID=NA
format="ID"
simplified_output=F


test6 <- list_TemporalItems(measure,simplified_output=F)

str(test6)

View(test6[[1]])


######################################################################
# measure=896 #includes 20k
# measure=876 #includes tract and tribal and has multiple geographies
# measure=357 #measure with only one county selectable
# 
# ephtracking.cdc.gov/apigateway/api/v1/temporalItems/1109/2/1/1
# 
# 
# ephtracking.cdc.gov/apigateway/api/v1/geographicItems/1109/2/1
# 
# list_GeographicItems(measure,geo_type = "County",rollup = 0)
