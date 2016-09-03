latlong2region <- function(p, shp, closest = TRUE) {

  proj <- "+proj=longlat +datum=WGS84"
  shp <- sp::spTransform(shp, sp::CRS(proj))

  if (class(p) != "SpatialPoints") {
    if (class(p) == "numeric") {
      p <- matrix(p, ncol = 2)
    }
    p <- sp::SpatialPoints(p, proj4string = sp::CRS(proj))
  }
  df <- cbind(sp::coordinates(p), sp::over(x = p, y = shp))
  names(df)[1:2] <- c("lon", "lat")


  if (closest) {
    ids <- 1:nrow(df)
    shp@data$latlong2region.id <- 1:nrow(shp@data)

    # Get the IDs of the unmatched observations
    unmatched <- ids[is.na(df[[names(shp@data)[1]]])]

    df$used.closest <- is.na(df[[names(shp@data)[1]]])

    if (length(unmatched) > 0) {
      message(length(unmatched), " point(s) not inside any region.",
              " Assigning to closest region.")
      # Convert the shapefile into a data.frame
      require(maptools)
      shp.df <- ggplot2::fortify(shp, region = "latlong2region.id")
    }

    for (i in unmatched) {
      # Get the coordinates of the unmatched points:
      crds <- c(unique(df[[1]][ids == i]), unique(df[[2]][ids == i]))

      # Find the distance between the point and every point in the polygon file:
      distance <- geosphere::distHaversine(crds, cbind(shp.df$long, shp.df$lat))

      # For the closest point, get the county ID
      closest <- shp.df$id[which.min(distance)]

      # Assign the county name corresponding to this ID to your missing data:
      for (j in names(shp@data)[-ncol(shp@data)]) {
        df[[j]][ids == i] <-
          shp@data[[j]][shp@data$latlong2region.id == closest]
      }
    }
  }
  return(df)
}
