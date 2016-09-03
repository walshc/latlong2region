# latlong2region
An `R` package to match coordinates to regions in a shapefile. Also includes
the possibility to find the region a point is closest to if, for example, the
point is the water.

## Installation

```r
if (!require(devtools)) install.packages("devtools")
devtools::install_github("walshc/latlong2region")
```

## Example Usage
Download, extract and load a shapefile of US counties:
```r
download.file("http://www2.census.gov/geo/tiger/GENZ2015/shp/cb_2015_us_county_500k.zip", "us_counties.zip")
unzip("us_counties.zip")
shp <- rgdal::readOGR(".", "cb_2015_us_county_500k")
```
Create a `data.frame` of sample coordinates:
```r
df <- data.frame(name = c("New York", "San Francisco", "Chicago"),
                 lon  = c(-74.00594, -122.41942, -87.61),
                 lat  = c(40.71278, 37.77493, 41.87811))
```
For demonstration purposes, the coordinates for Chicago are in the water so they won't be matched to any county:


<div align="center">
<img src="https://github.com/walshc/latlong2region/blob/master/images/chicago.png?raw=true" width="500">
</div>

The function will find the county the point is closest to:

```r
p <- cbind(df$lon, df$lat)
latlong2region(p, shp)
```

### Output
```
         lon      lat STATEFP COUNTYFP COUNTYNS       AFFGEOID GEOID          NAME LSAD
1  -74.00594 40.71278      36      061 00974129 0500000US36061 36061      New York   06
2 -122.41942 37.77493      06      075 00277302 0500000US06075 06075 San Francisco   06
3  -87.61000 41.87811      17      031 01784766 0500000US17031 17031          Cook   06
       ALAND     AWATER used.closest
1   58678310   28554415        FALSE
2  121455687  479135404        FALSE
3 2448400204 1785626819         TRUE
```
The `used.closest` variable indicates whether or not the coordinates were matched by using the closest region.
