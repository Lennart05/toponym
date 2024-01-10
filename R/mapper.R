mapper <- function(mapdata, ...){

if(!is.data.frame(mapdata)) stop("'mapdata' must be a data frame.")
if(!all(c("name", "latitude", "longitude") %in% colnames(mapdata))) stop("'mapdata' must have the following columns: 'name', 'latitude' & 'longitude'.")
#if("color" %in% colnames(mapdata))
#if(!"country code" %in% colnames(mapdata)) warning("'mapdata does not contain ")



#sum(is.na(mapdata$`country code`))


coordinates <- list(latitude = mapdata$`latitude`, longitude = mapdata$`longitude`, "country code" = mapdata$`country code`, matches = mapdata$`matches`, color = mapdata$`color`)

opt <- list(...)
if (is.null(opt$regions)) opt$regions <- 0
if (is.null(opt$plot)) opt$plot <- TRUE


simpleMap(opt$label, #optional labels
          coordinates, opt$color, opt$regions, opt$plot, opt$polygon)


}
