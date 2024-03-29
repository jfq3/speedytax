% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/import_rdp_tax_table.R
\name{import_rdp_tax_table}
\alias{import_rdp_tax_table}
\title{Import RDP Classifier Taxonomy Table}
\usage{
import_rdp_tax_table(in_file, confidence)
}
\arguments{
\item{in_file}{A fix-rank tab-delimited text file output by the RDP Classifier}

\item{confidence}{The confidence level for filtering the taxonomy}
}
\value{
A phyloseq tax_table object
}
\description{
Imports fixed rank taxonomy files created with the RDP Classifier
}
\details{
The RDP Classifier must be given the option -f fixrank (or --format fixrank) in order for this importer to work correctly.

A confidence value of 0.8 for is recommended for full-length 16S rRNA gene sequences and a value of 0.5 is recommended for shorter amplicons.
}
\examples{
taxonomy_file <- system.file("extdata", "rdp_table.tsv", package = "speedytax")
example_tax_table <- import_rdp_tax_table(in_file = taxonomy_file)
example_tax_table
}
\references{
Wang Q, Garrity GM, Tiedje JM, Cole JR. 2007. Naive Bayesian classifier for rapid assignment of rRNA sequences into the new bacterial taxonomy. Appl Environ Microbiol 73:5261-5267.
}
