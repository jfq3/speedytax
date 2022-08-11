#' Import SINTAX Classifier Taxonomy Sorted
#' @aliases import_sintax_file_sorted
#' @param in_file A fix-rank tab-delimited text file output by SINTAX
#' @param confidence The confidence level for filtering the taxonomy
#' @usage import_sintax_file_sorted(in_file, confidence)
#' @details A confidence value of 0.5 is recommended for shorter amplicons and a value of 0.8 for full-length 16S rRNA gene sequences.
#' @return A phyloseq tax_table object
#' @export
#'
#' @examples
#' \dontrun{
#' import_sintax_file_sorted(in_file = "sintax_file.txt", confidence = 0.8)
#' }
#'

import_sintax_file_sorted <- function(in_file, confidence) {

# For testing purposes:
library(tidyverse)
temp <- as.matrix(read.table(file = "../sintax_tax_table.txt", sep = "\t",
                             fill = TRUE, stringsAsFactors = FALSE))
confidence <- 0.5

# temp <- as.matrix(read.table(file = in_file, sep = "\t", fill = TRUE, stringsAsFactors = FALSE))

# Create unsorted data, IDs with confidence in parenthesis, ragged.
unsorted_data <- temp %>%
  as_tibble() %>%
  dplyr::select(V1, V2) %>%
  tidyr::separate(col=V2, sep = ",", into = c("domain", "phylum", "class", "order", "family", "genus"),
                  fill = "right" )
unsorted_data <- as.matrix(unsorted_data)
rownames(unsorted_data) <- unsorted_data[, 1]
unsorted_data <- unsorted_data[, -1]
# rownames(unsorted_data) <- temp$V1
# head(unsorted_data)
# Create sorted_data, made non-ragged by sorting into ranks.
# Some empty intermediate ranks, confidences still in parentheses.
sorted_data <- matrix(data="", ncol = ncol(unsorted_data), nrow = nrow(unsorted_data))
# sorted_data <- as.data.frame(sorted_data)
colnames(sorted_data) <- c("d", "p", "c", "o", "f", "g")
rownames(sorted_data) <- rownames(unsorted_data)

for (i in 1:nrow(unsorted_data)) {
  for (j in 1:ncol(unsorted_data)) {
    if (is.na(unsorted_data[i, j])) {
      next
    } else {
      rank <- substr(unsorted_data[i, j], 1, 1)
      # sorted_data[i, rank] <- unsorted_data[i, j]
      sorted_data[i, rank] <- gsub(":", "_", unsorted_data[i, j])
    }
  }
}

# Convert to a sorted taxa_matrix, non-ragged, some empty ranks, no confidences in parenthesis.
taxa_matrix <- sorted_data

for (i in 1:nrow(taxa_matrix)) {
  for (j in 1:ncol(taxa_matrix)) {
    # taxa_matrix[i, j] <- str_replace(taxa_matrix[i, j], "([[:alpha:][:digit:]\\_]+)(.+)", "\\1")
    taxa_matrix[i, j] <- str_replace(taxa_matrix[i, j],  "(.+)(\\()(.+)(\\))", "\\1")
  }
}

# taxa_matrix <- as.matrix(taxa_matrix)

# Make corresponding numeric confidence matrix.
confidence_matrix <- sorted_data
for (i in 1:nrow(confidence_matrix)) {
  for (j in 1:ncol(confidence_matrix)) {
    confidence_matrix[i, j] <- str_replace(confidence_matrix[i, j],
                                           "(.+)(\\()(.+)(\\))", "\\3")
  }
}

confidence_matrix[confidence_matrix == ""] <- confidence/2

# Fix the first rank as in "old way > Uncl_Domain"
for (i in 1:nrow(taxa_matrix)) {
  if (confidence_matrix[i, 1] < confidence) {
    taxa_matrix[i, 1] <- "uncl_Domain"
  }
}

ranks_pre <- c("d_", "p_", "c_", "o_", "f_", "g_", "s_")
# ranks_pre
# ranks_pre[2]

# Copied from import sintax file mod:
# Replace IDs where confidence is less than specified confidence:
for (i in 1:nrow(taxa_matrix)) {
  for (j in 2:ncol(taxa_matrix)) {
    if (confidence_matrix[i, j] >= confidence) {
      taxa_matrix[i, j] <- taxa_matrix[i, j] # Simply copy
    } else { # confidence is too low
      if(substring(taxa_matrix[i, j-1], 1, 4) == "uncl") {
        taxa_matrix[i, j] <- taxa_matrix[i, j-1] # copy lower rank
      } else { # confidences is too low, but not for previous rank
        taxa_matrix[i, j] <- paste0("uncl_", taxa_matrix[i, j-1]) # add uncl_ prefix
      }
    }
  }
}

colnames(taxa_matrix) <- c("Domain", "Phylum", "Class", "Order", "Family", "Genus")

return(taxa_matrix)

}
