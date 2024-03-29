# Generated by using Rcpp::compileAttributes() -> do not edit by hand
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

copy_SM <- function(x) {
    .Call(`_speedytax_copy_SM`, x)
}

fix_domain_C <- function(taxa_matrix, confidence_matrix, confidence) {
    .Call(`_speedytax_fix_domain_C`, taxa_matrix, confidence_matrix, confidence)
}

fix_qiime2_domain_C <- function(sorted_data) {
    .Call(`_speedytax_fix_qiime2_domain_C`, sorted_data)
}

fix_qiime2_rest_C <- function(sorted_data) {
    .Call(`_speedytax_fix_qiime2_rest_C`, sorted_data)
}

fix_rdp_rest_C <- function(taxa_matrix, confidence_matrix, confidence) {
    .Call(`_speedytax_fix_rdp_rest_C`, taxa_matrix, confidence_matrix, confidence)
}

