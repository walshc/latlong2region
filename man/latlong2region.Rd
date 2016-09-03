\name{latlong2region}
\alias{latlong2region}
\title{Match coordinates to regions in a shapefile.}
\description{Match coordinates to regions in a shapefile.
  Also includes the possibility to find the region a point is closest to if,
  for example, the point is the water.}
\usage{
latlong2region(p, shp, closest = TRUE)
}
\arguments{
  \item{p}{Longitudes and latitudes of points. Can be a vector of two points or
    a matrix or \code{data.frame} of 2 columns (first is longitude, second is
    latitude). Can also be a \code{SpatialPoints} object.}
  \item{shp}{The \code{SpatialPolygonDataFrame} to match to.}
  \item{closest}{Whether to find the closest region for points that don't fall
    in any region in \code{shp}. Default is \code{TRUE}. This step can be slow
    for large shapefiles.}
}
\value{
  Returns a \code{data.frame} with \code{p} and the corresponding elements in \code{shp}.
}
\examples{
  # Download, extract and load the US counties shapefile:
  us <- "http://www2.census.gov/geo/tiger/GENZ2015/shp/cb_2015_us_county_500k.zip"
  download.file(us, "us_counties.zip")
  unzip("us_counties.zip")
  shp <- rgdal::readOGR(".", "cb_2015_us_county_500k")

  # Points to use, the Chicago point is in Lake Michigan so it won't be matched.
  # It will be matched to the closest county.
  df <- data.frame(name = c("New York", "San Francisco", "Chicago"),
                   lon  = c(-74.00594, -122.41942, -87.61),
                   lat  = c(40.71278, 37.77493, 41.87811))

  p <- df[, c("lon", "lat")]
  latlong2region(p, shp)
}
