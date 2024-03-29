% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/list_indicators.R
\name{list_indicators}
\alias{list_indicators}
\title{List indicators}
\usage{
list_indicators(content_area = NA, token = NULL)
}
\arguments{
\item{content_area}{Optional argument used to specify the content area(s) of interest as an ID or name. IDs should be unquoted numeric values; name entries should be quoted strings. Use list_content_areas() to identify available content areas.}

\item{token}{An optional argument to submit a Tracking API token acquired from trackingsupport(AT)cdc.gov as a quoted string. It is recommended that you save your token using the tracking_api_token() function so that you don't need to enter your token when you run this function. It will be automatically pulled from you .Renviron file.}
}
\value{
This function returns a data frame containing all indicator names, shortNames, and IDs contained in the specified content area(s).
}
\description{
Lists the indicators contained within the specified content area(s). Indicators are groups of highly related measures.
}
\examples{
\dontrun{

#create a comprehensive inventory of all indicators and associated content areas
all_indicators<-list_indicators()

list_indicators(25)

list_indicators("Drought")




}
}
