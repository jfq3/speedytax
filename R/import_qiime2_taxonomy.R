#' Import QIIME Classification Table
#' @aliases import_qiime2_taxonomy
#' @usage import_qiime2_taxonomy(in_file)
#' @param in_file A tab-delimited classification table output by QIIME2
#'
#' @return A phyloseq tax_table object
#' @details This function expects 8 ranks: Domain, Kingdom, Phylum, Class, Order, Family, Genus and Species.
#' @export
#'
#' @examples
#' \dontrun{
#' import_rdp_tax_table(in_file = "qiime2_classifier_result.tsv", confidence = 0.8)
#' }

import_qiime2_taxonomy <- function(in_file) {
  temp <- read.table(file = in_file, header = TRUE,
                     stringsAsFactors = FALSE, sep = "\t")
  
  taxa_matrix <- temp %>%
    dplyr::select(-Confidence) %>% 
    tidyr::separate(col = Taxon, sep = "; ", into = c("Domain",
                                                      "Kingdom",
                                                      "Phylum",
                                                      "Class",
                                                      "Order",
                                                      "Family",
                                                      "Genus",
                                                      "Species"),
                    fill = "right") %>% 
    as.matrix()
  
  
  # Take care of NA values
  for (i in 1:nrow(taxa_matrix)) {
    for (j in 3:ncol(tax_matrix)) {
      if(is.na(taxa_matrix[i, j])) {
        taxa_matrix[i, j] <- taxa_matrix[i, j-1]
      }
    }
  }
  
  rownames(taxa_matrix) <- taxa_matrix[, 1]
  taxa_matrix <- taxa_matrix[, -1]
  
  tax_table <- phyloseq::tax_table(taxa_matrix)
  
  return(tax_table)

}



