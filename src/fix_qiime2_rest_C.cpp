#include <Rcpp.h>
#include <string>

using namespace Rcpp;

// [[Rcpp::export]]
StringMatrix fix_qiime2_rest_C(StringMatrix sorted_data) {
  for(int i = 0; i < sorted_data.nrow(); i++) {
    for (int j = 1; j < sorted_data.ncol(); j++) {
      std::string s = as<std::string>(sorted_data(i,j-1));
      std::string n = as<std::string>(sorted_data(i,j));
      if (n != "") {
        sorted_data(1, j) = sorted_data(i, j);
      } else if (s.substr(0,4)=="uncl") {
        sorted_data(i, j) = sorted_data(i, j-1);
      } else {
        sorted_data(i, j) = "uncl_" + sorted_data(i, j - 1);
      }
    }
  }
  return sorted_data;
}

// # Fill in other cases of empty data
// # for (i in 1:nrow(sorted_data)) {
// #   for (j in 2:ncol(sorted_data)) {
// #     if(!is.na(sorted_data[i, j])) {
// #       sorted_data[1, j] <- sorted_data[i, j]
// #     } else {
// #       if (stringr::str_starts(sorted_data[i, j-1], "uncl")) {
// #         sorted_data[i, j] <- sorted_data[i, j-1]
// #       } else {
// #         sorted_data[i, j] <- paste0("uncl_", sorted_data[i, j-1])
// #       }
// #     }
// #   }
// # }
