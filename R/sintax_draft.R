sintax_draft <- function(in_file, confidence) {

temp <- read.table(file = in_file, sep = "\t", fill = TRUE, stringsAsFactors = FALSE)
temp <- read.table(file = "../sintax_tax_table.txt", sep = "\t", fill = TRUE, stringsAsFactors = FALSE)
confidence <- 0.5

n <- RDPutils:::count_char_occurrences(",", temp[1,2]) + 1
ranks <- c("Domain",
           "Phylum",
           "Class",
           "Order",
           "Family",
           "Genus",
           "Species")[1:n]

ranks

xyz <- temp %>%
  dplyr::select(V1, V2) %>%
  dplyr::mutate(V2 = stringr::str_replace_all(V2, ":", "_")) %>%
  tidyr::separate(col=V2, sep=",", into = ranks,
                  fill = "right") %>%
  tibble::as_tibble()

# xyz %>% filter(V1 == "Otu14")

taxa_matrix <- xyz %>%
  as_tibble() %>%
  pivot_longer(-V1, names_to = "Rank") %>%
  mutate(value = str_replace(value, "([[:alpha:]_\\d]+).+", "\\1")) %>%
  pivot_wider(id_cols = "V1", names_from = "Rank", values_from = "value") %>%
  as.matrix()

# head(taxa_matrix)
# taxa_matrix %>% as_tibble() %>%
#   filter(V1 == "Otu14")

rownames(taxa_matrix) <- taxa_matrix[, 1]
taxa_matrix <- taxa_matrix[, -1]
head(taxa_matrix)
taxa_matrix[14, ]

confidence_matrix <- xyz %>%
  pivot_longer(-V1, names_to = "Rank") %>%
  mutate(value = str_replace(value, "([[:alpha:]_\\d]+)(.+)", "\\2"),
         value = str_remove(value, "\\("),
         value = str_remove(value, "\\)")) %>%
  as_tibble()

head(confidence_matrix)
confidence_matrix %>%
  mutate(value = as.numeric(value)) %>%
  filter(value > 1)

confidence_matrix <- xyz %>%
  pivot_longer(-V1, names_to = "Rank") %>%
  mutate(value = str_replace(value, "([[:alpha:]_\\d]+)(.+)", "\\2"),
         value = str_remove(value, "\\("),
         value = str_remove(value, "\\)")) %>%
  pivot_wider(id_cols = "V1", names_from = "Rank", values_from = "value") %>%
  as.matrix()

# confidence_matrix [14, ]
#
# otus <- confidence_matrix[, 1]

confidence_matrix <- confidence_matrix[, -1]
confidence_matrix <- apply(confidence_matrix[, 1:ncol(confidence_matrix)], 2, as.numeric)
rownames(confidence_matrix) <- otus
# head(confidence_matrix)
# confidence_matrix[14, ]

#There may be NA's in some columns, so replace them first.
# with confidence < specified confidence:
for (i in 1:nrow(confidence_matrix)) {
  for (j in 1:ncol(confidence_matrix)) {
    if (is.na(confidence_matrix[i, j])) {
      confidence_matrix[i, j] <- confidence/2
    }
  }
}

# Take care of confidences less than cutoff in first column
for (i in 1:nrow(taxa_matrix)) {
  if (confidence_matrix[i, 1] < confidence) {
    # taxa_matrix[i, 1] <- paste0("uncl_", taxa_matrix[i, 1])
    taxa_matrix[i, 1] <- "uncl_domain"
  }
}

# head(taxa_matrix)
#


# taxa_matrix %>%
#   as_tibble() %>%
#   pull(Domain) %>%
#   unique()

# Take care of confidences less than cutoff in other columns
for (i in 1:nrow(taxa_matrix)) {
  for (j in 2:ncol(taxa_matrix)) {
    if(substring(taxa_matrix[i, j-1], 1, 4) == "uncl") {
      taxa_matrix[i, j] <- taxa_matrix[i, j-1]
    } else {
      if(confidence_matrix[i, j] < confidence) {
        taxa_matrix[i, j] <-  paste0("uncl_", taxa_matrix[i, j-1])
      }
    }
  }
}

# Take care of confidences less than cutoff in other columns
for (i in 1:nrow(taxa_matrix)) {
  for (j in 2:ncol(taxa_matrix)) {
    if(confidence_matrix[i, j] < confidence) {
      taxa_matrix[i, j] <-  paste0("uncl_", taxa_matrix[i, j-1])
    } else {
      if(substring(taxa_matrix[i, j-1], 1, 4) == "uncl") {
        taxa_matrix[i, j] <- taxa_matrix[i, j-1]
      }
    }
  }
}


taxa_matrix[14, ]

class.table <- tax_table(taxa_matrix, errorIfNULL = TRUE)
return(class.table)

}
