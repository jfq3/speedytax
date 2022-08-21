#include <Rcpp.h>

using namespace Rcpp;

// [[Rcpp::export]]
StringMatrix fix_domain_C(StringMatrix taxa_matrix, NumericMatrix confidence_matrix, double confidence) {
  for(int i = 0; i < taxa_matrix.nrow(); i++) {
    if (confidence_matrix(i, 0) < confidence) {
      taxa_matrix(i, 0) = "uncl_domain";
    }
  }
  return taxa_matrix;
}
