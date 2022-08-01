#' Import QIIME Classification Table
#' @aliases import_qiime2_taxonomy
#' @usage import_qiime2_taxonomy(in_file)
#' @param in_file A tab-delimited classification table output by QIIME2
#'
#' @return A phyloseq tax_table object
#' @details This function expects 7 ranks: Domain, Phylum, Class, Order, Family, Genus and Species.
#' @export
#'
#' @examples
#' \dontrun{
#' import_qiime2_taxonomy(in_file = "qiime2_classifier_result.tsv")
#' }

import_qiime2_taxonomy <- function(in_file) {
  temp <- utils::read.table(file = in_file, header = TRUE,
                     stringsAsFactors = FALSE, sep = "\t")

  unsorted_data <-  temp %>%
    tibble::as_tibble() %>%
    dplyr::select(-Confidence) %>%
    dplyr::mutate(Taxon = str_replace_all(Taxon, "__", "_")) %>%
    tidyr::separate(col = Taxon, sep = "; ", into = c("Domain",
                                                      "Phylum",
                                                      "Class",
                                                      "Order",
                                                      "Family",
                                                      "Genus",
                                                      "Species"),
                    fill = "right") %>%
    as.matrix()

  rownames(unsorted_data) <- unsorted_data[, 1]
  unsorted_data <- unsorted_data[, -1]

  ranks <- c("d", "p", "c", "o", "f", "g", "s")

  # Sort
  sorted_data <- matrix(data="", ncol = ncol(unsorted_data), nrow = nrow(unsorted_data))
  colnames(sorted_data) <- ranks
  rownames(sorted_data) <- rownames(unsorted_data)
  for (i in 1:nrow(unsorted_data)) {
    for (j in 1:ncol(unsorted_data)) {
      rank <- ranks[j]
      sorted_data[i, rank] <- unsorted_data[i, j]
    }
  }

  # Take care of empty data in first (domain) column
  for (i in 1:nrow(sorted_data)) {
    if (sorted_data[i, 1] == "") {
      sorted_data[i, 1] = "uncl_domain"
    }
  }

  # Fill in other cases of empty data
  for (i in 1:nrow(sorted_data)) {
    for (j in 2:ncol(sorted_data)) {
      if (is.na(sorted_data[i, j])) {
        if (stringr::str_starts(sorted_data[i, j-1], "uncl")) {
          sorted_data[i, j] == sorted_data[i, j-1]
        } else {
        # sorted_data[i, j] = paste(ranks[j], sorted_data[i, j-1], sep = "_")
        sorted_data[i, j] = sorted_data[i, j-1]
        }
      }
    }
  }

  # Convert to phyloseq tax_table
  tax_table <- phyloseq::tax_table(sorted_data)

  return(tax_table)

}



