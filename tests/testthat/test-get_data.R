# ####Testing scenario 1. Simple annual county-level measure with only measure entry####
# measure = 296
# 
# 
# test1 <- get_data(measure)
# 
# #str(test1)
# 
# #View(test1[[1]])
# 
# ######################################################################
# 
# 
# ####Testing scenario 2. Simple annual county-level measure with measure entry and geo_type and a parent geography####
# measure = 296
# geo_type="County"
# geoItems = "Alabama"
# 
# 
# test2 <- get_data(measure=measure, 
#                   geo_type=geo_type,
#                   geoItems = geoItems)
# 
# #str(test2)
# 
# #View(test2[[1]])
# 
# ####Testing scenario 3. Simple annual county-level measure with measure entry and geo_typeID used for geo_type entry and specifying a parent geography by state FIPS rather than name####
# measure = 296
# geo_type=2
# geoItems = 6
# 
# 
# test3 <- get_data(measure,
#                   geo_type=geo_type,
#                   geoItems = geoItems)
# 
# #str(test3)
# 
# #View(test3[[1]])
# 
# 
# ######################################################################
# 
# 
# 
# ####Testing scenario 4. Measure with only one county selectable in data explorer####
# measure=357 
# temporalItems = 2001
# geoItems = c(1001,1003)
# simplified_output=TRUE
# 
# 
# test4 <- get_data(measure,
#                   temporalItems=temporalItems,
#                   geoItems = geoItems,
#                   simplified_output=simplified_output)
# 
# #str(test4)
# 
# #View(test4[[1]])
# 
# 
# ####Testing scenario 5. Testing simple stratification with advanced options####
# measure=99 
# strat_level = "State x gender"
# 
# 
# test5 <- get_data(measure,
#                   strat_level = strat_level)
# 
# #str(test5)
# 
# #View(test5[[1]])
# 
# 
# 
# ####Testing scenario 6. Testing simple stratification with advanced options specified as abbreviation####
# measure=99 
# strat_level = "ST_AG_GN_klj"
# temporalItems = 2005
# geoItems = 4
# 
# 
# test6 <- tryCatch(expr = { test6 <- get_data(measure,
#                     strat_level = strat_level,
#                     temporalItems = temporalItems,
#                     geoItems = geoItems)},
#          error = function(cond){return("success")})
# 
# if(test6 != "success"){stop("Need error.")}
# 
# 
# #str(test6)
# 
# #View(test6[[1]])
# 
# 
# ####Testing scenario 7. Testing out request for subset of stratification types####
# measure=99 
# strat_level = "ST_AG_GN"
# temporalItems = 2005
# geoItems = 4
# stratItems = c("GenderId=1","AgeBandId=3")
# 
# 
# test7 <- get_data(measure,
#                   strat_level = strat_level,
#                   temporalItems = temporalItems,
#                   geoItems = geoItems,
#                   stratItems = stratItems)
# 
# #str(test7)
# 
# #View(test7[[1]])
# 
# 
# ####Testing scenario 8. Testing out daily measure that only displays a single county with vector of dates and geos. Also testing entering county as string. Also testing NA token submission.####
# measure=357
# temporalItems = c(2005,2006)
# geoItems = c(1,"Alameda, CA")
# 
# 
# 
# test8 <- get_data(measure,
#                   temporalItems = temporalItems,
#                   geoItems = geoItems,
#                   token=NA)
# 
# #str(test8)
# 
# #View(test8[[1]])
# 
# ####Testing scenario 9. Testing a retrieving a smoothed measure####
# measure=1151
# strat_level = "State x County"
# smoothing = 1
# geoItems = 42041
# simplified_output = FALSE
# 
# 
# 
# test9 <- get_data(measure,
#                   strat_level = strat_level,
#                   smoothing=smoothing,
#                   simplified_output = simplified_output,
#                   geoItems = geoItems)
# 
# #str(test9)
# 
# #View(test9[[1]])
# 
# 
# 
# 
# ####Testing scenario 10. Testing a daily temporal call####
# measure=1204
# temporalItems = 20230220
# geoItems = 42041
# strat_level="State x County x Datasource"
# 
# 
# 
# test10 <- get_data(measure,
#                    strat_level = strat_level,
#                    temporalItems = temporalItems,
#                    geoItems = geoItems)
# 
# #str(test10)
# 
# #View(test10[[1]])
# 
# ####Testing scenario 11. Testing a daily temporal call####
# measure=896
# temporalItems = 2019
# geoItems = c(9001156,9001183,"MI")
# strat_level="state x 20k"
# 
# 
# 
# test11 <- get_data(measure,
#                    strat_level = strat_level,
#                    temporalItems = temporalItems,
#                    geoItems = geoItems)
# 
# 
# #str(test11)
# 
# #View(test11[[1]])
# 
# 
