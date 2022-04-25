#' Simple Capitalization
#' @aliases simple_cap
#' @usage simple_cap(x)
#' @param x A string or vector of strings
#'
#' @return The string with every word capitalized
#' @export
#'
#' @examples
#' simple_cap("an old dog learning new tricks")
#'
simple_cap <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1,1)), substring(s, 2),
        sep="", collapse=" ")
}
