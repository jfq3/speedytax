#' Import SINTAX Taxonomy Table cpp
#' @aliases import_sintax_tax_table_cpp
#' @param in_file A fix-rank tab-delimited text file output by SINTAX
#' @param confidence The confidence level for filtering the taxonomy (0.8 by default)
#' @usage import_sintax_tax_table_cpp(in_file, confidence)
#' @details A confidence value of 0.5 is recommended for shorter amplicons and a value of 0.8 for full-length 16S rRNA gene sequences.
#' @return A phyloseq tax_table object
#' @export
#' @importFrom dplyr select mutate pull rename
#' @importFrom tibble as_tibble
#' @importFrom tidyr separate
#' @importFrom phyloseq tax_table
#' @importFrom utils read.table
#' @examples
#' taxonomy_file <- read_tax_example("sintax_classification_table.tsv")
#' example_tax_table <- import_sintax_tax_table_cpp(in_file = taxonomy_file)
#' example_tax_table
#' \dontrun{
#' import_sintax_tax_table_cpp(in_file = "sintax_classification_table.tsv", confidence = 0.8)
#' }
#'

import_sintax_tax_table_cpp <- function (in_file, confidence = 0.8) {
  # Read in sintax file.
  temp <- read.table(file = in_file, sep = "\t", fill = TRUE, stringsAsFactors = FALSE)

  # Determine the number of ranks
  n_ranks <- temp |>
    dplyr::select(V2) |>
    dplyr::mutate(n_ranks = stringr::str_count(V2, ":")) |>
    dplyr::pull(n_ranks) |> max()

  # Convert input file to class_table including both taxonomy and confidences
  suppressWarnings(class_table <- temp |>
                     tibble::as_tibble() |>
                     dplyr::select(V1, V2) |>
                     dplyr::rename(OTU = V1, taxa = V2) |>
                     dplyr::mutate(taxa = gsub(')', '', taxa),
                                   taxa = gsub(':', '_', taxa),
                                   taxa = gsub('\\(', ',', taxa)) |>
                     tidyr::separate(col = taxa, sep = ",", into = letters[1:(2*n_ranks)]))

  # Extract otu names.
  otus <- temp[ , 1]

  # Extract a confidence matrix from class_table
  # Create a vector designating confidence columns.
  conf.col.no <- seq(from=3, to=ncol(class_table), by=2)
  # Extract the confidence columns to a matrix of numbers
  confidence_matrix <- class_table[, conf.col.no]
  confidence_matrix <- apply(confidence_matrix, 2, as.numeric)
  #There may be NA's in some columns, so replace them with confidence < specified confidence:
  confidence_matrix[is.na(confidence_matrix)] <- confidence/2
  confidence_matrix <- as.matrix(confidence_matrix)

  # Extract a taxa matrix from class_table
  # Create a vector designating taxa columns.
  taxa.col.no <- seq(from=2, to=ncol(class_table)-1, by=2)
  # Extract these columns to taxa_table
  taxa_matrix <- class_table[, taxa.col.no]
  taxa_matrix <- as.matrix(taxa_matrix)

  # Take care of confidences less than cutoff in first column
  rslt <- fix_domain_C(taxa_matrix = taxa_matrix, confidence_matrix = confidence_matrix, confidence = confidence)
  rm(taxa_matrix)

  # Take care of confidences less than cutoff in other columns
  taxa_matrix <- fix_rdp_rest_C(taxa_matrix = rslt, confidence_matrix = confidence_matrix, confidence = confidence)
  rm(rslt)

  ranks <- c("Domain", "Phylum", "Class", "Order", "Family", "Genus", "Species")
  colnames(taxa_matrix) <- ranks[1:ncol(taxa_matrix)]
  taxa_matrix <- as.matrix(taxa_matrix)
  rownames(taxa_matrix) <- otus

  class_table <- phyloseq::tax_table(as.matrix(taxa_matrix), errorIfNULL=TRUE)
  return(class_table)
}
