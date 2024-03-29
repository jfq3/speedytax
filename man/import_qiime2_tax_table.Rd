% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/import_qiime2_tax_table.R
\name{import_qiime2_tax_table}
\alias{import_qiime2_tax_table}
\title{Import QIIME2 Classification Table}
\usage{
import_qiime2_tax_table(in_file)
}
\arguments{
\item{in_file}{A tab-delimited classification table output by QIIME2}
}
\value{
A phyloseq tax_table object
}
\description{
Import taxonomy results exported from the QIIME2 Bayesian classifiers
}
\details{
This function expects up to 7 ranks (Domain, Phylum, Class, Order, Family, Genus and Species) but determines the number actually in the file.
}
\examples{
taxonomy_file <- system.file("extdata", "qiime2_table.tsv", package = "speedytax")
example_tax_table <- import_qiime2_tax_table(in_file = taxonomy_file)
example_tax_table
}
\references{
Bolyen E, Rideout JR, Dillon MR, Bokulich NA, \emph{et al}. 2019. Reproducible, interactive, scalable and extensible microbiome data science using QIIME 2. Nat Biotechnol 37:852-857.
}
