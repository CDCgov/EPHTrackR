% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/list_stratification_values.R
\name{list_stratification_values}
\alias{list_stratification_values}
\title{List stratification values}
\usage{
list_stratification_values(
  measure = NA,
  geo_type = NA,
  geo_type_ID = NA,
  format = "ID",
  smoothing = 0
)
}
\arguments{
\item{measure}{Specifies the measure of interest as an ID, name, or shortName. IDs should be unquoted; name and shortName entries should be quoted strings.}

\item{geo_type}{An optional argument in which you can specify a geographic type as a quoted string (e.g., "State", "County"). The "geographicType" column in the list_geography_types() output contains a list of geo_types associated with each measure.}

\item{geo_type_ID}{An optional argument in which you can specify a geographic type ID as an unquoted numeric value (e.g., 1, 2). The "geographicTypeId" column in the list_geography_types() output contains a list of geo_types associated with each measure.}

\item{format}{Indicates whether the measure argument contains entries formatted as an ID, name, or shortName as a quoted string (e.g., "name", "shortName"). The default is ID.}

\item{smoothing}{Specifies whether to return stratification values for geographically smoothed versions of a measure (1) or not (0). The default value is 0 because smoothing is not available for most measures.}
}
\value{
This function returns a list with each element containing a data frame corresponding to all combinations of specified measures and geographic types. Within each row of the data frame is a nested data frame containing the stratification values. If the specified measure and associated geography type do not have any "Advanced Options" stratifications, the returned list element will be empty.
}
\description{
Some measures on the Tracking Network have a set of "Advanced Options" that allow the user to access data stratified by variables other than geography or temporal period. For instance, data on asthma hospitalizations can be broken down further by age and/or gender. This function allows the user to list available "Advanced Options" stratification values for specified measures and geographic types. For instance, in the case of the asthma hospitalization data, it would be possible to view the potential gender (e.g., Male, Female), and age (e.g., 0–4 years, >=65 years) values that are available.


The user should not need this function to retrieve data from the Tracking Network Data API because the get_data() function calls it internally. It can, however, be used as a reference to view available stratification values.
}
\examples{
\dontrun{


}
}
