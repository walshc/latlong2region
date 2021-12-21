latlong2region <- function(p, shp, closest = FALSE, get.distance = FALSE,
                           show.pb = TRUE) {

  proj <- "+proj=longlat +datum=WGS84"
  shp <- sp::spTransform(shp, sp::CRS(proj))

  if (!any("SpatialPoints" %in% class(p))) {
    if (any("numeric" %in% class(p))) {
      p <- matrix(p, ncol = 2)
    }
    p <- sp::SpatialPoints(p, proj4string = sp::CRS(proj))
  }
  df <- cbind(sp::coordinates(p), sp::over(x = p, y = shp))

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
      # shp.df <- ggplot2::fortify(shp, region = "latlong2region.id")
    } else {
      message("No points outside a region.")
    }

    # Getting the distance adds computational load, so put it outside:
    if (show.pb) {
      pb <- txtProgressBar(min = 0, max = length(unmatched), style = 3)
    }
    if (get.distance) {
      df$distance <- 0
      for (i in unmatched) {
        dist <- suppressWarnings(rgeos::gDistance(p[i], shp, byid = TRUE))
        closest <- which.min(dist)
        df$distance[i] <- geosphere::dist2Line(p[i], shp[closest, ])[1, 1]
        for (j in names(shp@data)[-ncol(shp@data)]) {
          df[[j]][ids == i] <-
            shp@data[[j]][shp@data$latlong2region.id == closest]
        }
        setTxtProgressBar(pb, which(unmatched == i))
      }
    } else {
      for (i in unmatched) {
        dist <- suppressWarnings(rgeos::gDistance(p[i], shp, byid = TRUE))
        closest <- which.min(dist)
        for (j in names(shp@data)[-ncol(shp@data)]) {
          df[[j]][ids == i] <-
            shp@data[[j]][shp@data$latlong2region.id == closest]
        }
        if (show.pb) {
          setTxtProgressBar(pb, which(unmatched == i))
        }
      }
    }
    if (show.pb) {
      close(pb)
    }
  }
  return(df)
}
