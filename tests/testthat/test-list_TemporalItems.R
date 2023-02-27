# ####Testing scenario 1. Simple annual county-level measure with only measure entry####
# measure = 296
# 
# 
# test1 <- list_TemporalItems(measure)
# 
# #str(test1)
# 
# #View(test1[[1]])
# 
# ######################################################################
# 
# ####Testing scenario 2. Simple annual county-level measure with measure entry and geo_type####
# measure = 296
# geo_type="County"
# 
# 
# test2 <- list_TemporalItems(measure,
#                             geo_type)
# 
# #str(test2)
# 
# #View(test2[[1]])
# 
# ######################################################################
# 
# ####Testing scenario 3. Simple annual county-level measure with measure entry and geo_typeID####
# measure = 296
# geo_type=2
# 
# 
# test3 <- list_TemporalItems(measure,
#                             geo_type=geo_type)
# 
# #str(test3)
# 
# #View(test3[[1]])
# 
# #measure = 1204
# 
# ######################################################################
# 
# 
# ####Testing scenario 4. Measure with only one county selectable in data explorer####
# measure=357 
# 
# 
# test4 <- list_TemporalItems(measure)
# 
# #str(test4)
# 
# #View(test4[[1]])
# 
# 
# 
# ######################################################################
# 
# 
# ####Testing scenario 5. Includes tract and tribal and has multiple geographies####
# measure=876 
# 
# 
# test5 <- list_TemporalItems(measure)
# 
# #str(test5)
# 
# #View(test5[[1]])
# #View(test5[[2]])
# #View(test5[[3]])
# 
# 
# ######################################################################
# 
# 
# ####Testing scenario 6. Includes a daily measure####
# measure=1204
# simplified_output=F
# 
# 
# test6 <- list_TemporalItems(measure,
#                             simplified_output=simplified_output)
# 
# #str(test6)
# 
# #View(test6[[1]])
# 
# 
