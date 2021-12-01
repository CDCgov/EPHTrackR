
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
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

<!-- [![Travis-CI Build Status](https://travis-ci.org/cont-limno/LAGOSNE.svg?branch=master)](https://travis-ci.org/cont-limno/LAGOSNE) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/LAGOSNE)](https://cran.r-project.org/package=LAGOSNE) [![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/LAGOSNE)](https://cran.r-project.org/package=LAGOSNE)
[![Codecov test coverage](https://codecov.io/gh/tidyverse/dplyr/branch/master/graph/badge.svg)](https://codecov.io/gh/tidyverse/dplyr?branch=master)-->

# EPHTrackR <img src="man/figures/CDC_Tracking_Combined.jpg" align="right" height=140/>

The `EPHTrackR` package provides an R interface to access and download
publicly available data stored on the [CDC National Environmental Public
Health Tracking Network](https://www.cdc.gov/nceh/tracking/about.htm)
(Tracking Network) via a connection with the [Tracking Network Data
API](https://ephtracking.cdc.gov/apihelp). Associated metadata can be
found on the Tracking Network [Indicators and
Data](https://ephtracking.cdc.gov/searchMetadata) page. Users might find
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
— Climate, such as extreme heat events <br> — Community design, such
as access to parks <br> — Lifestyle risk factors, such as smoking <br> —
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
#> Run `update_inventory()` to update the stored list of content areas, indicators, and measures.
```

## Update data inventory

The `update_inventory` function retrieves the latest inventory of
content areas, indicators, and measures from the Tracking Network Data
API. This information is used internally by the package to send
appropriate API data requests. We recommend that you run this function
before each session to ensure that the inventory is up-to-date.

``` r
update_inventory()
```

You can access a data frame containing the full inventory of content
areas, indicators, and measures in the R environment after the package
is loaded using the command below.

``` r
data(measures_indicators_CAs)
```

## Viewing content area, indicator, and measure names

Each content area, indicator, and measure has a full name, a shortened
name, and a unique identifier. You can use this information to determine
what data are available on the Tracking Network and make appropriate
calls to download the data (see below).

#### List content areas available

``` r
ca_df <- list_content_areas()

head(ca_df)
#>   content_area_ID         content_area_name content_area_shortName
#> 1               1            Drinking Water                    DWQ
#> 2               2 Carbon Monoxide Poisoning                     CO
#> 3               3                    Asthma                     AS
#> 4               4  Heart Disease and Stroke                     MI
#> 5               5             Birth Defects                     BD
#> 6               6  Childhood Lead Poisoning                    CLP
```

#### List indicators in specified content area(s)

``` r
ind_df <- list_indicators(content_area = "Heat & Heat-related Illness",
                     format="name")

head(ind_df)
#>   indicator_ID                           indicator_name
#> 1           67                   Heat-Related Mortality
#> 2           88            Heat-related Hospitalizations
#> 3           89 Heat-related Emergency Department Visits
#> 4           97           Temperature & Heat Projections
#> 5          172       Vulnerability & Preparedness: Heat
#> 6          173      Historical Temperature & Heat Index
#>                        indicator_shortName content_area_ID
#> 1                   Heat-Related Mortality              35
#> 2            Heat-related Hospitalizations              35
#> 3 Heat-related Emergency Department Visits              35
#> 4           Temperature & Heat Projections              35
#> 5       Vulnerability & Preparedness: Heat              35
#> 6      Historical Temperature & Heat Index              35
#>             content_area_name content_area_shortName
#> 1 Heat & Heat-related Illness                    HHI
#> 2 Heat & Heat-related Illness                    HHI
#> 3 Heat & Heat-related Illness                    HHI
#> 4 Heat & Heat-related Illness                    HHI
#> 5 Heat & Heat-related Illness                    HHI
#> 6 Heat & Heat-related Illness                    HHI
```

#### List measures in specified indicator(s) and/or content area(s)

``` r
meas_df <- list_measures(content_area =c(36),
                    format="ID")

head(meas_df)
#>   measure_ID
#> 1        576
#> 2        577
#> 3        578
#> 4        579
#> 5        580
#> 6        581
#>                                                               measure_name
#> 1                                     Number of extreme precipitation days
#> 2                                       Monthly estimates of precipitation
#> 3                    Projected number of future extreme precipitation days
#> 4                                 Projected annual precipitation intensity
#> 5 Projected ratio of precipitation falling as rain to that falling as snow
#> 6          Number of square miles within FEMA designated flood hazard area
#>                                       measure_shortName indicator_ID
#> 1                  Number of extreme precipitation days          108
#> 2                    Monthly estimates of precipitation          108
#> 3 Projected number of future extreme precipitation days          107
#> 4              Projected annual precipitation intensity          107
#> 5                       Projected ratio of rain to snow          107
#> 6             Total area (square miles) FEMA floodplain          106
#>                                           indicator_name
#> 1                               Historical Precipitation
#> 2                               Historical Precipitation
#> 3                   Precipitation & Flooding Projections
#> 4                   Precipitation & Flooding Projections
#> 5                   Precipitation & Flooding Projections
#> 6 Vulnerability & Preparedness: Precipitation & Flooding
#>                                      indicator_shortName content_area_ID
#> 1                               Historical Precipitation              36
#> 2                               Historical Precipitation              36
#> 3                   Precipitation & Flooding Projections              36
#> 4                   Precipitation & Flooding Projections              36
#> 5                   Precipitation & Flooding Projections              36
#> 6 Vulnerability & Preparedness: Precipitation & Flooding              36
#>          content_area_name content_area_shortName
#> 1 Precipitation & Flooding                     PF
#> 2 Precipitation & Flooding                     PF
#> 3 Precipitation & Flooding                     PF
#> 4 Precipitation & Flooding                     PF
#> 5 Precipitation & Flooding                     PF
#> 6 Precipitation & Flooding                     PF
```

## Viewing available geography types and temporal periods for specified measures

Measures on the Tracking Network vary in their geographic resolution
(e.g., state, county), and their temporal resolution (e.g., year, month)
and extent (e.g., 2000-2010, 2010-2020). By becoming familiar with the
locations and temporal periods for which data are available using this
function, you can make more targeted data downloads.

#### List geography types available for specified measures

Measures are typically available at the state, county, or census tract
level.

``` r
geog_type_df <- list_geography_types(measure= "Number of extreme heat days",
                             format="name")

head(geog_type_df)
#> [[1]]
#>   geographicType geographicTypeId Measure_ID                Measure_Name
#> 1         County                2        423 Number of extreme heat days
#> 2   Census Tract                7        423 Number of extreme heat days
#>             Measure_shortName
#> 1 Number of extreme heat days
#> 2 Number of extreme heat days
```

#### List temporal periods available for specified measures

Measures are typically available at an annual scale, but also can be
daily, monthly, or weekly.

``` r
temp_df <- list_temporal(measure= "Number of extreme heat days",
                             format="name")

head(temp_df[[1]])
#>   parentTemporal parentTemporalType Geo_Type Measure_ID
#> 1           1979               Year   County        423
#> 2           1980               Year   County        423
#> 3           1981               Year   County        423
#> 4           1982               Year   County        423
#> 5           1983               Year   County        423
#> 6           1984               Year   County        423
#>                       Measure
#> 1 Number of extreme heat days
#> 2 Number of extreme heat days
#> 3 Number of extreme heat days
#> 4 Number of extreme heat days
#> 5 Number of extreme heat days
#> 6 Number of extreme heat days
```

## Viewing available Advanced Options for data stratification

In addition to geographic and temporal specifications, some measures on
the Tracking Network have a set of **Advanced Options** that allow users
to access data stratified by other variables. For instance, data on
asthma hospitalizations can be broken down by age and/or gender.

Users are not yet able to directly select a specific stratification
level with this package. Rather, users select whether they’d like the
data stratified to receive results for all levels. Specific
stratification levels can then be selected using filtering functions in
the local environment.

#### List available stratification levels for a measure

**Advanced Options** might only be available at a particular geographic
scale (e.g., age-breakdown of asthma hospitalizations is only available
at the state level). Therefore, results showing available stratification
levels always include the geography type. The output of this function is
a list with a separate element for each geography type available (e.g.,
state, county) for the specified measure. Each row in the data frame
elements of the list shows a stratification available for the measure.

``` r
strat_df <- list_stratification_levels(measure=99, format="ID")

head(strat_df)
#> [[1]]
#>   id                 name abbreviation geographicTypeId
#> 1  1                State           ST                1
#> 2  3          State x Age        ST_AG                1
#> 3  4       State x Gender        ST_GN                1
#> 4 37 State x Age x Gender     ST_AG_GN                1
#>                                     stratificationType Measure_ID
#> 1                                                 NULL         99
#> 2                          3, Age Group, AG, AgeBandId         99
#> 3                              4, Gender, GN, GenderId         99
#> 4 3, 4, Age Group, Gender, AG, GN, AgeBandId, GenderId         99
#>                            Measure_Name                      Measure_shortName
#> 1 Number of hospitalizations for asthma Number of hospitalizations for asthma 
#> 2 Number of hospitalizations for asthma Number of hospitalizations for asthma 
#> 3 Number of hospitalizations for asthma Number of hospitalizations for asthma 
#> 4 Number of hospitalizations for asthma Number of hospitalizations for asthma 
#>   Geo_Type Geo_Type_ID
#> 1    State           1
#> 2    State           1
#> 3    State           1
#> 4    State           1
#> 
#> [[2]]
#>   id           name abbreviation geographicTypeId stratificationType Measure_ID
#> 1  2 State x County        ST_CT                2               NULL         99
#>                            Measure_Name                      Measure_shortName
#> 1 Number of hospitalizations for asthma Number of hospitalizations for asthma 
#>   Geo_Type Geo_Type_ID
#> 1   County           2
```

## Accessing Tracking Network data

You can use the information from the functions listed above to request
specific data from the Tracking Network Data API. Be careful when making
queries. If you request data that include many years and/or data at a
fine geographic scale, the dataset could be very large and take a long
time to download (if it doesn’t crash your session).

We recommend that you include only one measure and one stratification
level in a data query. However, many geographies and temporal periods
may be submitted. The function will likely still work if vectors of
multiple measures or stratifications are submitted, but the resulting
object will be a multi-element list and distinguishing the element that
applies to a particular measure or stratification level might be
difficult. The output of calls with a single measure and stratification
level is a list with one element containing the relevant data frame.

#### Downloading state-level measure data

``` r

data_st<-get_data(measure=99, 
                      format="ID",  
                      strat_level = "ST")
#> Retrieving data...
#> Done

head(data_st[[1]])
#>   dataValue date suppressionFlag confidenceIntervalLow confidenceIntervalHigh
#> 1      7115 2005               0                    NA                     NA
#> 2      6712 2006               0                    NA                     NA
#> 3      6735 2007               0                    NA                     NA
#> 4      7511 2008               0                    NA                     NA
#> 5      8265 2009               0                    NA                     NA
#> 6      8050 2010               0                    NA                     NA
#>   confidenceIntervalName standardError standardErrorName secondaryValue
#> 1                     NA            NA                NA             NA
#> 2                     NA            NA                NA             NA
#> 3                     NA            NA                NA             NA
#> 4                     NA            NA                NA             NA
#> 5                     NA            NA                NA             NA
#> 6                     NA            NA                NA             NA
#>   secondaryValueName   title confidenceIntervalLowName     geo parentGeo geoId
#> 1                 NA Arizona                           Arizona        NA    04
#> 2                 NA Arizona                           Arizona        NA    04
#> 3                 NA Arizona                           Arizona        NA    04
#> 4                 NA Arizona                           Arizona        NA    04
#> 5                 NA Arizona                           Arizona        NA    04
#> 6                 NA Arizona                           Arizona        NA    04
#>   parentGeoId geoAbbreviation parentGeoAbbreviation Measure_ID
#> 1          NA              AZ                    NA         99
#> 2          NA              AZ                    NA         99
#> 3          NA              AZ                    NA         99
#> 4          NA              AZ                    NA         99
#> 5          NA              AZ                    NA         99
#> 6          NA              AZ                    NA         99
#>                            Measure_Name                      Measure_shortName
#> 1 Number of hospitalizations for asthma Number of hospitalizations for asthma 
#> 2 Number of hospitalizations for asthma Number of hospitalizations for asthma 
#> 3 Number of hospitalizations for asthma Number of hospitalizations for asthma 
#> 4 Number of hospitalizations for asthma Number of hospitalizations for asthma 
#> 5 Number of hospitalizations for asthma Number of hospitalizations for asthma 
#> 6 Number of hospitalizations for asthma Number of hospitalizations for asthma 
#>   Strat_Level_ID Geo_Type_ID Geo_Type
#> 1              1           1    State
#> 2              1           1    State
#> 3              1           1    State
#> 4              1           1    State
#> 5              1           1    State
#> 6              1           1    State
```

#### Downloading measure data with advanced options

The advanced stratification options are submitted via the `strat_level`
argument and do not need to be included elsewhere.

``` r

data_ad<-get_data(measure=99, 
                      format="ID",  
                      strat_level = "ST_AG_GN")
#> Retrieving data...
#> Done

head(data_ad[[1]])
#>   dataValue date suppressionFlag confidenceIntervalLow confidenceIntervalHigh
#> 1       879 2005               0                    NA                     NA
#> 2       422 2005               0                    NA                     NA
#> 3       739 2005               0                    NA                     NA
#> 4       436 2005               0                    NA                     NA
#> 5       304 2005               0                    NA                     NA
#> 6       541 2005               0                    NA                     NA
#>   confidenceIntervalName standardError standardErrorName secondaryValue
#> 1                     NA            NA                NA             NA
#> 2                     NA            NA                NA             NA
#> 3                     NA            NA                NA             NA
#> 4                     NA            NA                NA             NA
#> 5                     NA            NA                NA             NA
#> 6                     NA            NA                NA             NA
#>   secondaryValueName   title confidenceIntervalLowName     geo parentGeo geoId
#> 1                 NA Arizona                           Arizona        NA    04
#> 2                 NA Arizona                           Arizona        NA    04
#> 3                 NA Arizona                           Arizona        NA    04
#> 4                 NA Arizona                           Arizona        NA    04
#> 5                 NA Arizona                           Arizona        NA    04
#> 6                 NA Arizona                           Arizona        NA    04
#>   parentGeoId geoAbbreviation parentGeoAbbreviation   stratification Measure_ID
#> 1          NA              AZ                    NA     0 TO 4, Male         99
#> 2          NA              AZ                    NA   0 TO 4, Female         99
#> 3          NA              AZ                    NA    5 TO 14, Male         99
#> 4          NA              AZ                    NA  5 TO 14, Female         99
#> 5          NA              AZ                    NA   15 TO 34, Male         99
#> 6          NA              AZ                    NA 15 TO 34, Female         99
#>                            Measure_Name                      Measure_shortName
#> 1 Number of hospitalizations for asthma Number of hospitalizations for asthma 
#> 2 Number of hospitalizations for asthma Number of hospitalizations for asthma 
#> 3 Number of hospitalizations for asthma Number of hospitalizations for asthma 
#> 4 Number of hospitalizations for asthma Number of hospitalizations for asthma 
#> 5 Number of hospitalizations for asthma Number of hospitalizations for asthma 
#> 6 Number of hospitalizations for asthma Number of hospitalizations for asthma 
#>   Strat_Level_ID Geo_Type_ID Geo_Type
#> 1             37           1    State
#> 2             37           1    State
#> 3             37           1    State
#> 4             37           1    State
#> 5             37           1    State
#> 6             37           1    State
```

#### Downloading measure data with advanced options and specific geographies

You can submit state-level FIPS codes with the geo\_ID argument. This
will return data for either the specified states or all the sub-county
geographies within the state, depending on the requested stratification
level. County-level FIPS codes cannot yet be submitted, but this feature
is in development.

``` r

data_mo.geo<-get_data(measure=988, 
                      format="ID",  
                      strat_level = "ST_PT",
                      geo_ID = c(4,8,9,12))
#> Retrieving data...
#> Done

head(data_mo.geo[[1]])
#>   dataValue   date suppressionFlag confidenceIntervalLow confidenceIntervalHigh
#> 1         5 200001               0                    NA                     NA
#> 2         5 200001               0                    NA                     NA
#> 3         5 200001               0                    NA                     NA
#> 4         5 200001               0                    NA                     NA
#> 5         5 200002               0                    NA                     NA
#> 6         5 200002               0                    NA                     NA
#>   confidenceIntervalName standardError standardErrorName secondaryValue
#> 1                     NA            NA                NA             NA
#> 2                     NA            NA                NA             NA
#> 3                     NA            NA                NA             NA
#> 4                     NA            NA                NA             NA
#> 5                     NA            NA                NA             NA
#> 6                     NA            NA                NA             NA
#>   secondaryValueName reportMonth   title confidenceIntervalLowName     geo
#> 1                 NA      200001 Arizona                           Arizona
#> 2                 NA      200001 Arizona                           Arizona
#> 3                 NA      200001 Arizona                           Arizona
#> 4                 NA      200001 Arizona                           Arizona
#> 5                 NA      200002 Arizona                           Arizona
#> 6                 NA      200002 Arizona                           Arizona
#>   parentGeo geoId parentGeoId geoAbbreviation parentGeoAbbreviation
#> 1        NA    04          NA              AZ                    NA
#> 2        NA    04          NA              AZ                    NA
#> 3        NA    04          NA              AZ                    NA
#> 4        NA    04          NA              AZ                    NA
#> 5        NA    04          NA              AZ                    NA
#> 6        NA    04          NA              AZ                    NA
#>   stratification Measure_ID                       Measure_Name
#> 1            All        988 State Agency Rule-making Authority
#> 2    Legislation        988 State Agency Rule-making Authority
#> 3     Regulation        988 State Agency Rule-making Authority
#> 4          Other        988 State Agency Rule-making Authority
#> 5            All        988 State Agency Rule-making Authority
#> 6    Legislation        988 State Agency Rule-making Authority
#>                    Measure_shortName Strat_Level_ID Geo_Type_ID Geo_Type
#> 1 State Agency Rule-making Authority           2239           1    State
#> 2 State Agency Rule-making Authority           2239           1    State
#> 3 State Agency Rule-making Authority           2239           1    State
#> 4 State Agency Rule-making Authority           2239           1    State
#> 5 State Agency Rule-making Authority           2239           1    State
#> 6 State Agency Rule-making Authority           2239           1    State
```

#### Downloading measure data with specific geographies and temporal periods selected

``` r

data_tpm.geo<-get_data(measure=99, format="ID",  
                      strat_level = "ST",
                      geo = c("CO", "ME", "FL"),
                      temporal_period = c(2014:2018)
                      )
#> Retrieving data...
#> Done

head(data_tpm.geo[[1]])
#>   dataValue date suppressionFlag confidenceIntervalLow confidenceIntervalHigh
#> 1      3979 2014               0                    NA                     NA
#> 2      3170 2015               0                    NA                     NA
#> 3      2484 2016               0                    NA                     NA
#> 4      2367 2017               0                    NA                     NA
#> 5      2236 2018               0                    NA                     NA
#> 6     28014 2014               0                    NA                     NA
#>   confidenceIntervalName standardError standardErrorName secondaryValue
#> 1                     NA            NA                NA             NA
#> 2                     NA            NA                NA             NA
#> 3                     NA            NA                NA             NA
#> 4                     NA            NA                NA             NA
#> 5                     NA            NA                NA             NA
#> 6                     NA            NA                NA             NA
#>   secondaryValueName    title confidenceIntervalLowName      geo parentGeo
#> 1                 NA Colorado                           Colorado        NA
#> 2                 NA Colorado                           Colorado        NA
#> 3                 NA Colorado                           Colorado        NA
#> 4                 NA Colorado                           Colorado        NA
#> 5                 NA Colorado                           Colorado        NA
#> 6                 NA  Florida                            Florida        NA
#>   geoId parentGeoId geoAbbreviation parentGeoAbbreviation Measure_ID
#> 1    08          NA              CO                    NA         99
#> 2    08          NA              CO                    NA         99
#> 3    08          NA              CO                    NA         99
#> 4    08          NA              CO                    NA         99
#> 5    08          NA              CO                    NA         99
#> 6    12          NA              FL                    NA         99
#>                            Measure_Name                      Measure_shortName
#> 1 Number of hospitalizations for asthma Number of hospitalizations for asthma 
#> 2 Number of hospitalizations for asthma Number of hospitalizations for asthma 
#> 3 Number of hospitalizations for asthma Number of hospitalizations for asthma 
#> 4 Number of hospitalizations for asthma Number of hospitalizations for asthma 
#> 5 Number of hospitalizations for asthma Number of hospitalizations for asthma 
#> 6 Number of hospitalizations for asthma Number of hospitalizations for asthma 
#>   Strat_Level_ID Geo_Type_ID Geo_Type
#> 1              1           1    State
#> 2              1           1    State
#> 3              1           1    State
#> 4              1           1    State
#> 5              1           1    State
#> 6              1           1    State
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
