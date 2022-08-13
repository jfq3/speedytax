#' Import QIIME2 RESCRIPt Classification Table
#' @aliases import_rescript_taxonomy
#' @usage import_rescript_taxonomy(in_file)
#' @param in_file A tab-delimited classification table output by QIIME2 when one of my RESCRIPt classsifiers is used.for the classification.
#'
#' @return A phyloseq tax_table object
#' @details This function is for use with QIIME2 taxonomy results when one of my classifiers built with RESCRIPt is used. These classifiers were built with the options p-rank-propagation and specifying the ranks Domain, Phylum, Class, Order, Family and Genus. However, a column for species is still expected (all entries are "s_"); it is removed by this function. I did not intend to include species because species assignments are usually nonsensical, especially with the SILVA database.
#' @export
#'
#' @examples
#' \dontrun{
#' import_rescript_taxonomy(in_file = "qiime2_classifier_result.tsv")
#' }

import_rescript_taxonomy <- function(in_file) {
  temp <- read.table(file = in_file, header = TRUE,
                     stringsAsFactors = FALSE, sep = "\t")
  # For testing:
  temp <- read.table(file = "../qiime2_classifier_result.tsv", header = TRUE,
                     stringsAsFactors = FALSE, sep = "\t")

  # For testing:
  temp <- read.table(file = "../full_length_taxonomy.tsv", header = TRUE,
                     stringsAsFactors = FALSE, sep = "\t")

  # For testing:
  temp <- read.table(file = "../v3v4_taxonomy.tsv", header = TRUE,
                     stringsAsFactors = FALSE, sep = "\t")

  taxa_matrix <-  temp  |>
    tibble::as_tibble() |>
    dplyr::select(-Confidence)  |>
    mutate(Taxon = str_replace_all(Taxon, "__", "_"))  |>
    tidyr::separate(col = Taxon, sep = "; ", into = c("Domain",
                                                      "Phylum",
                                                      "Class",
                                                      "Order",
                                                      "Family",
                                                      "Genus",
                                                      "Species"),
                    fill = "right") |>
    select(-Species) |>
    as.matrix()

  rownames(taxa_matrix) <- taxa_matrix[, 1]
  taxa_matrix <- taxa_matrix[, -1]
  taxa_matrix[is.na(taxa_matrix)] <- ""

  ranks <- c("d", "p", "c", "o", "f", "g")

  for (i in 1:nrow(taxa_matrix)) {
    for (j in 2:ncol(taxa_matrix)) {
      rank <- ranks[j]
      if (taxa_matrix[i, j] == "" | str_detect(taxa_matrix[i, j], "uncultured") | str_detect(taxa_matrix[i, j], "Subgroup")) {
        taxa_matrix[i, j] <- paste(rank, taxa_matrix[i, j-1], sep = "_")
      }
    }
  }

  head(taxa_matrix)



  # # Sort
  # sorted_data <- matrix(data="", ncol = ncol(taxa_matrix), nrow = nrow(taxa_matrix))
  # colnames(sorted_data) <- ranks
  # rownames(sorted_data) <- rownames(taxa_matrix)
  #
  # unsorted_data <- taxa_matrix
  # unsorted_data[is.na(unsorted_data)] <- ""
  # colnames(unsorted_data) <- ranks
  #
  # for (i in 1:nrow(unsorted_data)) {
  #   for (j in 1:ncol(unsorted_data)) {
  #     rank <- ranks[j]
  #     sorted_data[i, rank] <- unsorted_data[i, j]
  #   }
  # }


  tax_table <- phyloseq::tax_table(taxa_matrix)

  return(tax_table)

}



