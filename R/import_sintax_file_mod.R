#' Import SINTAX Classifier Taxonomy Modified
#' @aliases import_sintax_file_mod
#' @param in_file A fix-rank tab-delimited text file output by SINTAX
#' @param confidence The confidence level for filtering the taxonomy
#' @usage import_sintax_file_mod(in_file, confidence)
#' @details A confidence value of 0.5 is recommended for shorter amplicons and a value of 0.8 for full-length 16S rRNA gene sequences.
#' @return A phyloseq tax_table object
#' @export
#'
#' @examples
#' \dontrun{
#' import_sintax_file_mod(in_file = "sintax_file.txt", confidence = 0.8)
#' }
#'

import_sintax_file_mod <- function (in_file = "sintax_file.txt", confidence = 0.8) {
  # Read in sintax file.
  temp <- read.table(file = in_file, sep = "\t", fill = TRUE, stringsAsFactors = FALSE)
  # Extract otu names.
  otus <- temp[ , 1]
  # Extract taxonomy with confidences.
  taxa <- temp[ , 2]
  # Modify taxonomy field.
  # Delete closing parenthesis
  taxa <- gsub(')', '', taxa)
  # Substitute commma for opening parenthesis.
  taxa <- gsub('\\(', ',', taxa)
  # Subsitute underscore for colon
  taxa <- gsub(':', '_', taxa)
  # Create data frame with ranks and confidences in separate columns.
  class.table <- matrix(data = NA, nrow = length(otus), ncol = 14)
  for (i in 1:nrow(class.table)) {
    taxa.line <- strsplit(taxa[i], ',')
    for (j in 1:14) {
      class.table[i, j] <- taxa.line[[1]][j]
    }
  }

  if (all(is.na(class.table[ , 13]))) {
    class.table <- class.table[ , -c(13,14)]
  }

  # At this point class.table is a matrix of characters
  # Separate into confidence and taxa matrices;
  # Convert the confidence matrix to numeric.

  #################################
  # Begin preparation of tax_matrix
  # Create a vector designating taxa columns.
  taxa.col.no <- seq(from=1, to=ncol(class.table)-1, by=2)
  # Extract the taxa columns to taxa_matrix
  taxa_matrix <- class.table[, taxa.col.no]
  taxa_matrix <- as.matrix(taxa_matrix)

  # End preparation of taxa_matrix

  ############################

  # Begin creation of confidence matrix.
  # Create a vector designating confidence columns.
  conf.col.no <- seq(from=2, to=ncol(class.table), by=2)
  # class.table[conf.col.no] <- lapply(class.table[conf.col.no], as.character)
  class.table[conf.col.no] <- lapply(class.table[conf.col.no], as.numeric)

  # Extract the confidence columns to confidence_matrix
  confidence_matrix <- class.table[, conf.col.no]
  # Convert to a matrix
  confidence_matrix <- as.matrix(confidence_matrix)

  #There may be NA's in some columns, so replace them first.
  # with confidence < specified confidence:

  for (i in 1:nrow(confidence_matrix)) {
    for (j in 1:ncol(confidence_matrix)) {
      if (is.na(confidence_matrix[i, j])) {
        confidence_matrix[i, j] <- confidence/2
      }
    }
  }

  # confidence_matrix[is.na(confidence_matrix)] <- confidence/2
  # End preparation of confidence matrix

  ##################################

  # Modify the taxa_matrix by confidence cutoff.
  # Replace taxa IDs where domain is unidentified.
  for (i in  1:nrow(taxa_matrix)) {
    if (confidence_matrix[i, 1] < confidence) {
      confidence_matrix[i, 1] <- 1
      taxa_matrix[i, 1] <- "uncl_Domain"
    }
  }

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

  # Add row names and column names.
  row.names(taxa_matrix) <- otus
  taxa <- c("Domain", "Phylum", "Class", "Order", "Family", "Genus", "Species")[1:ncol(taxa_matrix)]
  colnames(taxa_matrix) <- taxa

  # Convert to phyloseq tax_table
  taxa_table <- tax_table(taxa_matrix, errorIfNULL = TRUE)

  return(taxa_table)
}
