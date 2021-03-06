% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/import_qiime2_taxonomy.R
\name{import_qiime2_taxonomy}
\alias{import_qiime2_taxonomy}
\title{Import QIIME Classification Table}
\usage{
import_qiime2_taxonomy(in_file)
}
\arguments{
\item{in_file}{A tab-delimited classification table output by QIIME2}
}
\value{
A phyloseq tax_table object
}
\description{
Import QIIME Classification Table
}
\details{
This function expects 8 ranks: Domain, Kingdom, Phylum, Class, Order, Family, Genus and Species.
}
\examples{
\dontrun{
import_rdp_tax_table(in_file = "qiime2_classifier_result.tsv", confidence = 0.8)
}
}
