#' Import QIIME2 Classification Table
#'
#' Import taxonomy results exported from the QIIME2 Bayesian classifiers
#'
#' @aliases import_qiime2_tax_table
#' @usage import_qiime2_tax_table(in_file)
#' @param in_file A tab-delimited classification table output by QIIME2
#' @return A phyloseq tax_table object
#' @details This function expects up to 7 ranks (Domain, Phylum, Class, Order, Family, Genus and Species) but determines the number actually in the file.
#' Depending on how the QIIME2 classifier is build, the ranks in the Taxon field of the classification result may be separated by a semicolon or by a semicolon plus a space. This function correctly parses the Taxon field in both cases.
#' @references Bolyen E, Rideout JR, Dillon MR, Bokulich NA, *et al*. 2019. Reproducible, interactive, scalable and extensible microbiome data science using QIIME 2. Nat Biotechnol 37:852-857.
#' @export
#' @importFrom dplyr select mutate pull
#' @importFrom tibble as_tibble
#' @importFrom tidyr separate
#' @importFrom stringr str_starts str_replace_all
#' @importFrom phyloseq tax_table
#' @importFrom utils read.table
#' @examples
#' ## Example with ranks in Taxon field separated by semicolon plus a space.
#' taxonomy_file <- system.file("extdata", "qiime2_table.tsv", package = "speedytax")
#' example_tax_table <- import_qiime2_tax_table(in_file = taxonomy_file)
#' example_tax_table
#' ## Example with ranks in Taxon field separated by semicolon only.
#' taxonomy_file <- system.file("extdata", "qiime2_table_a.tsv", package = "speedytax")
#' example_tax_table <- import_qiime2_tax_table(in_file = taxonomy_file)
#' example_tax_table

import_qiime2_tax_table <- function(in_file) {
  temp <- utils::read.table(file = in_file, header = TRUE,
                     stringsAsFactors = FALSE, sep = "\t")

  # intialize global variables
  Taxon <- Confidence <- NULL

  # Determine the number of ranks
  n_ranks <- temp |>
    dplyr::select(Taxon) |>
    dplyr::mutate(n_ranks = stringr::str_count(Taxon, ";")) |>
    dplyr::pull(n_ranks) |> max() + 1

  ranks <- c("d", "p", "c", "o", "f", "g", "s")

  suppressWarnings(sorted_data <-  temp |>
                     tibble::as_tibble() |>
                     dplyr::select(-Confidence) |>
                     dplyr::mutate(Taxon = str_replace_all(Taxon, "; ", ";"),
                                   Taxon = str_replace_all(Taxon, "__", "_")) |>
                     tidyr::separate(col = Taxon, sep = ";", into = ranks[1:n_ranks],
                                     fill = "right") |>
                     as.matrix())

  rownames(sorted_data) <- sorted_data[, 1]
  sorted_data <- sorted_data[, -1]
  sorted_data[is.na(sorted_data)] <-  ""

  # Take care of empty data in first (domain) column
  rslt <- fix_qiime2_domain_C(sorted_data = sorted_data)
  rm(sorted_data)

  # Take cate of remaining empty ranks
  sorted_data <- fix_qiime2_rest_C(sorted_data = rslt)
  rm(rslt)

  ranks <-  c("Domain", "Phylum", "Class", "Order", "Family", "Genus", "Species")
  colnames(sorted_data) <- ranks[1:n_ranks]

  # Convert to phyloseq tax_table
  tax_table <- phyloseq::tax_table(sorted_data)

  return(tax_table)

}



