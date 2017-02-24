st_just_data <- function(x) {
  xx <- as.data.frame(x)
  cols_sfc <- sapply(xx, function(i) inherits(i, "sfc"))
  xx[, !cols_sfc]
}

st_over <- function(x, y) {
  inds <- sapply(sf::st_intersects(x, y),
                 function(z) {
                   if (length(z) == 0) {
                     NA_integer_
                   } else {
                     z[1]
                   }
                 })
  y[inds, ]
}
