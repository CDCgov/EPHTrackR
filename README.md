
<!-- README.md is generated from README.Rmd. Please edit the README.Rmd file -->
<!-- badges: start -->

[![Project Status: Active - The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R build
status](https://github.com/CDCgov/EPHTrackR/workflows/R-CMD-check/badge.svg)](https://github.com/CDCgov/EPHTrackR/actions?workflow=R-CMD-check)
[![CRAN
status](https://www.r-pkg.org/badges/version/sword)](https://CRAN.R-project.org/package=sword)
[![Lifecycle:
stable](https://lifecycle.r-lib.org/articles/figures/lifecycle-stable.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
<!-- badges: end -->

<!-- [![Travis-CI Build Status](https://travis-ci.org/cont-limno/LAGOSNE.svg?branch=master)](https://travis-ci.org/cont-limno/LAGOSNE) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/LAGOSNE)](https://cran.r-project.org/package=LAGOSNE) [![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/LAGOSNE)](https://cran.r-project.org/package=LAGOSNE)
[![Codecov test coverage](https://codecov.io/gh/tidyverse/dplyr/branch/master/graph/badge.svg)](https://codecov.io/gh/tidyverse/dplyr?branch=master)-->

# EPHTrackR <img src="man/figures/CDC_Tracking_Combined.jpg" align="right" height=140/>

The `EPHTrackR` package provides an R interface to access and download
publicly available data stored on the [CDC National Environmental Public
Health Tracking Network](https://ephtracking.cdc.gov/) (Tracking
Network) via a connection with the [Tracking Network Data
API](https://ephtracking.cdc.gov/apihelp). A detailed user guide
describing available API calls and associated outputs can be found at
that link. Associated metadata for downloaded measure data can be found
on the Tracking Network [Indicators and
Data](https://ephtracking.cdc.gov/metadataSearch) page. Users might find
it easier to view the online [Data
Explorer](https://ephtracking.cdc.gov/DataExplorer/) to get a sense of
the available datasets before or while using this package.

The purpose of the Tracking Network is to deliver information and data
to protect the nation from health issues arising from or directly
related to environmental factors. At the local, state, and national
levels, the Tracking Network relies on a variety of people and
information systems to deliver a core set of health, exposure, and
hazards data; information summaries; and tools to enable analysis,
visualization, and reporting of insights drawn from data.

**Measures** are the core data product of the Tracking Network. Measures
are organized into **indicators**, groups of highly related measures,
and **content areas**, the highest level of categorization containing
all the indicators related to a broad topic of interest. Using Tracking
Network data, users can create customized maps, tables, and graphs of
local, state, and national data. The Tracking Network contains data
covering several focal areas: <br> — Health effects of exposures, such
as asthma <br> — Hazards in the environment, such as air pollution <br>
— Climate, such as extreme heat events <br> — Community design, such as
access to parks <br> — Lifestyle risk factors, such as smoking <br> —
Population characteristics, such as age and income <br>

## Installation

``` r
#install development version from Github
#install devtools first if you haven't previously - install.packages("devtools")
devtools::install_github("CDCgov/EPHTrackR", 
                         dependencies = TRUE)
```

## Load package

``` r
library(EPHTrackR)
#> Welcome to the CDC Environmental Public Health Tracking Network! This package provides an R interface to the Tracking Network Data API. To easily visualize our data products, please visit https://ephtracking.cdc.gov/DataExplorer/.
```

## Saving a Tracking API token

The `tracking_api_token()` function adds a Tracking API token to your
.Renviron file so it can be called securely without being stored in your
code. After you have run this function, the token will be called
automatically by all the other functions in this package. Leaving the
default argument `install=T`, ensures that the token will be saved in
future R sessions. A token can be acquired by emailing,
trackingsupport(AT)cdc.gov. A token is not required to use this package,
but you will experience less throttling and better API support if you
have one. Further information is available at
<https://ephtracking.cdc.gov/apihelp>.

``` r
tracking_api_token("XXXXXXXXXXXXXXXXX", 
                   install=T)

#After you run this function, reload your environment so you can use the token without restarting R.
readRenviron("~/.Renviron")


#Token can be viewed by running:
Sys.getenv("TRACKING_API_TOKEN")
```

## Full measure inventory

Running the `list_measures()` function without any additional inputs
retrieves the latest inventory of content areas, indicators, and
measures from the Tracking Network Data API.

``` r
measures_inventory <- list_measures()

View(measures_inventory)
```

## Viewing content area, indicator, and measure names

Each content area, indicator, and measure has a full name and a unique
identifier. You can use this information to determine what data are
available on the Tracking Network and make appropriate calls to download
the data (see below).

#### List content areas available

``` r
ca_df <- list_content_areas()

head(ca_df)
#>   contentAreaId                              contentAreaName
#> 1             1                               Drinking Water
#> 2             2 Unintentional Carbon Monoxide (CO) Poisoning
#> 3             3                                       Asthma
#> 4             4                       Heart Disease & Stroke
#> 5             5                                Birth Defects
#> 6             6                     Childhood Lead Poisoning
```

#### List indicators in specified content area(s)

``` r
ind_df <- list_indicators(content_area = "Heat & Heat-related Illness (HRI)")

head(ind_df)
#>   contentAreaId                   contentAreaName indicatorId
#> 1            35 Heat & Heat-related Illness (HRI)          67
#> 2            35 Heat & Heat-related Illness (HRI)          88
#> 3            35 Heat & Heat-related Illness (HRI)          89
#> 4            35 Heat & Heat-related Illness (HRI)          97
#> 5            35 Heat & Heat-related Illness (HRI)         172
#> 6            35 Heat & Heat-related Illness (HRI)         173
#>                         indicatorName
#> 1                  Mortality from HRI
#> 2            Hospitalizations for HRI
#> 3 Emergency Department Visits for HRI
#> 4        Projected Temperature & Heat
#> 5  Vulnerability & Preparedness: Heat
#> 6 Historical Temperature & Heat Index
```

#### List measures in specified indicator(s) and/or content area(s)

``` r
meas_df <- list_measures(content_area = 36)

head(meas_df)
#>   contentAreaId          contentAreaName indicatorId
#> 1            36 Precipitation & Flooding         106
#> 2            36 Precipitation & Flooding         106
#> 3            36 Precipitation & Flooding         106
#> 4            36 Precipitation & Flooding         106
#> 5            36 Precipitation & Flooding         106
#> 6            36 Precipitation & Flooding         106
#>                                            indicatorName measureId
#> 1 Vulnerability & Preparedness: Precipitation & Flooding       581
#> 2 Vulnerability & Preparedness: Precipitation & Flooding       582
#> 3 Vulnerability & Preparedness: Precipitation & Flooding       583
#> 4 Vulnerability & Preparedness: Precipitation & Flooding       584
#> 5 Vulnerability & Preparedness: Precipitation & Flooding      1133
#> 6 Vulnerability & Preparedness: Precipitation & Flooding      1134
#>                                                            measureName
#> 1      Number of Square Miles within FEMA Designated Flood Hazard Area
#> 2 Percent Area (Square Miles) within FEMA Designated Flood Hazard Area
#> 3            Number of People within FEMA Designated Flood Hazard Area
#> 4     Number of Housing Units within FEMA Designated Flood Hazard Area
#> 5       Number of Square Miles within EPA Designated Flood Hazard Area
#> 6  Percent Area (Square Miles) within EPA Designated Flood Hazard Area
#>   indicatorStatusId contentAreaStatusId
#> 1                 3                   3
#> 2                 3                   3
#> 3                 3                   3
#> 4                 3                   3
#> 5                 3                   3
#> 6                 3                   3
#>                                                                                  keywords
#> 1                         flood, hazard, area, flash, weather, wet, zone, climate, change
#> 2                         flood, hazard, area, flash, weather, wet, zone, climate, change
#> 3     flood, hazard, area, flash, weather, wet, zone, climate, change, population, people
#> 4 flood, hazard, area, flash, weather, wet, zone, climate, change, housing, houses, units
#> 5                                                           flood, flood hazard, flooding
#> 6                                                           flood, flood hazard, flooding
```

## Viewing available geographic and temporal types and items for specified measures

Measures on the Tracking Network vary in their geographic resolution
(e.g., state, county), geographic extent (e.g., Massachusetts, Michigan,
Pennsylvania, California, Georgia), temporal resolution (e.g., year,
month) and temporal extent (e.g., 2000-2010, 2010-2020). By becoming
familiar with the geographies and temporal periods for which data are
available using this function, you can make more targeted data
downloads.

#### List geographic types available for specified measures

Measures are typically available at the state, county, or census tract
level.

``` r
geog_type_df <- list_GeographicTypes(measure= "Number of Square Miles within FEMA Designated Flood Hazard Area")

head(geog_type_df[[1]])
#>   geographicType geographicTypeId measureId
#> 1         County                2       581
#>                                                       measureName
#> 1 Number of Square Miles within FEMA Designated Flood Hazard Area
#>           smoothingLevel
#> 1 No Smoothing Available
```

#### List geographic items available for specified measures

This function identifies the particular geographic items (e.g., Alabama)
that are available for a specified measure. It will reveal both the
lowest level geographic items available (e.g., a county or census tract)
and an overarching items, like states (i.e., parent geographic item)
that contains the lowest level geographic items you would like returned
in the data.

``` r
geog_item_df <- list_GeographicItems(measure= "Annual Number of Extreme Heat Days from May to September",
                                     geo_type="County")

head(geog_item_df[[1]])
#>   parentGeographicId parentName childGeographicId childName measureId
#> 1                  1    Alabama              1001   Autauga       423
#> 2                  1    Alabama              1003   Baldwin       423
#> 3                  1    Alabama              1005   Barbour       423
#> 4                  1    Alabama              1007      Bibb       423
#> 5                  1    Alabama              1009    Blount       423
#> 6                  1    Alabama              1011   Bullock       423
#>                                                measureName geo_type geo_typeID
#> 1 Annual Number of Extreme Heat Days from May to September   County          2
#> 2 Annual Number of Extreme Heat Days from May to September   County          2
#> 3 Annual Number of Extreme Heat Days from May to September   County          2
#> 4 Annual Number of Extreme Heat Days from May to September   County          2
#> 5 Annual Number of Extreme Heat Days from May to September   County          2
#> 6 Annual Number of Extreme Heat Days from May to September   County          2
```

#### List temporal items available for specified measures

Measures are typically available at an annual scale, but also can be
daily, monthly, or weekly. This function identifies the particular
years, months, days etc. that are available for the specified measure
(e.g., 2001, Aug 2020, etc.)

``` r
temp_df <- list_TemporalItems(measure= "Annual Number of Extreme Heat Days from May to September")

head(temp_df[[1]])
#>     id parentTemporalId parentTemporal parentMinimumTemporalId
#> 1 1979               NA             NA                      NA
#> 2 1980               NA             NA                      NA
#> 3 1981               NA             NA                      NA
#> 4 1982               NA             NA                      NA
#> 5 1983               NA             NA                      NA
#> 6 1984               NA             NA                      NA
#>   parentTemporalTypeId parentTemporalType temporalId minimumTemporalId
#> 1                   NA                 NA       1979                NA
#> 2                   NA                 NA       1980                NA
#> 3                   NA                 NA       1981                NA
#> 4                   NA                 NA       1982                NA
#> 5                   NA                 NA       1983                NA
#> 6                   NA                 NA       1984                NA
#>   minimumTemporal temporal temporalTypeId temporalType temporalTextOverride
#> 1              NA     1979              1         Year                   NA
#> 2              NA     1980              1         Year                   NA
#> 3              NA     1981              1         Year                   NA
#> 4              NA     1982              1         Year                   NA
#> 5              NA     1983              1         Year                   NA
#> 6              NA     1984              1         Year                   NA
#>   parentTemporalDisplay
#> 1                      
#> 2                      
#> 3                      
#> 4                      
#> 5                      
#> 6                      
#>                                                measureName measureId geo_type
#> 1 Annual Number of Extreme Heat Days from May to September       423   County
#> 2 Annual Number of Extreme Heat Days from May to September       423   County
#> 3 Annual Number of Extreme Heat Days from May to September       423   County
#> 4 Annual Number of Extreme Heat Days from May to September       423   County
#> 5 Annual Number of Extreme Heat Days from May to September       423   County
#> 6 Annual Number of Extreme Heat Days from May to September       423   County
#>   geo_typeID
#> 1          2
#> 2          2
#> 3          2
#> 4          2
#> 5          2
#> 6          2
```

## Viewing available Advanced Options for data stratification

In addition to geographic and temporal specifications, some measures on
the Tracking Network have a set of **Advanced Options** that allow users
to access data stratified by other variables. For instance, data on
asthma hospitalizations can be broken down by age and/or gender.

#### List available stratification levels for a measure

**Advanced Options** might only be available at a particular geographic
scale (e.g., age-breakdown of asthma hospitalizations is only available
at the state level). Therefore, results showing available stratification
levels always include the geography type. The output of this function is
a list with a separate element for each geography type available (e.g.,
state, county) for the specified measure. Each row in the data frame
elements of the list shows a stratification available for the measure.

``` r
strat_df <- list_StratificationLevels(measure=99)

head(strat_df[[1]])
#>   stratificationLevelId stratificationLevelName stratificationLevelAbbreviation
#> 1                     1                   State                              ST
#> 2                     3             State x Age                           ST_AG
#> 3                     4          State x Gender                           ST_GN
#> 4                    37    State x Age x Gender                        ST_AG_GN
#> 5                     2          State x County                           ST_CT
#>   geographicTypeId                                   stratificationType
#> 1                1                                                 NULL
#> 2                1                          3, Age Group, AG, AgeBandId
#> 3                1                              4, Gender, GN, GenderId
#> 4                1 3, 4, Age Group, Gender, AG, GN, AgeBandId, GenderId
#> 5                2                                                 NULL
#>   measureId                                  measureName Geo_Type geo_typeID
#> 1        99 Annual Number of Hospitalizations for Asthma    State          1
#> 2        99 Annual Number of Hospitalizations for Asthma    State          1
#> 3        99 Annual Number of Hospitalizations for Asthma    State          1
#> 4        99 Annual Number of Hospitalizations for Asthma    State          1
#> 5        99 Annual Number of Hospitalizations for Asthma   County          2
```

#### List available stratification types for a measure

If you’d like to query Tracking data by a specific stratification level
(e.g., you’d like data for just males), then you need to run the
`list_StratificationTypes()` function to identify the internal name for
the stratification and the appropriate code for the stratification level
of interest (e.g., 1 for male, 2 for female). The internal name can be
found in the in the ColumnName column of the function output and codes
can be found in the nested list found in the stratificationItem column
of the function output. Refer back to these when constructing queries
with with the `get_data()` function.

``` r
strat_df <- list_StratificationTypes(measure=99,
                                     geo_type="State")

strat_df[[1]]
#>   displayName isDisplayed isRequired isGrouped displayAllValues selectOneItem
#> 1   Age Group        TRUE      FALSE     FALSE            FALSE         FALSE
#> 2      Gender        TRUE      FALSE     FALSE            FALSE         FALSE
#>                                                                                                                                                            stratificationItem
#> 1 0 TO 4, 5 TO 14, 15 TO 34, 35 TO 64, >= 65, 0 TO 4, 5 TO 14, 15 TO 34, 35 TO 64, >= 65, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 1, 2, 3, 4, 5
#> 2                                                                                                                Male, Female, Male, Female, FALSE, FALSE, FALSE, FALSE, 1, 2
#>   columnName stratificationTypeId measureId
#> 1  AgeBandId                    3        99
#> 2   GenderId                    4        99
#>                                    measureName Geo_Type geo_typeID
#> 1 Annual Number of Hospitalizations for Asthma    State          1
#> 2 Annual Number of Hospitalizations for Asthma    State          1

#viewing the nested list in the stratificationItem column of the function output to identify stratification level codes
strat_df[[1]]$stratificationItem
#> [[1]]
#>       name longName isDefault useLongName localId
#> 1   0 TO 4   0 TO 4     FALSE       FALSE       1
#> 2  5 TO 14  5 TO 14     FALSE       FALSE       2
#> 3 15 TO 34 15 TO 34     FALSE       FALSE       3
#> 4 35 TO 64 35 TO 64     FALSE       FALSE       4
#> 5    >= 65    >= 65     FALSE       FALSE       5
#> 
#> [[2]]
#>     name longName isDefault useLongName localId
#> 1   Male     Male     FALSE       FALSE       1
#> 2 Female   Female     FALSE       FALSE       2
```

## Accessing Tracking Network data

You can use the information from the functions listed above to request
specific data from the Tracking Network Data API. Be careful when making
queries. If you request data that include many years and/or data at a
fine geographic scale, the dataset could be very large and take a long
time to download (if it doesn’t crash your session and bog down the
entire API).

We recommend that you include only one measure and one stratification
level in a data query. Many geographies and temporal periods may be
submitted. The function will likely still work if vectors of multiple
measures or stratification levels are submitted, but the resulting
object will be a multi-element list and distinguishing the element that
applies to a particular measure or stratification might be difficult.
The output of function calls with a single measure and stratification
level is a list with one element containing the relevant data frame.

#### Downloading state-level measure data

``` r
data_st<-get_data(measure=99,
                  strat_level = "ST")
#> Building API call for measure: 99 with stratification: State.
#> Retrieving data...
#> Done

head(data_st[[1]])
#>       geo geoId   geoAbbreviation parentGeographicTypeId parentGeo parentGeoId
#> 1 Arizona    04 StateAbbreviation                     NA        NA          NA
#> 2 Arizona    04 StateAbbreviation                     NA        NA          NA
#> 3 Arizona    04 StateAbbreviation                     NA        NA          NA
#> 4 Arizona    04 StateAbbreviation                     NA        NA          NA
#> 5 Arizona    04 StateAbbreviation                     NA        NA          NA
#> 6 Arizona    04 StateAbbreviation                     NA        NA          NA
#>   parentGeoAbbreviation temporalTypeId temporal temporalDescription
#> 1                    NA              1     2005         Single Year
#> 2                    NA              1     2006         Single Year
#> 3                    NA              1     2007         Single Year
#> 4                    NA              1     2008         Single Year
#> 5                    NA              1     2009         Single Year
#> 6                    NA              1     2010         Single Year
#>   temporalColumnName temporalRollingColumnName temporalId minimumTemporal
#> 1         ReportYear          RollingYearCount       2005              NA
#> 2         ReportYear          RollingYearCount       2006              NA
#> 3         ReportYear          RollingYearCount       2007              NA
#> 4         ReportYear          RollingYearCount       2008              NA
#> 5         ReportYear          RollingYearCount       2009              NA
#> 6         ReportYear          RollingYearCount       2010              NA
#>   minimumTemporalId parentTemporalTypeId parentTemporalType parentTemporal
#> 1                NA                   NA                 NA             NA
#> 2                NA                   NA                 NA             NA
#> 3                NA                   NA                 NA             NA
#> 4                NA                   NA                 NA             NA
#> 5                NA                   NA                 NA             NA
#> 6                NA                   NA                 NA             NA
#>   parentTemporalId date dataValue suppressionFlag confidenceIntervalLow
#> 1               NA 2005      7115               0                    NA
#> 2               NA 2006      6712               0                    NA
#> 3               NA 2007      6735               0                    NA
#> 4               NA 2008      7511               0                    NA
#> 5               NA 2009      8265               0                    NA
#> 6               NA 2010      8050               0                    NA
#>   confidenceIntervalHigh confidenceIntervalName standardError standardErrorName
#> 1                     NA                     NA            NA                NA
#> 2                     NA                     NA            NA                NA
#> 3                     NA                     NA            NA                NA
#> 4                     NA                     NA            NA                NA
#> 5                     NA                     NA            NA                NA
#> 6                     NA                     NA            NA                NA
#>   secondaryValue secondaryValueName descriptiveValue descriptiveValueName
#> 1             NA                 NA               NA                   NA
#> 2             NA                 NA               NA                   NA
#> 3             NA                 NA               NA                   NA
#> 4             NA                 NA               NA                   NA
#> 5             NA                 NA               NA                   NA
#> 6             NA                 NA               NA                   NA
#>   includeDescriptiveValueName category categoryName   title
#> 1                          NA       NA           NA Arizona
#> 2                          NA       NA           NA Arizona
#> 3                          NA       NA           NA Arizona
#> 4                          NA       NA           NA Arizona
#> 5                          NA       NA           NA Arizona
#> 6                          NA       NA           NA Arizona
#>   confidenceIntervalLowName parentMinimumTemporal parentMinimumTemporalId
#> 1                                              NA                      NA
#> 2                                              NA                      NA
#> 3                                              NA                      NA
#> 4                                              NA                      NA
#> 5                                              NA                      NA
#> 6                                              NA                      NA
#>   measureId                                  measureName geo_typeID Geo_Type
#> 1        99 Annual Number of Hospitalizations for Asthma          1    State
#> 2        99 Annual Number of Hospitalizations for Asthma          1    State
#> 3        99 Annual Number of Hospitalizations for Asthma          1    State
#> 4        99 Annual Number of Hospitalizations for Asthma          1    State
#> 5        99 Annual Number of Hospitalizations for Asthma          1    State
#> 6        99 Annual Number of Hospitalizations for Asthma          1    State
```

#### Downloading measure data with advanced options

The advanced stratification options are submitted via the `strat_level`
argument and the subset of stratification levels derived from the
`list_StratificationTypes()` function can be submitted with the
`stratItems` argument.

``` r



data_strat.item <- get_data(measure=99,
                  strat_level =  "ST_AG_GN",
                  temporalItems = c(2005),
                  geoItems = "Arizona",
                  stratItems = c("GenderId=1","AgeBandId=3"))
#> Building API call for measure: 99 with stratification: State x Age x Gender.
#> Retrieving data...
#> Done

head(data_strat.item[[1]])
#>       geo geoId   geoAbbreviation parentGeographicTypeId parentGeo parentGeoId
#> 1 Arizona    04 StateAbbreviation                     NA        NA          NA
#>   parentGeoAbbreviation temporalTypeId temporal temporalDescription
#> 1                    NA              1     2005         Single Year
#>   temporalColumnName temporalRollingColumnName temporalId minimumTemporal
#> 1         ReportYear          RollingYearCount       2005              NA
#>   minimumTemporalId parentTemporalTypeId parentTemporalType parentTemporal
#> 1                NA                   NA                 NA             NA
#>   parentTemporalId date dataValue suppressionFlag confidenceIntervalLow
#> 1               NA 2005       304               0                    NA
#>   confidenceIntervalHigh confidenceIntervalName standardError standardErrorName
#> 1                     NA                     NA            NA                NA
#>   secondaryValue secondaryValueName descriptiveValue descriptiveValueName
#> 1             NA                 NA               NA                   NA
#>   includeDescriptiveValueName category categoryName   title
#> 1                          NA       NA           NA Arizona
#>   confidenceIntervalLowName parentMinimumTemporal parentMinimumTemporalId
#> 1                                              NA                      NA
#>   full_stratification Gender Age Group measureId
#> 1      Male, 15 TO 34   Male  15 TO 34        99
#>                                    measureName geo_typeID Geo_Type
#> 1 Annual Number of Hospitalizations for Asthma          1    State
```

#### Downloading measure data with advanced options and specific geographies

You can submit state names, abbreviations, or state FIPS codes with the
`geoItems` argument. This will return data for either the specified
state(s) or all the sub-state geographies within the state, depending on
the geography type of the data (e.g., state, county). Individual
sub-state geographies can also be submitted by FIPS code or name with
this argument. For measures with sub-state geographies, a mix of state
and sub-state entries can be submitted.

``` r
data_mo.geo<-get_data(measure=99,  
                      strat_level = "State x County", #this can be written by name or ID (i.e., "ST_CT)
                      geoItems = c("Massachusetts",
                                   "Alameda, CA", #county name should not include word 'county' and must have state
                                   1001))
#> Building API call for measure: 99 with stratification: State x County.
#> Retrieving data...
#> Done

head(data_mo.geo[[1]])
#>       geo geoId    geoAbbreviation parentGeographicTypeId  parentGeo
#> 1 Alameda 06001 CountyAbbreviation                      1 California
#> 2 Alameda 06001 CountyAbbreviation                      1 California
#> 3 Alameda 06001 CountyAbbreviation                      1 California
#> 4 Alameda 06001 CountyAbbreviation                      1 California
#> 5 Alameda 06001 CountyAbbreviation                      1 California
#> 6 Alameda 06001 CountyAbbreviation                      1 California
#>   parentGeoId parentGeoAbbreviation temporalTypeId temporal temporalDescription
#> 1          06                    CA              1     2000         Single Year
#> 2          06                    CA              1     2001         Single Year
#> 3          06                    CA              1     2002         Single Year
#> 4          06                    CA              1     2003         Single Year
#> 5          06                    CA              1     2004         Single Year
#> 6          06                    CA              1     2005         Single Year
#>   temporalColumnName temporalRollingColumnName temporalId minimumTemporal
#> 1         ReportYear          RollingYearCount       2000              NA
#> 2         ReportYear          RollingYearCount       2001              NA
#> 3         ReportYear          RollingYearCount       2002              NA
#> 4         ReportYear          RollingYearCount       2003              NA
#> 5         ReportYear          RollingYearCount       2004              NA
#> 6         ReportYear          RollingYearCount       2005              NA
#>   minimumTemporalId parentTemporalTypeId parentTemporalType parentTemporal
#> 1                NA                   NA                 NA             NA
#> 2                NA                   NA                 NA             NA
#> 3                NA                   NA                 NA             NA
#> 4                NA                   NA                 NA             NA
#> 5                NA                   NA                 NA             NA
#> 6                NA                   NA                 NA             NA
#>   parentTemporalId date dataValue suppressionFlag confidenceIntervalLow
#> 1               NA 2000      2389               0                    NA
#> 2               NA 2001      2243               0                    NA
#> 3               NA 2002      2260               0                    NA
#> 4               NA 2003      2383               0                    NA
#> 5               NA 2004      2059               0                    NA
#> 6               NA 2005      2348               0                    NA
#>   confidenceIntervalHigh confidenceIntervalName standardError standardErrorName
#> 1                     NA                     NA            NA                NA
#> 2                     NA                     NA            NA                NA
#> 3                     NA                     NA            NA                NA
#> 4                     NA                     NA            NA                NA
#> 5                     NA                     NA            NA                NA
#> 6                     NA                     NA            NA                NA
#>   secondaryValue secondaryValueName descriptiveValue descriptiveValueName
#> 1             NA                 NA               NA                   NA
#> 2             NA                 NA               NA                   NA
#> 3             NA                 NA               NA                   NA
#> 4             NA                 NA               NA                   NA
#> 5             NA                 NA               NA                   NA
#> 6             NA                 NA               NA                   NA
#>   includeDescriptiveValueName category categoryName       title
#> 1                          NA       NA           NA Alameda, CA
#> 2                          NA       NA           NA Alameda, CA
#> 3                          NA       NA           NA Alameda, CA
#> 4                          NA       NA           NA Alameda, CA
#> 5                          NA       NA           NA Alameda, CA
#> 6                          NA       NA           NA Alameda, CA
#>   confidenceIntervalLowName parentMinimumTemporal parentMinimumTemporalId
#> 1                                              NA                      NA
#> 2                                              NA                      NA
#> 3                                              NA                      NA
#> 4                                              NA                      NA
#> 5                                              NA                      NA
#> 6                                              NA                      NA
#>   measureId                                  measureName geo_typeID Geo_Type
#> 1        99 Annual Number of Hospitalizations for Asthma          2   County
#> 2        99 Annual Number of Hospitalizations for Asthma          2   County
#> 3        99 Annual Number of Hospitalizations for Asthma          2   County
#> 4        99 Annual Number of Hospitalizations for Asthma          2   County
#> 5        99 Annual Number of Hospitalizations for Asthma          2   County
#> 6        99 Annual Number of Hospitalizations for Asthma          2   County
```

#### Downloading measure data with specific geographies and temporal periods selected

``` r
data_tpm.geo <- get_data(measure=99, 
                      strat_level = "ST",
                      geoItems = c("CO", "ME", "FL"),
                      temporalItems = c(2014:2018))
#> Building API call for measure: 99 with stratification: State.
#> Retrieving data...
#> Done

head(data_tpm.geo[[1]])
#>        geo geoId   geoAbbreviation parentGeographicTypeId parentGeo parentGeoId
#> 1 Colorado    08 StateAbbreviation                     NA        NA          NA
#> 2 Colorado    08 StateAbbreviation                     NA        NA          NA
#> 3 Colorado    08 StateAbbreviation                     NA        NA          NA
#> 4 Colorado    08 StateAbbreviation                     NA        NA          NA
#> 5 Colorado    08 StateAbbreviation                     NA        NA          NA
#> 6  Florida    12 StateAbbreviation                     NA        NA          NA
#>   parentGeoAbbreviation temporalTypeId temporal temporalDescription
#> 1                    NA              1     2014         Single Year
#> 2                    NA              1     2015         Single Year
#> 3                    NA              1     2016         Single Year
#> 4                    NA              1     2017         Single Year
#> 5                    NA              1     2018         Single Year
#> 6                    NA              1     2014         Single Year
#>   temporalColumnName temporalRollingColumnName temporalId minimumTemporal
#> 1         ReportYear          RollingYearCount       2014              NA
#> 2         ReportYear          RollingYearCount       2015              NA
#> 3         ReportYear          RollingYearCount       2016              NA
#> 4         ReportYear          RollingYearCount       2017              NA
#> 5         ReportYear          RollingYearCount       2018              NA
#> 6         ReportYear          RollingYearCount       2014              NA
#>   minimumTemporalId parentTemporalTypeId parentTemporalType parentTemporal
#> 1                NA                   NA                 NA             NA
#> 2                NA                   NA                 NA             NA
#> 3                NA                   NA                 NA             NA
#> 4                NA                   NA                 NA             NA
#> 5                NA                   NA                 NA             NA
#> 6                NA                   NA                 NA             NA
#>   parentTemporalId date dataValue suppressionFlag confidenceIntervalLow
#> 1               NA 2014      3979               0                    NA
#> 2               NA 2015      3170               0                    NA
#> 3               NA 2016      2484               0                    NA
#> 4               NA 2017      2367               0                    NA
#> 5               NA 2018      2236               0                    NA
#> 6               NA 2014     28014               0                    NA
#>   confidenceIntervalHigh confidenceIntervalName standardError standardErrorName
#> 1                     NA                     NA            NA                NA
#> 2                     NA                     NA            NA                NA
#> 3                     NA                     NA            NA                NA
#> 4                     NA                     NA            NA                NA
#> 5                     NA                     NA            NA                NA
#> 6                     NA                     NA            NA                NA
#>   secondaryValue secondaryValueName descriptiveValue descriptiveValueName
#> 1             NA                 NA               NA                   NA
#> 2             NA                 NA               NA                   NA
#> 3             NA                 NA               NA                   NA
#> 4             NA                 NA               NA                   NA
#> 5             NA                 NA               NA                   NA
#> 6             NA                 NA               NA                   NA
#>   includeDescriptiveValueName category categoryName    title
#> 1                          NA       NA           NA Colorado
#> 2                          NA       NA           NA Colorado
#> 3                          NA       NA           NA Colorado
#> 4                          NA       NA           NA Colorado
#> 5                          NA       NA           NA Colorado
#> 6                          NA       NA           NA  Florida
#>   confidenceIntervalLowName parentMinimumTemporal parentMinimumTemporalId
#> 1                                              NA                      NA
#> 2                                              NA                      NA
#> 3                                              NA                      NA
#> 4                                              NA                      NA
#> 5                                              NA                      NA
#> 6                                              NA                      NA
#>   measureId                                  measureName geo_typeID Geo_Type
#> 1        99 Annual Number of Hospitalizations for Asthma          1    State
#> 2        99 Annual Number of Hospitalizations for Asthma          1    State
#> 3        99 Annual Number of Hospitalizations for Asthma          1    State
#> 4        99 Annual Number of Hospitalizations for Asthma          1    State
#> 5        99 Annual Number of Hospitalizations for Asthma          1    State
#> 6        99 Annual Number of Hospitalizations for Asthma          1    State
```

## Public Domain Standard Notice

This repository constitutes a work of the United States Government and
is not subject to domestic copyright protection under 17 USC § 105. This
repository is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain
dedication](https://creativecommons.org/publicdomain/zero/1.0/). All
contributions to this repository will be released under the CC0
dedication. By submitting a pull request you are agreeing to comply with
this waiver of copyright interest.

## License Standard Notice

The repository utilizes code licensed under the terms of the Apache
Software License and therefore is licensed under ASL v2 or later.

This source code in this repository is free: you can redistribute it
and/or modify it under the terms of the Apache Software License version
2, or (at your option) any later version.

This source code in this repository is distributed in the hope that it
will be useful, but WITHOUT ANY WARRANTY; without even the implied
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
Apache Software License for more details.

You should have received a copy of the Apache Software License along
with this program. If not, see
<http://www.apache.org/licenses/LICENSE-2.0.html>

The source code forked from other open source projects will inherit its
license.

## Privacy Standard Notice

This repository contains only non-sensitive, publicly available data and
information. All material and community participation is covered by the
[Disclaimer](https://github.com/CDCgov/EPHTrackR/blob/master/DISCLAIMER.md)
and [Code of
Conduct](https://github.com/CDCgov/EPHTrackR/blob/master/code-of-conduct.md).
For more information about CDC’s privacy policy, please visit
[http://www.cdc.gov/other/privacy.html](https://www.cdc.gov/other/privacy.html).

## Contributing Standard Notice

Anyone is encouraged to contribute to the repository by
[forking](https://help.github.com/articles/fork-a-repo) and submitting a
pull request. (If you are new to GitHub, you might start with a [basic
tutorial](https://help.github.com/articles/set-up-git).) By contributing
to this project, you grant a world-wide, royalty-free, perpetual,
irrevocable, non-exclusive, transferable license to all users under the
terms of the [Apache Software License
v2](http://www.apache.org/licenses/LICENSE-2.0.html) or later.

All comments, messages, pull requests, and other submissions received
through CDC including this GitHub page may be subject to applicable
federal law, including but not limited to the Federal Records Act, and
may be archived. Learn more at <http://www.cdc.gov/other/privacy.html>.

## Records Management Standard Notice

This repository is not a source of government records, but is a copy to
increase collaboration and collaborative potential. All government
records will be published through the [CDC web
site](http://www.cdc.gov).
