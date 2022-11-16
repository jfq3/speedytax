#include <Rcpp.h>
#include <string>

using namespace Rcpp;

// [[Rcpp::export]]
StringMatrix copy_SM(StringMatrix x) {
  // Make empty string matrix named m of the same size as x
  int r;
  int c;
  r =x.nrow();
  c = x.ncol();
  StringMatrix m ( r, c );
  // Copy element by element
  for (int i = 0; i < r; i++) {
    for (int j = 0; j < c; c++) {
      m(i, j) = x(i, j);
    }
  }
  return m;
}

