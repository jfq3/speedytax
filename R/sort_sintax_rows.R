sort_sintax <- function(in_file, confidence) {

# Sort SINTAX file rows into columns
# library(tidyverse)

# temp <- read.table(file = "../sintax_tax_table.txt", sep = "\t", fill = TRUE, stringsAsFactors = FALSE)
temp <- read.table(file = in_file, sep = "\t", fill = TRUE, stringsAsFactors = FALSE)
# head(temp)


# # Extract otu names.
# otus <- temp[ , 1]
# # Extract taxonomy with confidences.
# taxa <- temp[ , 2]
# # Modify taxonomy field.
# # Delete closing parenthesis
# taxa <- gsub(')', '', taxa)
# # Substitute commma for opening parenthesis.
# taxa <- gsub('\\(', ',', taxa)
# # Substitute underscore for colon
# taxa <- gsub(':', '_', taxa)
# # Create data frame with ranks and confidences in separate columns.
# class.table <- matrix(data = NA, nrow = length(otus), ncol = 14)
# for (i in 1:nrow(class.table)) {
#   taxa.line <- strsplit(taxa[i], ',')
#   for (j in 1:14) {
#     class.table[i, j] <- taxa.line[[1]][j]
#   }
# }
# head(class.table)
#
#
# temp %>%
#   as_tibble() %>%
#   select(V4)

unsorted_data <- temp %>%
  #as_tibble() %>%
  select(V2) %>%
  separate(col=V2, sep = ",", into = c("domain", "phylum", "class", "order", "family", "genus"), fill = "right" )
rownames(unsorted_data) <- temp$V1

# head(unsorted_data)

sorted_data <- matrix(data="", ncol = ncol(unsorted_data), nrow = nrow(unsorted_data))
sorted_data <- as.data.frame(sorted_data)
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

# dim(sorted_data)
# head(sorted_data)

# str_replace("p_Proteobacteria(1.0000)", "([[:alpha:]\\_]+)(.+)", "\\1")

#
# g_Armatimonadetes_gp6(0.0700)
#
# str_replace("g_Armatimonadetes_gp6(1.0700)", "([[:alpha:][:digit:]\\_]+)(.+)", "\\1")

taxa_matrix <- sorted_data

for (i in 1:nrow(taxa_matrix)) {
  for (j in 1:ncol(taxa_matrix)) {
    # taxa_matrix[i, j] <- str_replace(taxa_matrix[i, j], "([[:alpha:][:digit:]\\_]+)(.+)", "\\1")
    taxa_matrix[i, j] <- str_replace(taxa_matrix[i, j],  "(.+)(\\()(.+)(\\))", "\\1")
  }
}

taxa_matrix <- as.matrix(taxa_matrix)
# head(taxa_matrix)
#
# temp[2,2]
#
# str_replace("p_Proteobacteria(1.0000)", "([[:alpha:][:digit:]\\_\\(]+)([[:digit:]\\.]+)(.+)", "\\2")
#
# str_replace("p_Proteobacteria(1.0000)", "([[:alpha:][:digit:]\\_\\(]+)([\\.]+)(.+)", "\\1")

# str_replace("g_Armatimonadetes_gp6(1.0700)", "(.+)(\\()(.+)(\\))", "\\3")


confidence_matrix <- sorted_data
for (i in 1:nrow(confidence_matrix)) {
  for (j in 1:ncol(confidence_matrix)) {
    confidence_matrix[i, j] <- str_replace(confidence_matrix[i, j],
                                           "(.+)(\\()(.+)(\\))", "\\3")
  }
}

confidence_matrix[confidence_matrix == ""] <- confidence/2
confidence_matrix <- hablar::convert(confidence_matrix, dbl(colnames(confidence_matrix)))

#confidence_matrix
#confidence_matrix <- as.matrix(confidence_matrix)
# head(confidence_matrix)
# temp[1,2]

# head(taxa_matrix)
# head(confidence_matrix)
# confidence <- 0.5

for (i in 1:nrow(taxa_matrix)) {
  if (confidence_matrix[i, 1] < confidence) {
    taxa_matrix[i, 1] <- "uncl_Domain"
  }
}

ranks_pre <- c("d_", "p_", "c_", "o_", "f_", "g_", "s_")
# ranks_pre
# ranks_pre[2]

for (i in 1:nrow(taxa_matrix)) {
  for (j in 2:ncol(taxa_matrix)) {
    if ((taxa_matrix[i, j] == "") | confidence_matrix[i, j] < confidence) {
      taxa_matrix[i, j] <- paste0(ranks_pre[j], taxa_matrix[i, j-1])
    }
  }
}

colnames(taxa_matrix) <- c("Domain", "Phylum", "Class", "Order", "Family", "Genus")

return(taxa_matrix)

}
