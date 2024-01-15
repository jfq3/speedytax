#' Import QIIME2 Classification Table cpp
#' @aliases import_qiime2_tax_table_cpp
#' @usage import_qiime2_tax_table_cpp(in_file)
#' @param in_file A tab-delimited classification table output by QIIME2
#'
#' @return A phyloseq tax_table object
#' @details This function expects up to 7 ranks (Domain, Phylum, Class, Order, Family, Genus and Species) but determines the number actually in the file.
#' @export
#' @importFrom dplyr select mutate pull
#' @importFrom tibble as_tibble
#' @importFrom tidyr separate
#' @importFrom stringr str_starts str_replace_all
#' @importFrom phyloseq tax_table
#' @importFrom utils read.table
#' @examples
#' taxonomy_file <- read_tax_example("qiime2_classification_table.tsv")
#' example_tax_table <- import_qiime2_tax_table_cpp(in_file = taxonomy_file)
#' example_tax_table
#' \dontrun{
#' import_qiime2_tax_table_cpp(in_file = "qiime2_classification_table.tsv")
#' }

import_qiime2_tax_table_cpp <- function(in_file) {
  temp <- utils::read.table(file = in_file, header = TRUE,
                     stringsAsFactors = FALSE, sep = "\t")
  # Determine the number of ranks
  n_ranks <- temp |>
    dplyr::select(Taxon) |>
    dplyr::mutate(n_ranks = stringr::str_count(Taxon, ";")) |>
    dplyr::pull(n_ranks) |> max()

  ranks <- c("d", "p", "c", "o", "f", "g", "s")

  suppressWarnings(sorted_data <-  temp |>
    tibble::as_tibble() |>
    dplyr::select(-Confidence) |>
    dplyr::mutate(Taxon = str_replace_all(Taxon, "__", "_")) |>
    tidyr::separate(col = Taxon, sep = "; ", into = ranks[1:n_ranks],
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



