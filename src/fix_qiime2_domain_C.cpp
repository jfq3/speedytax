#include <Rcpp.h>
using namespace Rcpp;


// [[Rcpp::export]]
StringMatrix fix_qiime2_domain_C(StringMatrix sorted_data) {
  for(int i = 0; i < sorted_data.nrow(); i++) {
    if ((sorted_data(i, 0) == "") || (sorted_data(i, 0) == "Unassigned")) {
      sorted_data(i, 0) = "uncl_Domain";
    }
  }
  return sorted_data;
}

// # for (i in 1:nrow(sorted_data)) {
// #   if (sorted_data[i, 1] == "" | sorted_data[i, 1] == "Unassigned") {
// #     sorted_data[i, 1] = "uncl_Domain"
// #   }
// # }
