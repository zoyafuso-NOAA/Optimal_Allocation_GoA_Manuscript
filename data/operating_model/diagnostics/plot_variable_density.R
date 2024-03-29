plot_variable_density = function (Y_gt, map_list, panel_labels, projargs = "+proj=longlat", 
    map_resolution = "medium", file_name = "density", 
    working_dir = paste0(getwd(), "/"), Format = "png", 
    Res = 200, add = FALSE, outermargintext = c("Eastings", 
        "Northings"), zlim, col, mar = c(0, 0, 2, 0), oma = c(4, 
        4, 0, 0), legend_x = c(0, 0.05), legend_y = c(0.05, 0.85), 
    cex.legend = 1, mfrow, land_color = "grey", n_cells, 
    xlim, ylim, ...) 
{
    if (is.vector(Y_gt)) {
        Y_gt = matrix(Y_gt, ncol = 1)
    }
    if (missing(zlim)) {
        zlim = range(Y_gt, na.rm = TRUE)
    }
    if (missing(map_list) || is.null(map_list$MapSizeRatio)) {
        MapSizeRatio = c(3, 3)
    }
    else {
        MapSizeRatio = map_list$MapSizeRatio
    }
    if (!("PlotDF" %in% names(map_list))) 
        stop("Check input `map_list`")
    Y_gt = Y_gt[map_list$PlotDF[which(map_list$PlotDF[, "Include"] > 
        0), "x2i"], , drop = FALSE]
    if (missing(n_cells)) 
        n_cells = nrow(Y_gt)
    if (missing(mfrow)) {
        mfrow = ceiling(sqrt(ncol(Y_gt)))
        mfrow = c(mfrow, ceiling(ncol(Y_gt)/mfrow))
    }
    if (missing(panel_labels)) {
        panel_labels = rep("", ncol(Y_gt))
    }
    if (length(panel_labels) != ncol(Y_gt)) {
        warning("panel_labels and `ncol(Y_gt)` don't match: Changing panel_labels'")
        panel_labels = 1:ncol(Y_gt)
    }
    if (missing(col)) {
        col = colorRampPalette(colors = c("darkblue", "blue", 
            "lightblue", "lightgreen", "yellow", 
            "orange", "red"))
    }
    if (is.function(col)) {
        col = col(1000)
    }
    if (all(is.numeric(c(legend_x, legend_y)))) {
        if (any(c(legend_x, legend_y) > 1.2) | any(c(legend_x, 
            legend_y) < -0.2)) {
            stop("Check values for `legend_x` and `legend_y`")
        }
    }
    loc_g = map_list$PlotDF[which(map_list$PlotDF[, "Include"] > 
        0), c("Lon", "Lat")]
    CRS_orig = sp::CRS("+proj=longlat")
    CRS_proj = sp::CRS(projargs)
    map_data = rnaturalearth::ne_countries(scale = switch(map_resolution, 
        low = 110, medium = 50, high = 10, 50))
    map_data = sp::spTransform(map_data, CRSobj = CRS_proj)
    Par = list(mfrow = mfrow, mar = mar, oma = oma, ...)
    if (Format == "png") {
        png(file = paste0(working_dir, file_name, ".png"), 
            width = Par$mfrow[2] * MapSizeRatio[2], height = Par$mfrow[1] * 
                MapSizeRatio[1], res = Res, units = "in")
        on.exit(dev.off())
    }
    if (Format == "jpg") {
        jpeg(file = paste0(working_dir, file_name, ".jpg"), 
            width = Par$mfrow[2] * MapSizeRatio[2], height = Par$mfrow[1] * 
                MapSizeRatio[1], res = Res, units = "in")
        on.exit(dev.off())
    }
    if (Format %in% c("tif", "tiff")) {
        tiff(file = paste0(working_dir, file_name, ".tif"), 
            width = Par$mfrow[2] * MapSizeRatio[2], height = Par$mfrow[1] * 
                MapSizeRatio[1], res = Res, units = "in")
        on.exit(dev.off())
    }
    if (add == FALSE) 
        par(Par)
    for (tI in 1:ncol(Y_gt)) {
        Points_orig = sp::SpatialPointsDataFrame(coords = loc_g, 
            data = data.frame(y = Y_gt[, tI]), proj4string = CRS_orig)
        Points_LongLat = sp::spTransform(Points_orig, sp::CRS("+proj=longlat"))
        Points_proj = sp::spTransform(Points_orig, CRS_proj)
        cell.size = mean(diff(Points_proj@bbox[1, ]), diff(Points_proj@bbox[2, 
            ]))/floor(sqrt(n_cells))
        Raster_proj = plotKML::vect2rast(Points_proj, cell.size = cell.size)
        if (missing(xlim)) 
            xlim = Raster_proj@bbox[1, ]
        if (missing(ylim)) 
            ylim = Raster_proj@bbox[2, ]
			
		plot_this = unlist(Y_gt[,tI])
		breaks_ = c(min(plot_this), 0, quantile(plot_this[plot_this>0], seq(0.25,1,length = 4))) 
        image(Raster_proj, col = col, zlim = zlim, xlim = xlim, ylim = ylim, 
			breaks = breaks_)
			
        sp::plot(map_data, col = land_color, add = TRUE)
        title(panel_labels[tI], line = 0.1, cex.main = ifelse(is.null(Par$cex.main), 
            1.5, Par$cex.main), cex = ifelse(is.null(Par$cex.main), 
            1.5, Par$cex.main))
        box()
    }
    if (all(is.numeric(c(legend_x, legend_y)))) {
        xl = (1 - legend_x[1]) * par("usr")[1] + (legend_x[1]) * 
            par("usr")[2]
        xr = (1 - legend_x[2]) * par("usr")[1] + (legend_x[2]) * 
            par("usr")[2]
        yb = (1 - legend_y[1]) * par("usr")[3] + (legend_y[1]) * 
            par("usr")[4]
        yt = (1 - legend_y[2]) * par("usr")[3] + (legend_y[2]) * 
            par("usr")[4]
        if (diff(legend_y) > diff(legend_x)) {
            align = c("lt", "rb")[2]
            gradient = c("x", "y")[2]
        }
        else {
            align = c("lt", "rb")[1]
            gradient = c("x", "y")[1]
        }
        plotrix::color.legend(xl = xl, yb = yb, xr = xr, yt = yt, 
            legend = c(paste0('<0'), round(quantile(plot_this[plot_this>0], 
			seq(0.25,1,length = 4)),2) ),
			#legend = round(seq(zlim[1], zlim[2], length = 4), 1), 
			rect.col = col, cex = cex.legend, align = align, 
            gradient = gradient)
    }
    if (add == FALSE) 
        mtext(side = 1, outer = TRUE, outermargintext[1], cex = 1.75, 
            line = par()$oma[1]/2)
    if (add == FALSE) 
        mtext(side = 2, outer = TRUE, outermargintext[2], cex = 1.75, 
            line = par()$oma[2]/2)
    return(invisible(list(Par = Par, cell.size = cell.size, n_cells = n_cells, 
        xlim = xlim, ylim = ylim)))
}