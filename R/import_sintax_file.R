#' Import SINTAX Classifier Taxonomy
#' @aliases import_sintax_file
#' @param in_file A fix-rank tab-delimited text file output by SINTAX
#' @param confidence The confidence level for filtering the taxonomy
#' @usage import_sintax_file(in_file, confidence)
#' @details A confidence value of 0.5 is recommended for shorter amplicons and a value of 0.8 for full-length 16S rRNA gene sequences.
#' @return A phyloseq tax_table object
#' @export
#'
#' @examples
#' \dontrun{
#' import_sintax_file(in_file = "sintax_tax_table.txt", confidence = 0.8)
#' }
#'

import_sintax_file <- function (in_file, confidence = 0.8) {
  # Read in sintax file.
  temp <- read.table(file = in_file, sep = "\t", fill = TRUE, stringsAsFactors = FALSE)
  # For testing purposes:
  # temp <- read.table(file = "../sintax_tax_table.txt", sep = "\t", fill = TRUE, stringsAsFactors = FALSE)
  # temp <- read.table(file = "loop_sample.txt", sep = "\t", fill = TRUE, stringsAsFactors = FALSE)

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

  # Create a vector designating confidence columns.
  conf.col.no <- seq(from=2, to=ncol(class.table), by=2)

  # Extract the confidence columns to a matrix of numbers
  confidence_matrix <- class.table[, conf.col.no]
  confidence_matrix <- apply(confidence_matrix, 2, as.numeric)
  #There may be NA's in some columns, so replace them first with confidence < specified confidence:
  confidence_matrix[is.na(confidence_matrix)] <- confidence/2

  # Create a vector designating taxa columns.
  taxa.col.no <- seq(from=1, to=ncol(class.table)-1, by=2)

  # Extract these columns to taxa_table
  taxa_matrix <- class.table[, taxa.col.no]


  # Take care of confidences less than cutoff in first column
  for (i in 1:nrow(taxa_matrix)) {
    if (confidence_matrix[i, 1] < confidence) {
      # taxa_matrix[i, 1] <- paste0("uncl_", taxa_matrix[i, 1])
      taxa_matrix[i, 1] <- "uncl_domain"
    }
  }

  # Take care of confidences less than cutoff in other columns
  for (i in 1:nrow(taxa_matrix)) {
    for (j in 2: ncol(taxa_matrix)) {
      if(substring(taxa_matrix[i, j-1], 1, 4) == "uncl") {
        taxa_matrix[i, j] <- taxa_matrix[i, j-1]
      } else {
        if(confidence_matrix[i, j] < confidence) {
          taxa_matrix[i, j] <-  paste0("uncl_", taxa_matrix[i, j-1])
        }
      }
    }
  }

  ranks <- c("Domain", "Phylum", "Class", "Order", "Family", "Genus", "Species")
  colnames(taxa_matrix) <- ranks[1:ncol(taxa_matrix)]
  rownames(taxa_matrix) <- otus

  class_table <- phyloseq::tax_table(as.matrix(taxa_matrix), errorIfNULL=TRUE)
  return(class_table)


  # # Replace IDs where domain is unidentified.
  # for (i in  1:nrow(class.table)) {
  #   if (class.table[i, 2] < confidence) {
  #     class.table[i, 2] <- 1
  #     class.table[i, 1] <- "uncl_Domain"
  #   }
  # }
  #
  # # Replace IDs where confidence is less than specified confidence:
  # col.no <- seq(from=4, to=ncol(class.table), by=2)
  # for (i in 1:nrow(class.table)) {
  #   for (j in col.no) {
  #     if (class.table[i, j] < confidence) {
  #       class.table[i, j] <- 1
  #       if(substr(class.table[i, (j-3)], 1, 5)=="uncl_") {class.table[i, (j-1)] <- class.table[i, (j-3)]}
  #       else {class.table[i, (j-1)] <- paste("uncl_", class.table[i, (j-3)], sep="")}
  #     }
  #   }
  # }
  #
  # # Remove confidence columns
  # class.table <- class.table[ , -c(seq(from = 2, to = ncol(class.table), by = 2))]
  # # Add row names and column names.
  # row.names(class.table) <- otus
  # taxa <- c("Domain", "Phylum", "Class", "Order", "Family", "Genus", "Species")[1:ncol(class.table)]
  # colnames(class.table) <- taxa
  # # Convert to phyloseq tax_table
  # class.table <- as.matrix(class.table)
  # class.table <- phyloseq::tax_table(class.table, errorIfNULL = TRUE)
  # return(class.table)
}
