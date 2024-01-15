#' Get path to example taxonomy files
#'
#' speedytax comes bundled with example taxonomy files in its `inst/extdata`
#' directory. This function make them easy to access
#'
#' @param file Name of file. If `NULL`, the example files will be listed.
#' @export
#' @examples
#' read_tax_example()
#' read_tax_example("qiime2_class_table.tsv")
read_tax_example <- function(file = NULL) {
  if (is.null(file)) {
    dir(system.file("extdata", package = "speedytax"))
  } else {
    system.file("extdata", file, package = "speedytax", mustWork = TRUE)
  }
}
