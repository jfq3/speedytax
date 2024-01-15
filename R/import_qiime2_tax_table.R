#' Import QIIME2 Classification Table
#' @aliases import_qiime2_tax_table
#' @usage import_qiime2_tax_table(in_file)
#' @param in_file A tab-delimited classification table output by QIIME2
#'
#' @return A phyloseq tax_table object
#' @details This function expects 7 ranks: Domain, Phylum, Class, Order, Family, Genus and Species.
#' @export
#' @importFrom dplyr select mutate pull
#' @importFrom tibble as_tibble
#' @importFrom tidyr separate
#' @importFrom stringr str_starts str_replace_all
#' @importFrom phyloseq tax_table
#' @importFrom utils read.table
#' @examples
#' \dontrun{
#' import_qiime2_taxonomy(in_file = "qiime2_class_table.tsv")
#' }

import_qiime2_tax_table <- function(in_file) {
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
  sorted_data[is.na(sorted_data)] <- ""

  # Take care of empty data in first (domain) column
  for (i in 1:nrow(sorted_data)) {
    if (sorted_data[i, 1] == "" | sorted_data[i, 1] == "Unassigned") {
      sorted_data[i, 1] = "uncl_Domain"
    }
  }

  # Fill in other cases of empty data
  for (i in 1:nrow(sorted_data)) {
    for (j in 2:ncol(sorted_data)) {
      if(sorted_data[i, j] != "") {
        sorted_data[1, j] <- sorted_data[i, j]
      } else {
        if (stringr::str_starts(sorted_data[i, j-1], "uncl")) {
          sorted_data[i, j] <- sorted_data[i, j-1]
        } else {
          sorted_data[i, j] <- paste0("uncl_", sorted_data[i, j-1])
        }
      }
    }
  }


  ranks <-  c("Domain", "Phylum", "Class", "Order", "Family", "Genus", "Species")
  colnames(sorted_data) <- ranks[1:n_ranks]

  # Convert to phyloseq tax_table
  tax_table <- phyloseq::tax_table(sorted_data)

  return(tax_table)

}



