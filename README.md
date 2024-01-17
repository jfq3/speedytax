
<!-- README.md is generated from README.Rmd. Please edit that file -->

# speedytax

<!-- badges: start -->

[![R-CMD-check](https://github.com/jfq3/speedytax/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jfq3/speedytax/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of speedytax is to quickly import classification files
generated with the QIIME2 classifier, the RDP Classifier and the USEARCH
or vsearch sintax classifier as phyloseq tax_table objects.

When importing RDP Classifier and sintax results, the confidence value
can be specified on import. In the case of the QIIME2 classifier the
confidence value must be given when calling the classifier.

All ranks are filled, If a taxa is unclassified at a given rank(*i.e.*
the confidence value at that rank is less than that specified), “the
letter for the higher rank”uncl\_” is prepended to the classification at
the higher rank and copied to all lower ranks.

For example, in the example below *Hyphomicrobiales* is classified to
order and the corresponding family and genus ranks are
unclass\_*Hyphomicrobiales*.

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
taxonomy_file <- read_tax_example("rdp_classifiification_table.tsv")
example_tax_table <- import_rdp_tax_table(in_file = taxonomy_file)
example_tax_table
#> Taxonomy Table:     [10 taxa by 6 taxonomic ranks]:
#>                                  Domain     Phylum           
#> 15dac1e6a414861c0db80d636ffb8a9a "Bacteria" "Acidobacteriota"
#> 58738b7c9e86d0e83a8c3f33c6778e93 "Bacteria" "Pseudomonadota" 
#> 714b0378efe0b8744e24aa04b48008d3 "Bacteria" "Bacillota"      
#> 72d78ad803e3cfc73fca6825e5fcddc1 "Bacteria" "Nitrospirota"   
#> 8cb24777cb48dde0aac60dfeca125d10 "Bacteria" "Bacillota"      
#> 8d2a29d23de2d1b6cada06bf85915274 "Bacteria" "Pseudomonadota" 
#> 9db2817f5c42be6a7bcbca662959982d "Bacteria" "Pseudomonadota" 
#> ad5db97e5236e5b1b1e5728586c8e087 "Bacteria" "Pseudomonadota" 
#> dc01606f995091a4a41ad216f02a265b "Bacteria" "Cyanobacteriota"
#> fb75fa1fac5ad54c9d64c653e50a7126 "Bacteria" "Pseudomonadota" 
#>                                  Class                 Order              
#> 15dac1e6a414861c0db80d636ffb8a9a "Acidobacteria_Gp16"  "Gp16"             
#> 58738b7c9e86d0e83a8c3f33c6778e93 "Alphaproteobacteria" "Sphingomonadales" 
#> 714b0378efe0b8744e24aa04b48008d3 "Bacilli"             "Caryophanales"    
#> 72d78ad803e3cfc73fca6825e5fcddc1 "Nitrospiria"         "Nitrospirales"    
#> 8cb24777cb48dde0aac60dfeca125d10 "Bacilli"             "Caryophanales"    
#> 8d2a29d23de2d1b6cada06bf85915274 "Alphaproteobacteria" "Sphingomonadales" 
#> 9db2817f5c42be6a7bcbca662959982d "Alphaproteobacteria" "Hyphomicrobiales" 
#> ad5db97e5236e5b1b1e5728586c8e087 "Alphaproteobacteria" "Hyphomicrobiales" 
#> dc01606f995091a4a41ad216f02a265b "Cyanophyceae"        "Coleofasciculales"
#> fb75fa1fac5ad54c9d64c653e50a7126 "Alphaproteobacteria" "Hyphomicrobiales" 
#>                                  Family                 
#> 15dac1e6a414861c0db80d636ffb8a9a "Gp16"                 
#> 58738b7c9e86d0e83a8c3f33c6778e93 "Sphingomonadaceae"    
#> 714b0378efe0b8744e24aa04b48008d3 "Bacillaceae"          
#> 72d78ad803e3cfc73fca6825e5fcddc1 "Nitrospiraceae"       
#> 8cb24777cb48dde0aac60dfeca125d10 "Bacillaceae"          
#> 8d2a29d23de2d1b6cada06bf85915274 "Sphingomonadaceae"    
#> 9db2817f5c42be6a7bcbca662959982d "Bradyrhizobiaceae"    
#> ad5db97e5236e5b1b1e5728586c8e087 "uncl_Hyphomicrobiales"
#> dc01606f995091a4a41ad216f02a265b "Wilmottiaceae"        
#> fb75fa1fac5ad54c9d64c653e50a7126 "Bradyrhizobiaceae"    
#>                                  Genus                  
#> 15dac1e6a414861c0db80d636ffb8a9a "Gp16"                 
#> 58738b7c9e86d0e83a8c3f33c6778e93 "Sphingomonas"         
#> 714b0378efe0b8744e24aa04b48008d3 "Priestia"             
#> 72d78ad803e3cfc73fca6825e5fcddc1 "Nitrospira"           
#> 8cb24777cb48dde0aac60dfeca125d10 "Bacillus"             
#> 8d2a29d23de2d1b6cada06bf85915274 "Sphingomonas"         
#> 9db2817f5c42be6a7bcbca662959982d "Bradyrhizobium"       
#> ad5db97e5236e5b1b1e5728586c8e087 "uncl_Hyphomicrobiales"
#> dc01606f995091a4a41ad216f02a265b "Pycnacronema"         
#> fb75fa1fac5ad54c9d64c653e50a7126 "Bradyrhizobium"
```
