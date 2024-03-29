#' Import RDP Classifier Taxonomy Table
#'
#' Imports fixed rank taxonomy files created with the RDP Classifier
#'
#' @aliases import_rdp_tax_table
#' @param in_file A fix-rank tab-delimited text file output by the RDP Classifier
#' @param confidence The confidence level for filtering the taxonomy
#' @usage import_rdp_tax_table(in_file, confidence)
#' @details The RDP Classifier must be given the option -f fixrank (or --format fixrank) in order for this importer to work correctly.
#' @details A confidence value of 0.8 for is recommended for full-length 16S rRNA gene sequences and a value of 0.5 is recommended for shorter amplicons.
#' @return A phyloseq tax_table object
#' @references Wang Q, Garrity GM, Tiedje JM, Cole JR. 2007. Naive Bayesian classifier for rapid assignment of rRNA sequences into the new bacterial taxonomy. Appl Environ Microbiol 73:5261-5267.
#' @export
#' @importFrom utils read.table
#' @examples
#' taxonomy_file <- system.file("extdata", "rdp_table.tsv", package = "speedytax")
#' example_tax_table <- import_rdp_tax_table(in_file = taxonomy_file)
#' example_tax_table

import_rdp_tax_table <- function(in_file, confidence=0.5) {
  #Begin with fixed rank output from command line version of classifier.
  class_table <- utils::read.table(in_file, sep="\t", fill=TRUE, stringsAsFactors=FALSE)
  class_table <- class_table[order(class_table[, 1]), ]

  rank.pos <- seq(from = 4, to = ncol(class_table), by = 3)

  ranks <- class_table[1 , rank.pos]
  ranks <- sapply(ranks, simple_cap)

  # Remove unnecessary columns
  class_table <- class_table[ , -c(2, rank.pos)]

  # Assign first column of class_table as row names.
  # Delete first column of class_table.
  # Sort class_table by row names. Necessary?
  row.names(class_table) <- class_table[ , 1]
  class_table <- class_table[ , -1]
  # class_table <- class_table[order(rownames(class_table)), ]

  # Fix class_table's by consolidating groups based on confidences.
  # For example, genera classified with less than specified confidence become uncl_family, etc.

  # Create a vector designating confidence columns
  col.no <- seq(from = 2, to = ncol(class_table), by = 2)

  # Subset to confidence columns; covert to a matrix
  confidence_matrix <- class_table[, col.no]
  confidence_matrix <- as.matrix(confidence_matrix)

  # Create a vector designating taxa
  tax_no <- seq(from = 1, to = ncol(class_table), by = 2)
  # Extract the taxa to a matrix
  taxa_matrix <- class_table[, tax_no]
  taxa_matrix <- as.matrix(taxa_matrix)

  # Take care of confidences less than cutoff in first column
  rslt <- fix_domain_C(taxa_matrix = taxa_matrix, confidence_matrix = confidence_matrix, confidence = confidence)
  rm(taxa_matrix)

  # Take care of confidences less than cutoff in other columns
  taxa_matrix <- fix_rdp_rest_C(taxa_matrix = rslt, confidence_matrix = confidence_matrix, confidence = confidence)
  colnames(taxa_matrix) <- ranks
  rm(rslt)

  class_table <- phyloseq::tax_table(taxa_matrix, errorIfNULL=TRUE)

  return(class_table)
}

