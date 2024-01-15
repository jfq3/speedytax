#' Import SINTAX Taxonomy Table
#' @aliases import_sintax_tax_table
#' @param in_file A fix-rank tab-delimited text file output by SINTAX
#' @param confidence The confidence level for filtering the taxonomy (0.8 by default)
#' @usage import_sintax_tax_table(in_file, confidence)
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
#' example_tax_table <- import_sintax_tax_table(in_file = taxonomy_file)
#' example_tax_table
#' \dontrun{
#' import_sintax_tax_table(in_file = "sintax_classification_table.txt", confidence = 0.8)
#' }
#'

import_sintax_tax_table <- function (in_file, confidence = 0.8) {
  # Read in sintax file.
  temp <- read.table(file = in_file, sep = "\t", fill = TRUE, stringsAsFactors = FALSE)

  # Initialize global variables
  V1 <- V2 <- NULL

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

  # Extract a taxa matrix from class_table
  # Create a vector designating taxa columns.
  taxa.col.no <- seq(from=2, to=ncol(class_table)-1, by=2)
  # Extract these columns to taxa_table
  taxa_matrix <- class_table[, taxa.col.no]

  # Take care of confidences less than cutoff in first column (domain)
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
  taxa_matrix <- as.matrix(taxa_matrix)
  rownames(taxa_matrix) <- otus

  class_table <- phyloseq::tax_table(as.matrix(taxa_matrix), errorIfNULL=TRUE)
  return(class_table)
}
