#include <Rcpp.h>
#include <string>

using namespace Rcpp;

// [[Rcpp::export]]
StringMatrix fix_rdp_rest_C(StringMatrix taxa_matrix, NumericMatrix confidence_matrix, double confidence) {
  for(int i = 0; i < taxa_matrix.nrow(); i++) {
    for (int j = 1; j < taxa_matrix.ncol(); j++) {
      std::string s = as<std::string>(taxa_matrix(i,j-1));
      if (s.substr(0,4)=="uncl") {
        taxa_matrix(i, j) = taxa_matrix(i, j-1);
        } else if (confidence_matrix(i, j) < confidence) {
        taxa_matrix(i, j) = "uncl_" + taxa_matrix(i, j-1);
      } else {
        taxa_matrix(i, j) = taxa_matrix(i, j);
      }
    }
  }
  return taxa_matrix;
}
