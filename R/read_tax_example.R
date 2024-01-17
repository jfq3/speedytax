#' Get path to example taxonomy files
#'
#' speedytax comes bundled with example taxonomy files in its `inst/extdata`
#' directory. This function make them easy to access
#'
#' @param file Name of file. If `NULL`, the example files will be listed.
#' @returns Returns the full paath to the requested file from the package sub-directory inst/extdata if it exists. If called without specifying a file, it returns a list of files in inst/extdata. This function has the added benefit of working during package development when the system.file method cannot be used.
#' @export
#' @examples
#' read_tax_example()
#' read_tax_example("rdp_classification_table.tsv")
read_tax_example <- function(file = NULL) {
  if (is.null(file)) {
    dir(system.file("extdata", package = "speedytax"))
  } else {
    system.file("extdata", file, package = "speedytax", mustWork = TRUE)
  }
}
