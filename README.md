
<!-- README.md is generated from README.Rmd. Please edit that file -->

# speedytax

<!-- badges: start -->

[![R-CMD-check](https://github.com/jfq3/speedytax/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jfq3/speedytax/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of speedytax is to quickly import classification files
generated with the QIIME2 classifier, the RDP Classifier and the vsearch
sintax classifier as phyloseq tax_table objects.

When importing RDP Classifier and sintax results, the confidence value
can be specified on import. In the case of the QIIME2 classifier the
confidence value must be given when calling the classifier.

For each rank, a letter preface indicates the rank: “p\_” for phylum,
“c\_” for class, *etc*. All ranks are filled, If a taxa is unclassified
at a given rank(*i.e.* the confidence value at that rank is less than
that specified), the letter for the higher rank is prepended to the
classification at the higher rank.

For example, if a taxa is classified as f_Oxalobacteraceae with a
confidence of 0.7 but the confidence at the genus level is only 0.4,
then its classification at the genus level will be g_f_Oxalobacteraceae.
Tis is made clearer by examining the example below.

## Installation

You can install the development version of speedytax from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("jfq3/speedytax")
```

## Example

This is an example of importing a classification file created with the
RDP Classifier:

``` r
library(speedytax)
taxonomy_file <- read_tax_example("rdp_classification_table.tsv")
example_tax_table <- import_rdp_tax_table(in_file = taxonomy_file)
example_tax_table
#> Taxonomy Table:     [10 taxa by 7 taxonomic ranks]:
#>            Rootrank Domain       Phylum              Class                  
#> ASV_000001 "Root"   "d_Bacteria" "p__Proteobacteria" "c_Gammaproteobacteria"
#> ASV_000002 "Root"   "d_Bacteria" "p__Proteobacteria" "c_Betaproteobacteria" 
#> ASV_000003 "Root"   "d_Bacteria" "p__GAL15"          "c_p__GAL15"           
#> ASV_000004 "Root"   "d_Bacteria" "p__GAL15"          "c_p__GAL15"           
#> ASV_000005 "Root"   "d_Bacteria" "p__Actinobacteria" "c_MB-A2-108"          
#> ASV_000006 "Root"   "d_Bacteria" "p__Proteobacteria" "c_Betaproteobacteria" 
#> ASV_000007 "Root"   "d_Bacteria" "p__Actinobacteria" "c_Actinobacteria"     
#> ASV_000008 "Root"   "d_Bacteria" "p__Proteobacteria" "c_Betaproteobacteria" 
#> ASV_000009 "Root"   "d_Bacteria" "p__Chloroflexi"    "c_Gitt-GS-136"        
#> ASV_000010 "Root"   "d_Bacteria" "p__Proteobacteria" "c_Betaproteobacteria" 
#>            Order               Family               Genus                 
#> ASV_000001 "o_Pseudomonadales" "f_Pseudomonadaceae" "g_Pseudomonas"       
#> ASV_000002 "o_Burkholderiales" "f_Oxalobacteraceae" "g_f_Oxalobacteraceae"
#> ASV_000003 "o_c_p__GAL15"      "f_o_c_p__GAL15"     "g_f_o_c_p__GAL15"    
#> ASV_000004 "o_c_p__GAL15"      "f_o_c_p__GAL15"     "g_f_o_c_p__GAL15"    
#> ASV_000005 "o_0319-7L14"       "f_o_0319-7L14"      "g_f_o_0319-7L14"     
#> ASV_000006 "o_Burkholderiales" "f_Oxalobacteraceae" "g_f_Oxalobacteraceae"
#> ASV_000007 "o_Actinomycetales" "f_Micrococcaceae"   "g_f_Micrococcaceae"  
#> ASV_000008 "o_Burkholderiales" "f_Comamonadaceae"   "g_Polaromonas"       
#> ASV_000009 "o_c_Gitt-GS-136"   "f_o_c_Gitt-GS-136"  "g_f_o_c_Gitt-GS-136" 
#> ASV_000010 "o_Burkholderiales" "f_Comamonadaceae"   "g_Ramlibacter"
```
