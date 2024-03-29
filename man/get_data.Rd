% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_data.R
\name{get_data}
\alias{get_data}
\title{Retrieve measure data}
\usage{
get_data(
  measure,
  strat_level = NA,
  geo_type = NA,
  geoItems = NA,
  temporalItems = NA,
  stratItems = NA,
  smoothing = 0,
  token = NULL,
  simplified_output = T
)
}
\arguments{
\item{measure}{Specifies the measure of interest as an ID or name. IDs should be unquoted; name entries should be quoted strings.}

\item{strat_level}{An optional argument that specifies a stratification level by abbreviation as a quoted string (e.g., "ST_CT"), name as an quoted string (e.g., "State x County") or ID and an unquoted numeric value (e.g., 2). Stratification level specifications always include the geography type. They also may include "Advanced Options" that allow stratification by additional variables (e.g., age, gender). We recommend that this argument always be included in your get_data() calls and that only one stratification level be included per call. Including this argument renders the geo_type argument redundant. You can find available stratification levels in the "stratificationLevelAbbreviation", "stratificationLevelName", and "stratificationLevelId" columns in the list_StratificationLevels() output.}

\item{geo_type}{An optional argument in which you can specify a geographic type as a quoted string (e.g., "State", "County") or a geographic type ID as an unquoted numeric value (e.g., 1, 2). The "geographicType" and "geographicTypeId" columns in the list_geography_types() output contain a list of potential geo_type entries associated with each measure. The requested geo_type represents the geographic type of the retrieved data, which is not necessarily the same as geographic type of the geoItems argument. Do not use this argument if you have already specified a strat_level.}

\item{geoItems}{An optional argument that specifies geographic items as a vector of quoted strings (e.g., "Alabama", "Colorado", "Alameda, CA") or full FIPS codes as unquoted numeric values without leading zeros (e.g., 1, 8, 6001). You can request either the lowest level geographic items you would like included in the returned dataset (e.g., specify a county or census tract) or a state (i.e., parent geographic item) that contains the lowest level geographic items you would like returned in the data (e.g., specify a state to retrieve data for all counties or census tracts within that state). The "parentName","parentGeographicId", "childName, and "childGeographicId"  columns in the list_GeographicItems() output contains a list of available geoItems. To request a specific county by name, it is best to include the state/territory abbreviation after a comma in a quoted string (e.g., "Cumberland, PA", "Ingham, MI", "Middlesex, MA") and to omit words like county. It is safer to use FIPS codes rather than names to ensure that you retrieve the appropriate county. You can also mix items of different geographic types (e.g., state, county). If this argument is NULL, all geographies will be included in the output table.}

\item{temporalItems}{An optional argument to specify the temporal items(s) of interest as a vector of unquoted numeric values (e.g., 2011, 2019). If this argument is not entered, all available temporal items for the supplied measure and geographic constraints will be included in the output. You can find available temporal items in the "temporal" and "parentTemporal" columns in the list_TemporalItems() output.}

\item{stratItems}{An optional argument to specify specific stratification(s) of interest as vector of a quoted strings (e.g., c("RaceEthnicityId=1,2","GenderId=1")). This function allows you to return data from a subset of strata (e.g., return data for only males). This argument only applies to measure/geography combinations that have advanced stratification options, which can be determined by whether values are returned in the  stratificationItem column in the output of the list_StratificationTypes() function. Appropriate stratification(s) can be identified using the list_StratificationTypes() function output and combining the "type" of stratification derived from the columnName column (e.g., "GenderId") and the the ID for the stata/stratum of interest.  The IDs of the stata/stratum can be found in the list(s) contained within the stratificationItem column of the list_StratificationTypes() function output. The localId column within this nested list contains IDs that can be submitted in this argument. .}

\item{smoothing}{Specifies whether to return geographically smoothed measure data (1) or not (0). The default value is 0 because smoothing is not available for most measures. Requesting smoothed data when it is not available will produce an error.}

\item{token}{An optional argument to submit a Tracking API token acquired from trackingsupport(AT)cdc.gov as a quoted string. It is recommended that you save your token using the tracking_api_token() function so that you don't need to enter your token when you run this function. It will be automatically pulled from you .Renviron file.}

\item{simplified_output}{If TRUE, a simplified output table is returned. If FALSE, the raw output from the Tracking Network Data API is returned. The default is TRUE.}
}
\value{
This function returns a list with each element containing a data frame corresponding to each combination of the specified measures and geographic types/stratification levels. Note that certain data values may be suppressed in accordance with CDC guidelines intended to protect individual privacy.
}
\description{
Retrieves data from the Tracking Network Data API for specified measures, geographies, stratifications, and temporal items. We recommend that you submit only one measure and one stratification level (many geographies and temporal periods may be provided, however). The function may work if multiple measures or stratification levels are submitted, but the resulting object will be a multi-element list from which it might be difficult to distinguish which element applies to a particular stratification level. The output of function calls with a single measure and stratification level is a list with one element containing the relevant data frame.
}
\examples{
\dontrun{


data_st <- get_data(measure=99, 
strat_level = "ST")

#return a subset of gender and age stratification items
data_ad <- get_data(measure=99,   
strat_level = "ST_AG_GN",
temporalItems = 2005,
stratItems = c("GenderId=1","AgeBandId=3"))

data_mo.geo <- get_data(measure=988,  
strat_level = "ST_PT",
geoItems = c(4,8,9,12))


}
}
