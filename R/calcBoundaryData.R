#' @include RcppExports.R raptr-internal.R
NULL

#' Calculate boundary data for planning units
#'
#' This function calculates boundary length data for
#' [PBSmapping::PolySet()], [sp::SpatialPolygons()], and
#' [sp::SpatialPolygonsDataFrame()] objects. Be aware that this
#' function is designed with performance in mind, and as a consequence, if this
#' function is used improperly then it may crash R. Furthermore, multipart
#' polygons with touching edges will likely result in inaccuracies.
#' If argument set to [sp::SpatialPolygons()] or
#' [sp::SpatialPolygonsDataFrame()], this will be converted to
#' PolySet before processing.
#'
#' @param x [PBSmapping::PolySet()],
#'   [sp::SpatialPolygons()] or
#'   [sp::SpatialPolygonsDataFrame()] object.
#'
#' @param tol `numeric` to specify precision of calculations. In other
#'   words, how far apart vertices have to be to be considered different?
#'
#' @param length.factor `numeric` to scale boundary lengths.
#'
#' @param edge.factor `numeric` to scale boundary lengths for edges that
#'   do not have any neighbors, such as those that occur along the margins.
#'
#' @return `data.frame` with 'id1' (`integer`), 'id2'
#'   (`integer`), and 'amount' (`numeric`) columns.
#'
#' @seealso This function is based on the algorithm in QMARXAN
#'   <https://github.com/tsw-apropos/qmarxan> for calculating boundary
#'   length.
#'
#' @examples
#' # simulate planning units
#' sim_pus <- sim.pus(225L)
#'
#' # calculate boundary data
#' bound.dat <- calcBoundaryData(sim_pus)
#'
#' # print summary of boundary data
#' summary(bound.dat)
#'
#' @export
calcBoundaryData <- function(x, tol, length.factor, edge.factor)
  UseMethod("calcBoundaryData")

#' @rdname calcBoundaryData
#'
#' @method calcBoundaryData PolySet
#'
#' @export
calcBoundaryData.PolySet <- function(x, tol = 0.001, length.factor = 1.0,
                                     edge.factor = 1.0) {
  assertthat::assert_that(inherits(x, "PolySet"), assertthat::is.scalar(tol),
                          assertthat::is.scalar(length.factor),
                          assertthat::is.scalar(edge.factor))
  ret <- rcpp_calcBoundaryDF(x, tolerance = tol, lengthFactor = length.factor,
                             edgeFactor = edge.factor)
  if (length(ret$warnings) != 0) {
    warning(paste0("Invalid geometries detected, see \"warnings\" attribute ",
                   "for more information."))
    attr(ret$bldf, "warnings") <- ret$warnings
  }
  return(ret$bldf)
}

#' @rdname calcBoundaryData
#'
#' @method calcBoundaryData SpatialPolygons
#'
#' @export
calcBoundaryData.SpatialPolygons <- function(x, tol = 0.001,
                                             length.factor = 1.0,
                                             edge.factor = 1.0) {
  return(calcBoundaryData(rcpp_Polygons2PolySet(x@polygons), tol,
                          length.factor, edge.factor))
}
