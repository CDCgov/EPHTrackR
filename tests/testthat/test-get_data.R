####Testing scenario 1. Simple annual county-level measure with only measure entry####
measure = 296
geo_type=NA
simplified_output=TRUE


test1 <- get_data(measure)

str(test1)

View(test1[[1]])

######################################################################


####Testing scenario 2. Simple annual county-level measure with measure entry and geo_type and a parent geography####
measure = 296
geo_type="County"
geoItems = "Alabama"
simplified_output=TRUE


test2 <- get_data(measure=measure, 
                  geo_type=geo_type,
                  geoItems = geoItems)

str(test2)

View(test2[[1]])

####Testing scenario 3. Simple annual county-level measure with measure entry and geo_typeID used for geo_type entry and specifying a parent geography by state fips rather than name####
measure = 296
geo_type=2
geoItems = 6
simplified_output=TRUE


test3 <- get_data(measure,
                  geo_type=geo_type,
                  geoItems = geoItems)

str(test3)

View(test3[[1]])


######################################################################



####Testing scenario 4. Measure with only one county selectable in data explorer####
measure=357 
geo_type=NA
temporalItems = 2001
geoItems = c(1001,1003)
simplified_output=TRUE


test4 <- get_data(measure,
                  temporalItems=temporalItems,
                  geoItems = geoItems)

str(test4)

View(test4[[1]])


####Testing scenario 5. Testing simple stratification with advanced options####
measure=99 
geo_type=NA
strat_level = "State x gender"
simplified_output=TRUE


test5 <- get_data(measure,
                  strat_level = strat_level)

str(test5)

View(test5[[1]])


####Testing scenario 5. Testing simple stratification with advanced options####
measure=99 
geo_type=NA
strat_level = "State x gender"
simplified_output=TRUE


test5 <- get_data(measure,
                  strat_level = strat_level)

str(test5)

View(test5[[1]])

####Testing scenario 6. Testing simple stratification with advanced options specified as abbreviation####
measure=99 
geo_type=NA
strat_level = "ST_AG_GN_klj"
temporalItems = 2005
geoItems = 4
simplified_output=TRUE


test6 <- get_data(measure,
                  strat_level = strat_level,
                  temporalItems = temporalItems,
                  geoItems = geoItems)

str(test6)

View(test6[[1]])


####Testing scenario 7. Testing out request for subset of stratification types####
measure=99 
geo_type=NA
strat_level = "ST_AG_GN"
temporalItems = 2005
geoItems = 4
stratItems = c("GenderId=1","AgeBandId=3")
simplified_output=TRUE


test7 <- get_data(measure,
                  strat_level = strat_level,
                  temporalItems = temporalItems,
                  geoItems = geoItems,
                  stratItems = stratItems)

str(test7)

View(test7[[1]])


####Testing scenario 8. Testing out daily measure that only displays a single county with vector of dates and geos. Also testing entering county as string. Also testing NA token submission.####
measure=357
geo_type=NA
temporalItems = c(2005,2006)
geoItems = c(1,"Alameda, CA")
simplified_output=TRUE



test8 <- get_data(measure,
                  temporalItems = temporalItems,
                  geoItems = geoItems,
                  token=NA)

str(test8)

View(test8[[1]])

###test out smoothing

##test out daily temporal calls

##test out sub-county calls


measure=99 #lots of advanced options
#measure = 1204
strat_level=NA
strat_levelID=NA
geo=NA
geo_ID=NA
temporal_period=NA
geo_type=NA
geo_typeID=NA


#Basic call

test <- get_data(measure=1204)
smoothing=0
geo_filter=1
format="ID"

simplified_output=T

measure=896 #includes 20k
measure=876 #includes tribal
measure=357 #measure with only one county selectable

ephtracking.cdc.gov/apigateway/api/v1/temporalItems/1109/2/1/1


ephtracking.cdc.gov/apigateway/api/v1/geographicItems/1109/2/1

list_GeographicItems(measure,geo_type = "County",rollup = 0)

#need to test out situations with multiple advanced options gender & age (measure 99) and situations where a wrong stratefication category (age) or an invalid strat category id (1) is submitted
