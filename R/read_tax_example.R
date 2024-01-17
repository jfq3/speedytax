#' Get path to example taxonomy files
#'
#' Access the files in speedyseq's inst/extdata sub-directory
#'
#' @param file Name of file to return.
#' @returns Returns the full path to the requested file from the package sub-directory inst/extdata if it exists, or a list of the files in the directory if no file is specified.
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
